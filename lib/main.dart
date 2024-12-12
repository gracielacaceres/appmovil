import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/pages/dashboard.dart';

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
      home: const DashboardPage(),
    );
  }
}