import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../data/models/alert_model.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../core/widgets/arvo_alert_card.dart';
import '../../core/widgets/arvo_brand_graphics.dart';
import '../../core/widgets/arvo_header.dart';
import '../../../../core/routes/app_routes.dart';

class IntelligenceView extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const IntelligenceView({super.key, this.onNavigateTab});

  @override
  State<IntelligenceView> createState() => _IntelligenceViewState();
}

class _IntelligenceViewState extends State<IntelligenceView> {
  AlertType? _selectedTypeFilter;
  AlertSeverity? _selectedSeverityFilter;

  void _navigateToSimulation(BuildContext context) {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(4);
    } else {
      AppRoutes.toSimulation(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final analysis = vm.analysis;
    final summary = vm.summary;

    if (analysis == null) {
      return const Scaffold(
        backgroundColor: ArvoColors.nevoa,
        body: Center(
          child: CircularProgressIndicator(color: ArvoColors.petroleo),
        ),
      );
    }

    var alerts = analysis.allAlerts;

    if (_selectedSeverityFilter != null) {
      alerts =
          alerts.where((a) => a.severity == _selectedSeverityFilter).toList();
    }

    if (_selectedTypeFilter != null) {
      alerts = alerts.where((a) => a.type == _selectedTypeFilter).toList();
    }

    final duplicates = analysis.duplicates;

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;
          final isCompact = constraints.maxWidth < 640;
          final isNarrowMobile = constraints.maxWidth < 480;
          final horizontalPad = isWide ? 28.0 : 16.0;

          void triggerReanalyze() {
            vm.reanalyze();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Reanálise de estoque e padrões concluída!',
                ),
                backgroundColor: ArvoColors.petroleo,
                duration: Duration(seconds: 1),
              ),
            );
          }

          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1240),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 1. Page Header Editorial Limpo (sem AppBar Petróleo duplicada)
                      ArvoPageHeader(
                        kicker: 'INTELIGÊNCIA PREDITIVA',
                        title: 'Central de Inteligência',
                        subtitle:
                            'Diagnóstico explicável em tempo real para antecipação de rupturas, perdas por validade e desvios estatísticos.',
                        allowStandaloneBack: widget.onNavigateTab == null,
                        mobileTrailing: OutlinedButton.icon(
                          onPressed: triggerReanalyze,
                          icon: const Icon(
                            Icons.refresh_rounded,
                            size: 15,
                          ),
                          label: const Text('Reanalisar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: ArvoColors.petroleo,
                            backgroundColor: Colors.white,
                            visualDensity: VisualDensity.compact,
                            minimumSize: const Size(0, 34),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            side: const BorderSide(color: ArvoColors.linha),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(9),
                            ),
                            textStyle: const TextStyle(
                              fontFamily: ArvoTypography.fontHeading,
                              fontSize: 11.5,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        actions: [
                          OutlinedButton.icon(
                            onPressed: triggerReanalyze,
                            icon: const Icon(
                              Icons.analytics_outlined,
                              size: 17,
                            ),
                            label: const Text('Reanalisar Estoque'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ArvoColors.petroleo,
                              backgroundColor: Colors.white,
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              side: const BorderSide(color: ArvoColors.linha),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _navigateToSimulation(context),
                            icon: const Icon(Icons.tune_rounded, size: 17),
                            label: const Text('Simulador What-If'),
                            style: FilledButton.styleFrom(
                              backgroundColor: ArvoColors.petroleo,
                              foregroundColor: ArvoColors.nevoa,
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),

                      // 2. Card Executivo de Diagnóstico contido no Grid (borderRadius: 20)
                      Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          gradient: ArvoColors.gradienteHeroPetroleo,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: ArvoColors.sombraCardSuave,
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Stack(
                            children: [
                              Positioned(
                                right: -25,
                                top: -20,
                                child: IgnorePointer(
                                  child: ArvoSymbol(
                                    size: 170,
                                    monochromeColor: ArvoColors
                                        .petroleoMarcaDagua
                                        .withValues(alpha: 0.45),
                                  ),
                                ),
                              ),
                              const Positioned(
                                left: 0,
                                right: 0,
                                bottom: -10,
                                child: ArvoHorizonArcs(
                                  strokeColor: ArvoColors.sucesso,
                                  maxOpacity: 0.30,
                                  height: 70,
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(isWide ? 22 : 16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 8,
                                            vertical: 3,
                                          ),
                                          decoration: BoxDecoration(
                                            color: ArvoColors.folhaClara
                                                .withValues(alpha: 0.18),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                            border: Border.all(
                                              color: ArvoColors.folhaClara
                                                  .withValues(alpha: 0.35),
                                            ),
                                          ),
                                          child: const Text(
                                            'DIAGNÓSTICO GERAL DA SAFRA',
                                            style: TextStyle(
                                              fontFamily:
                                                  ArvoTypography.fontHeading,
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: ArvoColors.folhaClara,
                                              letterSpacing: 1.0,
                                            ),
                                          ),
                                        ),
                                        const Spacer(),
                                        Text(
                                          '${analysis.allAlerts.length} ocorrências ativas',
                                          style: const TextStyle(
                                            fontFamily: ArvoTypography.fontBody,
                                            fontSize: 11.5,
                                            color: Color(0xFFBDD0C7),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      summary != null &&
                                              summary.criticalAlertsCount > 0
                                          ? '${summary.criticalAlertsCount} pontos críticos exigem ação imediata'
                                          : 'Estoque operando com estabilidade',
                                      style: TextStyle(
                                        fontFamily: ArvoTypography.fontHeading,
                                        fontSize: isWide ? 22 : 18.5,
                                        fontWeight: FontWeight.w700,
                                        color: ArvoColors.nevoa,
                                        letterSpacing: -0.3,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Monitoramento contínuo por 6 motores matemáticos: ruptura preditiva, validade FEFO vs. consumo, desvios (> 2σ), Curva ABC, inflação de custos e deduplicação cadastral.',
                                      style: TextStyle(
                                        fontFamily: ArvoTypography.fontBody,
                                        fontSize: isWide ? 13 : 12,
                                        color: const Color(0xFFCEE0D7),
                                        height: 1.4,
                                      ),
                                    ),
                                    const SizedBox(height: 14),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: _buildRiskBadge(
                                            label: 'Risco de Vencimento',
                                            value: isNarrowMobile
                                                ? Formatters
                                                    .formatCompactCurrency(
                                                    summary?.capitalAtRiskOfExpiry ??
                                                        0,
                                                  )
                                                : Formatters.formatCurrency(
                                                    summary?.capitalAtRiskOfExpiry ??
                                                        0,
                                                  ),
                                            color: const Color(0xFFFF8A78),
                                            icon: Icons.event_busy_rounded,
                                            isCompact: isNarrowMobile,
                                          ),
                                        ),
                                        SizedBox(
                                          width: isNarrowMobile ? 8 : 12,
                                        ),
                                        Expanded(
                                          child: _buildRiskBadge(
                                            label: 'Capital Ocioso (ABC)',
                                            value: isNarrowMobile
                                                ? Formatters
                                                    .formatCompactCurrency(
                                                    summary?.idleCapitalAmount ??
                                                        0,
                                                  )
                                                : Formatters.formatCurrency(
                                                    summary?.idleCapitalAmount ??
                                                        0,
                                                  ),
                                            color: ArvoColors.ambarClaro,
                                            icon: Icons
                                                .pie_chart_outline_rounded,
                                            isCompact: isNarrowMobile,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      // 3. Destaque Acionável de Deduplicação Cadastral (quando houver duplicatas)
                      if (duplicates.isNotEmpty) ...[
                        Container(
                          width: double.infinity,
                          padding: EdgeInsets.all(isCompact ? 14 : 16),
                          decoration: BoxDecoration(
                            color: ArvoColors.infoFundo,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ArvoColors.infoBorda),
                          ),
                          child: isCompact
                              ? Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius:
                                                BorderRadius.circular(10),
                                          ),
                                          child: const Icon(
                                            Icons.merge_type_rounded,
                                            color: ArvoColors.infoTexto,
                                            size: 19,
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                '${duplicates.length} inconsistência(s) cadastral(is) detectada(s) por similaridade fonética/textual',
                                                style: const TextStyle(
                                                  fontFamily: ArvoTypography
                                                      .fontHeading,
                                                  fontSize: 13,
                                                  fontWeight: FontWeight.w700,
                                                  color: ArvoColors.infoTexto,
                                                ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                'Ex: "${duplicates.first.productA.name}" e "${duplicates.first.productB.name}" podem ser unificados.',
                                                style: const TextStyle(
                                                  fontFamily:
                                                      ArvoTypography.fontBody,
                                                  fontSize: 12,
                                                  color: ArvoColors.grafite,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: () {
                                          final dupAlert =
                                              analysis.allAlerts.firstWhere(
                                            (a) =>
                                                a.type == AlertType.duplicidade,
                                            orElse: () =>
                                                analysis.allAlerts.first,
                                          );
                                          _showMergeDialog(
                                            context,
                                            dupAlert,
                                            vm,
                                          );
                                        },
                                        icon: const Icon(
                                          Icons.merge_rounded,
                                          size: 16,
                                        ),
                                        label:
                                            const Text('Revisar & Unificar'),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: ArvoColors.infoTexto,
                                          foregroundColor: Colors.white,
                                          minimumSize: const Size(0, 40),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 14,
                                            vertical: 10,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.all(9),
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      child: const Icon(
                                        Icons.merge_type_rounded,
                                        color: ArvoColors.infoTexto,
                                        size: 20,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${duplicates.length} inconsistência(s) cadastral(is) detectada(s) por similaridade fonética/textual',
                                            style: const TextStyle(
                                              fontFamily:
                                                  ArvoTypography.fontHeading,
                                              fontSize: 13.5,
                                              fontWeight: FontWeight.w700,
                                              color: ArvoColors.infoTexto,
                                            ),
                                          ),
                                          Text(
                                            'Ex: "${duplicates.first.productA.name}" e "${duplicates.first.productB.name}" podem ser unificados.',
                                            style: const TextStyle(
                                              fontFamily:
                                                  ArvoTypography.fontBody,
                                              fontSize: 12,
                                              color: ArvoColors.grafite,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ElevatedButton(
                                      onPressed: () {
                                        final dupAlert =
                                            analysis.allAlerts.firstWhere(
                                          (a) =>
                                              a.type == AlertType.duplicidade,
                                          orElse: () =>
                                              analysis.allAlerts.first,
                                        );
                                        _showMergeDialog(context, dupAlert, vm);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: ArvoColors.infoTexto,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size(0, 40),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 14,
                                          vertical: 10,
                                        ),
                                      ),
                                      child: const Text('Revisar & Unificar'),
                                    ),
                                  ],
                                ),
                        ),
                        const SizedBox(height: 16),
                      ],

                      // 4. Barra de Ferramentas Limpa (6 Motores Matemáticos + Severidade em Superfície Branca)
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(isWide ? 16 : 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ArvoColors.linha),
                          boxShadow: ArvoColors.sombraCardSuave,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Expanded(
                                  child: Text(
                                    'TRIAGEM POR PRIORIDADE & MOTOR ANALÍTICO',
                                    style: ArvoTypography.kicker,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                if (_selectedSeverityFilter != null ||
                                    _selectedTypeFilter != null)
                                  TextButton.icon(
                                    onPressed: () {
                                      setState(() {
                                        _selectedSeverityFilter = null;
                                        _selectedTypeFilter = null;
                                      });
                                    },
                                    icon: const Icon(
                                      Icons.filter_alt_off_rounded,
                                      size: 15,
                                    ),
                                    label: const Text('Limpar Filtros'),
                                    style: TextButton.styleFrom(
                                      visualDensity: VisualDensity.compact,
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildSeverityFilterChip(
                                    null,
                                    'Todos (${analysis.allAlerts.length})',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSeverityFilterChip(
                                    AlertSeverity.critico,
                                    'Críticos (${analysis.criticalAlerts.length})',
                                    color: ArvoColors.erro,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSeverityFilterChip(
                                    AlertSeverity.atencao,
                                    'Atenção (${analysis.warningAlerts.length})',
                                    color: ArvoColors.alerta,
                                  ),
                                  const SizedBox(width: 8),
                                  _buildSeverityFilterChip(
                                    AlertSeverity.info,
                                    'Informativos (${analysis.infoAlerts.length})',
                                    color: ArvoColors.info,
                                  ),
                                ],
                              ),
                            ),
                            const Divider(height: 20, color: ArvoColors.linha),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildTypeChip(null, 'Todos os 6 Motores'),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(
                                    AlertType.ruptura,
                                    'Ruptura / Falta',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(
                                    AlertType.vencimento,
                                    'Validade vs Consumo',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(
                                    AlertType.anomalia,
                                    'Anomalias (2σ)',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(
                                    AlertType.curvaAbc,
                                    'Curva ABC',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(
                                    AlertType.variacaoPreco,
                                    'Variação de Preço',
                                  ),
                                  const SizedBox(width: 8),
                                  _buildTypeChip(
                                    AlertType.duplicidade,
                                    'Inconsistência Cadastral',
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 18),

                      // 5. Lista de Alertas Inteligentes Explicáveis
                      if (alerts.isEmpty)
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(32),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ArvoColors.linha),
                          ),
                          child: Column(
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 48,
                                color: ArvoColors.folha,
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Nenhum alerta para o filtro selecionado.',
                                style: TextStyle(
                                  fontFamily: ArvoTypography.fontHeading,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: ArvoColors.petroleo,
                                ),
                              ),
                              const SizedBox(height: 8),
                              if (_selectedSeverityFilter != null ||
                                  _selectedTypeFilter != null)
                                TextButton.icon(
                                  onPressed: () {
                                    setState(() {
                                      _selectedSeverityFilter = null;
                                      _selectedTypeFilter = null;
                                    });
                                  },
                                  icon: const Icon(
                                    Icons.filter_alt_off_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Limpar Filtros'),
                                ),
                            ],
                          ),
                        )
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return ArvoAlertCard(
                              key: ValueKey(alert.id),
                              alert: alert,
                              actionLabel: _getActionLabel(alert.type),
                              onAction: () =>
                                  _handleAlertAction(context, alert, vm),
                            );
                          },
                        ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildRiskBadge({
    required String label,
    required String value,
    required Color color,
    required IconData icon,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 14,
        vertical: isCompact ? 9 : 10,
      ),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
      ),
      child: Row(
        children: [
          ExcludeSemantics(
            child: Icon(icon, size: isCompact ? 16 : 18, color: color),
          ),
          SizedBox(width: isCompact ? 7 : 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: ArvoTypography.fontBody,
                    fontSize: isCompact ? 10.5 : 11,
                    color: ArvoColors.nevoa,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: ArvoTypography.fontHeading,
                    fontSize: isCompact ? 13.5 : 15,
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontFeatures: ArvoTypography.tabularFigures,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityFilterChip(
    AlertSeverity? severity,
    String label, {
    Color? color,
  }) {
    final isSelected = _selectedSeverityFilter == severity;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedSeverityFilter = selected ? severity : null;
        });
      },
      selectedColor: color ?? ArvoColors.petroleo,
      backgroundColor: ArvoColors.nevoa,
      labelStyle: TextStyle(
        fontFamily:
            isSelected ? ArvoTypography.fontHeading : ArvoTypography.fontBody,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? Colors.white : (color ?? ArvoColors.grafite),
      ),
      side: BorderSide(
        color: isSelected ? (color ?? ArvoColors.petroleo) : ArvoColors.linha,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  Widget _buildTypeChip(AlertType? type, String label) {
    final isSelected = _selectedTypeFilter == type;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedTypeFilter = selected ? type : null;
        });
      },
      selectedColor: ArvoColors.superficieDestaque,
      checkmarkColor: ArvoColors.petroleo,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily:
            isSelected ? ArvoTypography.fontHeading : ArvoTypography.fontBody,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? ArvoColors.petroleo : ArvoColors.musgo,
      ),
      side: BorderSide(
        color: isSelected ? ArvoColors.petroleo : ArvoColors.linha,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }

  String _getActionLabel(AlertType type) {
    switch (type) {
      case AlertType.duplicidade:
        return 'Unificar';
      case AlertType.ruptura:
        return 'Pedir Compra';
      case AlertType.vencimento:
        return 'Remanejar';
      case AlertType.anomalia:
        return 'Investigar';
      case AlertType.curvaAbc:
        return 'Reavaliar';
      case AlertType.variacaoPreco:
        return 'Auditar';
    }
  }

  void _handleAlertAction(
    BuildContext context,
    AlertModel alert,
    StockIntelligenceViewModel vm,
  ) {
    if (alert.type == AlertType.duplicidade) {
      _showMergeDialog(context, alert, vm);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: Row(
            children: [
              Icon(alert.severity.icon, color: alert.severity.color, size: 22),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  alert.title,
                  style: const TextStyle(
                    fontFamily: ArvoTypography.fontHeading,
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 460),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: ArvoColors.nevoa,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ArvoColors.linha),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'JUSTIFICATIVA TÉCNICA EXPLICÁVEL',
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontHeading,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w700,
                          color: ArvoColors.petroleo,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        alert.reasonExplanation,
                        style: const TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: 13,
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Plano de Ação Recomendado pelo Arvô:',
                  style: TextStyle(
                    fontFamily: ArvoTypography.fontHeading,
                    fontWeight: FontWeight.w600,
                    color: ArvoColors.petroleo,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  alert.recommendedAction,
                  style: const TextStyle(
                    fontFamily: ArvoTypography.fontBody,
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Fechar'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  void _showMergeDialog(
    BuildContext context,
    AlertModel alert,
    StockIntelligenceViewModel vm,
  ) {
    final duplicates = vm.analysis?.duplicates ?? [];
    if (duplicates.isEmpty) return;

    final candidate = duplicates.firstWhere(
      (d) =>
          d.productA.id == alert.affectedProductId ||
          d.productB.id == alert.affectedProductId,
      orElse: () => duplicates.first,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        title: const Text(
          'Unificar Insumos Duplicados',
          style: TextStyle(fontFamily: ArvoTypography.fontHeading),
        ),
        content: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 460),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'O motor de inteligência identificou dois cadastros para o mesmo produto:',
                style: TextStyle(fontFamily: ArvoTypography.fontBody),
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: ArvoColors.nevoa,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: ArvoColors.linha),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '1. ${candidate.productA.name} (${candidate.productA.currentStock.toStringAsFixed(0)} ${candidate.productA.unit})',
                      style: const TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '2. ${candidate.productB.name} (${candidate.productB.currentStock.toStringAsFixed(0)} ${candidate.productB.unit})',
                      style: const TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Nome unificado sugerido: "${candidate.suggestedUnifiedName}"',
                style: const TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontWeight: FontWeight.w700,
                  color: ArvoColors.sucessoTexto,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Os saldos físicos, lotes e históricos de movimentação serão consolidados automaticamente.',
                style: TextStyle(
                  fontFamily: ArvoTypography.fontBody,
                  fontSize: 12,
                  color: ArvoColors.musgo,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              vm.unifyProducts(
                candidate.productA.id,
                candidate.productB.id,
                candidate.suggestedUnifiedName,
              );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Insumos unificados sob "${candidate.suggestedUnifiedName}" com sucesso!',
                  ),
                  backgroundColor: ArvoColors.sucesso,
                ),
              );
            },
            child: const Text('Confirmar Unificação'),
          ),
        ],
      ),
    );
  }
}
