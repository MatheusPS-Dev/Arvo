import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/theme/arvo_colors.dart';
import '../../../../core/theme/arvo_typography.dart';
import '../../../../core/utils/formatters.dart';
import '../../../data/models/product_model.dart';
import '../../../data/models/category_enum.dart';
import '../../../domain/engine/abc_curve_analyzer.dart';
import '../../../domain/engine/runout_calculator.dart';
import '../../../domain/viewmodels/stock_intelligence_viewmodel.dart';
import '../../../../core/routes/app_routes.dart';
import '../../core/widgets/arvo_brand_graphics.dart';
import '../../core/widgets/arvo_header.dart';

class InventoryView extends StatelessWidget {
  final ValueChanged<int>? onNavigateTab;

  const InventoryView({super.key, this.onNavigateTab});

  void _navigate(BuildContext context, int tabIndex, String fallbackRoute) {
    if (onNavigateTab != null) {
      onNavigateTab!(tabIndex);
    } else {
      AppRoutes.to(context, fallbackRoute);
    }
  }

  @override
  Widget build(BuildContext context) {
    final vm = context.watch<StockIntelligenceViewModel>();
    final products = vm.products;
    final runouts = vm.analysis?.runoutByProductId ?? {};
    final abcItems = vm.analysis?.abcItems ?? [];
    final abcByProductId = <String, AbcItemResult>{
      for (final item in abcItems) item.product.id: item,
    };

    final totalValue =
        products.fold<double>(0.0, (sum, p) => sum + p.totalStockValue);
    final belowMinCount = products.where((p) => p.isBelowMinStock).length;

    return Scaffold(
      backgroundColor: ArvoColors.nevoa,
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
                    // 1. Page Header Editorial Limpo (sem AppBar Petróleo duplicada)
                    SliverToBoxAdapter(
                      child: ArvoPageHeader(
                        kicker: 'PORTFÓLIO & LOTES',
                        title: 'Gestão de Insumos',
                        subtitle:
                            'Controle físico-financeiro, Curva ABC de Pareto e rastreabilidade FEFO por lote e validade.',
                        allowStandaloneBack: onNavigateTab == null,
                        actions: [
                          OutlinedButton.icon(
                            onPressed: () =>
                                _navigate(context, 3, AppRoutes.movements),
                            icon: const Icon(
                              Icons.swap_horiz_rounded,
                              size: 17,
                            ),
                            label: const Text('Movimentações'),
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
                            onPressed: () =>
                                _navigate(context, 4, AppRoutes.simulation),
                            icon: const Icon(Icons.tune_rounded, size: 17),
                            label: const Text('Simulador What-If'),
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

                    // 2. Resumo de Portfólio (3 Cards Adaptativos dentro do Grid 1240px)
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
                                  child: _buildPortfolioStatCard(
                                    iconName: 'icone-estoque',
                                    label: 'Itens Exibidos',
                                    compactLabel: 'Itens Ativos',
                                    value: '${products.length}',
                                    subtitle: 'Insumos ativos no filtro',
                                    bgColor: ArvoColors.iconePastoFundo,
                                    textColor: ArvoColors.petroleo,
                                    isCompact: isCompact,
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _buildPortfolioStatCard(
                                    iconName: 'icone-financeiro',
                                    label: 'Capital no Filtro',
                                    compactLabel: 'Capital Filtro',
                                    value: Formatters.formatCompactCurrency(
                                      totalValue,
                                    ),
                                    subtitle: 'Valor em estoque físico',
                                    bgColor: ArvoColors.iconeFinanceiroFundo,
                                    textColor: ArvoColors.petroleo,
                                    isCompact: isCompact,
                                  ),
                                ),
                                SizedBox(width: gap),
                                Expanded(
                                  child: _buildPortfolioStatCard(
                                    iconName: 'icone-relatorio',
                                    label: 'Abaixo do Mín.',
                                    compactLabel: 'Abaixo Mín.',
                                    value: '$belowMinCount',
                                    subtitle: belowMinCount > 0
                                        ? 'Requer reposição'
                                        : 'Saldos regulares',
                                    bgColor: belowMinCount > 0
                                        ? ArvoColors.erroFundo
                                        : ArvoColors.sucessoFundo,
                                    textColor: belowMinCount > 0
                                        ? ArvoColors.erroTexto
                                        : ArvoColors.sucessoTexto,
                                    highlightBorder: belowMinCount > 0,
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

                    // 3. Barra de Busca + Filtros de Categoria Contida no Grid (borderRadius: 16)
                    SliverToBoxAdapter(
                      child: Container(
                        padding: EdgeInsets.all(isWide ? 16 : 13),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: ArvoColors.linha),
                          boxShadow: ArvoColors.sombraCardSuave,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              onChanged: vm.setSearchQuery,
                              decoration: InputDecoration(
                                hintText:
                                    'Buscar insumo por nome, código ou localização no galpão...',
                                prefixIcon: const Icon(
                                  Icons.search_rounded,
                                  color: ArvoColors.musgo,
                                ),
                                suffixIcon: vm.searchQuery.isNotEmpty
                                    ? IconButton(
                                        icon: const Icon(
                                          Icons.clear_rounded,
                                          size: 18,
                                        ),
                                        tooltip: 'Limpar busca',
                                        onPressed: () => vm.setSearchQuery(''),
                                      )
                                    : null,
                                isDense: true,
                              ),
                            ),
                            const SizedBox(height: 12),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: [
                                  _buildCategoryChip(
                                    context,
                                    null,
                                    'Todas (${vm.summary?.totalProductsCount ?? products.length})',
                                    vm,
                                  ),
                                  for (final cat in ProductCategory.values) ...[
                                    const SizedBox(width: 8),
                                    _buildCategoryChip(
                                      context,
                                      cat,
                                      cat.displayName,
                                      vm,
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SliverToBoxAdapter(child: SizedBox(height: 16)),

                    // 4. Lista de Produtos Alinhada ao Grid
                    if (products.isEmpty)
                      SliverToBoxAdapter(
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(36),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(color: ArvoColors.linha),
                          ),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 56,
                                height: 56,
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  color: ArvoColors.iconePastoFundo,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: const ArvoBrandIcon(
                                  iconName: 'icone-estoque',
                                  size: 28,
                                  color: ArvoColors.petroleo,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Nenhum insumo encontrado para a busca.',
                                style: ArvoTypography.titleSmall,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 4),
                              const Text(
                                'Tente limpar os filtros ou buscar por outro código ou categoria.',
                                style: ArvoTypography.bodySmall,
                                textAlign: TextAlign.center,
                              ),
                              if (vm.selectedCategory != null ||
                                  vm.searchQuery.isNotEmpty) ...[
                                const SizedBox(height: 12),
                                OutlinedButton.icon(
                                  onPressed: () {
                                    vm.setCategoryFilter(null);
                                    vm.setSearchQuery('');
                                  },
                                  icon: const Icon(
                                    Icons.filter_alt_off_rounded,
                                    size: 16,
                                  ),
                                  label: const Text('Limpar Filtros'),
                                ),
                              ],
                            ],
                          ),
                        ),
                      )
                    else
                      SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final product = products[index];
                            final runout = runouts[product.id];
                            final abcItem = abcByProductId[product.id];
                            return _buildProductCard(
                              context,
                              product,
                              runout,
                              abcItem,
                            );
                          },
                          childCount: products.length,
                        ),
                      ),

                    const SliverToBoxAdapter(child: SizedBox(height: 36)),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildPortfolioStatCard({
    required String iconName,
    required String label,
    String? compactLabel,
    required String value,
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
                        value,
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
                          fontSize: 19,
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

  Widget _buildCategoryChip(
    BuildContext context,
    ProductCategory? category,
    String label,
    StockIntelligenceViewModel vm,
  ) {
    final isSelected = vm.selectedCategory == category;
    return ChoiceChip(
      avatar: category != null
          ? ArvoBrandIcon(
              iconName: category.iconName,
              size: 14,
              color: isSelected ? Colors.white : category.color,
            )
          : null,
      label: Text(label),
      selected: isSelected,
      onSelected: (_) => vm.setCategoryFilter(category),
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

  Widget _buildProductCard(
    BuildContext context,
    ProductModel product,
    RunoutResult? runout,
    AbcItemResult? abcItem,
  ) {
    final isCompactMobile = MediaQuery.sizeOf(context).width < 600;
    final bool isBelowMin = product.isBelowMinStock;
    final bool isCriticalRunout = runout != null &&
        runout.dailyConsumptionRate > 0 &&
        runout.daysOfStockRemaining < 10;
    final double stockPercent = product.minStock > 0
        ? (product.currentStock / (product.minStock * 2)).clamp(0.0, 1.0)
        : 1.0;

    final Color statusBg = isBelowMin || isCriticalRunout
        ? ArvoColors.erroFundo
        : (stockPercent < 0.65
            ? ArvoColors.alertaFundo
            : ArvoColors.sucessoFundo);
    final Color statusText = isBelowMin || isCriticalRunout
        ? ArvoColors.erroTexto
        : (stockPercent < 0.65
            ? ArvoColors.alertaTexto
            : ArvoColors.sucessoTexto);
    final String statusLabel = isBelowMin
        ? 'Abaixo do Mínimo'
        : (isCriticalRunout ? 'Ruptura < 10d' : 'Estoque Saudável');

    return Semantics(
      button: true,
      label:
          '${product.name}, saldo ${product.currentStock.toStringAsFixed(0)} ${product.unit}, $statusLabel',
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
          border: Border.all(
            color: isBelowMin
                ? ArvoColors.erro.withValues(alpha: 0.45)
                : ArvoColors.linha,
          ),
          boxShadow: ArvoColors.shadowCard,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(ArvoColors.radiusLg),
            onTap: () =>
                _showProductDetails(context, product, runout, abcItem),
            child: Padding(
              padding: EdgeInsets.all(isCompactMobile ? 13 : 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Ícone Oficial Arvô em Container Pastel
                      Container(
                        width: isCompactMobile ? 36 : 42,
                        height: isCompactMobile ? 36 : 42,
                        padding: EdgeInsets.all(isCompactMobile ? 8 : 9),
                        decoration: BoxDecoration(
                          color: product.category.color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(11),
                        ),
                        child: ArvoBrandIcon(
                          iconName: product.category.iconName,
                          size: isCompactMobile ? 19 : 22,
                          color: product.category.color,
                        ),
                      ),
                      SizedBox(width: isCompactMobile ? 10 : 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Wrap(
                              spacing: 6,
                              runSpacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: product.category.color
                                        .withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    product.category.displayName,
                                    style: TextStyle(
                                      fontFamily: ArvoTypography.fontBody,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: product.category.color,
                                    ),
                                  ),
                                ),
                                if (abcItem != null)
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 7,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: abcItem.classification.color
                                          .withValues(alpha: 0.12),
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: abcItem.classification.color
                                            .withValues(alpha: 0.3),
                                      ),
                                    ),
                                    child: Text(
                                      abcItem.classification.label,
                                      style: TextStyle(
                                        fontFamily: ArvoTypography.fontHeading,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: abcItem.classification.color,
                                      ),
                                    ),
                                  ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 7,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusBg,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    statusLabel,
                                    style: TextStyle(
                                      fontFamily: ArvoTypography.fontBody,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                      color: statusText,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 5),
                            Text(
                              product.name,
                              style: ArvoTypography.titleSmall.copyWith(
                                fontSize: isCompactMobile ? 15 : 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              '${product.code} • ${product.location}',
                              style: ArvoTypography.bodySmall.copyWith(
                                fontSize: isCompactMobile ? 11.5 : 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            '${product.currentStock.toStringAsFixed(0)} ${product.unit}',
                            style: ArvoTypography.metricSmall.copyWith(
                              fontSize: isCompactMobile ? 16 : 18,
                              color: isBelowMin
                                  ? ArvoColors.erroTexto
                                  : ArvoColors.petroleo,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            Formatters.formatCurrency(product.totalStockValue),
                            style: ArvoTypography.numberMono.copyWith(
                              fontSize: isCompactMobile ? 11 : 12,
                              fontWeight: FontWeight.w600,
                              color: ArvoColors.musgo,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 11),

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
                        style: ArvoTypography.numberMono.copyWith(
                          fontSize: 11,
                          color: ArvoColors.musgo,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (runout != null && runout.dailyConsumptionRate > 0)
                        Flexible(
                          child: Text(
                            'Autonomia: ~${runout.daysOfStockRemaining.toStringAsFixed(0)}d (${runout.dailyConsumptionRate.toStringAsFixed(1)} ${product.unit}/d)',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: ArvoTypography.numberMono.copyWith(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: runout.daysOfStockRemaining < 10
                                  ? ArvoColors.erroTexto
                                  : ArvoColors.petroleo,
                            ),
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
      ),
    );
  }

  void _showProductDetails(
    BuildContext context,
    ProductModel product,
    RunoutResult? runout,
    AbcItemResult? abcItem,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.78,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(11),
                    decoration: BoxDecoration(
                      color: product.category.color.withValues(alpha: 0.14),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: ArvoBrandIcon(
                      iconName: product.category.iconName,
                      size: 26,
                      color: product.category.color,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          product.name,
                          style: ArvoTypography.titleLarge,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${product.code} • Categoria: ${product.category.displayName} • ${product.location}',
                          style: ArvoTypography.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Divider(height: 28),

              const Text(
                'INDICADORES DE GESTÃO',
                style: ArvoTypography.sectionHeader,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildDetailTile(
                    'Saldo Atual',
                    '${product.currentStock.toStringAsFixed(0)} ${product.unit}',
                  ),
                  _buildDetailTile(
                    'Estoque Mínimo',
                    '${product.minStock.toStringAsFixed(0)} ${product.unit}',
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  _buildDetailTile(
                    'Custo Médio',
                    Formatters.formatCurrency(product.averageUnitCost),
                  ),
                  _buildDetailTile(
                    'Capital Parado',
                    Formatters.formatCurrency(product.totalStockValue),
                  ),
                ],
              ),
              if (abcItem != null ||
                  (runout != null && runout.dailyConsumptionRate > 0)) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    if (abcItem != null)
                      _buildDetailTile(
                        'Curva ABC Pareto',
                        '${abcItem.classification.label} (${abcItem.percentOfTotal.toStringAsFixed(1)}%)',
                      ),
                    if (runout != null && runout.dailyConsumptionRate > 0)
                      _buildDetailTile(
                        'Previsão Esgotamento',
                        '~${runout.daysOfStockRemaining.toStringAsFixed(0)} dias (${runout.dailyConsumptionRate.toStringAsFixed(1)} ${product.unit}/d)',
                      ),
                  ],
                ),
              ],
              const SizedBox(height: 20),

              const Text(
                'LOTES E VALIDADES (FEFO)',
                style: ArvoTypography.sectionHeader,
              ),
              const SizedBox(height: 10),
              if (product.batches.isEmpty)
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: ArvoColors.nevoa,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: ArvoColors.linha),
                  ),
                  child: const Text(
                    'Nenhum lote específico registrado para este insumo.',
                    style: ArvoTypography.bodySmall,
                  ),
                )
              else
                for (final batch in product.batches)
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: batch.daysUntilExpiration < 30
                          ? ArvoColors.erroFundo.withValues(alpha: 0.45)
                          : ArvoColors.nevoa,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: batch.daysUntilExpiration < 30
                            ? ArvoColors.erro.withValues(alpha: 0.4)
                            : ArvoColors.linha,
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Lote ${batch.batchNumber}',
                                    style: ArvoTypography.labelLarge
                                        .copyWith(fontSize: 13),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 6,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: batch.daysUntilExpiration < 30
                                          ? ArvoColors.erroFundo
                                          : ArvoColors.sucessoFundo,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      batch.daysUntilExpiration < 0
                                          ? 'Vencido'
                                          : '${batch.daysUntilExpiration} dias',
                                      style: ArvoTypography.numberMono.copyWith(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        color: batch.daysUntilExpiration < 30
                                            ? ArvoColors.erroTexto
                                            : ArvoColors.sucessoTexto,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'Vence em: ${Formatters.formatDate(batch.expirationDate)}',
                                style: TextStyle(
                                  fontFamily: ArvoTypography.fontBody,
                                  fontSize: 12,
                                  color: batch.daysUntilExpiration < 30
                                      ? ArvoColors.erroTexto
                                      : ArvoColors.musgo,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${batch.remainingQuantity.toStringAsFixed(0)} ${product.unit}',
                          style: ArvoTypography.metricSmall.copyWith(
                            fontSize: 15,
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
          border: Border.all(color: ArvoColors.linha.withValues(alpha: 0.7)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontFamily: ArvoTypography.fontBody,
                fontSize: 11,
                color: ArvoColors.musgo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: ArvoTypography.numberMono.copyWith(
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
