class BatchModel {
  final String batchNumber;
  final DateTime expirationDate;
  final double initialQuantity;
  final double remainingQuantity;
  final double unitCost;
  final DateTime entryDate;

  const BatchModel({
    required this.batchNumber,
    required this.expirationDate,
    required this.initialQuantity,
    required this.remainingQuantity,
    required this.unitCost,
    required this.entryDate,
  });

  bool get isExpired => DateTime.now().isAfter(expirationDate);

  int get daysUntilExpiration {
    final now = DateTime.now();
    return expirationDate.difference(DateTime(now.year, now.month, now.day)).inDays;
  }

  double get totalValue => remainingQuantity * unitCost;

  BatchModel copyWith({
    String? batchNumber,
    DateTime? expirationDate,
    double? initialQuantity,
    double? remainingQuantity,
    double? unitCost,
    DateTime? entryDate,
  }) {
    return BatchModel(
      batchNumber: batchNumber ?? this.batchNumber,
      expirationDate: expirationDate ?? this.expirationDate,
      initialQuantity: initialQuantity ?? this.initialQuantity,
      remainingQuantity: remainingQuantity ?? this.remainingQuantity,
      unitCost: unitCost ?? this.unitCost,
      entryDate: entryDate ?? this.entryDate,
    );
  }
}
