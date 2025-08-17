import 'package:flutter/material.dart';
import 'modules/home/home_page.dart';
import 'modules/parent/parent_page.dart';
import 'modules/child/child_page.dart';

class AppRoutes {
  static const home = '/';
  static const parent = '/parent';
  static const child = '/child';

  static Map<String, WidgetBuilder> routes = {
    home: (context) => HomePage(),
    //parent: (context) => ParentPage(),
    //child: (context) => ChildPage(),
  };
}
