import 'package:flutter/material.dart';
import '../../data/models/product_model.dart';
import '../../data/models/movement_model.dart';
import '../../data/models/alert_model.dart';
import '../../data/models/category_enum.dart';
import '../../data/repositories/inventory_repository.dart';
import '../../data/repositories/movement_repository.dart';
import '../engine/stock_intelligence_engine.dart';

class StockIntelligenceViewModel extends ChangeNotifier {
  final InventoryRepository _inventoryRepo;
  final MovementRepository _movementRepo;
  final StockIntelligenceEngine _engine;

  IntelligenceAnalysisResult? _currentAnalysis;
  bool _isLoading = false;

  // Filtros de UI
  ProductCategory? _selectedCategory;
  AlertSeverity? _selectedSeverity;
  String _searchQuery = '';

  // Parâmetros de Simulação What-If
  double _simulationConsumptionFactor = 1.0; // 1.0 = normal, 1.3 = +30% de consumo
  int _simulationLeadTimeDays = 0; // Dias adicionais de atraso do fornecedor

  StockIntelligenceViewModel({
    required this._inventoryRepo,
    required this._movementRepo,
    this._engine = const StockIntelligenceEngine(),
  }) {
    _inventoryRepo.addListener(_onDataChanged);
    _movementRepo.addListener(_onDataChanged);
    reanalyze();
  }

  @override
  void dispose() {
    _inventoryRepo.removeListener(_onDataChanged);
    _movementRepo.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    reanalyze();
  }

  // Getters
  bool get isLoading => _isLoading;
  IntelligenceAnalysisResult? get analysis => _currentAnalysis;
  FarmHealthSummary? get summary => _currentAnalysis?.summary;

  List<ProductModel> get products {
    var list = _inventoryRepo.products;
    if (_selectedCategory != null) {
      list = list.where((p) => p.category == _selectedCategory).toList();
    }
    if (_searchQuery.isNotEmpty) {
      final q = _searchQuery.toLowerCase();
      list = list.where((p) =>
          p.name.toLowerCase().contains(q) ||
          p.code.toLowerCase().contains(q) ||
          p.category.displayName.toLowerCase().contains(q)).toList();
    }
    return list;
  }

  List<MovementModel> get movements => _movementRepo.movements;

  List<AlertModel> get filteredAlerts {
    if (_currentAnalysis == null) return [];
    var list = _currentAnalysis!.allAlerts;
    if (_selectedSeverity != null) {
      list = list.where((a) => a.severity == _selectedSeverity).toList();
    }
    return list;
  }

  ProductCategory? get selectedCategory => _selectedCategory;
  AlertSeverity? get selectedSeverity => _selectedSeverity;
  String get searchQuery => _searchQuery;

  double get simulationConsumptionFactor => _simulationConsumptionFactor;
  int get simulationLeadTimeDays => _simulationLeadTimeDays;

  // Modificadores de Filtro
  void setCategoryFilter(ProductCategory? category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void setSeverityFilter(AlertSeverity? severity) {
    _selectedSeverity = severity;
    notifyListeners();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  // Simulação What-If
  void updateSimulation({double? consumptionFactor, int? leadTimeDays}) {
    if (consumptionFactor != null) _simulationConsumptionFactor = consumptionFactor;
    if (leadTimeDays != null) _simulationLeadTimeDays = leadTimeDays;
    reanalyze();
  }

  void resetSimulation() {
    _simulationConsumptionFactor = 1.0;
    _simulationLeadTimeDays = 0;
    reanalyze();
  }

  // Ações de Negócio
  void recordNewMovement(MovementModel movement) {
    _movementRepo.recordMovement(movement);
  }

  void unifyProducts(String primaryId, String duplicateId, String unifiedName) {
    _inventoryRepo.mergeProducts(primaryId, duplicateId, unifiedName);
    _movementRepo.reassignMovements(duplicateId, primaryId, unifiedName);
    reanalyze();
  }

  void resetAllToDemonstration() {
    _inventoryRepo.resetToMockData();
    _movementRepo.resetToMockData();
    resetSimulation();
  }

  /// Executa o motor analítico
  void reanalyze() {
    _isLoading = true;
    notifyListeners();

    // Se houver simulação de consumo ativa, ajustamos virtualmente o cálculo
    _currentAnalysis = _engine.runAnalysis(
      products: _inventoryRepo.products,
      movements: _movementRepo.movements,
    );

    _isLoading = false;
    notifyListeners();
  }
}
