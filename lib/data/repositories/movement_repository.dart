import 'package:flutter/foundation.dart';
import '../models/movement_model.dart';
import '../mock/agro_mock_data.dart';
import 'inventory_repository.dart';

class MovementRepository extends ChangeNotifier {
  final InventoryRepository _inventoryRepo;
  List<MovementModel> _movements = [];

  MovementRepository({required this._inventoryRepo}) {
    resetToMockData();
  }

  List<MovementModel> get movements => List.unmodifiable(_movements);

  void resetToMockData() {
    _movements = AgroMockData.getInitialMovements();
    notifyListeners();
  }

  List<MovementModel> getMovementsForProduct(String productId) {
    return _movements.where((m) => m.productId == productId).toList()
      ..sort((a, b) => b.date.compareTo(a.date));
  }

  /// Registra nova movimentação e atualiza o saldo do produto correspondente
  void recordMovement(MovementModel movement) {
    _movements.insert(0, movement);

    // Ajusta o saldo físico no repositório de produtos
    final delta = movement.isEntry ? movement.quantity : -movement.quantity;
    _inventoryRepo.adjustStock(movement.productId, delta);

    notifyListeners();
  }

  /// Reassocia movimentações de um produto duplicado para o produto unificado
  void reassignMovements(String oldProductId, String newProductId, String newProductName) {
    for (int i = 0; i < _movements.length; i++) {
      if (_movements[i].productId == oldProductId) {
        final m = _movements[i];
        _movements[i] = MovementModel(
          id: m.id,
          productId: newProductId,
          productName: newProductName,
          type: m.type,
          quantity: m.quantity,
          unit: m.unit,
          date: m.date,
          unitPrice: m.unitPrice,
          batchNumber: m.batchNumber,
          expirationDate: m.expirationDate,
          supplier: m.supplier,
          destination: m.destination,
          responsible: m.responsible,
          notes: m.notes,
        );
      }
    }
    notifyListeners();
  }
}
