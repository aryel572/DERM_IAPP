import 'package:flutter/material.dart';

/// Pantalla de entrada para RF-09 a RF-14; la captura y validación llegan en S3.
class EntryScreen extends StatelessWidget {
  /// Crea la pantalla de entrada.
  const EntryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Entrada')),
      body: const Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Funcionalidades previstas para S3:'),
            SizedBox(height: 12),
            Text('• Captura con cámara o selección desde galería (RF-09).'),
            Text('• Previsualización y confirmación antes de analizar (RF-10).'),
            Text(
              '• Validación técnica V1–V5 antes de inferir, con suelo de 600×450 px (RF-11).',
            ),
            Text('• Mensajes de rechazo accionables (RF-12).'),
            Text(
              '• Aviso: el modelo fue entrenado con imágenes dermatoscópicas; una fotografía de celular no es equivalente (RF-13).',
            ),
          ],
        ),
      ),
    );
  }
}
