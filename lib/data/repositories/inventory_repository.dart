import 'package:flutter/foundation.dart';
import '../models/product_model.dart';
import '../models/category_enum.dart';
import '../mock/agro_mock_data.dart';

class InventoryRepository extends ChangeNotifier {
  List<ProductModel> _products = [];

  InventoryRepository() {
    resetToMockData();
  }

  List<ProductModel> get products => List.unmodifiable(_products);

  void resetToMockData() {
    _products = AgroMockData.getInitialProducts();
    notifyListeners();
  }

  ProductModel? getProductById(String id) {
    try {
      return _products.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<ProductModel> getByCategory(ProductCategory category) {
    return _products.where((p) => p.category == category).toList();
  }

  List<ProductModel> search(String query) {
    if (query.trim().isEmpty) return products;
    final q = query.toLowerCase();
    return _products.where((p) {
      return p.name.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.category.displayName.toLowerCase().contains(q) ||
          p.location.toLowerCase().contains(q);
    }).toList();
  }

  void addProduct(ProductModel product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(ProductModel product) {
    final index = _products.indexWhere((p) => p.id == product.id);
    if (index != -1) {
      _products[index] = product;
      notifyListeners();
    }
  }

  void adjustStock(String productId, double quantityDelta) {
    final index = _products.indexWhere((p) => p.id == productId);
    if (index != -1) {
      final p = _products[index];
      final newStock = (p.currentStock + quantityDelta).clamp(0.0, double.infinity);
      _products[index] = p.copyWith(
        currentStock: newStock,
        lastUpdated: DateTime.now(),
      );
      notifyListeners();
    }
  }

  /// Unifica dois cadastros duplicados em um único insumo
  void mergeProducts(String primaryId, String duplicateId, String unifiedName) {
    final primaryIndex = _products.indexWhere((p) => p.id == primaryId);
    final duplicateIndex = _products.indexWhere((p) => p.id == duplicateId);

    if (primaryIndex != -1 && duplicateIndex != -1) {
      final primary = _products[primaryIndex];
      final duplicate = _products[duplicateIndex];

      final mergedStock = primary.currentStock + duplicate.currentStock;
      final mergedBatches = [...primary.batches, ...duplicate.batches];
      final double totalValue = primary.totalStockValue + duplicate.totalStockValue;
      final double avgCost = mergedStock > 0 ? totalValue / mergedStock : primary.averageUnitCost;

      _products[primaryIndex] = primary.copyWith(
        name: unifiedName,
        currentStock: mergedStock,
        averageUnitCost: avgCost,
        batches: mergedBatches,
        lastUpdated: DateTime.now(),
        notes: '${primary.notes ?? ''} [Unificado com ${duplicate.code} em ${DateTime.now().day}/${DateTime.now().month}].',
      );

      _products.removeAt(duplicateIndex);
      notifyListeners();
    }
  }
}
