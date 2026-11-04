# DERM_IAPP — Aplicación móvil con Deep Learning para detección de carcinoma basocelular

Proyecto de tesis de la Universidad Privada Antenor Orrego (Trujillo, 2026).

## Estructura del repositorio

```text
DERM_IAPP/
├── model/        # Pipeline CRISP-DM: datos, entrenamiento, TFLite
├── app/          # Aplicación móvil Flutter (Mobile-D)
├── backend/      # FastAPI: versiones del modelo
├── docs/         # Arquitectura, ADRs, BPMN
├── herramientas/ # Scripts de push y trazabilidad
├── README.md
└── .gitignore
```

## Metodologías

- **Equipo:** Scrum (2 miembros + Product Owner: DERMATÓLOGO)
- **Modelo:** CRISP-DM
- **App móvil:** Mobile-D
- **Commits:** Conventional Commits v1.0.0

## Nota

Los artefactos grandes (dataset, zips, modelo .tflite) no se versionan aquí.
Se documentan con su hash SHA-256 en el manifiesto correspondiente.
