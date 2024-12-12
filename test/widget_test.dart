import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:myapp/screens/pages/dashboard.dart';
import 'package:myapp/screens/login_screen.dart';

void main() {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarBrightness: Brightness.dark,
    systemNavigationBarColor: Colors.transparent,
    systemNavigationBarDividerColor: Colors.transparent,
    systemNavigationBarIconBrightness: Brightness.dark,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Gestión Barbería',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
        canvasColor: Colors.white,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
        ),
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16.0),
        ),
      ),
      home: const LoginScreen(),
    );
  }
}
