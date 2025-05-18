import 'package:eco_quest/config/app_theme.dart';
import 'package:flutter/material.dart';

class WhiteAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;

  const WhiteAppBar({
    super.key,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppBar(
      title: Text(
        title,
        style: theme.textTheme.displayLarge?.copyWith(
          color: theme.colorScheme.primary,
        ),
      ),
      centerTitle: true,
      backgroundColor: AppTheme.lightTheme.colorScheme.surface,
      elevation: 0,
      automaticallyImplyLeading: false, // jaga-jaga supaya nggak muncul default leading
      actions: actions,
      iconTheme: IconThemeData(color: theme.colorScheme.primary),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
