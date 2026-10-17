import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../data/models/movement_model.dart';
import '../../../data/models/product_model.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../../../core/routes/app_routes.dart';

class MovementsView extends StatelessWidget {
  const MovementsView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final movements = vm.movements;

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      appBar: AppBar(
        title: const Text('Movimentações'),
        backgroundColor: ArvoColors.petroleo,
        actions: [
          IconButton(
            icon: const Icon(Icons.inventory_2_outlined),
            tooltip: 'Ver Insumos',
            onPressed: () => AppRoutes.toInventory(context),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showNewMovementDialog(context, vm),
        backgroundColor: ArvoColors.petroleo,
        foregroundColor: ArvoColors.nevoa,
        icon: const Icon(Icons.add_rounded),
        label: const Text(
          'Registrar',
          style: TextStyle(fontFamily: ArvoTypography.fontHeading, fontWeight: FontWeight.w600),
        ),
      ),
      body: movements.isEmpty
          ? const Center(
              child: Text(
                'Nenhuma movimentação registrada.',
                style: TextStyle(fontFamily: ArvoTypography.fontBody, color: ArvoColors.musgo),
              ),
            )
          : ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
              itemCount: movements.length,
              itemBuilder: (context, index) {
                final mov = movements[index];
                return _buildMovementCard(mov);
              },
            ),
    );
  }

  Widget _buildMovementCard(MovementModel mov) {
    final isEntry = mov.isEntry;
    final color = isEntry ? ArvoColors.folha : ArvoColors.ambar;
    final sign = isEntry ? '+' : '-';

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ArvoColors.linha),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Ícone de Tipo
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isEntry ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(width: 14),

          // Detalhes da Movimentação
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mov.productName,
                  style: const TextStyle(
                    fontFamily: ArvoTypography.fontHeading,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: ArvoColors.grafite,
                  ),
                ),
                const SizedBox(height: 3),
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

          // Quantidade
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '$sign${mov.quantity.toStringAsFixed(0)} ${mov.unit}',
                style: TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
              if (mov.unitPrice != null && mov.unitPrice! > 0)
                Text(
                  Formatters.formatCurrency(mov.totalValue),
                  style: const TextStyle(
                    fontFamily: ArvoTypography.fontBody,
                    fontSize: 11,
                    color: ArvoColors.musgo,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  void _showNewMovementDialog(BuildContext context, StockIntelligenceViewModel vm) {
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
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text(
              'Nova Movimentação de Insumo',
              style: TextStyle(fontFamily: ArvoTypography.fontHeading),
            ),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Insumo:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
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

                  const Text('Tipo de Movimentação:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Saída / Retirada')),
                          selected: selectedType == MovementType.saida,
                          onSelected: (_) => setState(() => selectedType = MovementType.saida),
                          selectedColor: ArvoColors.ambar,
                          labelStyle: TextStyle(
                            color: selectedType == MovementType.saida ? Colors.white : ArvoColors.grafite,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Center(child: Text('Entrada / Compra')),
                          selected: selectedType == MovementType.entrada,
                          onSelected: (_) => setState(() => selectedType = MovementType.entrada),
                          selectedColor: ArvoColors.folha,
                          labelStyle: TextStyle(
                            color: selectedType == MovementType.entrada ? Colors.white : ArvoColors.grafite,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  Text('Quantidade (${selectedProduct.unit}):',
                      style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                  const SizedBox(height: 4),
                  TextField(
                    controller: qtyController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(isDense: true),
                  ),
                  const SizedBox(height: 12),

                  if (selectedType == MovementType.saida) ...[
                    const Text('Destino da Retirada (Talhão / Máquina):',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: targetController,
                      decoration: const InputDecoration(isDense: true),
                    ),
                  ] else ...[
                    const Text('Preço Unitário de Aquisição (R\$):',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(isDense: true),
                    ),
                    const SizedBox(height: 12),
                    const Text('Fornecedor:', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
                    const SizedBox(height: 4),
                    TextField(
                      controller: targetController,
                      decoration: const InputDecoration(isDense: true, hintText: 'Ex: AgroSul Distribuidora'),
                    ),
                  ],
                  const SizedBox(height: 12),

                  const Text('Responsável pela Operação:',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
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
                    unitPrice: selectedType == MovementType.entrada ? price : selectedProduct.averageUnitCost,
                    supplier: selectedType == MovementType.entrada ? targetController.text : null,
                    destination: selectedType == MovementType.saida ? targetController.text : null,
                    responsible: respController.text.trim().isNotEmpty ? respController.text : 'Operador',
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
