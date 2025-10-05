import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';

class PromoteListingScreen extends StatefulWidget {
  const PromoteListingScreen({super.key});

  @override
  State<PromoteListingScreen> createState() => _PromoteListingScreenState();
}

class _PromoteListingScreenState extends State<PromoteListingScreen> {
  bool _isProcessing = false;

  List<_PromotionPackage> get _packages => [
    _PromotionPackage(
      id: 'vitrin_3',
      name: 'Vitrin 3 Gün',
      price: '₺249',
      durationDays: 3,
      highlights: const [
        'Vitrin sayfasında öne çıkan konum',
        'Yoğun WhatsApp bildirimi',
        'Tek seferlik performans özeti',
      ],
      color: const Color(0xFF0D47A1),
    ),
    _PromotionPackage(
      id: 'vitrin_7',
      name: 'Vitrin 7 Gün',
      price: '₺449',
      durationDays: 7,
      highlights: const [
        'Premium rozet ve üst sıralar',
        '%50 daha fazla görüntülenme',
        'Haftalık performans raporu',
      ],
      color: const Color(0xFF00838F),
    ),
    _PromotionPackage(
      id: 'corporate_plus',
      name: 'Kurumsal Plus',
      price: 'İletişime Geçin',
      durationDays: null,
      highlights: const [
        'Sınırsız vitrin ilanı',
        'Kurumsal danışman desteği',
        'Kişiye özel kampanyalar',
      ],
      color: const Color(0xFFFFB300),
    ),
  ];

  Future<void> _handlePackageTap(_PromotionPackage package) async {
    if (package.durationDays == null) {
      _showCorporateDialog();
      return;
    }

    final appState = context.read<AppState>();
    final listings = appState.myListings();

    if (listings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Önce bir ilan oluşturmalısınız.')),
      );
      return;
    }

    final Listing? selected = await showModalBottomSheet<Listing>(
      context: context,
      useSafeArea: true,
      builder: (context) {
        return _ListingPicker(listings: listings, packageName: package.name);
      },
    );

    if (selected == null) return;

    setState(() => _isProcessing = true);
    try {
      await appState.promoteListing(
        listingId: selected.id,
        durationDays: package.durationDays!,
        packageId: package.id,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${selected.title} ${package.name} paketine taşındı.'),
        ),
      );
    } on AuthException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(error.message)));
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Paket uygulanamadı: $error')));
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  void _showCorporateDialog() {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kurumsal Plus'),
        content: const Text(
          'Kurumsal Plus paketi için satış ekibimizle iletişime geçin. '
          'Size özel kampanyalar, sınırsız vitrin ilanı ve danışman desteği sunuyoruz.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Kapat'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'info@kktccaraba.com adresinden bize ulaşabilirsiniz.',
                  ),
                ),
              );
            },
            child: const Text('İletişim Bilgisi Gönder'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('İlanı Öne Çıkar')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _packages.length,
        itemBuilder: (_, index) {
          final pkg = _packages[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 20),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(pkg.name, style: theme.textTheme.titleLarge),
                        Chip(
                          label: Text(pkg.price),
                          backgroundColor: pkg.color.withValues(alpha: .12),
                          labelStyle: theme.textTheme.labelLarge!.copyWith(
                            color: pkg.color,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...pkg.highlights.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.check_circle_rounded,
                              color: pkg.color,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _isProcessing
                          ? null
                          : () => _handlePackageTap(pkg),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pkg.color,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: _isProcessing
                          ? const SizedBox(
                              height: 18,
                              width: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              pkg.durationDays == null
                                  ? 'Satış ekibine ulaş'
                                  : 'Bu paketi uygula',
                            ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class _PromotionPackage {
  const _PromotionPackage({
    required this.id,
    required this.name,
    required this.price,
    required this.highlights,
    required this.color,
    required this.durationDays,
  });

  final String id;
  final String name;
  final String price;
  final List<String> highlights;
  final Color color;
  final int? durationDays;
}

class _ListingPicker extends StatelessWidget {
  const _ListingPicker({required this.listings, required this.packageName});

  final List<Listing> listings;
  final String packageName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('İlan seç', style: theme.textTheme.titleLarge),
                const SizedBox(height: 6),
                Text(
                  '$packageName paketini hangi ilana uygulamak istersiniz?',
                  style: theme.textTheme.bodyMedium!.copyWith(
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              padding: const EdgeInsets.only(bottom: 24),
              itemBuilder: (_, index) {
                final listing = listings[index];
                return ListTile(
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: listing.images.isNotEmpty
                        ? Image.network(
                            listing.images.first,
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                        : Container(
                            width: 60,
                            height: 60,
                            color: theme.colorScheme.primary.withValues(
                              alpha: .1,
                            ),
                            child: Icon(
                              Icons.image_not_supported_rounded,
                              color: theme.colorScheme.primary,
                            ),
                          ),
                  ),
                  title: Text(
                    listing.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    formatPrice(listing.price, listing.currency),
                    style: theme.textTheme.bodyMedium,
                  ),
                  onTap: () => Navigator.of(context).pop(listing),
                );
              },
              separatorBuilder: (_, __) => const Divider(height: 0),
              itemCount: listings.length,
            ),
          ),
        ],
      ),
    );
  }
}
