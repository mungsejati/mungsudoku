import 'package:go_router/go_router.dart';

import '../../features/game/presentation/game_page.dart';
import '../../features/home/presentation/home_page.dart';

/// Centralized routing configuration for MungSudoku.
///
/// All application routes are declared here. Never add navigation
/// logic inside widgets — use `context.go()` or `context.push()` instead.
abstract final class AppRouter {
  static const String homePath = '/';
  static const String gamePath = '/game';

  static final GoRouter router = GoRouter(
    initialLocation: homePath,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: homePath,
        name: 'home',
        builder: (context, state) => const HomePage(),
      ),
      GoRoute(
        path: gamePath,
        name: 'game',
        builder: (context, state) => const GamePage(),
      ),
    ],
  );
}
