import 'package:go_router/go_router.dart';

import '../../features/custom_sudoku/presentation/custom_sudoku_list_page.dart';

import '../../features/custom_sudoku/presentation/custom_sudoku_page.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/game/presentation/game_result_args.dart';
import '../../features/game/presentation/game_result_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/profile/presentation/profile_page.dart';
import '../../features/shop/presentation/shop_page.dart';

/// Centralized routing configuration for MungSudoku.
///
/// All application routes are declared here. Never add navigation
/// logic inside widgets — use `context.go()` or `context.push()` instead.
abstract final class AppRouter {
  static const String homePath = '/';
  static const String gamePath = '/game';
  static const String customSudokuPath = '/custom';
  static const String customSudokuListPath = '/custom_list';
  static const String shopPath = '/shop';
  static const String profilePath = '/profile';
  static const String gameResultPath = '/result';

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
      GoRoute(
        path: gameResultPath,
        name: 'game_result',
        builder: (context, state) {
          final args = state.extra as GameResultArgs;
          return GameResultPage(args: args);
        },
      ),
      GoRoute(
        path: customSudokuPath,
        name: 'custom_sudoku',
        builder: (context, state) => const CustomSudokuPage(),
      ),
      GoRoute(
        path: customSudokuListPath,
        name: 'custom_sudoku_list',
        builder: (context, state) => const CustomSudokuListPage(),
      ),
      GoRoute(
        path: shopPath,
        name: 'shop',
        builder: (context, state) => const ShopPage(),
      ),
      GoRoute(
        path: profilePath,
        name: 'profile',
        builder: (context, state) => const ProfilePage(),
      ),
    ],
  );
}
