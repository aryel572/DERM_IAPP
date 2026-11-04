/// Define el contrato de inferencia local entre la app y el modelo CRISP-DM,
/// conforme al §6 de S1_explore_requisitos_app.md. Su implementación llegará
/// en S3 en lib/servicios/inference_service.dart con tflite_flutter. La imagen
/// nunca sale del dispositivo.
abstract interface class LocalInferenceModel {
  /// Carga el .tflite verificado desde version, architecture, input_size,
  /// normalization, threshold, sha256, signature, size_bytes y ta_referencia.
  Future<void> loadFromManifest(
    Map<String, Object?> manifest, {
    String? modelPath,
  });

  /// Replica el preprocesamiento del entrenamiento; V1–V5 ya garantiza 600×450.
  Future<List<double>> preprocess(
    List<int> imageBytes,
    int inputSize,
    String normalization,
  );

  /// Ejecuta la inferencia local: esBcc es confianza >= threshold del manifiesto.
  Future<({bool esBcc, double confianza})> infer(List<double> preprocessed);

  /// Libera el intérprete TFLite.
  Future<void> unload();
}
