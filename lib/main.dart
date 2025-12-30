import 'package:flutter/material.dart';
import 'core/routing/app_router.dart';
import 'core/theme/app_theme.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appRouter = AppRouter();

    return MaterialApp.router(
      title: 'Fantasy Hike - Silk Road',
      theme: AppTheme.darkTheme,
      routerConfig: appRouter.config(),
      debugShowCheckedModeBanner: false,
    );
  }
}
