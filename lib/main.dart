import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';

void main() {
  runApp(const ProviderScope(child: MungSudokuApp()));
}

/// Root widget of the MungSudoku application.
///
/// [ProviderScope] is the outermost widget, ensuring all Riverpod
/// providers are accessible throughout the entire widget tree.
class MungSudokuApp extends StatelessWidget {
  const MungSudokuApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'MungSudoku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
    );
  }
}
