import 'package:stacked/stacked.dart';
import 'package:flutter/material.dart';
import 'ui/views/home/home_view.dart';
import 'ui/views/offers/offers_view.dart';
import 'ui/views/settings/settings_view.dart';
import 'ui/views/main_navigation/main_navigation_view.dart';

class Routes {
  static const String mainNavigation = '/';
  static const String home = '/home';
  static const String offers = '/offers';
  static const String settings = '/settings';
}

class AppRouter extends RouterBase {
  @override
  List<RouteDef> get routes => [
    RouteDef(Routes.mainNavigation, page: MainNavigationView),
    RouteDef(Routes.home, page: HomeView),
    RouteDef(Routes.offers, page: OffersView),
    RouteDef(Routes.settings, page: SettingsView),
  ];

  @override
  Map<Type, StackedRouteFactory> get pagesMap => {
    MainNavigationView: (data) => MaterialPageRoute(
      builder: (_) => const MainNavigationView(),
      settings: data,
    ),
    HomeView: (data) =>
        MaterialPageRoute(builder: (_) => const HomeView(), settings: data),
    OffersView: (data) =>
        MaterialPageRoute(builder: (_) => const OffersView(), settings: data),
    SettingsView: (data) =>
        MaterialPageRoute(builder: (_) => const SettingsView(), settings: data),
  };
}
