import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../data/models/movement_model.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/engine/anomaly_detector.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../../../core/routes/app_routes.dart';
import '../../core/widgets/arvo_brand_graphics.dart';
import '../../core/widgets/arvo_header.dart';

class MovementsView extends StatefulWidget {
  final ValueChanged<int>? onNavigateTab;

  const MovementsView({super.key, this.onNavigateTab});

  @override
  State<MovementsView> createState() => _MovementsViewState();
}

class _MovementsViewState extends State<MovementsView> {
  String _selectedTypeFilter = 'all'; // 'all', 'entrada', 'saida', 'anomaly'

  void _navigateToInventory(BuildContext context) {
    if (widget.onNavigateTab != null) {
      widget.onNavigateTab!(2);
    } else {
      AppRoutes.toInventory(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final allMovements = vm.movements;
    final outliers = vm.analysis?.outlierMovements ?? [];
    final outlierByMovementId = <String, AnomalyResult>{
      for (final o in outliers) o.movement.id: o,
    };

    final filteredMovements = allMovements.where((m) {
      if (_selectedTypeFilter == 'entrada') return m.isEntry;
      if (_selectedTypeFilter == 'saida') return m.isExit;
      if (_selectedTypeFilter == 'anomaly') {
        return outlierByMovementId.containsKey(m.id);
      }
      return true;
    }).toList();

    final entriesCount = allMovements.where((m) => m.isEntry).length;
    final exitsCount = allMovements.where((m) => m.isExit).length;
    final screenWidth = MediaQuery.sizeOf(context).width;
    final isMobile = screenWidth < 768;

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      // FloatingActionButton exclusivo para Mobile (< 768px); em Desktop o CTA primário fica no Page Header
      floatingActionButton: isMobile
          ? FloatingActionButton.extended(
              onPressed: () => _showNewMovementDialog(context, vm),
              backgroundColor: ArvoColors.petroleo,
              foregroundColor: ArvoColors.nevoa,
              icon: const Icon(Icons.add_rounded),
              label: const Text(
                'Registrar',
                style: TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontWeight: FontWeight.w600,
                ),
              ),
            )
          : null,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 768;
          final horizontalPad = isWide ? 28.0 : 16.0;

          return Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1240),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPad),
                child: CustomScrollView(
                  slivers: [
                    // 1. Page Header Editorial Limpo com CTA Primário "+ Registrar Movimentação"
                    SliverToBoxAdapter(
                      child: ArvoPageHeader(
                        kicker: 'RASTREABILIDADE DE CAMPO',
                        title: 'Movimentações',
                        subtitle:
                            'Histórico auditável de entradas, aplicações por talhão e detecção estatística de desvios (> 2σ).',
                        allowStandaloneBack: widget.onNavigateTab == null,
                        actions: [
                          OutlinedButton.icon(
                            onPressed: () => _navigateToInventory(context),
                            icon: const Icon(
                              Icons.inventory_2_outlined,
                              size: 17,
                            ),
                            label: const Text('Ver Insumos'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: ArvoColors.petroleo,
                              backgroundColor: Colors.white,
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 10,
                              ),
                              side: const BorderSide(color: ArvoColors.linha),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          FilledButton.icon(
                            onPressed: () => _showNewMovementDialog(context, vm),
                            icon: const Icon(Icons.add_rounded, size: 18),
                            label: const Text('Registrar Movimentação'),
                            style: FilledButton.styleFrom(
                              backgroundColor: ArvoColors.petroleo,
                              foregroundColor: ArvoColors.nevoa,
                              minimumSize: const Size(0, 42),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              textStyle: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // 2. Resumo de Entradas / Saídas / Anomalias (2σ) dentro do Grid 1240px
                    SliverToBoxAdapter(
                      child: Builder(
                        builder: (context) {
                          final isCompact = constraints.maxWidth < 640;
                          final gap = isCompact ? 8.0 : 12.0;
                          return IntrinsicHeight(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Expanded(
                                  child: _buildSummaryCard(
                                    iconName: 'icone-estoque',
                                    label: 'Entradas / Compra',
                                    compactLabel: 'Entradas',
                                    value: '+$entriesCount',
                                    subtitle: 'Abastecimentos de lote',
                                    bgColor: ArvoColors.sucessoFundo,
                                    textColor: ArvoColors.sucessoTexto,
                                    isCompact: isCompact,
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _buildSummaryCard(
                                    iconName: 'icone-talhao',
                                    label: 'Saídas Campo',
                                    compactLabel: 'Saídas Campo',
                                    value: '-$exitsCount',
                                    subtitle: 'Aplicações em talhão',
                                    bgColor: ArvoColors.alertaFundo,
                                    textColor: ArvoColors.alertaTexto,
                                    isCompact: isCompact,
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _buildSummaryCard(
                                    iconName: 'icone-relatorio',
                                    label: 'Desvios (> 2σ)',
                                    compactLabel: 'Desvios (> 2σ)',
                                    value: '${outliers.length} alerta(s)',
                                    compactValue: '${outliers.length}',
                                    subtitle: outliers.isNotEmpty
                                        ? 'Fora do padrão histórico'
                                        : 'Dentro da normalidade',
                                    bgColor: outliers.isNotEmpty
                                        ? ArvoColors.erroFundo
                                        : ArvoColors.infoFundo,
                                    textColor: outliers.isNotEmpty
                                        ? ArvoColors.erroTexto
                                        : ArvoColors.infoTexto,
                                    highlightBorder: outliers.isNotEmpty,
                                    isCompact: isCompact,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 14)),

                    // 3. Barra de Filtros Rápidos em Container Branco Alinhado ao Grid
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: isWide ? 16 : 13,
                          vertical: isWide ? 14 : 11,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ArvoColors.linha),
                          boxShadow: ArvoColors.sombraCardSuave,
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              const Text(
                                'FILTRAR REGISTROS:',
                                style: ArvoTypography.kicker,
                              ),
                              const SizedBox(width: 12),
                              _buildFilterChip(
                                'all',
                                'Todas (${allMovements.length})',
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'saida',
                                'Saídas / Campo ($exitsCount)',
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'entrada',
                                'Entradas / Compra ($entriesCount)',
                              ),
                              const SizedBox(width: 8),
                              _buildFilterChip(
                                'anomaly',
                                'Anomalias 2σ (${outliers.length})',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // 4. Lista de Movimentações
                    if (filteredMovements.isEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ArvoColors.linha),
                          ),
                          child: const Center(
                            child: Text(
                              'Nenhuma movimentação registrada para este filtro.',
                              style: TextStyle(
                                fontFamily: ArvoTypography.fontBody,
                                color: ArvoColors.musgo,
                              ),
                            ),
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final mov = filteredMovements[index];
                            final anomaly = outlierByMovementId[mov.id];
                            return _buildMovementCard(mov, anomaly);
                          },
                          childCount: filteredMovements.length,
                        ),
                      ),

                    SliverToBoxAdapter(
                      child: SizedBox(height: isMobile ? 88 : 36),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryCard({
    required String iconName,
    required String label,
    String? compactLabel,
    required String value,
    String? compactValue,
    required String subtitle,
    required Color bgColor,
    required Color textColor,
    bool highlightBorder = false,
    bool isCompact = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isCompact ? 10 : 16,
        vertical: isCompact ? 11 : 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(isCompact ? 14 : 16),
        border: Border.all(
          color: highlightBorder
              ? ArvoColors.erro.withValues(alpha: 0.45)
              : ArvoColors.linha,
        ),
        boxShadow: ArvoColors.sombraCardSuave,
      ),
      child: isCompact
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: bgColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: ArvoBrandIcon(
                        iconName: iconName,
                        size: 15,
                        color: textColor,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        compactValue ?? value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArvoTypography.metricSmall.copyWith(
                          fontSize: 15.5,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  compactLabel ?? label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: ArvoTypography.fontBody,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: ArvoColors.musgo,
                  ),
                ),
              ],
            )
          : Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  padding: const EdgeInsets.all(9),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: ArvoBrandIcon(
                    iconName: iconName,
                    size: 20,
                    color: textColor,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: ArvoColors.musgo,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        value,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: ArvoTypography.metricSmall.copyWith(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: textColor,
                        ),
                      ),
                      Text(
                        subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: 11,
                          color: ArvoColors.musgo,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final isSelected = _selectedTypeFilter == key;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedTypeFilter = key),
      selectedColor: ArvoColors.petroleo,
      backgroundColor: ArvoColors.nevoa,
      checkmarkColor: Colors.white,
      labelStyle: TextStyle(
        fontFamily: ArvoTypography.fontBody,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
        color: isSelected ? Colors.white : ArvoColors.grafite,
      ),
      side: BorderSide(
        color: isSelected ? ArvoColors.petroleo : ArvoColors.linha,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(ArvoColors.radiusPill),
      ),
    );
  }

  Widget _buildMovementCard(MovementModel mov, AnomalyResult? anomaly) {
    final isEntry = mov.isEntry;
    final hasAnomaly = anomaly != null;
    final isCompactMobile = MediaQuery.sizeOf(context).width < 600;
    final color = hasAnomaly
        ? ArvoColors.erroTexto
        : (isEntry ? ArvoColors.sucessoTexto : ArvoColors.alertaTexto);
    final bgColor = hasAnomaly
        ? ArvoColors.erroFundo
        : (isEntry ? ArvoColors.sucessoFundo : ArvoColors.alertaFundo);
    final sign = isEntry ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: EdgeInsets.all(isCompactMobile ? 13 : 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
        border: Border.all(
          color: hasAnomaly
              ? ArvoColors.erro.withValues(alpha: 0.45)
              : ArvoColors.linha,
        ),
        boxShadow: ArvoColors.shadowSm,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Ícone de Tipo com Fundo Semântico WCAG AA
              Container(
                width: isCompactMobile ? 36 : 42,
                height: isCompactMobile ? 36 : 42,
                decoration: BoxDecoration(
                  color: bgColor,
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(
                  isEntry
                      ? Icons.south_west_rounded
                      : Icons.north_east_rounded,
                  color: color,
                  size: isCompactMobile ? 18 : 20,
                ),
              ),
              SizedBox(width: isCompactMobile ? 10 : 14),

              // Detalhes da Movimentação
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: Text(
                            mov.productName,
                            style: TextStyle(
                              fontFamily: ArvoTypography.fontHeading,
                              fontSize: isCompactMobile ? 14.5 : 15,
                              fontWeight: FontWeight.w700,
                              color: ArvoColors.grafite,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Quantidade Tabular no canto superior direito
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              '$sign${mov.quantity.toStringAsFixed(0)} ${mov.unit}',
                              style: ArvoTypography.metricSmall.copyWith(
                                fontSize: isCompactMobile ? 15 : 16,
                                color: color,
                              ),
                            ),
                            if (mov.unitPrice != null && mov.unitPrice! > 0)
                              Text(
                                Formatters.formatCurrency(mov.totalValue),
                                style: ArvoTypography.numberMono.copyWith(
                                  fontSize: 11,
                                  color: ArvoColors.musgo,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Wrap(
                      spacing: 6,
                      runSpacing: 4,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        if (hasAnomaly)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 7,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: ArvoColors.erroFundo,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              'Anomalia ${anomaly.deviationFactor.toStringAsFixed(1)}x',
                              style: ArvoTypography.numberMono.copyWith(
                                fontSize: 10,
                                fontWeight: FontWeight.w700,
                                color: ArvoColors.erroTexto,
                              ),
                            ),
                          ),
                        Text(
                          isEntry
                              ? 'Fornecedor: ${mov.supplier ?? "Almoxarifado"}'
                              : 'Destino: ${mov.destination ?? "Geral"}',
                          style: const TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            fontSize: 12,
                            color: ArvoColors.musgo,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${Formatters.formatDate(mov.date)} • Resp: ${mov.responsible}',
                      style: const TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        fontSize: 11,
                        color: ArvoColors.musgo,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (hasAnomaly) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
              decoration: BoxDecoration(
                color: ArvoColors.erroFundo.withValues(alpha: 0.6),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_amber_rounded,
                    size: 15,
                    color: ArvoColors.erroTexto,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Volume ${anomaly.deviationFactor.toStringAsFixed(1)}x acima da média histórica (${anomaly.typicalMean.toStringAsFixed(1)} ${mov.unit} ± ${anomaly.stdDev.toStringAsFixed(1)}).',
                      style: const TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: ArvoColors.erroTexto,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showNewMovementDialog(
    BuildContext context,
    StockIntelligenceViewModel vm,
  ) {
    final products = vm.products;
    if (products.isEmpty) return;

    ProductModel selectedProduct = products.first;
    MovementType selectedType = MovementType.saida;
    final qtyController = TextEditingController(text: '10');
    final targetController = TextEditingController(text: 'Talhão 03 - Milho');
    final respController = TextEditingController(text: 'Lucas Ferreira');
    final priceController = TextEditingController(text: '150');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Nova Movimentação de Insumo',
              style: TextStyle(fontFamily: ArvoTypography.fontHeading),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Insumo:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  DropdownButtonFormField<ProductModel>(
                    initialValue: selectedProduct,
                    isExpanded: true,
                    items: products.map((p) {
                      return DropdownMenuItem(
                        value: p,
                        child: Text(
                          '${p.name} (Saldo: ${p.currentStock.toStringAsFixed(0)} ${p.unit})',
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 13),
                        ),
                      );
                    }).toList(),
                    onChanged: (p) {
                      if (p != null) setState(() => selectedProduct = p);
                    },
                    decoration: const InputDecoration(isDense: true),
                  ),
                  const SizedBox(height: 12),

                  const Text(
                    'Tipo de Movimentação:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Saída / Retirada')),
                          selected: selectedType == MovementType.saida,
                          onSelected: (_) =>
                              setState(() => selectedType = MovementType.saida),
                          selectedColor: ArvoColors.ambar,
                          labelStyle: TextStyle(
                            color: selectedType == MovementType.saida
                                ? Colors.white
                                : ArvoColors.grafite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Entrada / Compra')),
                          selected: selectedType == MovementType.entrada,
                          onSelected: (_) => setState(
                            () => selectedType = MovementType.entrada,
                          ),
                          selectedColor: ArvoColors.folha,
                          labelStyle: TextStyle(
                            color: selectedType == MovementType.entrada
                                ? Colors.white
                                : ArvoColors.grafite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text(
                    'Quantidade (${selectedProduct.unit}):',
                    style: const TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(isDense: true),
                  ),
                  const SizedBox(height: 12),

                  if (selectedType == MovementType.saida) ...[
                    const Text(
                      'Destino da Retirada (Talhão / Máquina):',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: targetController,
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ] else ...[
                    const Text(
                      'Preço Unitário de Aquisição (R\$):',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(isDense: true),
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Fornecedor:',
                      style:
                          TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                    ),
                    const SizedBox(height: 4),
                    TextField(
                      controller: targetController,
                      decoration: const InputDecoration(
                        isDense: true,
                        hintText: 'Ex: AgroSul Distribuidora',
                      ),
                    ),
                  ],
                  const SizedBox(height: 12),

                  const Text(
                    'Responsável pela Operação:',
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  TextField(
                    controller: respController,
                    decoration: const InputDecoration(isDense: true),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar'),
              ),
              ElevatedButton(
                onPressed: () {
                  final qty = double.tryParse(qtyController.text) ?? 1.0;
                  final price = double.tryParse(priceController.text);
                  Navigator.pop(ctx);

                  final movement = MovementModel(
                    id: 'mov_${DateTime.now().millisecondsSinceEpoch}',
                    productId: selectedProduct.id,
                    productName: selectedProduct.name,
                    type: selectedType,
                    quantity: qty,
                    unit: selectedProduct.unit,
                    date: DateTime.now(),
                    unitPrice: selectedType == MovementType.entrada
                        ? price
                        : selectedProduct.averageUnitCost,
                    supplier: selectedType == MovementType.entrada
                        ? targetController.text
                        : null,
                    destination: selectedType == MovementType.saida
                        ? targetController.text
                        : null,
                    responsible: respController.text.trim().isNotEmpty
                        ? respController.text
                        : 'Operador',
                  );

                  vm.recordNewMovement(movement);

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Movimentação de ${selectedType.label.toLowerCase()} de ${selectedProduct.name} registrada com sucesso!',
                      ),
                      backgroundColor: ArvoColors.folha,
                    ),
                  );
                },
                child: const Text('Confirmar Registro'),
              ),
            ],
          );
        },
      ),
    );
  }
}
