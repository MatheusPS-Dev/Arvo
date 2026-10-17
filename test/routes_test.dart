import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:arvo_app/core/routes/app_routes.dart';
import 'package:arvo_app/data/repositories/inventory_repository.dart';
import 'package:arvo_app/data/repositories/movement_repository.dart';
import 'package:arvo_app/domain/viewmodels/stock_intelligence_viewmodel.dart';
import 'package:arvo_app/ui/features/dashboard/dashboard_view.dart';
import 'package:arvo_app/ui/features/intelligence/intelligence_view.dart';
import 'package:arvo_app/ui/features/inventory/inventory_view.dart';
import 'package:arvo_app/ui/features/movements/movements_view.dart';
import 'package:arvo_app/ui/features/simulation/simulation_view.dart';
import 'package:arvo_app/ui/main_screen.dart';

Widget _buildTestApp({required String initialRoute}) {
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
      initialRoute: initialRoute,
      routes: AppRoutes.routes,
      onGenerateRoute: AppRoutes.onGenerateRoute,
    ),
  );
}

void main() {
  group('AppRoutes Verification', () {
    test('Route constants should be properly defined', () {
      expect(AppRoutes.initial, equals('/'));
      expect(AppRoutes.main, equals('/main'));
      expect(AppRoutes.dashboard, equals('/dashboard'));
      expect(AppRoutes.intelligence, equals('/intelligence'));
      expect(AppRoutes.inventory, equals('/inventory'));
      expect(AppRoutes.movements, equals('/movements'));
      expect(AppRoutes.simulation, equals('/simulation'));
    });

    testWidgets('Renders MainScreen on AppRoutes.initial', (tester) async {
      await tester.pumpWidget(_buildTestApp(initialRoute: AppRoutes.initial));
      await tester.pumpAndSettle();
      expect(find.byType(MainScreen), findsOneWidget);
    });

    testWidgets('Renders DashboardView on AppRoutes.dashboard', (tester) async {
      await tester.pumpWidget(_buildTestApp(initialRoute: AppRoutes.dashboard));
      await tester.pumpAndSettle();
      expect(find.byType(DashboardView), findsOneWidget);
    });

    testWidgets('Renders IntelligenceView on AppRoutes.intelligence', (tester) async {
      await tester.pumpWidget(_buildTestApp(initialRoute: AppRoutes.intelligence));
      await tester.pumpAndSettle();
      expect(find.byType(IntelligenceView), findsOneWidget);
    });

    testWidgets('Renders InventoryView on AppRoutes.inventory', (tester) async {
      await tester.pumpWidget(_buildTestApp(initialRoute: AppRoutes.inventory));
      await tester.pumpAndSettle();
      expect(find.byType(InventoryView), findsOneWidget);
    });

    testWidgets('Renders MovementsView on AppRoutes.movements', (tester) async {
      await tester.pumpWidget(_buildTestApp(initialRoute: AppRoutes.movements));
      await tester.pumpAndSettle();
      expect(find.byType(MovementsView), findsOneWidget);
    });

    testWidgets('Renders SimulationView on AppRoutes.simulation', (tester) async {
      await tester.pumpWidget(_buildTestApp(initialRoute: AppRoutes.simulation));
      await tester.pumpAndSettle();
      expect(find.byType(SimulationView), findsOneWidget);
    });
  });
}
