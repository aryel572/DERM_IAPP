import 'package:flutter/material.dart';

/// Pantalla de Registro del modelo para RF-21 a RF-26, sin red durante S2.
class ModelRegistryScreen extends StatelessWidget {
  /// Crea la pantalla de registro del modelo.
  const ModelRegistryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro del modelo')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Funcionalidades previstas para S3/S4:'),
            SizedBox(height: 12),
            Text(
              '• Ficha del modelo activo: versión, fecha, arquitectura, input size, normalización, umbral, SHA-256, firma, tamaño y TA de referencia (RF-21).',
            ),
            Text('• Verificación de integridad al arrancar (RF-22).'),
            Text('• Consulta GET /v1/models/latest (RF-23).'),
            Text(
              '• Actualización con consentimiento: descarga temporal, SHA-256 y firma, activación atómica y rollback (RF-24/RF-25).',
            ),
            Text('• Atribución ISIC 2019, CC BY-NC-SA 4.0 (RF-26).'),
            SizedBox(height: 16),
            Text('S2 no incluye código de red.'),
          ],
        ),
      ),
    );
  }
}
