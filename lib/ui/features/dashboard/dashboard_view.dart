import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../core/widgets/arvo_header.dart';
import '../../core/widgets/arvo_metric_card.dart';
import '../../core/widgets/arvo_alert_card.dart';

class DashboardView extends StatelessWidget {
  final Function(int targetIndex)? onNavigateTab;

  const DashboardView({super.key, this.onNavigateTab});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final summary = vm.summary;
    final criticalAlerts = vm.analysis?.criticalAlerts ?? [];
    final warningAlerts = vm.analysis?.warningAlerts ?? [];

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Cabeçalho Oficial Arvô
            ArvoHeader(
              farmName: 'Fazenda Boa Vista',
              season: 'Safra 2026/27',
              onResetDemo: () {
                vm.resetAllToDemonstration();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cenário oficial do Hackathon restaurado com sucesso!'),
                    backgroundColor: ArvoColors.petroleo,
                    duration: Duration(seconds: 2),
                  ),
                );
              },
            ),

            // Grade de Métricas Principais (Inspirada no Mockup A03-app-celular)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Transform.translate(
                offset: const Offset(0, -22),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: ArvoMetricCard(
                            icon: Icons.grass_rounded,
                            title: 'Área monitorada',
                            value: '842',
                            unit: 'ha',
                            onTap: () => onNavigateTab != null
                                ? onNavigateTab!(1)
                                : AppRoutes.to(context, AppRoutes.intelligence),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ArvoMetricCard(
                            icon: Icons.inventory_2_outlined,
                            title: 'Insumos ativos',
                            value: summary != null ? '${summary.totalProductsCount}' : '...',
                            unit: 'itens',
                            onTap: () => onNavigateTab != null
                                ? onNavigateTab!(2)
                                : AppRoutes.to(context, AppRoutes.inventory),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ArvoMetricCard(
                            icon: Icons.attach_money_rounded,
                            title: 'Capital em estoque',
                            value: summary != null
                                ? Formatters.formatCurrencyCompact(summary.totalInventoryCapital)
                                : '...',
                            iconColor: ArvoColors.ambar,
                            onTap: () => onNavigateTab != null
                                ? onNavigateTab!(1)
                                : AppRoutes.to(context, AppRoutes.intelligence),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ArvoMetricCard(
                            icon: Icons.warning_amber_rounded,
                            title: 'Situações críticas',
                            value: summary != null ? '${summary.criticalAlertsCount}' : '...',
                            unit: 'alertas',
                            iconColor: ArvoColors.erro,
                            valueColor: summary != null && summary.criticalAlertsCount > 0
                                ? ArvoColors.erro
                                : ArvoColors.petroleo,
                            onTap: () => onNavigateTab != null
                                ? onNavigateTab!(1)
                                : AppRoutes.to(context, AppRoutes.intelligence),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Card de Gráfico de Consumo / Produtividade (Estilo Mockup Arvô)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: ArvoColors.linha),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.04),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Expanded(
                              child: Text(
                                'Consumo Recente por Categoria',
                                style: TextStyle(
                                  fontFamily: ArvoTypography.fontHeading,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ArvoColors.petroleo,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: ArvoColors.nevoa,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Text(
                                'Últimos 30 dias',
                                style: TextStyle(
                                  fontFamily: ArvoTypography.fontBody,
                                  fontSize: 11,
                                  color: ArvoColors.musgo,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          height: 150,
                          child: BarChart(
                            BarChartData(
                              alignment: BarChartAlignment.spaceAround,
                              maxY: 100,
                              barTouchData: BarTouchData(
                                enabled: true,
                                touchTooltipData: BarTouchTooltipData(
                                  getTooltipColor: (_) => ArvoColors.petroleoProfundo,
                                  getTooltipItem: (group, groupIndex, rod, rodIndex) {
                                    final categories = [
                                      'Fertilizantes',
                                      'Defensivos',
                                      'Combustível',
                                      'Sementes',
                                      'Irrigação',
                                      'Peças'
                                    ];
                                    return BarTooltipItem(
                                      '${categories[group.x.toInt()]}\n${rod.toY.toInt()}% do previsto',
                                      const TextStyle(
                                        color: Colors.white,
                                        fontFamily: ArvoTypography.fontBody,
                                        fontSize: 12,
                                      ),
                                    );
                                  },
                                ),
                              ),
                              titlesData: FlTitlesData(
                                show: true,
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      const titles = ['Fert', 'Def', 'Comb', 'Sem', 'Irrig', 'Peças'];
                                      if (value.toInt() >= 0 && value.toInt() < titles.length) {
                                        return Padding(
                                          padding: const EdgeInsets.only(top: 8),
                                          child: Text(
                                            titles[value.toInt()],
                                            style: const TextStyle(
                                              fontFamily: ArvoTypography.fontBody,
                                              fontSize: 11,
                                              color: ArvoColors.musgo,
                                            ),
                                          ),
                                        );
                                      }
                                      return const SizedBox();
                                    },
                                    reservedSize: 26,
                                  ),
                                ),
                                leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              gridData: const FlGridData(show: false),
                              borderData: FlBorderData(show: false),
                              barGroups: [
                                BarChartGroupData(
                                  x: 0,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 88,
                                      color: ArvoColors.folha,
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 1,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 92,
                                      color: ArvoColors.ambarClaro,
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 2,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 78,
                                      color: ArvoColors.folha,
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 3,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 55,
                                      color: ArvoColors.ambarClaro,
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 4,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 34,
                                      color: ArvoColors.folha,
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                ),
                                BarChartGroupData(
                                  x: 5,
                                  barRods: [
                                    BarChartRodData(
                                      toY: 42,
                                      color: ArvoColors.ambarClaro,
                                      width: 18,
                                      borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Acesso Rápido às Páginas (Linkadas via AppRoutes)
                  const Text(
                    'Acesso Rápido aos Módulos',
                    style: TextStyle(
                      fontFamily: ArvoTypography.fontHeading,
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      color: ArvoColors.petroleo,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: _buildQuickNavButton(
                          context,
                          icon: Icons.inventory_2_outlined,
                          label: 'Insumos',
                          onTap: () => onNavigateTab != null
                              ? onNavigateTab!(2)
                              : AppRoutes.toInventory(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickNavButton(
                          context,
                          icon: Icons.swap_horiz_rounded,
                          label: 'Movimentos',
                          onTap: () => onNavigateTab != null
                              ? onNavigateTab!(3)
                              : AppRoutes.toMovements(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickNavButton(
                          context,
                          icon: Icons.tune_rounded,
                          label: 'Simulador',
                          onTap: () => onNavigateTab != null
                              ? onNavigateTab!(4)
                              : AppRoutes.toSimulation(context),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: _buildQuickNavButton(
                          context,
                          icon: Icons.psychology_outlined,
                          label: 'Inteligência',
                          onTap: () => onNavigateTab != null
                              ? onNavigateTab!(1)
                              : AppRoutes.toIntelligence(context),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),

                  // Radar de Alertas Prioritários
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Expanded(
                        child: Text(
                          'Radar de Prioridades',
                          style: TextStyle(
                            fontFamily: ArvoTypography.fontHeading,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: ArvoColors.petroleo,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      TextButton(
                        onPressed: () => onNavigateTab != null
                            ? onNavigateTab!(1)
                            : AppRoutes.toIntelligence(context),
                        child: const Text(
                          'Ver todos',
                          style: TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: ArvoColors.folha,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  if (criticalAlerts.isEmpty && warningAlerts.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: ArvoColors.linha),
                      ),
                      child: const Center(
                        child: Text(
                          'Nenhum alerta crítico no momento. Estoque estabilizado.',
                          style: TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            color: ArvoColors.musgo,
                          ),
                        ),
                      ),
                    )
                  else ...[
                    // Exibe os alertas críticos ou de atenção prioritários
                    for (final alert in [...criticalAlerts, ...warningAlerts].take(3))
                      ArvoAlertCard(
                        alert: alert,
                        onAction: () => onNavigateTab != null
                            ? onNavigateTab!(1)
                            : AppRoutes.toIntelligence(context),
                        actionLabel: 'Ver Diagnóstico',
                      ),
                  ],

                  const SizedBox(height: 32),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickNavButton(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: ArvoColors.linha),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: ArvoColors.petroleo.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: ArvoColors.petroleo, size: 20),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: const TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: ArvoColors.petroleo,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
