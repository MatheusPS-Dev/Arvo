import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../../../core/routes/app_routes.dart';
import '../../core/widgets/arvo_brand_graphics.dart';
import '../../core/widgets/arvo_header.dart';

class SimulationView extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const SimulationView({super.key, this.onNavigateTab});

  @override
  State<SimulationView> createState() => _SimulationViewState();
}

class _SimulationViewState extends State<SimulationView> {
  double _consumptionFactor = 1.0;
  int _leadTimeDelayDays = 0;

  void _applyScenario(double factor, int delayDays) {
    setState(() {
      _consumptionFactor = factor;
      _leadTimeDelayDays = delayDays;
    });
  }

  void _navigateToIntelligence(BuildContext context) {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(1);
    } else {
      AppRoutes.toIntelligence(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final products = vm.products;
    final runouts = vm.analysis?.runoutByProductId ?? {};

    // Calcular impacto agregado do cenário simulado
    int baseRuptureCount = 0;
    int simulatedRuptureCount = 0;
    double emergencyCapitalNeeded = 0.0;

    for (final product in products) {
      final runout = runouts[product.id];
      if (runout == null || runout.dailyConsumptionRate <= 0) continue;
      final baseDays = product.currentStock / runout.dailyConsumptionRate;
      final simRate = runout.dailyConsumptionRate * _consumptionFactor;
      final simDays = (product.currentStock / simRate) - _leadTimeDelayDays;
      if (baseDays <= 7) baseRuptureCount++;
      if (simDays <= 7) {
        simulatedRuptureCount++;
        final neededUnits =
            (simRate * 30 - product.currentStock).clamp(0.0, double.infinity);
        emergencyCapitalNeeded += neededUnits * product.averageUnitCost;
      }
    }

    final bool isModified =
        _consumptionFactor != 1.0 || _leadTimeDelayDays != 0;

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;
          final isCompactMobile = constraints.maxWidth < 600;
          final isTwoColumns = constraints.maxWidth >= 980;
          final horizontalPad = isWide ? 28.0 : 16.0;

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
                        kicker: 'ENGENHARIA DE CENÁRIOS',
                        title: 'Simulador de Cenários What-If',
                        subtitle:
                            'Projete oscilações de consumo e atrasos logísticos para antecipar compras críticas antes que a lavoura seja impactada.',
                        allowStandaloneBack: widget.onNavigateTab == null,
                        mobileTrailing: isModified
                            ? OutlinedButton.icon(
                                onPressed: () => _applyScenario(1.0, 0),
                                icon: const Icon(
                                  Icons.restart_alt_rounded,
                                  size: 15,
                                ),
                                label: const Text('Restaurar'),
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: ArvoColors.petroleo,
                                  backgroundColor: Colors.white,
                                  visualDensity: VisualDensity.compact,
                                  minimumSize: const Size(0, 34),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 10,
                                    vertical: 6,
                                  ),
                                  side: const BorderSide(
                                    color: ArvoColors.linha,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(9),
                                  ),
                                  textStyle: const TextStyle(
                                    fontFamily: ArvoTypography.fontHeading,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              )
                            : null,
                        actions: [
                          if (isModified)
                            OutlinedButton.icon(
                              onPressed: () => _applyScenario(1.0, 0),
                              icon: const Icon(
                                Icons.restart_alt_rounded,
                                size: 17,
                              ),
                              label: const Text('Restaurar Base'),
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
                            onPressed: () => _navigateToIntelligence(context),
                            icon: const Icon(
                              Icons.psychology_outlined,
                              size: 18,
                            ),
                            label:
                                const Text('Ver Diagnóstico de Inteligência'),
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

                      // 2. Painel Superior: Em Desktop (>= 980px), Controles + Card de Impacto Executivo lado a lado
                      if (isTwoColumns)
                        IntrinsicHeight(
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Expanded(
                                flex: 6,
                                child: _buildSimulationControlsCard(
                                  isCompactMobile: isCompactMobile,
                                ),
                              ),
                              const SizedBox(width: 18),
                              Expanded(
                                flex: 5,
                                child: _buildExecutiveImpactCard(
                                  baseRuptureCount: baseRuptureCount,
                                  simulatedRuptureCount: simulatedRuptureCount,
                                  emergencyCapitalNeeded:
                                      emergencyCapitalNeeded,
                                  isCompactMobile: isCompactMobile,
                                ),
                              ),
                            ],
                          ),
                        )
                      else ...[
                        _buildExecutiveImpactCard(
                          baseRuptureCount: baseRuptureCount,
                          simulatedRuptureCount: simulatedRuptureCount,
                          emergencyCapitalNeeded: emergencyCapitalNeeded,
                          isCompactMobile: isCompactMobile,
                        ),
                        const SizedBox(height: 14),
                        _buildSimulationControlsCard(
                          isCompactMobile: isCompactMobile,
                        ),
                      ],
                      const SizedBox(height: 22),

                      // 3. Tabela/Lista Comparativa de Insumos (Atual vs. Simulado)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              'PROJEÇÃO DE IMPACTO POR INSUMO',
                              style: ArvoTypography.sectionHeader,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            'ATUAL VS. SIMULADO',
                            style: ArvoTypography.kicker.copyWith(fontSize: 10),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: products.length,
                        itemBuilder: (context, index) {
                          final product = products[index];
                          final runout = runouts[product.id];
                          if (runout == null ||
                              runout.dailyConsumptionRate <= 0) {
                            return const SizedBox();
                          }

                          final baseDays = product.currentStock /
                              runout.dailyConsumptionRate;
                          final simulatedRate = runout.dailyConsumptionRate *
                              _consumptionFactor;
                          final simulatedDays =
                              (product.currentStock / simulatedRate) -
                                  _leadTimeDelayDays;
                          final bool willRupture = simulatedDays <= 5;

                          return Container(
                            margin: const EdgeInsets.only(bottom: 10),
                            padding: EdgeInsets.all(isCompactMobile ? 13 : 16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius:
                                  BorderRadius.circular(ArvoColors.radiusLg),
                              border: Border.all(
                                color: willRupture
                                    ? ArvoColors.erro.withValues(alpha: 0.5)
                                    : ArvoColors.linha,
                              ),
                              boxShadow: ArvoColors.shadowSm,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Container(
                                  width: isCompactMobile ? 36 : 40,
                                  height: isCompactMobile ? 36 : 40,
                                  padding: EdgeInsets.all(
                                    isCompactMobile ? 7 : 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.category.color
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: ArvoBrandIcon(
                                    iconName: product.category.iconName,
                                    size: isCompactMobile ? 18 : 20,
                                    color: product.category.color,
                                  ),
                                ),
                                SizedBox(width: isCompactMobile ? 10 : 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        product.name,
                                        style: TextStyle(
                                          fontFamily:
                                              ArvoTypography.fontHeading,
                                          fontWeight: FontWeight.w700,
                                          fontSize:
                                              isCompactMobile ? 14 : 14.5,
                                          color: ArvoColors.grafite,
                                        ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'Saldo: ${product.currentStock.toStringAsFixed(0)} ${product.unit} • Consumo: ${simulatedRate.toStringAsFixed(1)} ${product.unit}/d',
                                        style:
                                            ArvoTypography.numberMono.copyWith(
                                          fontSize: 11,
                                          color: ArvoColors.musgo,
                                        ),
                                      ),
                                      if (isModified)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 3),
                                          child: Text(
                                            'Base: ~${baseDays.toStringAsFixed(0)}d → Simulado: ${simulatedDays > 0 ? "~${simulatedDays.toStringAsFixed(0)}d" : "0d"}',
                                            style: ArvoTypography.numberMono
                                                .copyWith(
                                              fontSize: 11,
                                              fontWeight: FontWeight.w600,
                                              color: willRupture
                                                  ? ArvoColors.erroTexto
                                                  : ArvoColors.petroleo,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 3,
                                      ),
                                      decoration: BoxDecoration(
                                        color: willRupture
                                            ? ArvoColors.erroFundo
                                            : ArvoColors.sucessoFundo,
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        simulatedDays > 0
                                            ? '~${simulatedDays.toStringAsFixed(0)} dias'
                                            : 'ESGOTADO',
                                        style:
                                            ArvoTypography.numberMono.copyWith(
                                          fontWeight: FontWeight.w700,
                                          fontSize:
                                              isCompactMobile ? 12 : 13,
                                          color: willRupture
                                              ? ArvoColors.erroTexto
                                              : ArvoColors.sucessoTexto,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    Text(
                                      simulatedDays > 0
                                          ? 'de autonomia'
                                          : 'Ruptura na lavoura',
                                      style: TextStyle(
                                        fontFamily: ArvoTypography.fontBody,
                                        fontSize: 10.5,
                                        fontWeight: FontWeight.w600,
                                        color: willRupture
                                            ? ArvoColors.erroTexto
                                            : ArvoColors.musgo,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 36),
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

  Widget _buildExecutiveImpactCard({
    required int baseRuptureCount,
    required int simulatedRuptureCount,
    required double emergencyCapitalNeeded,
    bool isCompactMobile = false,
  }) {
    return Container(
      padding: EdgeInsets.all(isCompactMobile ? 16 : 22),
      decoration: BoxDecoration(
        gradient: ArvoColors.gradienteHeroPetroleo,
        borderRadius: BorderRadius.circular(20),
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
                children: [
                  Container(
                    width: isCompactMobile ? 38 : 42,
                    height: isCompactMobile ? 38 : 42,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ArvoBrandIcon(
                      iconName: 'icone-clima',
                      size: isCompactMobile ? 20 : 22,
                      color: ArvoColors.ambarClaro,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'LABORATÓRIO PREDITIVO DE SAFRA',
                          style: ArvoTypography.kicker.copyWith(
                            color: ArvoColors.ambarClaro,
                            fontSize: isCompactMobile ? 10 : 11,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          'Antecipação de Cenários Futuros',
                          style: TextStyle(
                            fontFamily: ArvoTypography.fontHeading,
                            fontSize: isCompactMobile ? 16.5 : 18,
                            fontWeight: FontWeight.w700,
                            color: ArvoColors.nevoa,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                'Simule variações no ritmo de aplicação ou atrasos na cadeia de suprimentos para planejar compras com semanas de antecedência antes que a safra seja afetada.',
                style: TextStyle(
                  fontFamily: ArvoTypography.fontBody,
                  fontSize: isCompactMobile ? 12 : 13,
                  color: ArvoColors.nevoa.withValues(alpha: 0.85),
                  height: 1.4,
                ),
              ),
            ],
          ),
          SizedBox(height: isCompactMobile ? 14 : 18),
          Container(
            padding: EdgeInsets.all(isCompactMobile ? 12 : 14),
            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.22),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Itens Críticos (≤ 7 dias)',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: isCompactMobile ? 11 : 11.5,
                          color: ArvoColors.nevoa.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '$baseRuptureCount atual → $simulatedRuptureCount simulado',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArvoTypography.numberMono.copyWith(
                          fontSize: isCompactMobile ? 13.5 : 15,
                          fontWeight: FontWeight.w700,
                          color: simulatedRuptureCount > baseRuptureCount
                              ? ArvoColors.ambarClaro
                              : ArvoColors.folhaClara,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  width: 1,
                  height: 32,
                  margin: EdgeInsets.symmetric(
                    horizontal: isCompactMobile ? 10 : 14,
                  ),
                  color: Colors.white.withValues(alpha: 0.15),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Reposição de Emergência',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: isCompactMobile ? 11 : 11.5,
                          color: ArvoColors.nevoa.withValues(alpha: 0.78),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        Formatters.formatCompactCurrency(
                          emergencyCapitalNeeded,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArvoTypography.numberMono.copyWith(
                          fontSize: isCompactMobile ? 13.5 : 15,
                          fontWeight: FontWeight.w700,
                          color: ArvoColors.nevoa,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSimulationControlsCard({bool isCompactMobile = false}) {
    return Container(
      padding: EdgeInsets.all(isCompactMobile ? 16 : 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
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
              const Text(
                'CENÁRIOS PRÉ-CONFIGURADOS (1 CLIQUE)',
                style: ArvoTypography.kicker,
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildPresetChip(
                      label: 'Cenário Base (100% / 0d)',
                      factor: 1.0,
                      delay: 0,
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: 'Surto de Praga (+40% / 0d)',
                      factor: 1.4,
                      delay: 0,
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: 'Crise Logística (+20% / +10d)',
                      factor: 1.2,
                      delay: 10,
                    ),
                    const SizedBox(width: 8),
                    _buildPresetChip(
                      label: 'Estresse Severo (+80% / +15d)',
                      factor: 1.8,
                      delay: 15,
                    ),
                  ],
                ),
              ),
              const Divider(height: 24, color: ArvoColors.linha),
            ],
          ),

          // Slider 1: Aceleração no Ritmo de Consumo
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Aceleração no Ritmo de Consumo:',
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontHeading,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _consumptionFactor > 1.0
                          ? ArvoColors.erroFundo
                          : ArvoColors.sucessoFundo,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      _consumptionFactor == 1.0
                          ? 'Normal (100%)'
                          : '+${((_consumptionFactor - 1.0) * 100).toStringAsFixed(0)}% de consumo',
                      style: ArvoTypography.numberMono.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _consumptionFactor > 1.0
                            ? ArvoColors.erroTexto
                            : ArvoColors.sucessoTexto,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Reduzir ritmo de consumo em 10%',
                    onPressed: _consumptionFactor > 1.0
                        ? () => setState(() {
                              _consumptionFactor =
                                  ((_consumptionFactor - 0.1) * 10).round() /
                                      10.0;
                            })
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: ArvoColors.petroleo,
                  ),
                  Expanded(
                    child: Slider(
                      value: _consumptionFactor,
                      min: 1.0,
                      max: 2.0,
                      divisions: 10,
                      activeColor: _consumptionFactor > 1.0
                          ? ArvoColors.erro
                          : ArvoColors.folha,
                      onChanged: (val) {
                        setState(() => _consumptionFactor = val);
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Aumentar ritmo de consumo em 10%',
                    onPressed: _consumptionFactor < 2.0
                        ? () => setState(() {
                              _consumptionFactor =
                                  ((_consumptionFactor + 0.1) * 10).round() /
                                      10.0;
                            })
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: ArvoColors.petroleo,
                  ),
                ],
              ),
              const Divider(height: 16, color: ArvoColors.linha),

              // Slider 2: Atraso na Entrega de Fornecedores
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Atraso na Entrega de Fornecedores:',
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontHeading,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: _leadTimeDelayDays > 0
                          ? ArvoColors.alertaFundo
                          : ArvoColors.sucessoFundo,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      '$_leadTimeDelayDays dias de atraso',
                      style: ArvoTypography.numberMono.copyWith(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: _leadTimeDelayDays > 0
                            ? ArvoColors.alertaTexto
                            : ArvoColors.sucessoTexto,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  IconButton(
                    tooltip: 'Reduzir atraso em 5 dias',
                    onPressed: _leadTimeDelayDays > 0
                        ? () => setState(() {
                              _leadTimeDelayDays =
                                  (_leadTimeDelayDays - 5).clamp(0, 30);
                            })
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                    color: ArvoColors.petroleo,
                  ),
                  Expanded(
                    child: Slider(
                      value: _leadTimeDelayDays.toDouble(),
                      min: 0,
                      max: 30,
                      divisions: 6,
                      activeColor: ArvoColors.ambar,
                      onChanged: (val) {
                        setState(() => _leadTimeDelayDays = val.toInt());
                      },
                    ),
                  ),
                  IconButton(
                    tooltip: 'Aumentar atraso em 5 dias',
                    onPressed: _leadTimeDelayDays < 30
                        ? () => setState(() {
                              _leadTimeDelayDays =
                                  (_leadTimeDelayDays + 5).clamp(0, 30);
                            })
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                    color: ArvoColors.petroleo,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPresetChip({
    required String label,
    required double factor,
    required int delay,
  }) {
    final isSelected = (_consumptionFactor - factor).abs() < 0.01 &&
        _leadTimeDelayDays == delay;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => _applyScenario(factor, delay),
      selectedColor: ArvoColors.petroleo,
      backgroundColor: ArvoColors.nevoa,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily: ArvoTypography.fontBody,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? Colors.white : ArvoColors.grafite,
      ),
      side: BorderSide(
        color: isSelected ? ArvoColors.petroleo : ArvoColors.linha,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ArvoColors.radiusPill),
      ),
    );
  }
}
