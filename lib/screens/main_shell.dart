import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../screens/showcase/vitrin_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/favorites/favorites_screen.dart';
import '../screens/profile/profile_screen.dart';
import '../screens/create_listing_screen.dart';
import '../state/app_state.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  bool _hasShownOnboarding = false;

  final List<Widget> _screens = const [
    VitrinScreen(),
    SearchScreen(),
    FavoritesScreen(),
    ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeShowOnboarding());
  }

  void _maybeShowOnboarding() {
    if (!mounted || _hasShownOnboarding) return;
    final appState = context.read<AppState>();
    if (!appState.showOnboarding) return;
    _hasShownOnboarding = true;
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const OnboardingSheet(),
    ).then((_) => appState.dismissOnboarding());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 350),
        child: _screens[_currentIndex],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.workspace_premium_outlined),
                activeIcon: Icon(Icons.workspace_premium_rounded),
                label: 'Vitrin',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.search_outlined),
                activeIcon: Icon(Icons.search_rounded),
                label: 'Ara',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.favorite_border_rounded),
                activeIcon: Icon(Icons.favorite_rounded),
                label: 'Favoriler',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.person_outline_rounded),
                activeIcon: Icon(Icons.person_rounded),
                label: 'Profil',
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: _currentIndex == 0
          ? FloatingActionButton.extended(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const CreateListingScreen()),
              ),
              icon: const Icon(Icons.add_rounded),
              label: const Text('İlan Ver'),
            )
          : null,
    );
  }
}

class OnboardingSheet extends StatefulWidget {
  const OnboardingSheet({super.key});

  @override
  State<OnboardingSheet> createState() => _OnboardingSheetState();
}

class _OnboardingSheetState extends State<OnboardingSheet> {
  final PageController _pageController = PageController();
  int _activeIndex = 0;

  final List<_OnboardingStep> _steps = const [
    _OnboardingStep(
      icon: Icons.explore_rounded,
      title: 'KKTC’nin en büyük vitrinine hoş geldin',
      description:
          'Deniz manzaralı villalardan prestijli araçlara kadar binlerce ilanı tek yerden keşfet.',
    ),
    _OnboardingStep(
      icon: Icons.workspace_premium_rounded,
      title: 'Vitrin ile öne çık',
      description: 'İlanlarını vitrine taşı, binlerce kullanıcıya ilk bakışta ulaş.',
    ),
    _OnboardingStep(
      icon: Icons.chat_rounded,
      title: 'WhatsApp ile hızla iletişime geç',
      description:
          'İlgilendiğin ilan sahiplerine tek dokunuşla ulaş ve anlaşmanı hızlandır.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _next(BuildContext context) {
    if (_activeIndex == _steps.length - 1) {
      Navigator.of(context).pop();
      return;
    }
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: BoxDecoration(
        color: theme.scaffoldBackgroundColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 16),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.black12,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 240,
              child: PageView.builder(
                controller: _pageController,
                itemCount: _steps.length,
                onPageChanged: (value) => setState(() => _activeIndex = value),
                itemBuilder: (_, index) {
                  final step = _steps[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(step.icon, size: 72, color: theme.colorScheme.primary),
                        const SizedBox(height: 24),
                        Text(
                          step.title,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          step.description,
                          textAlign: TextAlign.center,
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _steps.length,
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _activeIndex == index ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _activeIndex == index
                        ? theme.colorScheme.primary
                        : theme.colorScheme.primary.withValues(alpha: .4),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                children: [
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text('Atla'),
                  ),
                  const Spacer(),
                  FilledButton(
                    onPressed: () => _next(context),
                    child: Text(
                      _activeIndex == _steps.length - 1 ? 'Başla' : 'Devam',
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingStep {
  const _OnboardingStep({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;
}
