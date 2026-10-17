import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/models/movement_model.dart';
import '../../data/models/alert_model.dart';
import '../../core/utils/formatters.dart';


enum AbcClass {
  a(label: 'Classe A', description: 'Alta relevância financeira (80% do capital)', color: Color(0xFFC0432F)),
  b(label: 'Classe B', description: 'Média relevância financeira (15% do capital)', color: Color(0xFFB28837)),
  c(label: 'Classe C', description: 'Baixa relevância financeira (5% do capital)', color: Color(0xFF1E9F68));

  const AbcClass({required this.label, required this.description, required this.color});
  final String label;
  final String description;
  final Color color;
}

class AbcItemResult {
  final ProductModel product;
  final double totalValue;
  final double percentOfTotal;
  final double cumulativePercent;
  final AbcClass classification;
  final int daysSinceLastExit;
  final bool isIdleCapital; // Capital parado de alto valor

  const AbcItemResult({
    required this.product,
    required this.totalValue,
    required this.percentOfTotal,
    required this.cumulativePercent,
    required this.classification,
    required this.daysSinceLastExit,
    required this.isIdleCapital,
  });
}

class AbcCurveAnalyzer {
  const AbcCurveAnalyzer();

  /// Executa a classificação de Pareto (Curva ABC) sobre todo o portfólio de insumos
  List<AbcItemResult> analyze({
    required List<ProductModel> products,
    required List<MovementModel> movements,
  }) {
    if (products.isEmpty) return [];

    final now = DateTime.now();

    // Calcular valor total do estoque da fazenda
    double grandTotalValue = 0.0;
    for (final p in products) {
      grandTotalValue += p.totalStockValue;
    }

    // Ordenar decrescente pelo valor total estocado
    final sortedProducts = List<ProductModel>.from(products)
      ..sort((a, b) => b.totalStockValue.compareTo(a.totalStockValue));

    final results = <AbcItemResult>[];
    double accumulatedValue = 0.0;

    for (final product in sortedProducts) {
      accumulatedValue += product.totalStockValue;
      final double percentOfTotal = grandTotalValue > 0
          ? (product.totalStockValue / grandTotalValue) * 100
          : 0.0;
      final double cumulativePercent = grandTotalValue > 0
          ? (accumulatedValue / grandTotalValue) * 100
          : 0.0;

      AbcClass classification;
      if (cumulativePercent <= 80.0 || results.isEmpty) {
        classification = AbcClass.a;
      } else if (cumulativePercent <= 95.0) {
        classification = AbcClass.b;
      } else {
        classification = AbcClass.c;
      }

      // Encontrar a última saída deste produto
      final productExits = movements
          .where((m) => m.productId == product.id && m.isExit)
          .toList()
        ..sort((a, b) => b.date.compareTo(a.date));

      int daysSinceLastExit = 999;
      if (productExits.isNotEmpty) {
        daysSinceLastExit = now.difference(productExits.first.date).inDays;
      }

      // Se for Classe A ou B e estiver há mais de 45 dias sem saída com saldo positivo
      final bool isIdle = (classification == AbcClass.a || classification == AbcClass.b) &&
          product.currentStock > 0 &&
          daysSinceLastExit >= 45 &&
          product.totalStockValue >= 10000;

      results.add(
        AbcItemResult(
          product: product,
          totalValue: product.totalStockValue,
          percentOfTotal: percentOfTotal,
          cumulativePercent: cumulativePercent,
          classification: classification,
          daysSinceLastExit: daysSinceLastExit,
          isIdleCapital: isIdle,
        ),
      );
    }

    return results;
  }

  /// Gera alertas para itens de alto valor com baixa movimentação (capital ocioso)
  List<AlertModel> generateAlerts(List<AbcItemResult> items) {
    final alerts = <AlertModel>[];
    final now = DateTime.now();

    for (final item in items) {
      if (item.isIdleCapital) {
        alerts.add(
          AlertModel(
            id: 'idle_capital_${item.product.id}',
            title: 'Capital Parado / Baixo Giro: ${item.product.name}',
            description:
                '${item.classification.label}: ${Formatters.formatCurrency(item.totalValue)} sem saída há ${item.daysSinceLastExit} dias.',
            reasonExplanation:
                'O produto ${item.product.name} representa ${item.percentOfTotal.toStringAsFixed(1)}% do valor total estocado na propriedade (${Formatters.formatCurrency(item.totalValue)}), mas não registra nenhuma saída há ${item.daysSinceLastExit} dias. Pode indicar compra excessiva antecipada.',
            severity: AlertSeverity.atencao,
            type: AlertType.curvaAbc,
            affectedProductId: item.product.id,
            affectedProductName: item.product.name,
            recommendedAction:
                'Avaliar se o produto será usado na safra atual ou negociar devolução parcial/permuta com a cooperativa ou fornecedor.',
            potentialFinancialImpact: item.totalValue,
            timestamp: now,
          ),
        );
      }
    }

    return alerts;
  }
}
