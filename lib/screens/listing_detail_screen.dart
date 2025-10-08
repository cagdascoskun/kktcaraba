import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/models.dart';
import '../state/app_state.dart';
import '../utils/formatters.dart';
import '../widgets/listing_widgets.dart';
import '../widgets/common_widgets.dart';

class ListingDetailScreen extends StatefulWidget {
  const ListingDetailScreen({super.key, required this.listing});

  final Listing listing;

  @override
  State<ListingDetailScreen> createState() => _ListingDetailScreenState();
}

class _ListingDetailScreenState extends State<ListingDetailScreen> {
  late final Future<String> _dialPhoneFuture;

  @override
  void initState() {
    super.initState();
    _dialPhoneFuture = _getDialPhone();
  }

  Future<String> _getDialPhone() async {
    final appState = Provider.of<AppState>(context, listen: false);
    final listingPhone = widget.listing.contactPhone.trim();

    String phone = normalizeTurkishPhone(listingPhone);

    if (phone.isEmpty) {
      final fetchedPhone = await appState.fetchUserPhone(
        widget.listing.publisherId,
      );
      phone = normalizeTurkishPhone(fetchedPhone ?? '');
    }

    if (phone.isEmpty &&
        appState.currentUser?.id == widget.listing.publisherId) {
      phone = normalizeTurkishPhone(appState.currentUser?.phone ?? '');
    }

    return phone;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return FutureBuilder<String>(
      future: _dialPhoneFuture,
      builder: (context, snapshot) {
        // Future tamamlanana kadar butonları devre dışı bırakmak için
        // bağlantı durumunu kontrol edebiliriz.
        final dialPhone = snapshot.data ?? '';

        final hasPhone = dialPhone.isNotEmpty;
        final displayPhone = hasPhone
            ? formatTurkishPhone(dialPhone)
            : 'Telefon bilgisi belirtilmedi';

        final agent = Agent(
          name: widget.listing.publisher,
          // `displayPhone` zaten formatlanmış ve boşsa uygun mesajı içeriyor.
          phone: displayPhone,
          email: 'info@kktccaraba.com',
          company: widget.listing.publisher,
          avatarUrl: widget.listing.publisherAvatar,
          isVerified: widget.listing.isPremium,
        );

        // URI'yi doğrudan `dialPhone` ile oluşturabiliriz.
        final callUri = hasPhone
            ? Uri(scheme: 'tel', path: '+$dialPhone')
            : null;

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          body: CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: ListingPhotoCarousel(images: widget.listing.images),
              ),
              SliverToBoxAdapter(
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.vertical(
                      top: Radius.circular(32),
                    ),
                  ),
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 100),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: theme.colorScheme.primary.withValues(
                                alpha: .08,
                              ),
                              borderRadius: BorderRadius.circular(14),
                            ),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            child: Text(
                              widget.listing.type == ListingType.kiralik
                                  ? 'Kiralık'
                                  : widget.listing.type == ListingType.satilik
                                  ? 'Satılık'
                                  : widget.listing.type == ListingType.hizmet
                                  ? 'Hizmet'
                                  : 'İkinci El',
                              style: theme.textTheme.labelLarge!.copyWith(
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          if (widget.listing.isPremium)
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFFFF4E5),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.bolt_rounded,
                                    color: Color(0xFFFF9800),
                                    size: 18,
                                  ),
                                  SizedBox(width: 6),
                                  Text('Öne Çıkan'),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        widget.listing.title,
                        style: theme.textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Text(
                            formatPrice(
                              widget.listing.price,
                              widget.listing.currency,
                            ),
                            style: theme.textTheme.headlineMedium!.copyWith(
                              color: theme.colorScheme.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '/ ${widget.listing.type == ListingType.kiralik ? 'aylık' : 'satış'}',
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.location_on_rounded,
                            color: Colors.black54,
                          ),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              widget.listing.location,
                              style: theme.textTheme.bodyLarge!.copyWith(
                                color: Colors.black54,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      if (widget.listing.tags.isNotEmpty)
                        SizedBox(
                          height: 44,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, index) {
                              final tag = widget.listing.tags[index];
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.primary.withValues(
                                    alpha: .08,
                                  ),
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      tag.iconData,
                                      size: 18,
                                      color: theme.colorScheme.primary,
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      tag.label,
                                      style: theme.textTheme.bodyMedium!
                                          .copyWith(
                                            color: theme.colorScheme.primary,
                                          ),
                                    ),
                                  ],
                                ),
                              );
                            },
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 12),
                            itemCount: widget.listing.tags.length,
                          ),
                        ),
                      const SizedBox(height: 24),
                      Text('Açıklama', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      Text(
                        widget.listing.description,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 24),
                      ListingFeatures(listing: widget.listing),
                      const SizedBox(height: 24),
                      Text('Konum', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Container(
                                color: Colors.grey.shade200,
                                child: const Center(
                                  child: Icon(
                                    Icons.map_rounded,
                                    size: 50,
                                    color: Colors.black45,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 12,
                                right: 12,
                                child: ElevatedButton.icon(
                                  onPressed: () {},
                                  icon: const Icon(Icons.directions_rounded),
                                  label: const Text('Haritada Aç'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text('İlan Sahibi', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      AgentCard(agent: agent),
                      const SizedBox(height: 24),
                      Text('Diğer İlanlar', style: theme.textTheme.titleLarge),
                      const SizedBox(height: 12),
                      ConsumerListings(
                        excludeId: widget.listing.id,
                        onItemTap: (other) => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => ListingDetailScreen(listing: other),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          bottomSheet: Container(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  offset: Offset(0, -2),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    // Arama butonu
                    onPressed: hasPhone
                        ? () => launchExternalUrl(context, callUri!)
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.primary,
                    ),
                    icon: const Icon(Icons.phone_in_talk_rounded),
                    label: const Text('Ara'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    // WhatsApp butonu
                    onPressed: hasPhone
                        ? () => openWhatsApp(
                            context,
                            dialPhone,
                            'Merhaba ${agent.name}, "${widget.listing.title}" ilanı hakkında bilgi almak istiyorum.',
                          )
                        : null,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: theme.colorScheme.secondary,
                    ),
                    icon: const Icon(Icons.chat_rounded),
                    label: const Text('WhatsApp'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
