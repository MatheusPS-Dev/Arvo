import 'package:flutter/material.dart';
import '../../ui/main_screen.dart';
import '../../ui/features/dashboard/dashboard_view.dart';
import '../../ui/features/intelligence/intelligence_view.dart';
import '../../ui/features/inventory/inventory_view.dart';
import '../../ui/features/movements/movements_view.dart';
import '../../ui/features/simulation/simulation_view.dart';

/// Gerenciador centralizado de rotas da aplicação Arvô.
/// Segue o padrão de arquitetura oficial Flutter/Dart com rotas nomeadas,
/// passagem de parâmetros e atalhos tipados de navegação.
class AppRoutes {
  AppRoutes._();

  // Nomes das Rotas
  static const String initial = '/';
  static const String main = '/main';
  static const String dashboard = '/dashboard';
  static const String intelligence = '/intelligence';
  static const String inventory = '/inventory';
  static const String movements = '/movements';
  static const String simulation = '/simulation';

  /// Mapa de rotas padrão do aplicativo
  static Map<String, WidgetBuilder> get routes => {
        initial: (context) => const MainScreen(),
        main: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final initialIndex = args is int ? args : 0;
          return MainScreen(initialIndex: initialIndex);
        },
        dashboard: (context) => const DashboardView(),
        intelligence: (context) => const IntelligenceView(),
        inventory: (context) => const InventoryView(),
        movements: (context) => const MovementsView(),
        simulation: (context) => const SimulationView(),
      };

  /// Gerador de rotas dinâmicas para suporte a argumentos ou transições personalizadas
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case initial:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(initialIndex: 0),
          settings: settings,
        );
      case main:
        final initialIndex =
            settings.arguments is int ? (settings.arguments as int) : 0;
        return MaterialPageRoute(
          builder: (_) => MainScreen(initialIndex: initialIndex),
          settings: settings,
        );
      case dashboard:
        return MaterialPageRoute(
          builder: (_) => const DashboardView(),
          settings: settings,
        );
      case intelligence:
        return MaterialPageRoute(
          builder: (_) => const IntelligenceView(),
          settings: settings,
        );
      case inventory:
        return MaterialPageRoute(
          builder: (_) => const InventoryView(),
          settings: settings,
        );
      case movements:
        return MaterialPageRoute(
          builder: (_) => const MovementsView(),
          settings: settings,
        );
      case simulation:
        return MaterialPageRoute(
          builder: (_) => const SimulationView(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const MainScreen(),
          settings: settings,
        );
    }
  }

  // Métodos Utilitários de Navegação Genéricos
  static Future<T?> to<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  static Future<T?> replace<T, TO>(
    BuildContext context,
    String routeName, {
    TO? result,
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      result: result,
      arguments: arguments,
    );
  }

  static void back<T>(BuildContext context, [T? result]) {
    if (Navigator.canPop(context)) {
      Navigator.pop<T>(context, result);
    }
  }

  // Atalhos Tipados de Navegação para cada Página
  static Future<void> toMain(BuildContext context, {int initialIndex = 0}) {
    return Navigator.pushNamed(context, main, arguments: initialIndex);
  }

  static Future<void> toDashboard(BuildContext context) {
    return Navigator.pushNamed(context, dashboard);
  }

  static Future<void> toIntelligence(BuildContext context) {
    return Navigator.pushNamed(context, intelligence);
  }

  static Future<void> toInventory(BuildContext context) {
    return Navigator.pushNamed(context, inventory);
  }

  static Future<void> toMovements(BuildContext context) {
    return Navigator.pushNamed(context, movements);
  }

  static Future<void> toSimulation(BuildContext context) {
    return Navigator.pushNamed(context, simulation);
  }
}
