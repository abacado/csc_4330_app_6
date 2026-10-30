import 'package:animations/animations.dart';
import 'package:material_ui/material_ui.dart';

import '../../theme/app_theme.dart';
import '../../widgets/pressable.dart';
import '../home/home_screen.dart';
import '../market/market_screen.dart';
import '../profile/profile_screen.dart';

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  void _select(int index) {
    if (index != _index) setState(() => _index = index);
  }

  @override
  Widget build(BuildContext context) {
    final page = switch (_index) {
      0 => HomeScreen(onOpenMarket: () => _select(1)),
      1 => const MarketScreen(),
      _ => const ProfileScreen(),
    };

    return Scaffold(
      body: PageTransitionSwitcher(
        duration: const Duration(milliseconds: 320),
        transitionBuilder: (child, animation, secondaryAnimation) =>
            FadeThroughTransition(
              animation: animation,
              secondaryAnimation: secondaryAnimation,
              fillColor: AppColors.paper,
              child: child,
            ),
        child: KeyedSubtree(key: ValueKey(_index), child: page),
      ),
      bottomNavigationBar: _NavBar(index: _index, onSelect: _select),
    );
  }
}

class _NavItemData {
  const _NavItemData(this.label, this.icon, this.selectedIcon);

  final String label;
  final IconData icon;
  final IconData selectedIcon;
}

const _navItems = [
  _NavItemData('Home', Icons.home_outlined, Icons.home_rounded),
  _NavItemData('Market', Icons.storefront_outlined, Icons.storefront_rounded),
  _NavItemData('You', Icons.person_outline_rounded, Icons.person_rounded),
];

class _NavBar extends StatelessWidget {
  const _NavBar({required this.index, required this.onSelect});

  final int index;
  final ValueChanged<int> onSelect;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return DecoratedBox(
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(top: BorderSide(color: AppColors.line)),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          child: Row(
            children: [
              for (final (i, item) in _navItems.indexed)
                Expanded(
                  child: Semantics(
                    button: true,
                    selected: i == index,
                    label: item.label,
                    child: Pressable(
                      onTap: () => onSelect(i),
                      scale: 0.92,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 280),
                            curve: Curves.easeOutCubic,
                            width: i == index ? 58 : 40,
                            height: 30,
                            decoration: BoxDecoration(
                              color: i == index
                                  ? AppColors.mossSoft
                                  : AppColors.mossSoft.withValues(alpha: 0),
                              borderRadius: BorderRadius.circular(99),
                            ),
                            child: Icon(
                              i == index ? item.selectedIcon : item.icon,
                              size: 21,
                              color: i == index
                                  ? AppColors.moss
                                  : AppColors.inkMuted,
                            ),
                          ),
                          const SizedBox(height: 4),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 200),
                            style: textTheme.labelSmall!.copyWith(
                              color: i == index
                                  ? AppColors.ink
                                  : AppColors.inkMuted,
                            ),
                            child: Text(item.label),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
