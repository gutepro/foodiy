import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:foodiy/router/app_routes.dart';

Future<void> goHome(BuildContext context) async {
  Navigator.of(context, rootNavigator: true).popUntil((r) => r.isFirst);
  context.go(AppRoutes.home);
}
