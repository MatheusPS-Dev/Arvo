import '../../data/models/product_model.dart';
import '../../data/models/movement_model.dart';
import '../../data/models/alert_model.dart';

class RunoutResult {
  final String productId;
  final String productName;
  final double currentStock;
  final double minStock;
  final String unit;
  final double dailyConsumptionRate;
  final double daysOfStockRemaining;
  final DateTime? forecastDepletionDate;
  final double recommendedPurchaseQuantity;
  final bool isDepletionImminent;

  const RunoutResult({
    required this.productId,
    required this.productName,
    required this.currentStock,
    required this.minStock,
    required this.unit,
    required this.dailyConsumptionRate,
    required this.daysOfStockRemaining,
    this.forecastDepletionDate,
    required this.recommendedPurchaseQuantity,
    required this.isDepletionImminent,
  });
}

class RunoutCalculator {
  const RunoutCalculator();

  /// Calcula a taxa diária ponderada de consumo e a autonomia restante do produto
  RunoutResult calculate({
    required ProductModel product,
    required List<MovementModel> productMovements,
    int analysisWindowDays = 30,
  }) {
    final now = DateTime.now();
    final cutoffDate = now.subtract(Duration(days: analysisWindowDays));

    // Filtrar saídas válidas dentro da janela de análise
    final exits = productMovements.where((m) {
      return m.isExit && m.date.isAfter(cutoffDate);
    }).toList();

    double totalConsumed = 0.0;
    for (final exit in exits) {
      totalConsumed += exit.quantity;
    }

    // Determinar dias efetivos para cálculo da taxa
    final int effectiveDays = exits.isEmpty ? 1 : analysisWindowDays;
    final double dailyConsumptionRate = totalConsumed / effectiveDays;

    double daysRemaining = double.infinity;
    DateTime? depletionDate;

    if (dailyConsumptionRate > 0) {
      daysRemaining = product.currentStock / dailyConsumptionRate;
      depletionDate = now.add(Duration(days: daysRemaining.toInt()));
    } else if (product.currentStock <= 0) {
      daysRemaining = 0;
      depletionDate = now;
    }

    // Quantidade sugerida para recompor estoque até 2x o estoque mínimo
    final double targetStock = product.minStock * 2.0;
    final double recommendedPurchase = targetStock > product.currentStock
        ? targetStock - product.currentStock
        : 0.0;

    // Considera iminente se a autonomia for menor ou igual a 10 dias ou abaixo do estoque mínimo
    final bool isImminent = (daysRemaining <= 10 && dailyConsumptionRate > 0) ||
        product.currentStock <= product.minStock;

    return RunoutResult(
      productId: product.id,
      productName: product.name,
      currentStock: product.currentStock,
      minStock: product.minStock,
      unit: product.unit,
      dailyConsumptionRate: dailyConsumptionRate,
      daysOfStockRemaining: daysRemaining,
      forecastDepletionDate: depletionDate,
      recommendedPurchaseQuantity: recommendedPurchase,
      isDepletionImminent: isImminent,
    );
  }

  /// Gera alertas baseados no esgotamento projetado
  List<AlertModel> generateAlerts({
    required ProductModel product,
    required RunoutResult result,
  }) {
    final alerts = <AlertModel>[];
    final now = DateTime.now();

    if (result.daysOfStockRemaining <= 3 && result.dailyConsumptionRate > 0) {
      alerts.add(
        AlertModel(
          id: 'runout_crit_${product.id}',
          title: 'Estoque Crítico: ${product.name}',
          description: 'Ruptura iminente de estoque em menos de 3 dias.',
          reasonExplanation:
              'Mantendo o consumo médio recente de ${result.dailyConsumptionRate.toStringAsFixed(1)} ${product.unit}/dia, o saldo atual de ${product.currentStock.toStringAsFixed(0)} ${product.unit} será suficiente por apenas aproximadamente ${result.daysOfStockRemaining.toStringAsFixed(0)} dias.',
          severity: AlertSeverity.critico,
          type: AlertType.ruptura,
          affectedProductId: product.id,
          affectedProductName: product.name,
          recommendedAction:
              'Emitir pedido urgente de compra de pelo menos ${result.recommendedPurchaseQuantity.toStringAsFixed(0)} ${product.unit} para evitar parada operacional.',
          timestamp: now,
        ),
      );
    } else if (result.daysOfStockRemaining <= 10 && result.dailyConsumptionRate > 0) {
      alerts.add(
        AlertModel(
          id: 'runout_warn_${product.id}',
          title: 'Atenção para Reposição: ${product.name}',
          description: 'Estoque em ritmo de consumo rápido.',
          reasonExplanation:
              'Ao ritmo de consumo de ${result.dailyConsumptionRate.toStringAsFixed(1)} ${product.unit}/dia, o estoque atual durará cerca de ${result.daysOfStockRemaining.toStringAsFixed(0)} dias (estoque mínimo seguro: ${product.minStock.toStringAsFixed(0)} ${product.unit}).',
          severity: AlertSeverity.atencao,
          type: AlertType.ruptura,
          affectedProductId: product.id,
          affectedProductName: product.name,
          recommendedAction:
              'Cotar compra de reposição de ${result.recommendedPurchaseQuantity.toStringAsFixed(0)} ${product.unit} com fornecedores habituais.',
          timestamp: now,
        ),
      );
    } else if (product.currentStock <= product.minStock && result.dailyConsumptionRate == 0) {
      alerts.add(
        AlertModel(
          id: 'runout_min_${product.id}',
          title: 'Abaixo do Estoque Mínimo: ${product.name}',
          description: 'Saldo abaixo do limite operacional de segurança.',
          reasonExplanation:
              'O saldo atual (${product.currentStock.toStringAsFixed(0)} ${product.unit}) está no limite ou abaixo do estoque mínimo definido (${product.minStock.toStringAsFixed(0)} ${product.unit}).',
          severity: AlertSeverity.atencao,
          type: AlertType.ruptura,
          affectedProductId: product.id,
          affectedProductName: product.name,
          recommendedAction: 'Programar compra de reposição de insumo.',
          timestamp: now,
        ),
      );
    }

    return alerts;
  }
}
