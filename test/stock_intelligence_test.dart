import 'package:flutter_test/flutter_test.dart';
import 'package:arvo_app/data/models/product_model.dart';
import 'package:arvo_app/data/models/movement_model.dart';
import 'package:arvo_app/data/models/batch_model.dart';
import 'package:arvo_app/data/models/category_enum.dart';
import 'package:arvo_app/data/models/alert_model.dart';
import 'package:arvo_app/domain/engine/runout_calculator.dart';
import 'package:arvo_app/domain/engine/expiry_risk_analyzer.dart';
import 'package:arvo_app/domain/engine/anomaly_detector.dart';
import 'package:arvo_app/domain/engine/abc_curve_analyzer.dart';
import 'package:arvo_app/domain/engine/deduplication_matcher.dart';

void main() {
  group('Stock Intelligence Engine Unit Tests', () {
    final now = DateTime.now();

    test('RunoutCalculator correctly computes daily rate and days of stock remaining', () {
      const calc = RunoutCalculator();

      final product = ProductModel(
        id: 'test_ureia',
        code: 'FERT-01',
        name: 'Ureia 46%',
        category: ProductCategory.fertilizantes,
        unit: 'sc',
        currentStock: 100.0,
        minStock: 50.0,
        averageUnitCost: 150.0,
        lastUpdated: now,
      );

      final movements = [
        MovementModel(
          id: 'm1',
          productId: 'test_ureia',
          productName: 'Ureia 46%',
          type: MovementType.saida,
          quantity: 150.0, // 300 sc total in 30 days = 10 sc/dia
          unit: 'sc',
          date: now.subtract(const Duration(days: 10)),
          responsible: 'Operador A',
        ),
        MovementModel(
          id: 'm2',
          productId: 'test_ureia',
          productName: 'Ureia 46%',
          type: MovementType.saida,
          quantity: 150.0,
          unit: 'sc',
          date: now.subtract(const Duration(days: 5)),
          responsible: 'Operador B',
        ),
      ];

      final result = calc.calculate(product: product, productMovements: movements);

      expect(result.dailyConsumptionRate, equals(10.0));
      expect(result.daysOfStockRemaining, equals(10.0)); // 100 sc / 10 sc/dia = 10 days
      expect(result.isDepletionImminent, isTrue);

      final alerts = calc.generateAlerts(product: product, result: result);
      expect(alerts.any((a) => a.type == AlertType.ruptura), isTrue);
    });

    test('ExpiryRiskAnalyzer correctly detects projected loss before expiration', () {
      const analyzer = ExpiryRiskAnalyzer();

      final product = ProductModel(
        id: 'test_inoc',
        code: 'DEF-01',
        name: 'Inoculante Biológico',
        category: ProductCategory.defensivosEBbiologicos,
        unit: 'dose',
        currentStock: 200.0,
        minStock: 40.0,
        averageUnitCost: 20.0,
        lastUpdated: now,
        batches: [
          BatchModel(
            batchNumber: 'LOTE-EXPIRE-SOON',
            expirationDate: now.add(const Duration(days: 10)), // 10 dias para expirar
            initialQuantity: 200.0,
            remainingQuantity: 200.0,
            unitCost: 20.0,
            entryDate: now.subtract(const Duration(days: 20)),
          ),
        ],
      );

      // Consumo diário de apenas 5 doses/dia -> em 10 dias usará 50 doses, restando 150 doses no lote!
      const dailyRate = 5.0;

      final results = analyzer.analyzeProduct(product: product, dailyConsumptionRate: dailyRate);

      expect(results.length, equals(1));
      final res = results.first;
      expect(res.projectedConsumptionUntilExpiry, equals(50.0));
      expect(res.unconsumedQuantityAtRisk, equals(150.0));
      expect(res.financialLossAtRisk, equals(3000.0)); // 150 * R$ 20 = R$ 3.000,00
      expect(res.hasDefiniteLossRisk, isTrue);

      final alerts = analyzer.generateAlerts(results);
      expect(alerts.isNotEmpty, isTrue);
      expect(alerts.first.severity, equals(AlertSeverity.critico));
    });

    test('AnomalyDetector flags outlier withdrawals that exceed 2 standard deviations', () {
      const detector = AnomalyDetector();

      final product = ProductModel(
        id: 'test_diesel',
        code: 'COMB-01',
        name: 'Diesel S10',
        category: ProductCategory.combustiveisELubrificantes,
        unit: 'L',
        currentStock: 5000.0,
        minStock: 2000.0,
        averageUnitCost: 6.0,
        lastUpdated: now,
      );

      final movements = [
        for (int i = 1; i <= 6; i++)
          MovementModel(
            id: 'd_$i',
            productId: 'test_diesel',
            productName: 'Diesel S10',
            type: MovementType.saida,
            quantity: 200.0 + (i * 10), // Média ~235L
            unit: 'L',
            date: now.subtract(Duration(days: i * 3)),
            responsible: 'Mecânico',
          ),
        MovementModel(
          id: 'd_outlier',
          productId: 'test_diesel',
          productName: 'Diesel S10',
          type: MovementType.saida,
          quantity: 1100.0, // Outlier gigante (> 4.5x da média)
          unit: 'L',
          date: now.subtract(const Duration(days: 1)),
          responsible: 'Operador X',
        ),
      ];

      final outliers = detector.detectOutlierMovements(product: product, movements: movements);
      expect(outliers.length, equals(1));
      expect(outliers.first.movement.id, equals('d_outlier'));
    });

    test('DeduplicationMatcher detects inconsistent duplicate product registrations', () {
      const matcher = DeduplicationMatcher();

      final p1 = ProductModel(
        id: '1',
        code: 'F1',
        name: 'Ureia Granulada 46%',
        category: ProductCategory.fertilizantes,
        unit: 'sc',
        currentStock: 100,
        minStock: 20,
        averageUnitCost: 150,
        lastUpdated: now,
      );

      final p2 = ProductModel(
        id: '2',
        code: 'F2',
        name: 'Uréia Agrícola Granulada',
        category: ProductCategory.fertilizantes,
        unit: 'sc',
        currentStock: 50,
        minStock: 20,
        averageUnitCost: 150,
        lastUpdated: now,
      );

      final similarity = matcher.calculateSimilarity(p1.name, p2.name);
      expect(similarity, greaterThan(0.70));

      final duplicates = matcher.findDuplicates([p1, p2]);
      expect(duplicates.length, equals(1));
      expect(duplicates.first.productA.name, equals('Ureia Granulada 46%'));
      expect(duplicates.first.productB.name, equals('Uréia Agrícola Granulada'));
    });

    test('AbcCurveAnalyzer categorizes portfolio and flags idle high-value stock', () {
      const analyzer = AbcCurveAnalyzer();

      final pA = ProductModel(
        id: 'item_expensive',
        code: 'IRR-01',
        name: 'Conjunto Motor Pivô Central',
        category: ProductCategory.materiaisDeIrrigacao,
        unit: 'un',
        currentStock: 5,
        minStock: 1,
        averageUnitCost: 10000.0, // R$ 50.000,00
        lastUpdated: now.subtract(const Duration(days: 80)),
      );

      final pB = ProductModel(
        id: 'item_cheap',
        code: 'EPI-01',
        name: 'Luvas',
        category: ProductCategory.epiEDiversos,
        unit: 'par',
        currentStock: 50,
        minStock: 20,
        averageUnitCost: 10.0, // R$ 500,00
        lastUpdated: now,
      );

      final items = analyzer.analyze(products: [pA, pB], movements: []);
      expect(items.first.classification, equals(AbcClass.a));
      expect(items.first.isIdleCapital, isTrue); // R$ 50.000 sem saídas há 80 dias
    });
  });
}
