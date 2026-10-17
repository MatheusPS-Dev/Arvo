import 'dart:math';
import '../../data/models/product_model.dart';
import '../../data/models/movement_model.dart';
import '../../data/models/alert_model.dart';
import '../../core/utils/formatters.dart';

class AnomalyResult {
  final MovementModel movement;
  final double typicalMean;
  final double stdDev;
  final double deviationFactor; // Quantas vezes acima da média
  final String destination;
  final String responsible;

  const AnomalyResult({
    required this.movement,
    required this.typicalMean,
    required this.stdDev,
    required this.deviationFactor,
    required this.destination,
    required this.responsible,
  });
}

class TrendAnomalyResult {
  final ProductModel product;
  final double recentDailyAvg; // Últimos 7 dias
  final double baselineDailyAvg; // 21 dias anteriores
  final double increaseRatio; // Percentual de aumento

  const TrendAnomalyResult({
    required this.product,
    required this.recentDailyAvg,
    required this.baselineDailyAvg,
    required this.increaseRatio,
  });
}

class AnomalyDetector {
  const AnomalyDetector();

  /// Identifica retiradas individuais cujo volume destoe significativamente do padrão histórico
  List<AnomalyResult> detectOutlierMovements({
    required ProductModel product,
    required List<MovementModel> movements,
  }) {
    final exits = movements.where((m) => m.productId == product.id && m.isExit).toList();
    if (exits.length < 3) return [];

    // Calcular média das retiradas
    final quantities = exits.map((e) => e.quantity).toList();
    final double sum = quantities.reduce((a, b) => a + b);
    final double mean = sum / quantities.length;

    // Calcular variância e desvio padrão amostral
    double sumSquaredDiff = 0.0;
    for (final q in quantities) {
      sumSquaredDiff += pow(q - mean, 2);
    }
    final double stdDev = sqrt(sumSquaredDiff / (quantities.length - 1));

    final anomalies = <AnomalyResult>[];

    // Se o desvio for muito pequeno ou zero, não há outliers estatísticos
    if (stdDev <= 0.01) return [];

    final double threshold = mean + (2.0 * stdDev);

    for (final exit in exits) {
      if (exit.quantity > threshold && exit.quantity >= (mean * 1.8)) {
        anomalies.add(
          AnomalyResult(
            movement: exit,
            typicalMean: mean,
            stdDev: stdDev,
            deviationFactor: exit.quantity / mean,
            destination: exit.destination ?? 'Não informado',
            responsible: exit.responsible,
          ),
        );
      }
    }

    return anomalies;
  }

  /// Identifica aumento progressivo ou aceleração repentina de consumo
  TrendAnomalyResult? detectAccelerationTrend({
    required ProductModel product,
    required List<MovementModel> movements,
  }) {
    final now = DateTime.now();
    final sevenDaysAgo = now.subtract(const Duration(days: 7));
    final twentyEightDaysAgo = now.subtract(const Duration(days: 28));

    final exits = movements.where((m) => m.productId == product.id && m.isExit).toList();

    double recentSum = 0.0;
    double baselineSum = 0.0;

    for (final exit in exits) {
      if (exit.date.isAfter(sevenDaysAgo)) {
        recentSum += exit.quantity;
      } else if (exit.date.isAfter(twentyEightDaysAgo)) {
        baselineSum += exit.quantity;
      }
    }

    final double recentAvg = recentSum / 7.0;
    final double baselineAvg = baselineSum / 21.0;

    if (baselineAvg > 0 && recentAvg >= (baselineAvg * 1.6) && recentSum > 0) {
      final double ratio = ((recentAvg - baselineAvg) / baselineAvg) * 100;
      return TrendAnomalyResult(
        product: product,
        recentDailyAvg: recentAvg,
        baselineDailyAvg: baselineAvg,
        increaseRatio: ratio,
      );
    }

    return null;
  }

  /// Gera alertas estruturados com justificativa técnica explicável
  List<AlertModel> generateAlerts({
    required List<AnomalyResult> outlierMovements,
    required List<TrendAnomalyResult> trends,
  }) {
    final alerts = <AlertModel>[];
    final now = DateTime.now();

    for (final anomaly in outlierMovements) {
      final mult = anomaly.deviationFactor.toStringAsFixed(1);
      alerts.add(
        AlertModel(
          id: 'outlier_${anomaly.movement.id}',
          title: 'Retirada Fora do Padrão: ${anomaly.movement.productName}',
          description:
              'Retirada de ${anomaly.movement.quantity.toStringAsFixed(0)} ${anomaly.movement.unit} em ${Formatters.formatDate(anomaly.movement.date)}.',
          reasonExplanation:
              'Esta movimentação é ${mult}x superior à média histórica (${anomaly.typicalMean.toStringAsFixed(1)} ${anomaly.movement.unit}/retirada). Destino: ${anomaly.destination}. Responsável: ${anomaly.responsible}.',
          severity: anomaly.deviationFactor >= 2.8 ? AlertSeverity.critico : AlertSeverity.atencao,
          type: AlertType.anomalia,
          affectedProductId: anomaly.movement.productId,
          affectedProductName: anomaly.movement.productName,
          recommendedAction:
              'Verificar junto ao operador (${anomaly.responsible}) se houve lançamento incorreto, vazamento ou necessidade especial no talhão.',
          timestamp: now,
        ),
      );
    }

    for (final trend in trends) {
      alerts.add(
        AlertModel(
          id: 'trend_accel_${trend.product.id}',
          title: 'Aumento Progressivo de Consumo: ${trend.product.name}',
          description: 'Aceleração de +${trend.increaseRatio.toStringAsFixed(0)}% no consumo recente.',
          reasonExplanation:
              'Nos últimos 7 dias, a média diária atingiu ${trend.recentDailyAvg.toStringAsFixed(1)} ${trend.product.unit}/dia, comparada a ${trend.baselineDailyAvg.toStringAsFixed(1)} ${trend.product.unit}/dia no histórico anterior (+${trend.increaseRatio.toStringAsFixed(0)}%).',
          severity: AlertSeverity.atencao,
          type: AlertType.anomalia,
          affectedProductId: trend.product.id,
          affectedProductName: trend.product.name,
          recommendedAction:
              'Inspecionar calibração dos equipamentos de aplicação e checar se há infestação de pragas ou condições climáticas anômalas.',
          timestamp: now,
        ),
      );
    }

    return alerts;
  }
}
