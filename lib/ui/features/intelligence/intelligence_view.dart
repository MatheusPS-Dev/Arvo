import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../data/models/alert_model.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../core/widgets/arvo_alert_card.dart';
import '../../../../core/routes/app_routes.dart';

class IntelligenceView extends StatefulWidget {
  const IntelligenceView({super.key});

  @override
  State<IntelligenceView> createState() => _IntelligenceViewState();
}

class _IntelligenceViewState extends State<IntelligenceView> {
  AlertType? _selectedTypeFilter;
  AlertSeverity? _selectedSeverityFilter;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final analysis = vm.analysis;
    final summary = vm.summary;

    if (analysis == null) {
      return const Scaffold(
        backgroundColor: ArvoColors.nevoa,
        body: Center(child: CircularProgressIndicator(color: ArvoColors.petroleo)),
      );
    }

    var alerts = analysis.allAlerts;

    if (_selectedSeverityFilter != null) {
      alerts = alerts.where((a) => a.severity == _selectedSeverityFilter).toList();
    }

    if (_selectedTypeFilter != null) {
      alerts = alerts.where((a) => a.type == _selectedTypeFilter).toList();
    }

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      appBar: AppBar(
        title: const Text('Central de Inteligência'),
        backgroundColor: ArvoColors.petroleo,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune_rounded, color: ArvoColors.nevoa),
            tooltip: 'Simulador What-If',
            onPressed: () => AppRoutes.toSimulation(context),
          ),
          IconButton(
            icon: const Icon(Icons.analytics_outlined, color: ArvoColors.nevoa),
            tooltip: 'Reanalisar Estoque',
            onPressed: () {
              vm.reanalyze();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Reanálise de estoque e padrões concluída!'),
                  backgroundColor: ArvoColors.petroleo,
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Resumo Executivo de Riscos e Capital
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [ArvoColors.petroleo, ArvoColors.petroleoProfundo],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'DIAGNÓSTICO GERAL DA SAFRA',
                    style: TextStyle(
                      fontFamily: ArvoTypography.fontHeading,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: ArvoColors.folhaClara,
                      letterSpacing: 1.0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    summary != null && summary.criticalAlertsCount > 0
                        ? '${summary.criticalAlertsCount} pontos críticos exigem ação imediata'
                        : 'Estoque operando com estabilidade',
                    style: const TextStyle(
                      fontFamily: ArvoTypography.fontHeading,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: _buildRiskBadge(
                          label: 'Risco de Vencimento',
                          value: Formatters.formatCurrency(summary?.capitalAtRiskOfExpiry ?? 0),
                          color: ArvoColors.erro,
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: _buildRiskBadge(
                          label: 'Capital Ocioso (ABC)',
                          value: Formatters.formatCurrency(summary?.idleCapitalAmount ?? 0),
                          color: ArvoColors.ambarClaro,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Filtro por Severidade (Triagem)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildSeverityFilterChip(null, 'Todos (${analysis.allAlerts.length})'),
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
            const SizedBox(height: 12),

            // Filtro por Tipo de Diagnóstico do Desafio
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildTypeChip(null, 'Todos os Tipos'),
                  const SizedBox(width: 8),
                  _buildTypeChip(AlertType.ruptura, 'Ruptura / Falta'),
                  const SizedBox(width: 8),
                  _buildTypeChip(AlertType.vencimento, 'Validade vs Consumo'),
                  const SizedBox(width: 8),
                  _buildTypeChip(AlertType.anomalia, 'Anomalias'),
                  const SizedBox(width: 8),
                  _buildTypeChip(AlertType.curvaAbc, 'Curva ABC'),
                  const SizedBox(width: 8),
                  _buildTypeChip(AlertType.variacaoPreco, 'Variação de Preço'),
                  const SizedBox(width: 8),
                  _buildTypeChip(AlertType.duplicidade, 'Inconsistência Cadastral'),
                ],
              ),
            ),
            const SizedBox(height: 18),

            // Lista de Alertas Inteligentes
            if (alerts.isEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: ArvoColors.linha),
                ),
                child: const Column(
                  children: [
                    Icon(Icons.check_circle_outline, size: 48, color: ArvoColors.folha),
                    SizedBox(height: 12),
                    Text(
                      'Nenhum alerta para o filtro selecionado.',
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontHeading,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: ArvoColors.petroleo,
                      ),
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
                    alert: alert,
                    actionLabel: _getActionLabel(alert.type),
                    onAction: () => _handleAlertAction(context, alert, vm),
                  );
                },
              ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildRiskBadge({
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontFamily: ArvoTypography.fontBody,
              fontSize: 11,
              color: ArvoColors.nevoa,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: TextStyle(
              fontFamily: ArvoTypography.fontHeading,
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeverityFilterChip(AlertSeverity? severity, String label, {Color? color}) {
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
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily: ArvoTypography.fontBody,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
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
      selectedColor: ArvoColors.petroleo.withValues(alpha: 0.12),
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily: ArvoTypography.fontBody,
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

  void _handleAlertAction(BuildContext context, AlertModel alert, StockIntelligenceViewModel vm) {
    if (alert.type == AlertType.duplicidade) {
      _showMergeDialog(context, alert, vm);
    } else {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Text(alert.title, style: const TextStyle(fontFamily: ArvoTypography.fontHeading)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ação recomendada pelo Arvô:',
                style: const TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontWeight: FontWeight.w600,
                  color: ArvoColors.petroleo,
                ),
              ),
              const SizedBox(height: 6),
              Text(alert.recommendedAction, style: const TextStyle(fontFamily: ArvoTypography.fontBody)),
              const SizedBox(height: 16),
              Text(
                'Justificativa Técnica:',
                style: const TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontWeight: FontWeight.w600,
                  color: ArvoColors.petroleo,
                ),
              ),
              const SizedBox(height: 6),
              Text(alert.reasonExplanation, style: const TextStyle(fontFamily: ArvoTypography.fontBody)),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
    }
  }

  void _showMergeDialog(BuildContext context, AlertModel alert, StockIntelligenceViewModel vm) {
    final duplicates = vm.analysis?.duplicates ?? [];
    if (duplicates.isEmpty) return;

    final candidate = duplicates.firstWhere(
      (d) => d.productA.id == alert.affectedProductId || d.productB.id == alert.affectedProductId,
      orElse: () => duplicates.first,
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Unificar Insumos Duplicados',
          style: TextStyle(fontFamily: ArvoTypography.fontHeading),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'O motor de inteligência identificou dois cadastros para o mesmo produto:',
              style: TextStyle(fontFamily: ArvoTypography.fontBody),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: ArvoColors.nevoa,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('1. ${candidate.productA.name} (${candidate.productA.currentStock.toStringAsFixed(0)} ${candidate.productA.unit})'),
                  const SizedBox(height: 4),
                  Text('2. ${candidate.productB.name} (${candidate.productB.currentStock.toStringAsFixed(0)} ${candidate.productB.unit})'),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Nome unificado sugerido: "${candidate.suggestedUnifiedName}"',
              style: const TextStyle(
                fontFamily: ArvoTypography.fontBody,
                fontWeight: FontWeight.w600,
                color: ArvoColors.folha,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Os saldos físicos e históricos de movimentação serão consolidados automaticamente.',
              style: TextStyle(fontFamily: ArvoTypography.fontBody, fontSize: 12, color: ArvoColors.musgo),
            ),
          ],
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
                  content: Text('Insumos unificados sob "${candidate.suggestedUnifiedName}" com sucesso!'),
                  backgroundColor: ArvoColors.folha,
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
