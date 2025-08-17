import 'package:flutter/material.dart';
import 'modules/home/home_page.dart';
import 'modules/parent/parent_page.dart'; // 👈 agrega este import
import 'modules/child/child_page.dart';

class AppRoutes {
  static const home = '/';
  static const parent = '/parent';
  static const child = '/child';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => const HomePage(),
    parent: (context) => const ParentPage(),
    child: (context) => const ChildPage(),
  };
}
