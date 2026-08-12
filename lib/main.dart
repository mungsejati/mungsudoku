import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import 'src/core/router/app_router.dart';
import 'src/core/theme/app_theme.dart';
import 'src/core/theme/game_theme.dart';
import 'src/features/settings/application/settings_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  WakelockPlus.enable();
  runApp(const ProviderScope(child: MungSudokuApp()));
}

/// Root widget of the MungSudoku application.
///
/// [ProviderScope] is the outermost widget, ensuring all Riverpod
/// providers are accessible throughout the entire widget tree.
class MungSudokuApp extends ConsumerWidget {
  const MungSudokuApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsNotifierProvider);
    final gameTheme = ref.watch(gameThemeProvider);

    return MaterialApp.router(
      title: 'MungSudoku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.build(gameTheme),
      themeMode: ThemeMode.light,
      routerConfig: AppRouter.router,
      builder: (context, child) {
        return MediaQuery(
          data: MediaQuery.of(
            context,
          ).copyWith(textScaler: TextScaler.linear(settings.fontSizeFactor)),
          child: child!,
        );
      },
    );
  }
}
