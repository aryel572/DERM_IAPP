import 'package:flutter/material.dart';

/// Pantalla de inicio para RF-04 a RF-08: estado del modelo, accesos y guía.
class HomeScreen extends StatelessWidget {
  /// Crea la pantalla de inicio.
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Modelo no cargado',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'En S3 se mostrarán versión, arquitectura, fecha, SHA-256 '
                      'truncado, tamaño e integridad del modelo activo.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/entrada'),
              child: const Text('Analizar imagen'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Navigator.pushNamed(context, '/resultado'),
              child: const Text('Ver Resultado (demo S2)'),
            ),
            const SizedBox(height: 8),
            OutlinedButton(
              onPressed: () => Navigator.pushNamed(context, '/registro'),
              child: const Text('Registro del modelo'),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aquí se incorporará el acceso a la advertencia médica general y '
              'a «qué es y qué no es esta app».',
            ),
            const SizedBox(height: 8),
            const Text(
              'El acceso demo al Resultado es temporal: en S3 solo se llegará '
              'con una imagen validada.',
            ),
          ],
        ),
      ),
    );
  }
}
