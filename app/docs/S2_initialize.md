# S2 — Registro de la fase Initialize (Mobile-D)

> **Proyecto:** DERM_IAPP — Aplicación móvil con técnicas de Deep Learning para la detección de carcinoma basocelular (BCC) en Trujillo 2026 (UPAO).
> **Sprint:** 2 (retroactivo, 19–30 de octubre de 2026) · **Fase Mobile-D:** 2 — Initialize (etapas: *project set-up*, *initial planning*, *trial day*).
> **Elaborado por:** agente mobile-d (equipo Dev) · **Revisión prevista:** Product Owner (dermatólogo de Trujillo, *Off-Site Customer*) y Scrum Master (Aryel Meza).
> **Estado:** fase **ejecutada a nivel de decisión y diseño**. El código del esqueleto se delega al agente coder mediante el prompt **INI-S2-01** (queda pendiente de revisión y commit por commiter-muga). Restricción de entorno sin Flutter SDK: declarada en §2 y tratada en §6–§7.
> **Fuentes:** [`S1_explore_requisitos_app.md`](S1_explore_requisitos_app.md) (línea base de requisitos), [`S1_plan_evaluacion.md`](S1_plan_evaluacion.md), [`S1_explore_resumen.md`](S1_explore_resumen.md) (decisión DE-11: ADRs en Initialize), [`../../docs/adr/ADR-002-estructura-app-flutter.md`](../../docs/adr/ADR-002-estructura-app-flutter.md) y `PRODUCTO/metodologias/MOBILE_D/CONOCIMIENTO_MOBILE_D.md`.

---

## 1. Propósito y método

La fase **Initialize** (Iteración 0 de Mobile-D) prepara los recursos que Productionize consumirá: el equipo y los stakeholders activos entienden el producto y quedan listos los recursos físicos, tecnológicos y de comunicaciones. Su salida esperada es el **esqueleto de la aplicación funcionando (aunque mínimo)**.

Aplicación de las 3 etapas en este proyecto:

| Etapa de Initialize | Resultado en DERM_IAPP | Evidencia |
|---|---|---|
| **Project set-up** | Estructura del repo `app/` definida; esqueleto Flutter convencional mínimo (10 archivos) especificado para el coder; decisiones DE-12–DE-17 | §4–§5, ADR-002 |
| **Initial planning** | Planificación inicial de Productionize (S3–S4): 2 ciclos Planning Day → Working Day → Release Day; contrato con S3 (dónde entra `tflite_flutter` y los servicios) | §8 |
| **Trial day** | Adaptado a la restricción del entorno (§2): se prueba el flujo completo de trabajo del equipo (requisito → prompt → código → verificación → commit) y queda documentada la verificación diferida de la app | §6–§7 |

**Reglas duras heredadas de Explore** (vigentes desde este momento, aunque su implementación plena es S3): la imagen **nunca sale del dispositivo**; la advertencia médica **siempre** se muestra; el backend **no recibe imágenes ni hace inferencia**.

## 2. Restricción del entorno (declaración honesta)

**Flutter SDK y Dart NO están instalados en la máquina de desarrollo** (verificado por el orquestador durante el Sprint 2). Consecuencias metodológicas asumidas:

1. El esqueleto se construye **a mano** como proyecto Flutter convencional mínimo y estándar, **sin ejecutar `flutter create`** (DE-12). Todos los archivos son los estándar de un proyecto Flutter: debe bastar un `flutter pub get` + `flutter run` cuando el usuario instale el SDK.
2. **Nada se compila ni se ejecuta en esta fase.** La verificación es: inspección cuidadosa de la sintaxis Dart (documentada por el coder), validación de los YAML (parseo) y una **checklist de verificación diferida** (§7) para ejecutar en cuanto exista SDK.
3. El `README.md` de la app documenta cómo **regenerar/verificar** las carpetas de plataforma con `flutter create .` **sin sobrescribir el código** de `lib/`, `test/`, `pubspec.yaml`.

Esta restricción **no altera el alcance** de Initialize: la definición del proyecto ya excluye CI/CD completo y publicación en tiendas en esta fase.

## 3. Alcance de la fase

### 3.1 Dentro del alcance (Initialize)

| # | Elemento |
|---|---|
| I1 | Estructura de carpetas y navegación de la app decidida y documentada (ADR-002) |
| I2 | Esqueleto Flutter mínimo: `pubspec.yaml`, `analysis_options.yaml`, `.gitignore`, `lib/main.dart` con las 4 rutas nombradas, 4 pantallas placeholder, stub del contrato de inferencia, test mínimo, `README.md` |
| I3 | Advertencia médica textual (3 oraciones, §7 de S1) **ya visible** en el placeholder de Resultado; estado del modelo «no cargado» visible en Inicio |
| I4 | Trial day adaptado (flujo de trabajo del equipo) + checklist de verificación diferida |
| I5 | Planificación inicial de Productionize y contrato con S3 |

### 3.2 Fuera del alcance (Initialize)

| # | Exclusión | Justificación |
|---|---|---|
| X1 | CI/CD (GitHub Actions u otro) | Definición del proyecto: «no se necesita CI/CD completo en Initialize»; MTDD + CI arrancan en S3 |
| X2 | Publicación en tiendas / signing / store listing | Fuera de alcance del prototipo (E6 de S1) |
| X3 | Dependencias externas (`tflite_flutter`, `image_picker`, `provider`, `go_router`, …) | DE-13: solo `flutter`, `cupertino_icons`, `flutter_test`, `flutter_lints` |
| X4 | Inferencia real, validación de entrada real, backend | Productionize (S3–S4); solo se define el **contrato** (stub) |
| X5 | Carpetas de plataforma (`android/`, `ios/`) | Se generan con `flutter create .` cuando haya SDK (§7); no se crean a mano |

## 4. Decisiones de la fase (continuación de la serie DE de S1)

| # | Decisión | Tipo | Sustento |
|---|---|---|---|
| DE-12 | Esqueleto Flutter **convencional y mínimo construido a mano** (sin `flutter create`) por la restricción del entorno; verificación de sintaxis por inspección + parse YAML + **checklist diferida** (§7); README con la nota de regeneración `flutter create .` | Técnica (adaptación) | §2; honestidad metodológica |
| DE-13 | Estructura **minimalista**: `lib/pantallas/` (un archivo por pantalla) + `lib/modelo/` (contrato de inferencia) + `lib/main.dart` (composición y rutas). Se evalúa y **difiere** la estructura *feature-first* (`lib/features/<pantalla>/`) al Planning Day de S3, solo si las pantallas acumulan widgets/servicios | Técnica — ADR-002 | App de 4 pantallas; equipo de 2; < 10 semanas |
| DE-14 | Navegación con **rutas nombradas** de `MaterialApp` (`/`, `/entrada`, `/resultado`, `/registro`); **estado local simple** (`setState`/`ValueNotifier` de Flutter) **sin paquetes externos** de estado o navegación (sin `go_router`, sin `provider`/`bloc`) | Técnica — ADR-002 | 4 rutas fijas, sin deep links (fuera de alcance); cero dependencias en S2 |
| DE-15 | El **contrato de inferencia** se expresa desde S2 como **interfaz stub** (`lib/modelo/modelo_tflite_stub.dart`): `loadFromManifest`, `preprocess`, `infer` → `{es_bcc, confianza}`, `unload` — sin implementación. Prepara MTDD (los tests del contrato preceden al servicio) y desacopla app ↔ CRISP-DM | Técnica — ADR-002 | §6 de S1 (contrato de inferencia); riesgo R1 de S1 (`.tflite` aún no existe) |
| DE-16 | La **advertencia médica textual íntegra** (3 oraciones normativas de S1 §7) se muestra **ya en el esqueleto** de Resultado (estática). En S3 se centraliza en **una constante única** (`lib/constantes/advertencia_medica.dart`) para evitar duplicación y deriva de texto (RF-07 la reutilizará desde Inicio) | Normativa — regla dura | RF-16; DE-6 de S1 |
| DE-17 | **Trial day adaptado**: sin SDK se prueba el flujo completo de trabajo del equipo (requisito → prompt → código → verificación por inspección → revisión/commit) y se documenta la verificación diferida; el flujo de la app (compilar, correr, navegar) se verifica con la checklist §7 | Metodológica | §2; Mobile-D Initialize (trial day) |

## 5. Estructura del proyecto (*project set-up*)

### 5.1 Árbol objetivo de `app/` (post-coder, pre-commit)

```text
DERM_IAPP/app/
├── pubspec.yaml                      # nombre derm_iapp; SDK ^3.5.0; sin dependencias externas
├── analysis_options.yaml             # flutter_lints estándar
├── .gitignore                        # plantilla estándar de flutter create (app)
├── README.md                         # instalación SDK, run, y nota de regeneración
├── docs/                             # (ya existía: S1_*, S2_initialize.md — el coder NO la toca)
├── lib/
│   ├── main.dart                     # DermIappApp: MaterialApp + tema + 4 rutas nombradas
│   ├── pantallas/
│   │   ├── pantalla_inicio.dart      # HomeScreen (estado del modelo: «no cargado»; RF-04–RF-08)
│   │   ├── pantalla_entrada.dart     # EntryScreen (placeholder; RF-09–RF-14, V1–V5 en S3)
│   │   ├── pantalla_resultado.dart   # ResultScreen (placeholder + ADVERTENCIA textual; RF-15–RF-20)
│   │   └── pantalla_registro_modelo.dart # ModelRegistryScreen (placeholder; RF-21–RF-26)
│   └── modelo/
│       └── modelo_tflite_stub.dart   # interfaz del contrato de inferencia local (sin implementar)
└── test/
    └── widget_test.dart              # test de render de Inicio, marcado skip hasta tener SDK
```

### 5.2 Reglas de la estructura

| Regla | Detalle |
|---|---|
| Un archivo por pantalla | `lib/pantallas/pantalla_*.dart`; clases en inglés (`HomeScreen`, `EntryScreen`, `ResultScreen`, `ModelRegistryScreen`) con doc comment en español que mapea archivo ↔ pantalla ↔ RF de S1 |
| `main.dart` solo compone | Tema + rutas; sin lógica de negocio (la lógica entra en S3 en `lib/servicios/`) |
| Placeholders con contenido significativo | Cada pantalla muestra su título; Inicio muestra «Modelo no cargado» + botones de navegación (RF-01/RF-05); Resultado muestra la advertencia íntegra; cada placeholder lista qué entrará en S3 (referencia a RF) |
| Codificación | UTF-8 **sin BOM**; saltos de línea LF; indentación 2 espacios, sin tabs (convención Dart) |
| Idioma | Español en comentarios, strings de UI y docs; identificadores en inglés convencional |
| Carpeta `docs/` intocable | `app/docs/` contiene los registros de fase; el coder no la modifica |

## 6. Trial day (adaptado, DE-17)

| Verificación del trial | Herramienta | Resultado |
|---|---|---|
| Flujo de trabajo completo del equipo: requisito (S1) → decisión (ADR-002) → prompt al coder (INI-S2-01) → código → verificación → revisión/commit | Orquestador + mensajero | Ejecutado; queda pendiente el tramo código→commit del coder |
| Sintaxis Dart de los 10 archivos | Inspección cuidadosa punto por punto (imports, llaves/paréntesis balanceados, strings cerrados, const/rutas coherentes) — documentada por el coder en su reporte | Ejecutada por el coder (sin SDK no compila localmente) |
| Validez de `pubspec.yaml` y `analysis_options.yaml` | Parseo (p. ej., PyYAML si está disponible; si no, revisión manual de indentación) | Ejecutada por el coder |
| Estructura de carpetas | Listado final del árbol | Ejecutada por el coder |
| **Flujo de la app** (compilar, correr, navegar las 4 pantallas, advertencia visible) | **Pendiente de SDK** → checklist §7 | **Diferido (documentado)** |

## 7. Checklist de verificación cuando haya SDK (verificación diferida)

Ejecutar en orden; cada paso debe cumplirse antes del siguiente. Registrar el resultado como evidencia del cierre formal de Initialize (anexo de este documento).

| # | Paso | Comando | Resultado esperado |
|---|---|---|---|
| 1 | Entorno sano | `flutter doctor` | Sin errores bloqueantes (Android/iOS según plataforma objetivo) |
| 2 | Dependencias | `flutter pub get` | `pubspec.lock` generado sin conflictos de versiones |
| 3 | Análisis estático | `flutter analyze` | 0 errores (avisos de lints se corrigen, no se suprimen) |
| 4 | Carpetas de plataforma (solo primera vez) | `flutter create . --project-name derm_iapp --org com.upao --platforms android,ios` | Genera `android/` e `ios/` **sin sobrescribir** `lib/`, `test/`, `pubspec.yaml`; revisar `git diff` antes de commitear |
| 5 | Tests | `flutter test` | 1 test ejecutado (quitar el `skip` del test antes) y pasado |
| 6 | Ejecución | `flutter run` | App arranca en Inicio |
| 7 | Navegación | Prueba manual | Las 4 pantallas accesibles; Resultado muestra la advertencia íntegra; Inicio muestra «Modelo no cargado» |
| 8 | Texto normativo | Verificación visual contra S1 §7 | Las 3 oraciones exactas, sin resumir ni parafrasear |
| 9 | Cierre | Registro en este documento (§11) | Initialize cierra formalmente; arranca Productionize (S3) |

## 8. Contrato con S3 — Productionize (*initial planning*)

### 8.1 Dónde entra cada pieza en S3–S4

| Pieza (S3+) | Ubicación | Nota |
|---|---|---|
| Paquete de inferencia | `pubspec.yaml` → `tflite_flutter` (LiteRT) | Primera dependencia externa; entra en el Planning Day del ciclo 1 (S3) |
| Servicio de inferencia | `lib/servicios/inference_service.dart` | **Implementa** el contrato de `lib/modelo/modelo_tflite_stub.dart`; el stub permanece como especificación |
| Validación de entrada | `lib/servicios/validacion_entrada.dart` | Reglas V1–V5 con **MTDD**: tests antes del código (suelo 600×450) |
| Captura/selección | `pubspec.yaml` → `image_picker` (o equivalente) | RF-09; decisión en el Planning Day de S3 |
| Modelo incluido (bundled) + manifiesto | `app/assets/models/` + registro en `pubspec.yaml` (`flutter: assets:`) | Cuando CRISP-DM entregue el primer `.tflite` versionado |
| Advertencia médica centralizada | `lib/constantes/advertencia_medica.dart` | Única fuente del texto (DE-16); Resultado e Inicio la referencian |
| Estado | Local simple (`setState`/`ValueNotifier`) | Si el flujo Entrada→Resultado requiere pasar datos entre rutas: argumentos de ruta; sin paquetes de estado |
| Backend de versiones | `backend/` (FastAPI) | Ciclo 2 (S4): `GET /v1/models/latest` + almacenamiento HTTPS; nunca recibe imágenes (RF-29) |
| Actualización segura | `lib/servicios/` (descarga temporal → SHA-256 + firma → activación atómica → rollback) | RF-24/RF-25; RNF-08 |

### 8.2 Ciclos previstos (Planning Day → Working Day → Release Day)

| Ciclo | Sprint | Contenido | Release Day |
|---|---|---|---|
| 1 | S3 (2–13 nov) | Contrato congelado; validación V1–V5 (MTDD); inferencia local básica; pantallas Inicio, Entrada, Resultado funcionales | v0.2: captura→análisis→resultado con advertencia |
| 2 | S4 (16–27 nov) | Registro del modelo + backend FastAPI de versiones + actualización segura + métricas (§7 de `S1_plan_evaluacion.md`) | v0.3: producto completo previo a Stabilize |

## 9. Handoffs

| Destino | Qué se transfiere |
|---|---|
| **coder** | Prompt **INI-S2-01** (esqueleto Flutter completo; entregado por el orquestador vía mensajero) |
| **commiter-muga** | Los archivos del esqueleto para revisión y commits (identidad de Franco; scopes sugeridos: `app`, `ui`; p. ej., `feat(app): esqueleto Flutter con 4 pantallas placeholder`) |
| **documentador** | Este documento + ADR-002 para Notion (App Mobile-D, fase Initialize; Presentación de Avances — semana S2) |
| **crisp-dm** | Sin cambios: el contrato de inferencia sigue congelado (§6 de S1); el stub lo refleja |

## 10. Riesgos de la fase

| # | Riesgo | Impacto | Mitigación |
|---|---|---|---|
| R11 | Defectos de sintaxis latentes por no compilar en S2 | Medio | Inspección documentada del coder + checklist §7 (analyze/test/run) al tener SDK; proyecto 100 % convencional para minimizar la superficie de error |
| R12 | `flutter create .` futuro introduce diferencias no deseadas | Bajo | README con la nota de regeneración; revisión de `git diff` antes de commitear (checklist paso 4) |
| R13 | Deriva del texto de la advertencia al duplicarlo | Alto | DE-16: en S3 una única constante; en S2 el texto se copia **literal** de S1 §7 y la checklist 8 lo verifica |
| R14 | PO-1 aún pendiente: requisitos [PO-1] siguen en borrador | Medio | El esqueleto no depende de decisiones [PO-1]; Productionize arranca con Planning Days que las incorporan |
| R15 | Migración futura a `lib/features/` genera churn de imports | Bajo | Decisión explícita DE-13: solo se migra en S3 si el Planning Day lo justifica (y se documenta en ADR) |

## 11. Historial de versiones

| Versión | Fecha | Descripción |
|---|---|---|
| v1.0 | 04/11/2026 | Registro de la fase Initialize (formalización retroactiva del Sprint 2, 19–30/10/2026). Decisiones DE-12–DE-17; prompt INI-S2-01 emitido al coder; verificación de la app diferida a la checklist §7. |

*Registro de fase Initialize · Mobile-D · DERM_IAPP · Sprint 2 (retroactivo, 19–30/10/2026).*
