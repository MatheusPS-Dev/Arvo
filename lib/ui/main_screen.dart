import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/arvo_colors.dart';
import '../core/theme/arvo_typography.dart';
import '../domain/viewmodels/stock_intelligence_viewmodel.dart';
import 'features/dashboard/dashboard_view.dart';
import 'features/intelligence/intelligence_view.dart';
import 'features/inventory/inventory_view.dart';
import 'features/movements/movements_view.dart';
import 'features/simulation/simulation_view.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;

  const MainScreen({super.key, this.initialIndex = 0});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int _currentIndex;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  @override
  void didUpdateWidget(covariant MainScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.initialIndex != widget.initialIndex) {
      _currentIndex = widget.initialIndex;
    }
  }

  void _navigateToIndex(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final criticalCount = vm.summary?.criticalAlertsCount ?? 0;

    final List<Widget> screens = [
      DashboardView(onNavigateTab: _navigateToIndex),
      const IntelligenceView(),
      const InventoryView(),
      const MovementsView(),
      const SimulationView(),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 768;

        if (isDesktop) {
          // Layout para Desktop / Web / Telas Grandes
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: ArvoColors.petroleoProfundo,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _navigateToIndex,
                  labelType: NavigationRailLabelType.all,
                  leading: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20),
                    child: Image.asset(
                      'assets/logos/simbolo/PNG/arvo-simbolo-colorido.png',
                      width: 42,
                      errorBuilder: (_, _, _) => const Icon(
                        Icons.eco,
                        color: ArvoColors.folhaClara,
                        size: 32,
                      ),
                    ),
                  ),
                  selectedIconTheme: const IconThemeData(color: ArvoColors.folhaClara),
                  unselectedIconTheme: const IconThemeData(color: ArvoColors.musgo),
                  selectedLabelTextStyle: const TextStyle(
                    fontFamily: ArvoTypography.fontHeading,
                    color: ArvoColors.nevoa,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    fontFamily: ArvoTypography.fontBody,
                    color: ArvoColors.musgo,
                    fontSize: 11,
                  ),
                  destinations: [
                    const NavigationRailDestination(
                      icon: Icon(Icons.dashboard_outlined),
                      selectedIcon: Icon(Icons.dashboard_rounded),
                      label: Text('Visão Geral'),
                    ),
                    NavigationRailDestination(
                      icon: Badge(
                        isLabelVisible: criticalCount > 0,
                        label: Text('$criticalCount'),
                        backgroundColor: ArvoColors.erro,
                        child: const Icon(Icons.psychology_outlined),
                      ),
                      selectedIcon: Badge(
                        isLabelVisible: criticalCount > 0,
                        label: Text('$criticalCount'),
                        backgroundColor: ArvoColors.erro,
                        child: const Icon(Icons.psychology_rounded),
                      ),
                      label: Text('Inteligência'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2_rounded),
                      label: Text('Estoque'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.swap_horiz_rounded),
                      selectedIcon: Icon(Icons.swap_horizontal_circle_rounded),
                      label: Text('Movimentos'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.tune_outlined),
                      selectedIcon: Icon(Icons.tune_rounded),
                      label: Text('Simulador'),
                    ),
                  ],
                ),
                const VerticalDivider(thickness: 1, width: 1, color: ArvoColors.linha),
                Expanded(child: screens[_currentIndex]),
              ],
            ),
          );
        }

        // Layout Mobile com Bottom Navigation idêntica ao design Arvô
        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: const BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: ArvoColors.linha, width: 1)),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: _navigateToIndex,
              backgroundColor: Colors.white,
              selectedItemColor: ArvoColors.folha,
              unselectedItemColor: ArvoColors.musgo,
              selectedLabelStyle: const TextStyle(
                fontFamily: ArvoTypography.fontHeading,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: ArvoTypography.fontBody,
                fontSize: 10,
              ),
              type: BottomNavigationBarType.fixed,
              elevation: 0,
              items: [
                const BottomNavigationBarItem(
                  icon: Icon(Icons.grass_outlined),
                  activeIcon: Icon(Icons.grass_rounded),
                  label: 'Visão Geral',
                ),
                BottomNavigationBarItem(
                  icon: Badge(
                    isLabelVisible: criticalCount > 0,
                    label: Text('$criticalCount'),
                    backgroundColor: ArvoColors.erro,
                    child: const Icon(Icons.psychology_outlined),
                  ),
                  activeIcon: Badge(
                    isLabelVisible: criticalCount > 0,
                    label: Text('$criticalCount'),
                    backgroundColor: ArvoColors.erro,
                    child: const Icon(Icons.psychology_rounded),
                  ),
                  label: 'Inteligência',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.inventory_2_outlined),
                  activeIcon: Icon(Icons.inventory_2_rounded),
                  label: 'Insumos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.swap_horiz_rounded),
                  activeIcon: Icon(Icons.swap_horizontal_circle_rounded),
                  label: 'Movimentos',
                ),
                const BottomNavigationBarItem(
                  icon: Icon(Icons.tune_outlined),
                  activeIcon: Icon(Icons.tune_rounded),
                  label: 'Simulador',
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
