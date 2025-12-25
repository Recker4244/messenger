import 'package:flutter/material.dart';
import 'package:stacked_services/stacked_services.dart';
import 'app_routes.dart';
import 'locator.dart';
import 'ui/views/main_navigation/main_navigation_view.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = ColorScheme.fromSeed(seedColor: Colors.deepPurple);
    return MaterialApp(
      title: 'Messenger',
      theme: ThemeData(
        colorScheme: colorScheme,
        // useMaterial3: true,
        // scaffoldBackgroundColor: colorScheme.surface,
      ),
      navigatorKey: StackedService.navigatorKey,
      onGenerateRoute: AppRouter().onGenerateRoute,
      home: const MainNavigationView(),
    );
  }
}
