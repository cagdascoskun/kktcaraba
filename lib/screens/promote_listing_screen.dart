import 'package:flutter/material.dart';

class PromoteListingScreen extends StatelessWidget {
  const PromoteListingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final packages = [
      _PromotionPackage(
        name: 'Vitrin 7 Gün',
        price: '₺649',
        highlights: const [
          'Vitrin sayfasında görünürlük',
          'Sınırsız WhatsApp bildirimi',
          'Öncelikli destek hattı',
        ],
        color: theme.colorScheme.primary,
      ),
      _PromotionPackage(
        name: 'Vitrin 30 Gün',
        price: '₺1999',
        highlights: const [
          'Premium rozet ve üst sıralar',
          '%50 daha fazla görüntülenme',
          'Haftalık performans raporu',
        ],
        color: theme.colorScheme.secondary,
      ),
      _PromotionPackage(
        name: 'Kurumsal Plus',
        price: 'İletişime Geçin',
        highlights: const [
          'Sınırsız vitrin ilanı',
          'Kurumsal danışman desteği',
          'Kişiye özel kampanyalar',
        ],
        color: Colors.amber.shade700,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('İlanı Öne Çıkar')),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: packages.length,
        itemBuilder: (_, index) {
          final pkg = packages[index];
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
                          labelStyle: theme.textTheme.labelLarge!
                              .copyWith(color: pkg.color),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...pkg.highlights.map(
                      (item) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle_rounded,
                                color: pkg.color, size: 20),
                            const SizedBox(width: 8),
                            Expanded(child: Text(item)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: pkg.color,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Satın Al / Talep Gönder'),
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
    required this.name,
    required this.price,
    required this.highlights,
    required this.color,
  });

  final String name;
  final String price;
  final List<String> highlights;
  final Color color;
}
