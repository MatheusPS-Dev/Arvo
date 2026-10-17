import '../../data/models/product_model.dart';
import '../../data/models/batch_model.dart';
import '../../data/models/alert_model.dart';
import '../../core/utils/formatters.dart';

class ExpiryRiskResult {
  final ProductModel product;
  final BatchModel batch;
  final int daysUntilExpiration;
  final double projectedConsumptionUntilExpiry;
  final double unconsumedQuantityAtRisk;
  final double financialLossAtRisk;
  final bool hasDefiniteLossRisk;

  const ExpiryRiskResult({
    required this.product,
    required this.batch,
    required this.daysUntilExpiration,
    required this.projectedConsumptionUntilExpiry,
    required this.unconsumedQuantityAtRisk,
    required this.financialLossAtRisk,
    required this.hasDefiniteLossRisk,
  });
}

class ExpiryRiskAnalyzer {
  const ExpiryRiskAnalyzer();

  /// Cruza a validade de cada lote com a taxa média diária de consumo
  List<ExpiryRiskResult> analyzeProduct({
    required ProductModel product,
    required double dailyConsumptionRate,
    int warningHorizonDays = 90,
  }) {
    final results = <ExpiryRiskResult>[];

    for (final batch in product.batches) {
      if (batch.remainingQuantity <= 0) continue;

      final daysRemaining = batch.daysUntilExpiration;

      // Se já está vencido ou vence dentro da janela de alerta
      if (daysRemaining <= warningHorizonDays) {
        double projectedConsumption = 0.0;
        if (daysRemaining > 0 && dailyConsumptionRate > 0) {
          projectedConsumption = daysRemaining * dailyConsumptionRate;
        }

        double unconsumedQuantity = 0.0;
        if (daysRemaining <= 0) {
          // Já venceu: perda total do saldo remanescente do lote
          unconsumedQuantity = batch.remainingQuantity;
        } else if (projectedConsumption < batch.remainingQuantity) {
          // Vencerá antes que todo o saldo seja utilizado ao ritmo atual
          unconsumedQuantity = batch.remainingQuantity - projectedConsumption;
        }

        final double financialLoss = unconsumedQuantity * batch.unitCost;
        final bool isRisk = unconsumedQuantity > 0 || daysRemaining <= 30;

        results.add(
          ExpiryRiskResult(
            product: product,
            batch: batch,
            daysUntilExpiration: daysRemaining,
            projectedConsumptionUntilExpiry: projectedConsumption,
            unconsumedQuantityAtRisk: unconsumedQuantity,
            financialLossAtRisk: financialLoss,
            hasDefiniteLossRisk: isRisk,
          ),
        );
      }
    }

    return results;
  }

  /// Gera alertas inteligentes e explicáveis para perdas por validade
  List<AlertModel> generateAlerts(List<ExpiryRiskResult> results) {
    final alerts = <AlertModel>[];
    final now = DateTime.now();

    for (final res in results) {
      if (!res.hasDefiniteLossRisk) continue;

      if (res.daysUntilExpiration <= 0) {
        alerts.add(
          AlertModel(
            id: 'expired_${res.product.id}_${res.batch.batchNumber}',
            title: 'Lote Vencido no Estoque: ${res.product.name}',
            description: 'Lote ${res.batch.batchNumber} ultrapassou a validade.',
            reasonExplanation:
                'O lote ${res.batch.batchNumber} venceu em ${Formatters.formatDate(res.batch.expirationDate)} com saldo remanescente de ${res.batch.remainingQuantity.toStringAsFixed(0)} ${res.product.unit}. Perda direta imobilizada: ${Formatters.formatCurrency(res.financialLossAtRisk)}.',
            severity: AlertSeverity.critico,
            type: AlertType.vencimento,
            affectedProductId: res.product.id,
            affectedProductName: res.product.name,
            recommendedAction:
                'Segregar o lote fisicamente para descarte ou avaliar laudo agronômico de revalidação.',
            potentialFinancialImpact: res.financialLossAtRisk,
            timestamp: now,
          ),
        );
      } else if (res.unconsumedQuantityAtRisk > 0 && res.daysUntilExpiration <= 45) {
        final percentLoss = (res.unconsumedQuantityAtRisk / res.batch.remainingQuantity) * 100;
        alerts.add(
          AlertModel(
            id: 'expiry_risk_${res.product.id}_${res.batch.batchNumber}',
            title: 'Risco de Perda por Validade: ${res.product.name}',
            description: 'Consumo insuficiente para utilizar o lote antes do vencimento.',
            reasonExplanation:
                'Restam ${res.daysUntilExpiration} dias para o vencimento do lote ${res.batch.batchNumber} (saldo: ${res.batch.remainingQuantity.toStringAsFixed(0)} ${res.product.unit}). No ritmo médio atual, apenas ${res.projectedConsumptionUntilExpiry.toStringAsFixed(0)} ${res.product.unit} serão aplicados até lá, gerando sobra estimada de ${res.unconsumedQuantityAtRisk.toStringAsFixed(0)} ${res.product.unit} (${percentLoss.toStringAsFixed(0)}% do lote) com prejuízo de ${Formatters.formatCurrency(res.financialLossAtRisk)}.',
            severity: res.daysUntilExpiration <= 20 ? AlertSeverity.critico : AlertSeverity.atencao,
            type: AlertType.vencimento,
            affectedProductId: res.product.id,
            affectedProductName: res.product.name,
            recommendedAction:
                'Priorizar a aplicação deste lote em talhões imediatos ou negociar remanejamento com propriedades parceiras.',
            potentialFinancialImpact: res.financialLossAtRisk,
            timestamp: now,
          ),
        );
      } else if (res.daysUntilExpiration <= 30) {
        alerts.add(
          AlertModel(
            id: 'expiry_soon_${res.product.id}_${res.batch.batchNumber}',
            title: 'Vencimento Próximo: ${res.product.name}',
            description: 'Lote ${res.batch.batchNumber} vence em ${res.daysUntilExpiration} dias.',
            reasonExplanation:
                'A validade do lote ${res.batch.batchNumber} expira em ${Formatters.formatDate(res.batch.expirationDate)}. Restam ${res.batch.remainingQuantity.toStringAsFixed(0)} ${res.product.unit} em estoque.',
            severity: AlertSeverity.atencao,
            type: AlertType.vencimento,
            affectedProductId: res.product.id,
            affectedProductName: res.product.name,
            recommendedAction:
                'Aplicar a regra FEFO (First Expired, First Out), garantindo que este lote seja retirado antes dos demais.',
            timestamp: now,
          ),
        );
      }
    }

    return alerts;
  }
}
