# DERM_IAPP

DERM_IAPP es una aplicación móvil experimental de apoyo para el análisis de imágenes dermatoscópicas en el contexto de la detección de carcinoma basocelular (BCC).

## Reglas duras

1. La imagen nunca sale del dispositivo: la inferencia será local.
2. La advertencia médica se muestra siempre, completa y sin posibilidad de descartarla en Resultado.

## Estado actual

El Sprint 2 contiene un esqueleto con navegación de cuatro pantallas placeholder (Inicio, Entrada, Resultado y Registro del modelo). No incluye inferencia ni dependencias externas.

## Requisitos

- Flutter SDK estable 3.24.0 o superior.
- Dart 3.5 o superior.

## Ejecución cuando el SDK esté disponible

```sh
flutter doctor
flutter pub get
# Solo la primera vez:
flutter create . --project-name derm_iapp --org com.upao --platforms android,ios
flutter run
flutter analyze
flutter test
```

El comando `flutter create . --project-name derm_iapp --org com.upao --platforms android,ios` genera solo las carpetas de plataforma que faltan y no sobrescribe `lib/`, `test/`, `pubspec.yaml` ni este README. Revise `git diff` antes de commitear. Para ejecutar el test, retire primero el `skip` indicado en `test/widget_test.dart`.

## Procedencia

El esqueleto se creó a mano sin SDK durante S2. La sintaxis fue verificada por inspección; consulte la checklist de `app/docs/S2_initialize.md` §7 para la verificación diferida con Flutter.

## Roadmap S3

Se incorporarán `tflite_flutter`, servicios de inferencia y validación, y el modelo bundled junto con su manifiesto.
