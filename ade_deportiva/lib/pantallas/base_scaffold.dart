import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class BaseScaffold extends StatelessWidget {
  final Widget body;
  final Color backgroundColor;

  const BaseScaffold({
    super.key,
    required this.body,
    this.backgroundColor = const Color(0xFF12192D), required BottomNavigationBar bottomNavigationBar,
  });

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Scaffold(
        backgroundColor: backgroundColor,
        body: body,
      ),
    );
  }
}