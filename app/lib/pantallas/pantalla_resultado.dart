import 'package:flutter/material.dart';

/// Pantalla de resultado para RF-15 a RF-20; la advertencia normativa de S1 §7
/// se muestra siempre, completa y sin posibilidad de descartarla.
class ResultScreen extends StatelessWidget {
  /// Crea la pantalla de resultado.
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Resultado')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            const Text(
              'En S3 se mostrará la salida binaria «Sospecha compatible con BCC» '
              'o «Sin sospecha de BCC», la probabilidad cruda, el umbral, la '
              'versión del modelo y la TA declarada (RF-15, RF-17 y RF-18).',
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Advertencia médica',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Este resultado procede de un modelo experimental que analiza imágenes dermatoscópicas. No constituye un diagnóstico, no confirma ni descarta cáncer de piel y no reemplaza la evaluación de un profesional de salud. Si existe una lesión nueva, cambiante, sangrante o preocupante, solicite valoración médica.',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Aquí estarán las acciones «analizar otra imagen» y «volver a Inicio» '
              '(RF-19). La imagen y el resultado no se persisten (RF-20).',
            ),
          ],
        ),
      ),
    );
  }
}
