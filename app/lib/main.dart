import 'package:flutter/material.dart';

import 'pantallas/pantalla_entrada.dart';
import 'pantallas/pantalla_inicio.dart';
import 'pantallas/pantalla_registro_modelo.dart';
import 'pantallas/pantalla_resultado.dart';

/// Aplicación DERM_IAPP: la imagen permanece en el dispositivo y la advertencia
/// médica es obligatoria en Resultado. La inferencia TFLite y sus servicios
/// locales se incorporarán en S3.
void main() {
  runApp(const DermIappApp());
}

/// Compone el tema y las rutas de las cuatro pantallas de la aplicación.
class DermIappApp extends StatelessWidget {
  /// Crea la aplicación raíz.
  const DermIappApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'DERM_IAPP',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/entrada': (context) => const EntryScreen(),
        '/resultado': (context) => const ResultScreen(),
        '/registro': (context) => const ModelRegistryScreen(),
      },
    );
  }
}
