import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../../../core/routes/app_routes.dart';

class SimulationView extends StatefulWidget {
  const SimulationView({super.key});

  @override
  State<SimulationView> createState() => _SimulationViewState();
}

class _SimulationViewState extends State<SimulationView> {
  double _consumptionFactor = 1.0;
  int _leadTimeDelayDays = 0;

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final products = vm.products;
    final runouts = vm.analysis?.runoutByProductId ?? {};

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      appBar: AppBar(
        title: const Text('Simulador de Cenários What-If'),
        backgroundColor: ArvoColors.petroleo,
        actions: [
          IconButton(
            icon: const Icon(Icons.psychology_outlined),
            tooltip: 'Ver Diagnóstico de Inteligência',
            onPressed: () => AppRoutes.toIntelligence(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Card de Introdução
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ArvoColors.linha),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_graph_rounded, color: ArvoColors.ambar, size: 24),
                      SizedBox(width: 8),
                      Text(
                        'Antecipação de Cenários Futuros',
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontHeading,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ArvoColors.petroleo,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Simule variações no ritmo de aplicação ou atrasos na cadeia de suprimentos para planejar compras com semanas de antecedência antes que a safra seja afetada.',
                    style: TextStyle(
                      fontFamily: ArvoTypography.fontBody,
                      fontSize: 13,
                      color: ArvoColors.musgo,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Controles de Simulação
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: ArvoColors.linha),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aceleração no Ritmo de Consumo:',
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontHeading,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        _consumptionFactor == 1.0
                            ? 'Normal (100%)'
                            : '+${((_consumptionFactor - 1.0) * 100).toStringAsFixed(0)}% de consumo',
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontHeading,
                          fontWeight: FontWeight.w700,
                          color: _consumptionFactor > 1.0 ? ArvoColors.erro : ArvoColors.petroleo,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _consumptionFactor,
                    min: 1.0,
                    max: 2.0,
                    divisions: 10,
                    activeColor: _consumptionFactor > 1.0 ? ArvoColors.erro : ArvoColors.folha,
                    onChanged: (val) {
                      setState(() => _consumptionFactor = val);
                    },
                  ),
                  const SizedBox(height: 14),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Atraso na Entrega de Fornecedores:',
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontHeading,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        '$_leadTimeDelayDays dias de atraso',
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontHeading,
                          fontWeight: FontWeight.w700,
                          color: _leadTimeDelayDays > 0 ? ArvoColors.alerta : ArvoColors.petroleo,
                        ),
                      ),
                    ],
                  ),
                  Slider(
                    value: _leadTimeDelayDays.toDouble(),
                    min: 0,
                    max: 30,
                    divisions: 6,
                    activeColor: ArvoColors.ambar,
                    onChanged: (val) {
                      setState(() => _leadTimeDelayDays = val.toInt());
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Tabela de Projeção Comparativa
            const Text(
              'PROJEÇÃO DE IMPACTO POR INSUMO',
              style: TextStyle(
                fontFamily: ArvoTypography.fontHeading,
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: ArvoColors.petroleo,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 10),

            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                final runout = runouts[product.id];
                if (runout == null || runout.dailyConsumptionRate <= 0) return const SizedBox();

                final simulatedRate = runout.dailyConsumptionRate * _consumptionFactor;
                final simulatedDays = (product.currentStock / simulatedRate) - _leadTimeDelayDays;
                final bool willRupture = simulatedDays <= 5;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: willRupture ? ArvoColors.erro.withValues(alpha: 0.5) : ArvoColors.linha,
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product.name,
                              style: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            Text(
                              'Saldo: ${product.currentStock.toStringAsFixed(0)} ${product.unit} • Consumo simulado: ${simulatedRate.toStringAsFixed(1)} ${product.unit}/dia',
                              style: const TextStyle(fontSize: 11, color: ArvoColors.musgo),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            simulatedDays > 0 ? '~${simulatedDays.toStringAsFixed(0)} dias' : 'ESGOTADO',
                            style: TextStyle(
                              fontFamily: ArvoTypography.fontHeading,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              color: willRupture ? ArvoColors.erro : ArvoColors.folha,
                            ),
                          ),
                          Text(
                            simulatedDays > 0 ? 'de autonomia' : 'Ruptura na lavoura',
                            style: TextStyle(
                              fontSize: 10,
                              color: willRupture ? ArvoColors.erro : ArvoColors.musgo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
