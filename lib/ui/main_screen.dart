import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/theme/arvo_colors.dart';
import '../core/theme/arvo_typography.dart';
import '../core/utils/formatters.dart';
import '../domain/viewmodels/stock_intelligence_viewmodel.dart';
import 'core/widgets/arvo_brand_graphics.dart';
import 'features/dashboard/dashboard_view.dart';
import 'features/intelligence/intelligence_view.dart';
import 'features/inventory/inventory_view.dart';
import 'features/movements/movements_view.dart';
import 'features/simulation/simulation_view.dart';

/// Shell adaptativo principal do sistema Arvô (UI/UX Pro Max):
/// - Desktop Wide (>= 1080px): Sidebar executiva em Petróleo Profundo com Letreiro Oficial,
///   navegação unificada e card compacto de status da unidade produtiva.
/// - Tablet (768px - 1079px): NavigationRail compacto com Símbolo Oficial Arvô.
/// - Mobile (< 768px): BottomNavigationBar fiel ao Mockup A03-app-celular.html.
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
    if (_currentIndex == index) return;
    setState(() => _currentIndex = index);
  }

  void _handleResetDemo(
    BuildContext context,
    StockIntelligenceViewModel vm,
  ) {
    vm.resetAllToDemonstration();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Cenário oficial do Hackathon restaurado com sucesso!',
        ),
        backgroundColor: ArvoColors.petroleo,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final criticalCount = vm.summary?.criticalAlertsCount ?? 0;
    final warningCount = vm.summary?.warningAlertsCount ?? 0;
    final totalCapital = vm.summary?.totalInventoryCapital ?? 0;

    final List<Widget> screens = [
      DashboardView(onNavigateTab: _navigateToIndex),
      IntelligenceView(onNavigateTab: _navigateToIndex),
      InventoryView(onNavigateTab: _navigateToIndex),
      MovementsView(onNavigateTab: _navigateToIndex),
      SimulationView(onNavigateTab: _navigateToIndex),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final isWideDesktop = width >= 1080;
        final isTablet = width >= 768 && width < 1080;

        if (isWideDesktop) {
          return Scaffold(
            backgroundColor: ArvoColors.nevoa,
            body: Row(
              children: [
                _ArvoDesktopSidebar(
                  currentIndex: _currentIndex,
                  criticalCount: criticalCount,
                  warningCount: warningCount,
                  totalCapital: totalCapital,
                  onSelectIndex: _navigateToIndex,
                  onResetDemo: () => _handleResetDemo(context, vm),
                ),
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: ArvoColors.linha,
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }

        if (isTablet) {
          return Scaffold(
            backgroundColor: ArvoColors.nevoa,
            body: Row(
              children: [
                NavigationRail(
                  backgroundColor: ArvoColors.petroleoProfundo,
                  selectedIndex: _currentIndex,
                  onDestinationSelected: _navigateToIndex,
                  labelType: NavigationRailLabelType.all,
                  useIndicator: true,
                  indicatorColor: ArvoColors.petroleo,
                  leading: const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: ArvoSymbol(size: 38, isReverse: true),
                  ),
                  trailing: Expanded(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 20),
                        child: IconButton(
                          tooltip: 'Restaurar Cenário Demo',
                          onPressed: () => _handleResetDemo(context, vm),
                          icon: const Icon(
                            Icons.refresh_rounded,
                            color: ArvoColors.nevoa,
                          ),
                        ),
                      ),
                    ),
                  ),
                  selectedIconTheme: const IconThemeData(
                    color: ArvoColors.folhaClara,
                    size: 24,
                  ),
                  unselectedIconTheme: const IconThemeData(
                    color: Color(0xFF9AB0A6),
                    size: 22,
                  ),
                  selectedLabelTextStyle: const TextStyle(
                    fontFamily: ArvoTypography.fontHeading,
                    color: ArvoColors.nevoa,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  unselectedLabelTextStyle: const TextStyle(
                    fontFamily: ArvoTypography.fontBody,
                    color: Color(0xFF9AB0A6),
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
                      label: const Text('Inteligência'),
                    ),
                    const NavigationRailDestination(
                      icon: Icon(Icons.inventory_2_outlined),
                      selectedIcon: Icon(Icons.inventory_2_rounded),
                      label: Text('Insumos'),
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
                const VerticalDivider(
                  thickness: 1,
                  width: 1,
                  color: ArvoColors.linha,
                ),
                Expanded(
                  child: IndexedStack(
                    index: _currentIndex,
                    children: screens,
                  ),
                ),
              ],
            ),
          );
        }

        // Layout Mobile fiel ao Mockup A03-app-celular.html
        return Scaffold(
          backgroundColor: ArvoColors.nevoa,
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: const Border(
                top: BorderSide(color: ArvoColors.linha, width: 1),
              ),
              boxShadow: [
                BoxShadow(
                  color: ArvoColors.petroleo.withValues(alpha: 0.04),
                  blurRadius: 12,
                  offset: const Offset(0, -3),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
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
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
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
          ),
        );
      },
    );
  }
}

class _ArvoDesktopSidebar extends StatelessWidget {
  final int currentIndex;
  final int criticalCount;
  final int warningCount;
  final double totalCapital;
  final ValueChanged<int> onSelectIndex;
  final VoidCallback onResetDemo;

  const _ArvoDesktopSidebar({
    required this.currentIndex,
    required this.criticalCount,
    required this.warningCount,
    required this.totalCapital,
    required this.onSelectIndex,
    required this.onResetDemo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 260,
      decoration: const BoxDecoration(
        gradient: ArvoColors.gradienteSidebarPetroleo,
      ),
      child: Stack(
        children: [
          // Grafismo oficial de Curvas de Nível na base da Sidebar
          const Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: ArvoHorizonArcs(
              strokeColor: ArvoColors.sucesso,
              maxOpacity: 0.25,
              height: 110,
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(18, 28, 18, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logotipo Letreiro Reverso Oficial com ótimo respiro
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const ArvoWordmark(width: 114, isReverse: true),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 7,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color:
                                ArvoColors.folhaClara.withValues(alpha: 0.16),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color:
                                  ArvoColors.folhaClara.withValues(alpha: 0.35),
                            ),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontFamily: ArvoTypography.fontHeading,
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: ArvoColors.folhaClara,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      'MÓDULOS OPERACIONAIS',
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontHeading,
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF8AA398),
                        letterSpacing: 1.2,
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Itens de Navegação
                  _SidebarNavItem(
                    icon: Icons.dashboard_outlined,
                    activeIcon: Icons.dashboard_rounded,
                    svgIcon: 'icone-lavoura',
                    label: 'Visão Geral',
                    isSelected: currentIndex == 0,
                    onTap: () => onSelectIndex(0),
                  ),
                  _SidebarNavItem(
                    icon: Icons.psychology_outlined,
                    activeIcon: Icons.psychology_rounded,
                    label: 'Inteligência',
                    badgeCount: criticalCount,
                    badgeColor: ArvoColors.erro,
                    isSelected: currentIndex == 1,
                    onTap: () => onSelectIndex(1),
                  ),
                  _SidebarNavItem(
                    icon: Icons.inventory_2_outlined,
                    activeIcon: Icons.inventory_2_rounded,
                    svgIcon: 'icone-estoque',
                    label: 'Insumos & Lotes',
                    isSelected: currentIndex == 2,
                    onTap: () => onSelectIndex(2),
                  ),
                  _SidebarNavItem(
                    icon: Icons.swap_horiz_rounded,
                    activeIcon: Icons.swap_horizontal_circle_rounded,
                    svgIcon: 'icone-maquinario',
                    label: 'Movimentos',
                    isSelected: currentIndex == 3,
                    onTap: () => onSelectIndex(3),
                  ),
                  _SidebarNavItem(
                    icon: Icons.tune_outlined,
                    activeIcon: Icons.tune_rounded,
                    svgIcon: 'icone-relatorio',
                    label: 'Simulador What-If',
                    isSelected: currentIndex == 4,
                    onTap: () => onSelectIndex(4),
                  ),

                  const Spacer(),

                  // Card Compacto da Fazenda Boa Vista + Resumo de Capital na base
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.22),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.09),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 32,
                              height: 32,
                              decoration: BoxDecoration(
                                color: ArvoColors.folhaClara
                                    .withValues(alpha: 0.16),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              alignment: Alignment.center,
                              child: const ArvoBrandIcon(
                                iconName: 'icone-lavoura',
                                size: 17,
                                color: ArvoColors.folhaClara,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Boa Vista • 842 ha',
                                    style: TextStyle(
                                      fontFamily: ArvoTypography.fontHeading,
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w600,
                                      color: ArvoColors.nevoa,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  Text(
                                    'Sorriso, MT • Ciclo 26/27',
                                    style: TextStyle(
                                      fontFamily: ArvoTypography.fontBody,
                                      fontSize: 11,
                                      color: Color(0xFFB5C7BE),
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: criticalCount > 0
                                    ? ArvoColors.ambarClaro
                                    : ArvoColors.folhaClara,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ],
                        ),
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 10),
                          child: Divider(
                            height: 1,
                            color: Color(0x22FFFFFF),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              'Estoque Total',
                              style: TextStyle(
                                fontFamily: ArvoTypography.fontBody,
                                fontSize: 11,
                                color: Color(0xFFB5C7BE),
                              ),
                            ),
                            Text(
                              Formatters.formatCurrencyCompact(totalCapital),
                              style: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 13.5,
                                fontWeight: FontWeight.w700,
                                color: ArvoColors.nevoa,
                                fontFeatures: ArvoTypography.tabularFigures,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: onResetDemo,
                            icon: const Icon(
                              Icons.refresh_rounded,
                              size: 14,
                              color: ArvoColors.nevoa,
                            ),
                            label: const Text(
                              'Restaurar Cenário Demo',
                              style: TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 11.5,
                                fontWeight: FontWeight.w600,
                                color: ArvoColors.nevoa,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size(0, 36),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              side: BorderSide(
                                color: Colors.white.withValues(alpha: 0.18),
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SidebarNavItem extends StatefulWidget {
  final IconData icon;
  final IconData activeIcon;
  final String? svgIcon;
  final String label;
  final int badgeCount;
  final Color? badgeColor;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarNavItem({
    required this.icon,
    required this.activeIcon,
    this.svgIcon,
    required this.label,
    this.badgeCount = 0,
    this.badgeColor,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarNavItem> createState() => _SidebarNavItemState();
}

class _SidebarNavItemState extends State<_SidebarNavItem> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final fgColor = isSelected
        ? ArvoColors.nevoa
        : (_isHovered ? ArvoColors.nevoa : const Color(0xFFB5C7BE));
    final iconColor = isSelected
        ? ArvoColors.folhaClara
        : (_isHovered ? ArvoColors.folhaClara : const Color(0xFF9AB0A6));

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        cursor: SystemMouseCursors.click,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            borderRadius: BorderRadius.circular(12),
            child: AnimatedContainer(
              duration: ArvoColors.motionFast,
              constraints: const BoxConstraints(minHeight: 46),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: isSelected
                    ? Colors.white.withValues(alpha: 0.12)
                    : (_isHovered
                        ? Colors.white.withValues(alpha: 0.06)
                        : Colors.transparent),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isSelected
                      ? ArvoColors.folhaClara.withValues(alpha: 0.35)
                      : Colors.transparent,
                ),
              ),
              child: Row(
                children: [
                  // Barra indicadora lateral de item ativo
                  AnimatedContainer(
                    duration: ArvoColors.motionFast,
                    width: 3,
                    height: isSelected ? 20 : 0,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: ArvoColors.ambarClaro,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  if (widget.svgIcon != null)
                    ArvoBrandIcon(
                      iconName: widget.svgIcon!,
                      size: 20,
                      color: iconColor,
                      fallbackIcon:
                          isSelected ? widget.activeIcon : widget.icon,
                    )
                  else
                    Icon(
                      isSelected ? widget.activeIcon : widget.icon,
                      size: 20,
                      color: iconColor,
                    ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.label,
                      style: TextStyle(
                        fontFamily: isSelected
                            ? ArvoTypography.fontHeading
                            : ArvoTypography.fontBody,
                        fontSize: 13.5,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w500,
                        color: fgColor,
                      ),
                    ),
                  ),
                  if (widget.badgeCount > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 7,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: widget.badgeColor ?? ArvoColors.erro,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${widget.badgeCount}',
                        style: const TextStyle(
                          fontFamily: ArvoTypography.fontHeading,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                          fontFeatures: ArvoTypography.tabularFigures,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
