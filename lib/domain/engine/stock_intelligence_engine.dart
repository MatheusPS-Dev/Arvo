import '../../data/models/product_model.dart';
import '../../data/models/movement_model.dart';
import '../../data/models/alert_model.dart';
import 'runout_calculator.dart';
import 'expiry_risk_analyzer.dart';
import 'anomaly_detector.dart';
import 'abc_curve_analyzer.dart';
import 'price_variance_detector.dart';
import 'deduplication_matcher.dart';

class FarmHealthSummary {
  final double totalInventoryCapital;
  final int totalProductsCount;
  final int criticalAlertsCount;
  final int warningAlertsCount;
  final int infoAlertsCount;
  final int itemsBelowMinStockCount;
  final double capitalAtRiskOfExpiry;
  final double idleCapitalAmount;
  final double averageAutonomyDays;

  const FarmHealthSummary({
    required this.totalInventoryCapital,
    required this.totalProductsCount,
    required this.criticalAlertsCount,
    required this.warningAlertsCount,
    required this.infoAlertsCount,
    required this.itemsBelowMinStockCount,
    required this.capitalAtRiskOfExpiry,
    required this.idleCapitalAmount,
    required this.averageAutonomyDays,
  });
}

class IntelligenceAnalysisResult {
  final FarmHealthSummary summary;
  final List<AlertModel> allAlerts;
  final Map<String, RunoutResult> runoutByProductId;
  final List<ExpiryRiskResult> expiryRisks;
  final List<AnomalyResult> outlierMovements;
  final List<TrendAnomalyResult> trendAnomalies;
  final List<AbcItemResult> abcItems;
  final List<PriceVarianceResult> priceVariances;
  final List<DuplicateCandidateResult> duplicates;

  const IntelligenceAnalysisResult({
    required this.summary,
    required this.allAlerts,
    required this.runoutByProductId,
    required this.expiryRisks,
    required this.outlierMovements,
    required this.trendAnomalies,
    required this.abcItems,
    required this.priceVariances,
    required this.duplicates,
  });

  List<AlertModel> get criticalAlerts =>
      allAlerts.where((a) => a.severity == AlertSeverity.critico).toList();

  List<AlertModel> get warningAlerts =>
      allAlerts.where((a) => a.severity == AlertSeverity.atencao).toList();

  List<AlertModel> get infoAlerts =>
      allAlerts.where((a) => a.severity == AlertSeverity.info).toList();
}

class StockIntelligenceEngine {
  final RunoutCalculator _runoutCalc;
  final ExpiryRiskAnalyzer _expiryAnalyzer;
  final AnomalyDetector _anomalyDetector;
  final AbcCurveAnalyzer _abcAnalyzer;
  final PriceVarianceDetector _priceDetector;
  final DeduplicationMatcher _dedupMatcher;

  const StockIntelligenceEngine({
    this._runoutCalc = const RunoutCalculator(),
    this._expiryAnalyzer = const ExpiryRiskAnalyzer(),
    this._anomalyDetector = const AnomalyDetector(),
    this._abcAnalyzer = const AbcCurveAnalyzer(),
    this._priceDetector = const PriceVarianceDetector(),
    this._dedupMatcher = const DeduplicationMatcher(),
  });

  /// Executa análise completa e integrada de todo o estoque e movimentações
  IntelligenceAnalysisResult runAnalysis({
    required List<ProductModel> products,
    required List<MovementModel> movements,
  }) {
    final allAlerts = <AlertModel>[];
    final runoutMap = <String, RunoutResult>{};
    final allExpiryRisks = <ExpiryRiskResult>[];
    final allOutlierMovements = <AnomalyResult>[];
    final allTrendAnomalies = <TrendAnomalyResult>[];

    double totalCapital = 0.0;
    int belowMinCount = 0;
    double sumAutonomyDays = 0.0;
    int productsWithRateCount = 0;

    // 1. Análise de Ruptura e Autonomia por Produto
    for (final product in products) {
      totalCapital += product.totalStockValue;
      if (product.isBelowMinStock) belowMinCount++;

      final runout = _runoutCalc.calculate(
        product: product,
        productMovements: movements,
      );
      runoutMap[product.id] = runout;

      if (runout.dailyConsumptionRate > 0) {
        sumAutonomyDays += runout.daysOfStockRemaining;
        productsWithRateCount++;
      }

      final runoutAlerts = _runoutCalc.generateAlerts(
        product: product,
        result: runout,
      );
      allAlerts.addAll(runoutAlerts);

      // 2. Análise de Risco de Vencimento
      final expiryRisks = _expiryAnalyzer.analyzeProduct(
        product: product,
        dailyConsumptionRate: runout.dailyConsumptionRate,
      );
      allExpiryRisks.addAll(expiryRisks);

      // 3. Análise de Anomalias de Retirada e Aceleração
      final outliers = _anomalyDetector.detectOutlierMovements(
        product: product,
        movements: movements,
      );
      allOutlierMovements.addAll(outliers);

      final trend = _anomalyDetector.detectAccelerationTrend(
        product: product,
        movements: movements,
      );
      if (trend != null) {
        allTrendAnomalies.add(trend);
      }
    }

    // Alertas de Vencimento
    final expiryAlerts = _expiryAnalyzer.generateAlerts(allExpiryRisks);
    allAlerts.addAll(expiryAlerts);

    // Alertas de Anomalias
    final anomalyAlerts = _anomalyDetector.generateAlerts(
      outlierMovements: allOutlierMovements,
      trends: allTrendAnomalies,
    );
    allAlerts.addAll(anomalyAlerts);

    // 4. Análise da Curva ABC e Capital Imobilizado
    final abcItems = _abcAnalyzer.analyze(
      products: products,
      movements: movements,
    );
    final abcAlerts = _abcAnalyzer.generateAlerts(abcItems);
    allAlerts.addAll(abcAlerts);

    // 5. Análise de Variações de Preço
    final priceVariances = _priceDetector.detectVariances(
      products: products,
      movements: movements,
    );
    final priceAlerts = _priceDetector.generateAlerts(priceVariances);
    allAlerts.addAll(priceAlerts);

    // 6. Análise de Duplicidades e Inconsistências Cadastrais
    final duplicates = _dedupMatcher.findDuplicates(products);
    final duplicateAlerts = _dedupMatcher.generateAlerts(duplicates);
    allAlerts.addAll(duplicateAlerts);

    // Ordenar alertas por severidade (Crítico -> Atenção -> Info) e depois por data
    allAlerts.sort((a, b) {
      final rankDiff = a.severity.priorityRank.compareTo(b.severity.priorityRank);
      if (rankDiff != 0) return rankDiff;
      return b.timestamp.compareTo(a.timestamp);
    });

    // Calcular métricas financeiras agregadas
    double capitalAtRiskOfExpiry = 0.0;
    for (final exp in allExpiryRisks) {
      if (exp.hasDefiniteLossRisk) {
        capitalAtRiskOfExpiry += exp.financialLossAtRisk;
      }
    }

    double idleCapitalAmount = 0.0;
    for (final abc in abcItems) {
      if (abc.isIdleCapital) {
        idleCapitalAmount += abc.totalValue;
      }
    }

    final double avgAutonomy = productsWithRateCount > 0
        ? sumAutonomyDays / productsWithRateCount
        : 30.0;

    final summary = FarmHealthSummary(
      totalInventoryCapital: totalCapital,
      totalProductsCount: products.length,
      criticalAlertsCount: allAlerts.where((a) => a.severity == AlertSeverity.critico).length,
      warningAlertsCount: allAlerts.where((a) => a.severity == AlertSeverity.atencao).length,
      infoAlertsCount: allAlerts.where((a) => a.severity == AlertSeverity.info).length,
      itemsBelowMinStockCount: belowMinCount,
      capitalAtRiskOfExpiry: capitalAtRiskOfExpiry,
      idleCapitalAmount: idleCapitalAmount,
      averageAutonomyDays: avgAutonomy,
    );

    return IntelligenceAnalysisResult(
      summary: summary,
      allAlerts: allAlerts,
      runoutByProductId: runoutMap,
      expiryRisks: allExpiryRisks,
      outlierMovements: allOutlierMovements,
      trendAnomalies: allTrendAnomalies,
      abcItems: abcItems,
      priceVariances: priceVariances,
      duplicates: duplicates,
    );
  }
}
