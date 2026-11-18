import 'package:design_system/design_system.dart' show FitColors;
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'router/app_router.dart';
import 'theme/app_colors.dart';
import 'theme/app_theme.dart';
import 'theme/theme_provider.dart';

class FitnessApp extends ConsumerWidget {
  const FitnessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    final brightness = ref.watch(themeControllerProvider);

    // Push the active palette into the runtime tokens BEFORE building, so every
    // screen (which reads AppColors/FitColors) renders in the chosen mode. The
    // ValueKey forces the whole tree to rebuild when the mode changes; the
    // GoRouter instance persists (it comes from a provider) so the current
    // location is kept.
    AppColors.apply(brightness);
    FitColors.apply(brightness);

    return MaterialApp.router(
      title: 'Fitness Platform',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
      // Remount the whole displayed content when the mode flips, so EVERY widget
      // (including const ones that read AppColors/FitColors directly, like the
      // menu tiles and the bottom nav) rebuilds with the new palette. Keying the
      // builder's child — not the MaterialApp — keeps the GoRouter instance and
      // the current location intact.
      builder: (context, child) => KeyedSubtree(
        key: ValueKey(brightness),
        child: child ?? const SizedBox.shrink(),
      ),
      locale: const Locale('es'),
      supportedLocales: const [Locale('es'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
