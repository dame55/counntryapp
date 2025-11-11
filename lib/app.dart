import 'package:flutter/material.dart';

import 'screens/home/detail_screen.dart';
import 'screens/home/favorites_screen.dart';
import 'screens/home/home_screen.dart';




Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const HomeScreen());
    case '/favorites':
      return MaterialPageRoute(builder: (_) => const FavoritesScreen());
    case '/detail':
      final args = settings.arguments as Map<String, dynamic>;
      return MaterialPageRoute(builder: (_) => DetailScreen(cca2: args['cca2'], name: args['name']));
    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
