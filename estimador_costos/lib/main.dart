import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => AppState(),
      child: const EstimadorCostosApp(),
    ),
  );
}

class EstimadorCostosApp extends StatelessWidget {
  const EstimadorCostosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Estimador de Costos',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF006B5F), // Teal/Greenish corporate feel
          brightness: Brightness.light,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
