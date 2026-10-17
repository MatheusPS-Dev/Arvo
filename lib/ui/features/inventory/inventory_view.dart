import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_enum.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../../../core/routes/app_routes.dart';

class InventoryView extends StatelessWidget {
  const InventoryView({super.key});

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final products = vm.products;
    final runouts = vm.analysis?.runoutByProductId ?? {};

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
      appBar: AppBar(
        title: const Text('Gestão de Insumos'),
        backgroundColor: ArvoColors.petroleo,
        actions: [
          IconButton(
            icon: const Icon(Icons.swap_horiz_rounded),
            tooltip: 'Ver Movimentações',
            onPressed: () => AppRoutes.toMovements(context),
          ),
          IconButton(
            icon: const Icon(Icons.tune_rounded),
            tooltip: 'Simulador What-If',
            onPressed: () => AppRoutes.toSimulation(context),
          ),
        ],
      ),
      body: Column(
        children: [
          // Barra de Pesquisa e Filtros de Categoria
          Container(
            color: Colors.white,
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Column(
              children: [
                TextField(
                  onChanged: vm.setSearchQuery,
                  decoration: InputDecoration(
                    hintText: 'Buscar insumo por nome, código ou local...',
                    prefixIcon: const Icon(Icons.search, color: ArvoColors.musgo),
                    suffixIcon: vm.searchQuery.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear, size: 18),
                            onPressed: () => vm.setSearchQuery(''),
                          )
                        : null,
                    isDense: true,
                  ),
                ),
                const SizedBox(height: 10),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip(context, null, 'Todas (${vm.products.length})', vm),
                      for (final cat in ProductCategory.values) ...[
                        const SizedBox(width: 6),
                        _buildCategoryChip(context, cat, cat.displayName, vm),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Lista de Produtos
          Expanded(
            child: products.isEmpty
                ? const Center(
                    child: Text(
                      'Nenhum insumo encontrado para a busca.',
                      style: TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        color: ArvoColors.musgo,
                      ),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: products.length,
                    itemBuilder: (context, index) {
                      final product = products[index];
                      final runout = runouts[product.id];
                      return _buildProductCard(context, product, runout);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(
    BuildContext context,
    ProductCategory? category,
    String label,
    StockIntelligenceViewModel vm,
  ) {
    final isSelected = vm.selectedCategory == category;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.setCategoryFilter(category),
      selectedColor: ArvoColors.petroleo,
      backgroundColor: ArvoColors.nevoa,
      labelStyle: TextStyle(
        fontFamily: ArvoTypography.fontBody,
        fontSize: 12,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
        color: isSelected ? Colors.white : ArvoColors.grafite,
      ),
      side: BorderSide(color: isSelected ? ArvoColors.petroleo : ArvoColors.linha),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    );
  }

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    dynamic runout,
  ) {
    final bool isBelowMin = product.isBelowMinStock;
    final double stockPercent = product.minStock > 0
        ? (product.currentStock / (product.minStock * 2)).clamp(0.0, 1.0)
        : 1.0;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isBelowMin ? ArvoColors.alerta.withValues(alpha: 0.5) : ArvoColors.linha,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => _showProductDetails(context, product, runout),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: product.category.color.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              product.category.displayName,
                              style: TextStyle(
                                fontFamily: ArvoTypography.fontBody,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                                color: product.category.color,
                              ),
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            product.name,
                            style: ArvoTypography.titleSmall.copyWith(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${product.code} • ${product.location}',
                            style: const TextStyle(
                              fontFamily: ArvoTypography.fontBody,
                              fontSize: 12,
                              color: ArvoColors.musgo,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${product.currentStock.toStringAsFixed(0)} ${product.unit}',
                          style: ArvoTypography.titleMedium.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: isBelowMin ? ArvoColors.erro : ArvoColors.petroleo,
                          ),
                        ),
                        Text(
                          Formatters.formatCurrency(product.totalStockValue),
                          style: const TextStyle(
                            fontFamily: ArvoTypography.fontBody,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: ArvoColors.musgo,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Barra de Nível de Estoque
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: stockPercent,
                    backgroundColor: ArvoColors.linha.withValues(alpha: 0.5),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      isBelowMin ? ArvoColors.erro : ArvoColors.folha,
                    ),
                    minHeight: 6,
                  ),
                ),
                const SizedBox(height: 8),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Mínimo: ${product.minStock.toStringAsFixed(0)} ${product.unit}',
                      style: const TextStyle(
                        fontFamily: ArvoTypography.fontBody,
                        fontSize: 11,
                        color: ArvoColors.musgo,
                      ),
                    ),
                    if (runout != null && runout.dailyConsumptionRate > 0)
                      Text(
                        'Autonomia: ~${runout.daysOfStockRemaining.toStringAsFixed(0)} dias (${runout.dailyConsumptionRate.toStringAsFixed(1)} ${product.unit}/dia)',
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: runout.daysOfStockRemaining < 10
                              ? ArvoColors.erro
                              : ArvoColors.petroleo,
                        ),
                      )
                    else
                      const Text(
                        'Sem consumo recente',
                        style: TextStyle(
                          fontFamily: ArvoTypography.fontBody,
                          fontSize: 11,
                          color: ArvoColors.musgo,
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showProductDetails(BuildContext context, ProductModel product, dynamic runout) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.75,
        maxChildSize: 0.95,
        minChildSize: 0.5,
        builder: (_, scrollController) => Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: ArvoColors.linha,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                product.name,
                style: ArvoTypography.titleLarge,
              ),
              Text(
                '${product.code} • Categoria: ${product.category.displayName}',
                style: const TextStyle(
                  fontFamily: ArvoTypography.fontBody,
                  color: ArvoColors.musgo,
                ),
              ),
              const Divider(height: 32),

              const Text(
                'INDICADORES DE GESTÃO',
                style: TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ArvoColors.petroleo,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDetailTile('Saldo Atual', '${product.currentStock.toStringAsFixed(0)} ${product.unit}'),
                  _buildDetailTile('Estoque Mínimo', '${product.minStock.toStringAsFixed(0)} ${product.unit}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildDetailTile('Custo Médio', Formatters.formatCurrency(product.averageUnitCost)),
                  _buildDetailTile('Capital Parado', Formatters.formatCurrency(product.totalStockValue)),
                ],
              ),
              const SizedBox(height: 20),

              const Text(
                'LOTES E VALIDADES',
                style: TextStyle(
                  fontFamily: ArvoTypography.fontHeading,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: ArvoColors.petroleo,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 10),
              if (product.batches.isEmpty)
                const Text('Nenhum lote específico registrado.')
              else
                for (final batch in product.batches)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: ArvoColors.nevoa,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: ArvoColors.linha),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Lote ${batch.batchNumber}',
                              style: const TextStyle(
                                fontFamily: ArvoTypography.fontHeading,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Vence em: ${Formatters.formatDate(batch.expirationDate)} (${batch.daysUntilExpiration} dias)',
                              style: TextStyle(
                                fontFamily: ArvoTypography.fontBody,
                                fontSize: 12,
                                color: batch.daysUntilExpiration < 30
                                    ? ArvoColors.erro
                                    : ArvoColors.musgo,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          '${batch.remainingQuantity.toStringAsFixed(0)} ${product.unit}',
                          style: const TextStyle(
                            fontFamily: ArvoTypography.fontHeading,
                            fontWeight: FontWeight.w700,
                            color: ArvoColors.petroleo,
                          ),
                        ),
                      ],
                    ),
                  ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Fechar Ficha do Insumo'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailTile(String label, String value) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: ArvoColors.nevoa,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label, style: const TextStyle(fontSize: 11, color: ArvoColors.musgo)),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontFamily: ArvoTypography.fontHeading,
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: ArvoColors.petroleo,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
