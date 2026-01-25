import 'package:flutter/material.dart';

import 'package:foodiy/core/brand/brand_assets.dart';
import 'package:foodiy/shared/navigation/go_home.dart';

class FoodiyAppBar extends StatelessWidget implements PreferredSizeWidget {
  const FoodiyAppBar({
    super.key,
    this.title,
    this.actions,
    this.bottom,
    this.centerTitle,
  });

  final Widget? title;
  final List<Widget>? actions;
  final PreferredSizeWidget? bottom;
  final bool? centerTitle;

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.of(context).canPop();
    final List<Widget> mergedActions = [
      if (actions != null) ...actions!,
      IconButton(
        icon: Image.asset(BrandAssets.foodiyLogo, height: 22),
        tooltip: 'Home',
        onPressed: () async => goHome(context),
      ),
    ];
    return AppBar(
      title: title,
      actions: mergedActions,
      bottom: bottom,
      centerTitle: centerTitle,
      automaticallyImplyLeading: true,
      leading: canPop ? const BackButton() : null,
    );
  }

  @override
  Size get preferredSize {
    final height = kToolbarHeight + (bottom?.preferredSize.height ?? 0);
    return Size.fromHeight(height);
  }
}
