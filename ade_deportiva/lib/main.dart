import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // 👈 IMPORTANTE
import 'package:flutter_localizations/flutter_localizations.dart';
import 'pantallas/principal_widget.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  /// 🔥 STATUS BAR BLANCA
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent, // opcional (más moderno)
      statusBarIconBrightness: Brightness.light, // 👈 ICONOS BLANCOS (Android)
      statusBarBrightness: Brightness.dark, // 👈 iOS
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Athetix', // 🔥 opcional: tu nombre de app
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Inter',
      ),
      home: const PrincipalWidget(),

      // 👇 Idiomas
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('es', 'ES'),
        Locale('en', 'US'),
      ],
    );
  }
}