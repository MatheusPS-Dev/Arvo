import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../../core/routes/app_routes.dart';
import '../../../domain/engine/abc_curve_analyzer.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../core/widgets/arvo_brand_graphics.dart';
import '../../core/widgets/arvo_header.dart';
import '../../core/widgets/arvo_metric_card.dart';
import '../../core/widgets/arvo_alert_card.dart';

class DashboardView extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const DashboardView({super.key, this.onNavigateTab});

  void _navigate(BuildContext context, int tabIndex, String fallbackRoute) {
    if (onNavigateTab != null) {
      onNavigateTab!(tabIndex);
    } else {
      AppRoutes.to(context, fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final summary = vm.summary;
    final analysis = vm.analysis;
    final criticalAlerts = analysis?.criticalAlerts ?? [];
    final warningAlerts = analysis?.warningAlerts ?? [];
    final abcItems = analysis?.abcItems ?? [];

    final totalRiskAndIdle =
        (summary?.capitalAtRiskOfExpiry ?? 0) + (summary?.idleCapitalAmount ?? 0);

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isDesktopOrTablet = constraints.maxWidth >= 768;
          final isWideCharts = constraints.maxWidth >= 960;
          final horizontalPad = isDesktopOrTablet ? 28.0 : 16.0;

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Cabeçalho adaptativo Arvô:
                // - Mobile (< 768px): Letreiro Reverso + Bloco Petróleo A03-app-celular.html
                // - Desktop/Tablet (>= 768px): Page Header editorial + Hero Card contido em 1240px
                ArvoHeader(
                  farmName: 'Fazenda Boa Vista',
                  season: 'Safra 2026/27',
                  criticalAlertsCount: summary?.criticalAlertsCount,
                  totalCapitalText: summary != null
                      ? Formatters.formatCurrency(summary.totalInventoryCapital)
                      : null,
                  autonomyText: summary != null
                      ? '~${summary.averageAutonomyDays.toStringAsFixed(0)} dias'
                      : null,
                  riskAtStakeText: summary != null
                      ? Formatters.formatCurrency(totalRiskAndIdle)
                      : null,
                  onPrimaryAction: () =>
                      _navigate(context, 4, AppRoutes.simulation),
                  primaryActionLabel: 'Simular Safra',
                  primaryActionIcon: Icons.tune_rounded,
                  onResetDemo: () {
                    vm.resetAllToDemonstration();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Cenário oficial do Hackathon restaurado com sucesso!',
                        ),
                        backgroundColor: ArvoColors.petroleo,
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                ),

                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1240),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (!isDesktopOrTablet) const SizedBox(height: 14),

                      // Grade de 4 KPIs Estratégicos com altura perfeitamente simétrica
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                        child: isDesktopOrTablet
                            ? IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: _buildAlertsCard(context, summary),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child:
                                          _buildProductsCard(context, summary),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      child:
                                          _buildCapitalCard(context, summary),
                                    ),
                                    const SizedBox(width: 14),
                                    Expanded(child: _buildAreaCard(context)),
                                  ],
                                ),
                              )
                            : Column(
                                children: [
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _buildAlertsCard(
                                            context,
                                            summary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _buildProductsCard(
                                            context,
                                            summary,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  IntrinsicHeight(
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Expanded(
                                          child: _buildCapitalCard(
                                            context,
                                            summary,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: _buildAreaCard(context),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                      ),

                      SizedBox(height: isDesktopOrTablet ? 20 : 12),

                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Em Mobile (< 768px), exibe a Faixa Executiva de Saúde Operacional
                            if (!isDesktopOrTablet && summary != null) ...[
                              _buildOperationalHealthStrip(context, summary),
                              const SizedBox(height: 16),
                            ],

                            // Seção Analítica: Gráfico de Consumo + Matriz Curva ABC
                            // Em Desktop (>= 960px), ficam lado a lado com a MESMA ALTURA exata
                            if (isWideCharts)
                              IntrinsicHeight(
                                child: Row(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      flex: 7,
                                      child: _buildConsumptionChartCard(context),
                                    ),
                                    const SizedBox(width: 16),
                                    Expanded(
                                      flex: 5,
                                      child: _buildAbcSummaryCard(
                                        context,
                                        abcItems,
                                        summary,
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            else ...[
                              _buildConsumptionChartCard(context),
                              const SizedBox(height: 14),
                              _buildAbcSummaryCard(context, abcItems, summary),
                            ],
                            const SizedBox(height: 22),

                            // Acesso Rápido aos Módulos (Ícones SVG Oficiais + Pastéis A06)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'Acesso Rápido aos Módulos',
                                    style: ArvoTypography.titleMedium,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Text(
                                  'FLUXO OPERACIONAL',
                                  style: ArvoTypography.kicker.copyWith(
                                    fontSize: 10,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            if (isDesktopOrTablet)
                              Row(
                                children: [
                                  Expanded(
                                    child: _buildQuickNavButton(
                                      context,
                                      icon: Icons.inventory_2_outlined,
                                      svgIconName: 'icone-estoque',
                                      pastelBg: ArvoColors.pastelEstoque,
                                      label: 'Insumos',
                                      subtitle: 'Lotes e saldos',
                                      onTap: () => _navigate(
                                        context,
                                        2,
                                        AppRoutes.inventory,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildQuickNavButton(
                                      context,
                                      icon: Icons.swap_horiz_rounded,
                                      svgIconName: 'icone-maquinario',
                                      pastelBg: ArvoColors.pastelMaquinario,
                                      label: 'Movimentos',
                                      subtitle: 'Entradas e saídas',
                                      onTap: () => _navigate(
                                        context,
                                        3,
                                        AppRoutes.movements,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildQuickNavButton(
                                      context,
                                      icon: Icons.tune_rounded,
                                      svgIconName: 'icone-relatorio',
                                      pastelBg: ArvoColors.pastelRelatorio,
                                      label: 'Simulador',
                                      subtitle: 'Cenários What-If',
                                      onTap: () => _navigate(
                                        context,
                                        4,
                                        AppRoutes.simulation,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: _buildQuickNavButton(
                                      context,
                                      icon: Icons.psychology_outlined,
                                      svgIconName: 'icone-clima',
                                      pastelBg: ArvoColors.pastelClima,
                                      label: 'Inteligência',
                                      subtitle: 'Diagnóstico IA',
                                      onTap: () => _navigate(
                                        context,
                                        1,
                                        AppRoutes.intelligence,
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            else
                              Column(
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildQuickNavButton(
                                          context,
                                          icon: Icons.inventory_2_outlined,
                                          svgIconName: 'icone-estoque',
                                          pastelBg: ArvoColors.pastelEstoque,
                                          label: 'Insumos',
                                          subtitle: 'Lotes e saldos',
                                          isCompactHorizontal: true,
                                          onTap: () => _navigate(
                                            context,
                                            2,
                                            AppRoutes.inventory,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildQuickNavButton(
                                          context,
                                          icon: Icons.swap_horiz_rounded,
                                          svgIconName: 'icone-maquinario',
                                          pastelBg: ArvoColors.pastelMaquinario,
                                          label: 'Movimentos',
                                          subtitle: 'Entradas e saídas',
                                          isCompactHorizontal: true,
                                          onTap: () => _navigate(
                                            context,
                                            3,
                                            AppRoutes.movements,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: _buildQuickNavButton(
                                          context,
                                          icon: Icons.tune_rounded,
                                          svgIconName: 'icone-relatorio',
                                          pastelBg: ArvoColors.pastelRelatorio,
                                          label: 'Simulador',
                                          subtitle: 'Cenários What-If',
                                          isCompactHorizontal: true,
                                          onTap: () => _navigate(
                                            context,
                                            4,
                                            AppRoutes.simulation,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Expanded(
                                        child: _buildQuickNavButton(
                                          context,
                                          icon: Icons.psychology_outlined,
                                          svgIconName: 'icone-clima',
                                          pastelBg: ArvoColors.pastelClima,
                                          label: 'Inteligência',
                                          subtitle: 'Diagnóstico IA',
                                          isCompactHorizontal: true,
                                          onTap: () => _navigate(
                                            context,
                                            1,
                                            AppRoutes.intelligence,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            const SizedBox(height: 24),

                            // Radar de Prioridades
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'DIAGNÓSTICO EXPLICÁVEL',
                                        style: ArvoTypography.kicker.copyWith(
                                          fontSize: 10,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      const Text(
                                        'Radar de Prioridades',
                                        style: ArvoTypography.titleMedium,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                                TextButton.icon(
                                  onPressed: () => _navigate(
                                    context,
                                    1,
                                    AppRoutes.intelligence,
                                  ),
                                  icon: const Text(
                                    'Ver todos',
                                    style: TextStyle(
                                      fontFamily: ArvoTypography.fontHeading,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: ArvoColors.sucesso,
                                    ),
                                  ),
                                  label: const Icon(
                                    Icons.arrow_forward_rounded,
                                    size: 16,
                                    color: ArvoColors.sucesso,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),

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
                              for (final alert
                                  in [...criticalAlerts, ...warningAlerts]
                                      .take(3))
                                ArvoAlertCard(
                                  alert: alert,
                                  onAction: () => _navigate(
                                    context,
                                    1,
                                    AppRoutes.intelligence,
                                  ),
                                  actionLabel: 'Ver Diagnóstico',
                                ),
                            ],

                            const SizedBox(height: 36),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAreaCard(BuildContext context) {
    return ArvoMetricCard(
      icon: Icons.grass_rounded,
      svgIconName: 'icone-lavoura',
      iconColor: ArvoColors.folha,
      iconBgColor: ArvoColors.pastelLavoura,
      title: 'Área monitorada',
      value: '842',
      unit: 'ha',
      subtitle: '4 talhões em cultivo',
      onTap: () => _navigate(context, 3, AppRoutes.movements),
    );
  }

  Widget _buildProductsCard(BuildContext context, dynamic summary) {
    final belowMin = summary?.itemsBelowMinStockCount ?? 0;
    return ArvoMetricCard(
      icon: Icons.inventory_2_outlined,
      svgIconName: 'icone-estoque',
      iconColor: ArvoColors.petroleo,
      iconBgColor: ArvoColors.pastelEstoque,
      title: 'Insumos ativos',
      value: summary != null ? '${summary.totalProductsCount}' : '...',
      unit: 'itens',
      subtitle: belowMin > 0 ? '$belowMin abaixo do mínimo' : 'Saldos regulares',
      onTap: () => _navigate(context, 2, AppRoutes.inventory),
    );
  }

  Widget _buildCapitalCard(BuildContext context, dynamic summary) {
    return ArvoMetricCard(
      icon: Icons.attach_money_rounded,
      svgIconName: 'icone-financeiro',
      iconColor: ArvoColors.ambar,
      iconBgColor: ArvoColors.pastelClima,
      title: 'Capital imobilizado',
      value: summary != null
          ? Formatters.formatCurrencyCompact(summary.idleCapitalAmount)
          : '...',
      subtitle: 'Oportunidade Curva ABC',
      onTap: () => _navigate(context, 1, AppRoutes.intelligence),
    );
  }

  Widget _buildAlertsCard(BuildContext context, dynamic summary) {
    final critCount = summary?.criticalAlertsCount ?? 0;
    final warnCount = summary?.warningAlertsCount ?? 0;
    return ArvoMetricCard(
      icon: Icons.warning_amber_rounded,
      iconColor: ArvoColors.erro,
      iconBgColor: ArvoColors.erroFundo,
      title: 'Situações críticas',
      value: summary != null ? '$critCount' : '...',
      unit: 'alertas',
      subtitle: '+$warnCount pontos de atenção',
      valueColor: critCount > 0 ? ArvoColors.erro : ArvoColors.petroleo,
      isHighlighted: critCount > 0,
      onTap: () => _navigate(context, 1, AppRoutes.intelligence),
    );
  }

  Widget _buildOperationalHealthStrip(BuildContext context, dynamic summary) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: ArvoColors.superficieDestaque,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ArvoColors.linha),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            Expanded(
              child: _buildStripIndicator(
                icon: Icons.timelapse_rounded,
                label: 'Autonomia',
                value: '~${summary.averageAutonomyDays.toStringAsFixed(0)} dias',
                color: ArvoColors.petroleo,
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              color: ArvoColors.linha,
            ),
            Expanded(
              child: _buildStripIndicator(
                icon: Icons.event_busy_rounded,
                label: 'Risco Validade',
                value: Formatters.formatCompactCurrency(
                  summary.capitalAtRiskOfExpiry,
                ),
                color: summary.capitalAtRiskOfExpiry > 0
                    ? ArvoColors.erroTexto
                    : ArvoColors.sucessoTexto,
              ),
            ),
            Container(
              width: 1,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              color: ArvoColors.linha,
            ),
            Expanded(
              child: _buildStripIndicator(
                icon: Icons.savings_outlined,
                label: 'Capital ABC',
                value: Formatters.formatCompactCurrency(
                  summary.idleCapitalAmount,
                ),
                color: ArvoColors.alertaTexto,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStripIndicator({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            ExcludeSemantics(
              child: Icon(icon, size: 13, color: color),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: ArvoTypography.fontBody,
                  fontSize: 10.5,
                  fontWeight: FontWeight.w500,
                  color: ArvoColors.musgo,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: ArvoTypography.fontHeading,
            fontSize: 13.5,
            fontWeight: FontWeight.w700,
            color: color,
            fontFeatures: ArvoTypography.tabularFigures,
          ),
        ),
      ],
    );
  }

  Widget _buildConsumptionChartCard(BuildContext context) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
        border: Border.all(color: ArvoColors.linha),
        boxShadow: ArvoColors.sombraCardSuave,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Consumo Recente por Categoria',
                          style: TextStyle(
                            fontFamily: ArvoTypography.fontHeading,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: ArvoColors.petroleo,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Percentual executado vs. cota operacional da safra',
                          style: TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            fontSize: 12,
                            color: ArvoColors.musgo,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: ArvoColors.nevoa,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ArvoColors.linha),
                    ),
                    child: const Text(
                      'Últimos 30 dias',
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontHeading,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ArvoColors.petroleo,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Wrap(
                spacing: 16,
                runSpacing: 6,
                children: [
                  _buildLegendItem(
                    color: ArvoColors.folha,
                    label: 'Ritmo Planejado (< 85%)',
                  ),
                  _buildLegendItem(
                    color: ArvoColors.ambarClaro,
                    label: 'Alta Demanda / Safra (> 85%)',
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),
          Semantics(
            label:
                'Gráfico de barras de consumo por categoria nos últimos 30 dias: Fertilizantes 88%, Defensivos 92%, Combustível 78%, Sementes 55%, Irrigação 34%, Peças 42%.',
            child: SizedBox(
              height: 185,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: 100,
                  barTouchData: BarTouchData(
                    enabled: true,
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipColor: (_) => ArvoColors.petroleoProfundo,
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        const categories = [
                          'Fertilizantes',
                          'Defensivos',
                          'Combustível',
                          'Sementes',
                          'Irrigação',
                          'Peças',
                        ];
                        return BarTooltipItem(
                          '${categories[group.x.toInt()]}\n${rod.toY.toInt()}% do previsto',
                          const TextStyle(
                            color: Colors.white,
                            fontFamily: ArvoTypography.fontBody,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                            fontFeatures: ArvoTypography.tabularFigures,
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
                          const titles = [
                            'Fert',
                            'Def',
                            'Comb',
                            'Sem',
                            'Irrig',
                            'Peças',
                          ];
                          if (value.toInt() >= 0 &&
                              value.toInt() < titles.length) {
                            return Padding(
                              padding: const EdgeInsets.only(top: 8),
                              child: Text(
                                titles[value.toInt()],
                                style: const TextStyle(
                                  fontFamily: ArvoTypography.fontBody,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w500,
                                  color: ArvoColors.musgo,
                                ),
                              ),
                            );
                          }
                          return const SizedBox();
                        },
                        reservedSize: 28,
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        interval: 50,
                        reservedSize: 36,
                        getTitlesWidget: (value, meta) {
                          return Text(
                            '${value.toInt()}%',
                            style: const TextStyle(
                              fontFamily: ArvoTypography.fontBody,
                              fontSize: 10,
                              color: ArvoColors.musgo,
                              fontFeatures: ArvoTypography.tabularFigures,
                            ),
                          );
                        },
                      ),
                    ),
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: 25,
                    getDrawingHorizontalLine: (_) => const FlLine(
                      color: ArvoColors.linha,
                      strokeWidth: 1,
                      dashArray: [4, 4],
                    ),
                  ),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _makeBarGroup(0, 88, ArvoColors.folha),
                    _makeBarGroup(1, 92, ArvoColors.ambarClaro),
                    _makeBarGroup(2, 78, ArvoColors.folha),
                    _makeBarGroup(3, 55, ArvoColors.ambarClaro),
                    _makeBarGroup(4, 34, ArvoColors.folha),
                    _makeBarGroup(5, 42, ArvoColors.ambarClaro),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  BarChartGroupData _makeBarGroup(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: color,
          width: 24,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
          backDrawRodData: BackgroundBarChartRodData(
            show: true,
            toY: 100,
            color: ArvoColors.nevoa,
          ),
        ),
      ],
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontFamily: ArvoTypography.fontBody,
            fontSize: 11.5,
            color: ArvoColors.musgo,
          ),
        ),
      ],
    );
  }

  Widget _buildAbcSummaryCard(
    BuildContext context,
    List<AbcItemResult> abcItems,
    dynamic summary,
  ) {
    final isMobile = MediaQuery.sizeOf(context).width < 600;
    final classA =
        abcItems.where((i) => i.classification == AbcClass.a).toList();
    final classB =
        abcItems.where((i) => i.classification == AbcClass.b).toList();
    final classC =
        abcItems.where((i) => i.classification == AbcClass.c).toList();

    final valA = classA.fold<double>(0, (s, i) => s + i.totalValue);
    final valB = classB.fold<double>(0, (s, i) => s + i.totalValue);
    final valC = classC.fold<double>(0, (s, i) => s + i.totalValue);
    final total = (valA + valB + valC) > 0 ? (valA + valB + valC) : 1.0;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(isMobile ? 16 : 22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
        border: Border.all(color: ArvoColors.linha),
        boxShadow: ArvoColors.sombraCardSuave,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Concentração de Capital (ABC)',
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontHeading,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ArvoColors.petroleo,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Classificação de Pareto do inventário',
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        fontSize: 12,
                        color: ArvoColors.musgo,
                      ),
                    ),
                  ],
                ),
              ),
              ArvoBrandIcon(
                iconName: 'icone-financeiro',
                size: 22,
                color: ArvoColors.petroleo,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Column(
            children: [
              _buildAbcRow(
                badge: 'Classe A',
                title: '${classA.length} insumos estratégicos',
                value: Formatters.formatCurrencyCompact(valA),
                fraction: (valA / total).clamp(0.0, 1.0),
                color: ArvoColors.petroleo,
              ),
              const SizedBox(height: 16),
              _buildAbcRow(
                badge: 'Classe B',
                title: '${classB.length} insumos intermediários',
                value: Formatters.formatCurrencyCompact(valB),
                fraction: (valB / total).clamp(0.0, 1.0),
                color: ArvoColors.folha,
              ),
              const SizedBox(height: 16),
              _buildAbcRow(
                badge: 'Classe C',
                title: '${classC.length} itens de apoio',
                value: Formatters.formatCurrencyCompact(valC),
                fraction: (valC / total).clamp(0.0, 1.0),
                color: ArvoColors.ambar,
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _navigate(context, 2, AppRoutes.inventory),
              icon: const Icon(Icons.inventory_2_outlined, size: 16),
              label: const Text('Inspecionar Portfólio Completo'),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(0, 42),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAbcRow({
    required String badge,
    required String title,
    required String value,
    required double fraction,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                    decoration: BoxDecoration(
                      color: color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Text(
                      badge,
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontHeading,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: color,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        fontSize: 12,
                        color: ArvoColors.grafite,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: const TextStyle(
                fontFamily: ArvoTypography.fontHeading,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ArvoColors.petroleo,
                fontFeatures: ArvoTypography.tabularFigures,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: fraction,
            minHeight: 6,
            backgroundColor: ArvoColors.nevoa,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildQuickNavButton(
    BuildContext context, {
    required IconData icon,
    required String svgIconName,
    required Color pastelBg,
    required String label,
    required String subtitle,
    required VoidCallback onTap,
    bool isCompactHorizontal = false,
  }) {
    return Semantics(
      button: true,
      label: 'Ir para módulo $label: $subtitle',
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            constraints: BoxConstraints(
              minHeight: isCompactHorizontal ? 62 : 88,
            ),
            padding: isCompactHorizontal
                ? const EdgeInsets.symmetric(vertical: 11, horizontal: 12)
                : const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ArvoColors.linha),
            ),
            child: isCompactHorizontal
                ? Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: pastelBg,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        alignment: Alignment.center,
                        child: ArvoBrandIcon(
                          iconName: svgIconName,
                          size: 18,
                          color: ArvoColors.petroleo,
                          fallbackIcon: icon,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              label,
                              style: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: ArvoColors.petroleo,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 1),
                            Text(
                              subtitle,
                              style: const TextStyle(
                                fontFamily: ArvoTypography.fontBody,
                                fontSize: 11,
                                color: ArvoColors.musgo,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  )
                : Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 42,
                        height: 42,
                        decoration: BoxDecoration(
                          color: pastelBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        alignment: Alignment.center,
                        child: ArvoBrandIcon(
                          iconName: svgIconName,
                          size: 22,
                          color: ArvoColors.petroleo,
                          fallbackIcon: icon,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        label,
                        style: const TextStyle(
                          fontFamily: ArvoTypography.fontHeading,
                          fontSize: 12.5,
                          fontWeight: FontWeight.w600,
                          color: ArvoColors.petroleo,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: 10.5,
                          color: ArvoColors.musgo,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
