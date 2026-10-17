enum MovementType {
  entrada(label: 'Entrada', prefix: '+'),
  saida(label: 'Saída', prefix: '-');

  const MovementType({required this.label, required this.prefix});
  final String label;
  final String prefix;
}

class MovementModel {
  final String id;
  final String productId;
  final String productName;
  final MovementType type;
  final double quantity;
  final String unit;
  final DateTime date;
  final double? unitPrice; // Para compras / entradas
  final String? batchNumber;
  final DateTime? expirationDate;
  final String? supplier; // Fornecedor
  final String? destination; // Destino da retirada (ex: Talhão 02 - Soja, Trator John Deere)
  final String responsible; // Responsável pela operação
  final String? notes;

  const MovementModel({
    required this.id,
    required this.productId,
    required this.productName,
    required this.type,
    required this.quantity,
    required this.unit,
    required this.date,
    this.unitPrice,
    this.batchNumber,
    this.expirationDate,
    this.supplier,
    this.destination,
    required this.responsible,
    this.notes,
  });

  double get totalValue => quantity * (unitPrice ?? 0.0);

  bool get isEntry => type == MovementType.entrada;
  bool get isExit => type == MovementType.saida;
}
