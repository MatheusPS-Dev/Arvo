import '../../data/models/product_model.dart';
import '../../data/models/movement_model.dart';
import '../../data/models/alert_model.dart';
import '../../core/utils/formatters.dart';

class PriceVarianceResult {
  final ProductModel product;
  final MovementModel latestEntry;
  final double latestPrice;
  final double historicalAveragePrice;
  final double percentChange;
  final String supplier;

  const PriceVarianceResult({
    required this.product,
    required this.latestEntry,
    required this.latestPrice,
    required this.historicalAveragePrice,
    required this.percentChange,
    required this.supplier,
  });
}

class PriceVarianceDetector {
  const PriceVarianceDetector();

  /// Detecta variações expressivas no custo unitário de aquisição entre lotes
  List<PriceVarianceResult> detectVariances({
    required List<ProductModel> products,
    required List<MovementModel> movements,
    double thresholdPercent = 15.0,
  }) {
    final results = <PriceVarianceResult>[];

    for (final product in products) {
      final entries = movements
          .where((m) => m.productId == product.id && m.isEntry && (m.unitPrice ?? 0) > 0)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      if (entries.length < 2) continue;

      final latestEntry = entries.first;
      final previousEntries = entries.sublist(1);

      double sumPrevPrices = 0.0;
      for (final e in previousEntries) {
        sumPrevPrices += e.unitPrice!;
      }
      final double avgPrevPrice = sumPrevPrices / previousEntries.length;

      final double latestPrice = latestEntry.unitPrice!;
      final double diff = latestPrice - avgPrevPrice;
      final double percentChange = (diff / avgPrevPrice) * 100;

      if (percentChange.abs() >= thresholdPercent) {
        results.add(
          PriceVarianceResult(
            product: product,
            latestEntry: latestEntry,
            latestPrice: latestPrice,
            historicalAveragePrice: avgPrevPrice,
            percentChange: percentChange,
            supplier: latestEntry.supplier ?? 'Fornecedor não informado',
          ),
        );
      }
    }

    return results;
  }

  /// Gera alertas para oscilações bruscas de preço
  List<AlertModel> generateAlerts(List<PriceVarianceResult> variances) {
    final alerts = <AlertModel>[];
    final now = DateTime.now();

    for (final v in variances) {
      final isIncrease = v.percentChange > 0;
      final sign = isIncrease ? '+' : '';
      final term = isIncrease ? 'Alta' : 'Queda';

      alerts.add(
        AlertModel(
          id: 'price_var_${v.product.id}_${v.latestEntry.id}',
          title: '$term Expressiva de Preço: ${v.product.name}',
          description:
              'Última compra com variação de $sign${v.percentChange.toStringAsFixed(1)}% no custo unitário.',
          reasonExplanation:
              'A aquisição de ${v.latestEntry.quantity.toStringAsFixed(0)} ${v.product.unit} em ${Formatters.formatDate(v.latestEntry.date)} via "${v.supplier}" teve preço unitário de ${Formatters.formatCurrency(v.latestPrice)}/${v.product.unit}, frente à média histórica anterior de ${Formatters.formatCurrency(v.historicalAveragePrice)}/${v.product.unit} ($sign${v.percentChange.toStringAsFixed(1)}%).',
          severity: isIncrease && v.percentChange >= 25 ? AlertSeverity.atencao : AlertSeverity.info,
          type: AlertType.variacaoPreco,
          affectedProductId: v.product.id,
          affectedProductName: v.product.name,
          recommendedAction: isIncrease
              ? 'Negociar com novos distribuidores ou verificar se houve frete embutido ou mudança na especificação química.'
              : 'Oportunidade de compra favorável observada junto ao fornecedor ${v.supplier}.',
          timestamp: now,
        ),
      );
    }

    return alerts;
  }
}
