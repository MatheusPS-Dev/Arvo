import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/theme/arvo_theme.dart';
import 'core/routes/app_routes.dart';
import 'data/repositories/inventory_repository.dart';
import 'data/repositories/movement_repository.dart';
import 'domain/viewmodels/stock_intelligence_viewmodel.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArvoApp());
}

class ArvoApp extends StatelessWidget {
  const ArvoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<InventoryRepository>(
          create: (_) => InventoryRepository(),
        ),
        ChangeNotifierProxyProvider<InventoryRepository, MovementRepository>(
          create: (ctx) => MovementRepository(
            inventoryRepo: ctx.read<InventoryRepository>(),
          ),
          update: (ctx, inventoryRepo, previous) =>
              previous ?? MovementRepository(inventoryRepo: inventoryRepo),
        ),
        ChangeNotifierProxyProvider2<InventoryRepository, MovementRepository,
            StockIntelligenceViewModel>(
          create: (ctx) => StockIntelligenceViewModel(
            inventoryRepo: ctx.read<InventoryRepository>(),
            movementRepo: ctx.read<MovementRepository>(),
          ),
          update: (ctx, inventoryRepo, movementRepo, previous) =>
              previous ??
              StockIntelligenceViewModel(
                inventoryRepo: inventoryRepo,
                movementRepo: movementRepo,
              ),
        ),
      ],
      child: MaterialApp(
        title: 'Arvô - Gestão Inteligente de Insumos',
        theme: ArvoTheme.lightTheme,
        debugShowCheckedModeBanner: false,
        initialRoute: AppRoutes.initial,
        routes: AppRoutes.routes,
        onGenerateRoute: AppRoutes.onGenerateRoute,
      ),
    );
  }
}
