import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/analytics_repository.dart';
import '../data/models.dart';
import '../state/app_state.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() =>
      _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  final AnalyticsRepository _analyticsRepository = AnalyticsRepository();
  AnalyticsData? _analyticsData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
  }

  Future<void> _loadAnalytics() async {
    final appState = context.read<AppState>();
    final userId = appState.currentUser?.id;

    if (userId == null) {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final data = await _analyticsRepository.fetchUserAnalytics(userId);
      if (mounted) {
        setState(() {
          _analyticsData = data;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('İstatistikler yüklenemedi: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final appState = context.watch<AppState>();
    final myListings = appState.myListings();

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('İstatistikler')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    if (appState.currentUser == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('İstatistikler')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.analytics_outlined,
                size: 72,
                color: theme.colorScheme.primary.withValues(alpha: .4),
              ),
              const SizedBox(height: 24),
              Text(
                'Giriş yapmanız gerekiyor',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 12),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 48),
                child: Text(
                  'İstatistiklerinizi görmek için lütfen giriş yapın',
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyMedium,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final data =
        _analyticsData ??
        const AnalyticsData(
          totalViews: 0,
          totalContacts: 0,
          totalFavorites: 0,
          activeListings: 0,
          premiumListings: 0,
          viewsByListing: {},
          contactsByListing: {},
          favoritesByListing: {},
          viewsOverTime: {},
        );

    return Scaffold(
      appBar: AppBar(
        title: const Text('İstatistikler'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: () {
              setState(() => _isLoading = true);
              _loadAnalytics();
            },
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          setState(() => _isLoading = true);
          await _loadAnalytics();
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Genel Bakış', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildOverviewCards(theme, data),
            const SizedBox(height: 32),
            Text('İlan Performansı', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            if (myListings.isEmpty)
              _buildEmptyState(theme, 'Henüz ilanınız yok')
            else
              _buildListingPerformance(theme, data, myListings),
            const SizedBox(height: 32),
            Text('Son 7 Gün Görüntülenme', style: theme.textTheme.titleLarge),
            const SizedBox(height: 16),
            _buildViewsChart(theme, data),
          ],
        ),
      ),
    );
  }

  Widget _buildOverviewCards(ThemeData theme, AnalyticsData data) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 16,
      crossAxisSpacing: 16,
      childAspectRatio: 1.3,
      children: [
        _buildStatCard(
          theme,
          'Toplam Görüntülenme',
          data.totalViews.toString(),
          Icons.visibility_rounded,
          const Color(0xFF2196F3),
        ),
        _buildStatCard(
          theme,
          'Toplam İletişim',
          data.totalContacts.toString(),
          Icons.phone_in_talk_rounded,
          const Color(0xFF4CAF50),
        ),
        _buildStatCard(
          theme,
          'Toplam Favori',
          data.totalFavorites.toString(),
          Icons.favorite_rounded,
          const Color(0xFFE91E63),
        ),
        _buildStatCard(
          theme,
          'Aktif İlan',
          data.activeListings.toString(),
          Icons.inventory_2_rounded,
          const Color(0xFFFF9800),
        ),
      ],
    );
  }

  Widget _buildStatCard(
    ThemeData theme,
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: .12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 24),
            ),
            const Spacer(),
            Text(
              value,
              style: theme.textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: theme.textTheme.bodySmall!.copyWith(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListingPerformance(
    ThemeData theme,
    AnalyticsData data,
    List<Listing> listings,
  ) {
    final sortedListings = List<Listing>.from(listings)
      ..sort((a, b) {
        final aViews = data.viewsByListing[a.id] ?? 0;
        final bViews = data.viewsByListing[b.id] ?? 0;
        return bViews.compareTo(aViews);
      });

    return Column(
      children: sortedListings.take(5).map((listing) {
        final views = data.viewsByListing[listing.id] ?? 0;
        final contacts = data.contactsByListing[listing.id] ?? 0;
        final favorites = data.favoritesByListing[listing.id] ?? 0;

        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    if (listing.images.isNotEmpty)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          listing.images.first,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      )
                    else
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary.withValues(
                            alpha: .1,
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.image_outlined,
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            listing.title,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            listing.location,
                            style: theme.textTheme.bodySmall!.copyWith(
                              color: Colors.black54,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildMetricChip(
                      theme,
                      Icons.visibility_rounded,
                      views.toString(),
                      'Görüntülenme',
                    ),
                    _buildMetricChip(
                      theme,
                      Icons.phone_rounded,
                      contacts.toString(),
                      'İletişim',
                    ),
                    _buildMetricChip(
                      theme,
                      Icons.favorite_rounded,
                      favorites.toString(),
                      'Favori',
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildMetricChip(
    ThemeData theme,
    IconData icon,
    String value,
    String label,
  ) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: theme.colorScheme.primary),
            const SizedBox(width: 4),
            Text(
              value,
              style: theme.textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall!.copyWith(color: Colors.black54),
        ),
      ],
    );
  }

  Widget _buildViewsChart(ThemeData theme, AnalyticsData data) {
    if (data.viewsOverTime.isEmpty) {
      return _buildEmptyState(theme, 'Henüz görüntülenme kaydı yok');
    }

    final sortedEntries = data.viewsOverTime.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    final last7Days = sortedEntries.length > 7
        ? sortedEntries.sublist(sortedEntries.length - 7)
        : sortedEntries;

    final maxValue = last7Days.isEmpty
        ? 1
        : last7Days.map((e) => e.value).reduce((a, b) => a > b ? a : b);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 200,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: last7Days.map((entry) {
                  final date = DateTime.tryParse(entry.key);
                  final label = date != null
                      ? '${date.day}/${date.month}'
                      : entry.key;
                  final height = maxValue > 0
                      ? (entry.value / maxValue) * 160
                      : 0.0;

                  return Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        entry.value.toString(),
                        style: theme.textTheme.bodySmall!.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 32,
                        height: height.clamp(4.0, 160.0),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.primary,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(label, style: theme.textTheme.bodySmall),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(ThemeData theme, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(Icons.bar_chart_rounded, size: 48, color: Colors.black26),
            const SizedBox(height: 16),
            Text(
              message,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium!.copyWith(
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
