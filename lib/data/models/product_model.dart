import 'batch_model.dart';
import 'category_enum.dart';

class ProductModel {
  final String id;
  final String code;
  final String name;
  final ProductCategory category;
  final String unit;
  final double currentStock;
  final double minStock;
  final double averageUnitCost;
  final String location;
  final List<BatchModel> batches;
  final DateTime lastUpdated;
  final String? notes;

  const ProductModel({
    required this.id,
    required this.code,
    required this.name,
    required this.category,
    required this.unit,
    required this.currentStock,
    required this.minStock,
    required this.averageUnitCost,
    this.location = 'Barracão Principal',
    this.batches = const [],
    required this.lastUpdated,
    this.notes,
  });

  double get totalStockValue => currentStock * averageUnitCost;

  bool get isBelowMinStock => currentStock <= minStock;

  bool get isCritical => currentStock <= (minStock * 0.5);

  ProductModel copyWith({
    String? id,
    String? code,
    String? name,
    ProductCategory? category,
    String? unit,
    double? currentStock,
    double? minStock,
    double? averageUnitCost,
    String? location,
    List<BatchModel>? batches,
    DateTime? lastUpdated,
    String? notes,
  }) {
    return ProductModel(
      id: id ?? this.id,
      code: code ?? this.code,
      name: name ?? this.name,
      category: category ?? this.category,
      unit: unit ?? this.unit,
      currentStock: currentStock ?? this.currentStock,
      minStock: minStock ?? this.minStock,
      averageUnitCost: averageUnitCost ?? this.averageUnitCost,
      location: location ?? this.location,
      batches: batches ?? this.batches,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      notes: notes ?? this.notes,
    );
  }
}
