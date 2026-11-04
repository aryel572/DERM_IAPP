# S1 — Requisitos de la aplicación móvil (Fase Explore · Mobile-D)

> **Proyecto:** DERM_IAPP — Aplicación móvil con técnicas de Deep Learning para la detección de carcinoma basocelular (BCC) en Trujillo 2026 (UPAO).
> **Sprint:** 1 (retroactivo, 5–16 de octubre de 2026) · **Fase Mobile-D:** 1 — Explore (etapas: stakeholder establishment, scope definition, project establishment).
> **Elaborado por:** agente mobile-d (equipo Dev) · **Revisión prevista:** Product Owner (dermatólogo de Trujillo, *Off-Site Customer*) y Scrum Master (Aryel Meza).
> **Estado:** **BORRADOR v1.0 — PENDIENTE DE VALIDACIÓN EN LA REUNIÓN PO-1.** Todo lo que depende del criterio clínico del PO está marcado **[PO-1]**. Nada de este documento ha sido aún validado por el dermatólogo en esta formalización del Sprint 1.
> **Fuentes:** planteamiento de la tesis (indicadores TA/NFS/PEO validados por el PO el 01/07/2026), [`model/docs/marco_muestral_v2.md`](../../model/docs/marco_muestral_v2.md) (marco de evaluación aprobado), [`model/docs/S1_fases_1_2.md`](../../model/docs/S1_fases_1_2.md) (Fases 1–2 CRISP-DM) y `PRODUCTO/metodologias/MOBILE_D/CONOCIMIENTO_MOBILE_D.md`.

---

## 1. Propósito y método

Este documento establece, en la fase **Explore** de Mobile-D, la base del proyecto de la aplicación móvil: quiénes son los stakeholders, cuál es el alcance y cuáles son los requisitos iniciales que guiarán las fases Initialize, Productionize, Stabilize y System Test & Fix.

**Método de recolección de requisitos (declarado por honestidad metodológica):**

1. Requisitos **derivados de la tesis**: problema general, variable independiente (uso de la app: GC sin app vs. GE con app), variable dependiente (detección de BCC medida con TA, NFS y PEO) y sus definiciones operativas ya validadas por el PO el 01/07/2026.
2. Requisitos **derivados del diseño de datos aprobado** (`marco_muestral_v2.md`): suelo de resolución del dataset (600×450), naturaleza dermatoscópica de las imágenes, advertencias declaradas y licencia de los datos (CC BY-NC-SA 4.0).
3. Requisitos **propuestos por el equipo Dev** (Mobile-D: user-centered focus con el dermatólogo de Trujillo como usuario final): validación de entrada, manejo del modelo, privacidad y usabilidad.

Todo requisito del grupo (3) y toda decisión con implicancia clínica se someten a la **reunión PO-1** (primera reunión formal Dev–PO de la app; propuesta de agenda en §9). El PO participa de forma remota (**Off-Site Customer**, práctica Mobile-D).

---

## 2. Establecimiento de stakeholders

| Stakeholder | Rol en Mobile-D | Interés / responsabilidad | Estado |
|---|---|---|---|
| **PO: dermatólogo de Trujillo** | *Off-Site Customer* / Product Owner | Valida requisitos y alcance, prioriza, define el encaje de la app en la consulta dermatológica real | Identidad y disponibilidad **por confirmar en PO-1** |
| **Scrum Master: Aryel Meza** | Gestión Scrum + Dev Team (pipeline CRISP-DM del modelo y soporte de app) | Coordinación metodológica, integración modelo–app | Activo |
| **Dev Team: Franco Muga** | Dev Team (app móvil Flutter) | Implementación de las 4 pantallas, inferencia local TFLite, validación de entrada | Activo |
| **Usuarios finales: dermatólogos de Trujillo** | Usuarios de la app | Segunda opinión fundamentada en imagen dermatoscópica dentro de su flujo de consulta | Requisitos de uso **[PO-1]** |
| **Pacientes** | Beneficiarios indirectos | No usan la app; sus imágenes (cuando las provea el profesional) **nunca salen del dispositivo** | Sin interacción directa |
| **UPAO (escuela, asesor, jurado)** | Stakeholders académicos | Rigor metodológico, entregables de tesis, trazabilidad | Activo |
| **Equipo del modelo (CRISP-DM / agente crisp-dm)** | Proveedor del contrato de inferencia | Entrega el `.tflite` versionado con manifiesto (versión, input size, normalización, umbral, SHA-256) | Frontera definida en §6 |
| **Proveedores de plataforma (Google/Apple)** | Restricciones externas | Políticas de publicación | Fuera del alcance del prototipo de tesis (§3.2) |

---

## 3. Alcance (scope definition)

### 3.1 Dentro del alcance — la app SÍ

| # | Elemento |
|---|---|
| A1 | **4 pantallas**: Inicio (estado del modelo) · Entrada (cámara/galería + validación técnica) · Resultado (ta + advertencia médica) · Registro del modelo (versión, hash, actualización). |
| A2 | **Inferencia local TFLite** (`tflite_flutter`/LiteRT) del modelo BCC vs. no-BCC en el dispositivo: Android e iOS (Flutter/Dart). |
| A3 | **Validación técnica de entrada** previa a toda inferencia (V1–V5, §4.2). |
| A4 | **Preprocesamiento local idéntico al entrenamiento** (resize al input size del manifiesto, RGB, normalización del manifiesto). |
| A5 | **Advertencia médica permanente** en el resultado (texto normativo íntegro, §7). |
| A6 | **Registro del modelo**: ficha de la versión activa, verificación de integridad y **actualización con consentimiento** (descarga temporal → SHA-256 + firma → activación atómica → rollback). |
| A7 | **Backend FastAPI de versiones del modelo** (componente del producto): `GET /v1/models/latest` con manifiesto JSON y almacenamiento HTTPS del `.tflite`. **El backend no recibe imágenes y no hace inferencia.** |

### 3.2 Fuera del alcance — la app NO

| # | Exclusión | Sustento |
|---|---|---|
| E1 | **No diagnostica**: no confirma ni descarta BCC ni ninguna patología; solo produce una salida clasificatoria experimental de apoyo al profesional | Advertencia médica (§7); tesis |
| E2 | **No es una app para pacientes**: el usuario es el dermatólogo; el paciente no interactúa con ella | User-centered focus (PO-1 ratifica) |
| E3 | **No envía imágenes ni resultados a ningún servidor**: sin telemetría de uso clínico; única comunicación de red = consulta/descarga de versiones del modelo | RNF-01 (privacidad) |
| E4 | **No gestiona historia clínica, agenda ni seguimiento de pacientes** | Alcance de tesis |
| E5 | **No hace teledermatología** ni coordinación de derivaciones | Alcance de tesis |
| E6 | **No se publica en tiendas** (prototipo de tesis con distribución controlada a los evaluadores) — **[PO-1]** | §8 del plan de evaluación |
| E7 | **Sin i18n**: solo español | Stabilize simplificado (definición del proyecto) |
| E8 | **Sin notificaciones push** ni sincronización en la nube | Definición del proyecto |
| E9 | **No persiste imágenes ni resultados** tras el uso (procesamiento volátil en memoria) — **propuesta [PO-1]** | RNF-01 |
| E10 | **No reemplaza la biopsia ni la histopatología** (patrón de referencia) ni el criterio del dermatólogo | Proceso as-is (docs/bpmn) |

---

## 4. Requisitos funcionales (por pantalla)

Convención: **Prioridad** Alta/Media (la priorización fina ocurre en los Planning Days de Productionize). La columna **PO-1** indica si el requisito requiere ratificación expresa del PO. Los criterios de aceptación definitivos se formalizan como acceptance tests en MTDD (S3–S4).

### 4.0 Transversales

| ID | Requisito | Prioridad | PO-1 |
|---|---|---|---|
| RF-01 | Navegación clara entre las 4 pantallas desde Inicio. | Alta | — |
| RF-02 | Idioma único: español. | Alta | — |
| RF-03 | Toda pantalla funcional **sin conexión**; la red se usa únicamente en Registro del modelo (RF-20/21) y en el aviso de actualización de Inicio (RF-06). | Alta | — |

### 4.1 Pantalla 1 — Inicio (estado del modelo)

| ID | Requisito | Prioridad | PO-1 |
|---|---|---|---|
| RF-04 | Mostrar el estado del modelo activo: versión, arquitectura, fecha de publicación, SHA-256 (truncado), tamaño y estado de integridad (verificado / no verificado). | Alta | — |
| RF-05 | Acceso directo a Entrada y a Registro del modelo. | Alta | — |
| RF-06 | Indicar si existe una versión más reciente del modelo (solo tras consultar el backend con conectividad; **sin descarga automática**). | Media | — |
| RF-07 | Acceso visible a la advertencia médica general y a una sección «qué es y qué no es esta app» (apoyo, no diagnóstico). | Alta | ✔ (texto) |
| RF-08 | Primera ejecución sin modelo activo: guiar al usuario al modelo incluido en la app (bundled) o a la actualización controlada. | Alta | — |

### 4.2 Pantalla 2 — Entrada (cámara/galería + validación)

| ID | Requisito | Prioridad | PO-1 |
|---|---|---|---|
| RF-09 | Capturar imagen con la cámara **o** seleccionarla de la galería del dispositivo. | Alta | — |
| RF-10 | Previsualización de la imagen y confirmación explícita antes de analizar. | Alta | — |
| RF-11 | **Validación técnica previa a toda inferencia** según las reglas V1–V5 (tabla siguiente). | Alta | ✔ (V3 y política) |
| RF-12 | Rechazos con **mensaje accionable** (qué corregir y por qué: p. ej., «la imagen es menor que 600×450 px, resolución mínima del dataset de entrenamiento»). | Alta | — |
| RF-13 | Aviso de dominio en pantalla: *el modelo fue entrenado con imágenes dermatoscópicas; una fotografía de celular no es equivalente*. | Alta | ✔ (texto) |
| RF-14 | De la imagen validada se deriva el flujo a Resultado; si la validación falla, no se ejecuta la inferencia. | Alta | — |

**Reglas de validación de entrada (V1–V5):**

| Regla | Verificación | Criterio | Ante incumplimiento |
|---|---|---|---|
| V1 | Archivo legible | Se puede abrir y decodificar sin corrupción | Rechazar con mensaje |
| V2 | Formato admitido | JPEG o PNG | Rechazar con mensaje |
| V3 | Dimensiones mínimas | Tras corregir orientación EXIF: **lado mayor ≥ 600 px y lado menor ≥ 450 px** (equivalente a ≥ 600×450; es el suelo real del dataset ISIC 2019) | **Recomendación: bloquear la inferencia** con mensaje explicativo — política exacta **[PO-1]** |
| V4 | Orientación | EXIF corregido antes de validar dimensiones y de preprocesar | Corregir automáticamente |
| V5 | Espacio de color | RGB (escala de grises convertible a RGB se admite; formatos no convertibles, p. ej. CMYK no decodificable, se rechazan) | Rechazar o convertir según el caso |

*Justificación de V3:* el modelo se entrena con ISIC 2019, cuyo suelo de resolución es 600×450; inferir sobre imágenes de menor resolución sería extrapolar fuera del dominio de entrenamiento. El suelo garantiza además que **todas** las imágenes del marco muestral v2 (1024×1024 y 600×450, entre otras) pasan la validación.

### 4.3 Pantalla 3 — Resultado (ta + advertencia)

| ID | Requisito | Prioridad | PO-1 |
|---|---|---|---|
| RF-15 | Mostrar el resultado binario: «**Sospecha compatible con BCC**» / «**Sin sospecha de BCC**», con la probabilidad cruda y el umbral aplicado (ambos tomados del manifiesto del modelo). | Alta | ✔ (formato) |
| RF-16 | Mostrar la **advertencia médica completa** (§7) de forma **permanente y no descartable** dentro de la pantalla. | Alta (obligatoria) | ✔ (texto) |
| RF-17 | Mostrar la **versión del modelo** que produjo el resultado (trazabilidad con Registro del modelo). | Alta | — |
| RF-18 | Mostrar la **TA declarada** del modelo activo (campo del manifiesto) como contexto de desempeño. **Propuesta:** en Resultado **solo se expone TA**; NFS y PEO **no** se muestran al usuario final (quedan para el estudio; ver `S1_plan_evaluacion.md` §6). | Media | ✔ (decisión) |
| RF-19 | Acciones: «analizar otra imagen» (vuelve a Entrada) y «volver a Inicio». | Alta | — |
| RF-20 | No persistir la imagen ni el resultado al cerrar la pantalla (procesamiento volátil). | Alta | ✔ (propuesta) |

### 4.4 Pantalla 4 — Registro del modelo

| ID | Requisito | Prioridad | PO-1 |
|---|---|---|---|
| RF-21 | Ficha completa del modelo activo: versión, fecha, arquitectura, input size, normalización, umbral, SHA-256 completo, firma, tamaño y TA de referencia declarada. | Alta | — |
| RF-22 | Verificación de integridad del modelo activo al arrancar (hash local vs. registro). | Alta | — |
| RF-23 | Consulta de nueva versión (`GET /v1/models/latest`), solo con conectividad, mostrando un resumen comparativo (versión actual vs. disponible). | Media | — |
| RF-24 | Actualización **solo con consentimiento explícito** del usuario: descarga a archivo temporal → verificación **SHA-256 + firma** → **activación atómica** → **rollback automático** ante cualquier fallo de verificación o activación. | Alta | — |
| RF-25 | Conservar la versión anterior hasta que la nueva esté activada y verificada; **rollback manual** disponible. | Alta | — |
| RF-26 | Atribución de datos visible: ISIC 2019, licencia CC BY-NC-SA 4.0 (no comercial, con atribución). | Alta (ética) | — |

### 4.5 Backend de versiones (componente no móvil)

| ID | Requisito | Prioridad | PO-1 |
|---|---|---|---|
| RF-27 | `GET /v1/models/latest` devuelve el **manifiesto JSON**: versión, input size, normalización, umbral, SHA-256, firma, URL de descarga, tamaño y TA de referencia (campo propuesto). | Alta | — |
| RF-28 | Almacenamiento HTTPS del `.tflite` versionado; integridad verificable end-to-end (hash en manifiesto = hash del archivo). | Alta | — |
| RF-29 | El backend **nunca** recibe imágenes, resultados ni datos de pacientes; **no hace inferencia**. | Alta (obligatorio) | — |

---

## 5. Requisitos no funcionales

| ID | Categoría | Requisito | PO-1 |
|---|---|---|---|
| RNF-01 | **Privacidad** | La imagen **nunca sale del dispositivo**. Sin telemetría de imágenes ni de resultados. Única comunicación de red: consulta/descarga de versiones del modelo. La app lo declara visiblemente. | — (regla dura) |
| RNF-02 | **Rendimiento local** | Tiempo de inferencia objetivo: **p95 ≤ 1 000 ms en gama media** y **p95 ≤ 500 ms en gama alta** (propuestos; medición según `S1_plan_evaluacion.md` §7). | ✔ (umbrales) |
| RNF-03 | **Compatibilidad** | Android 8.0+ e iOS 13+ (propuestos); dispositivos de prueba definidos antes de S3. | ✔ |
| RNF-04 | **Usabilidad** | Español; flujo Inicio→resultado en ≤ 3 toques desde Inicio; sin capacitación técnica; legible en consulta. | ✔ |
| RNF-05 | **Fiabilidad** | Validación antes de inferencia; ningún crash ante entradas inválidas; errores con mensaje claro. | — |
| RNF-06 | **Ética / legal** | Advertencia médica permanente (§7); licencia de datos CC BY-NC-SA 4.0 con atribución; uso profesional como apoyo a la decisión, nunca como diagnóstico. | — (regla dura) |
| RNF-07 | **Trazabilidad** | Todo resultado queda asociado en pantalla a la versión verificada del modelo que lo produjo. | — |
| RNF-08 | **Seguridad de actualización** | SHA-256 + firma + activación atómica + rollback; nunca se activa un modelo cuya verificación falle. | — |
| RNF-09 | **Autonomía** | Toda la función clínica (captura → análisis → resultado) funciona 100 % sin conexión. | — |
| RNF-10 | **Mantenibilidad** | La app consume el **contrato de inferencia** (manifiesto) desacoplado del entrenamiento; MTDD + CI a partir de S3. | — |

---

## 6. Contrato de inferencia (frontera app ↔ modelo, CRISP-DM)

La app y el pipeline del modelo comparten un contrato único (coordinación con el agente crisp-dm; se congela antes de S3):

| Campo del manifiesto | Uso en la app |
|---|---|
| `version` | Identificación en Inicio, Resultado y Registro |
| `architecture` | Ficha del modelo (RF-21) |
| `input_size` | Resize local idéntico al entrenamiento |
| `normalization` | Normalización local idéntica al entrenamiento |
| `threshold` | Umbral del resultado binario (RF-15) |
| `sha256` | Verificación de integridad al arrancar (RF-22) y tras descargar (RF-24) |
| `signature` | Verificación de autenticidad de la actualización (RF-24) |
| `size_bytes` | Ficha y verificación de descarga |
| `ta_referencia` *(propuesto)* | TA declarada mostrada en Resultado/Registro (RF-18) — **[PO-1]** y por coordinar con crisp-dm |

Reglas del contrato: (1) una sola versión activa; (2) la semántica de salida es **probabilidad de BCC**; (3) el preprocesamiento en el dispositivo replica exactamente el del entrenamiento; (4) cualquier cambio de contrato exige nueva versión de modelo y de manifiesto, nunca un cambio silencioso.

---

## 7. Advertencia médica (texto normativo obligatorio)

> «Este resultado procede de un modelo experimental que analiza imágenes dermatoscópicas. No constituye un diagnóstico, no confirma ni descarta cáncer de piel y no reemplaza la evaluación de un profesional de salud. Si existe una lesión nueva, cambiante, sangrante o preocupante, solicite valoración médica.»

**Reglas de exhibición:** (1) se muestra **siempre**, completa y sin resumir, en la pantalla Resultado, de forma permanente y no descartable; (2) es accesible además desde Inicio (RF-07); (3) no se traduce ni se parafrasea (texto único normativo); (4) su eliminación o acortamiento en cualquier pantalla es un **defecto bloqueante** en System Test & Fix.

---

## 8. Restricciones y supuestos

| # | Restricción / supuesto |
|---|---|
| R1 | Datos exclusivamente ISIC 2019; licencia CC BY-NC-SA 4.0 (no comercial, con atribución). |
| R2 | En S1 el modelo `.tflite` **aún no existe** (CRISP-DM está en Fase 3): la app se desarrollará contra el contrato de inferencia (§6) y modelos de prueba, y se integrará en S3–S4. |
| R3 | Imágenes del dominio: dermatoscópicas. La app **no promete** desempeño sobre fotografías de celular y lo advierte (RF-13). |
| R4 | Prevalencia artificial del marco de evaluación (50 % BCC): la TA declarada no es extrapolable a la prevalencia real de Trujillo; se declara en Registro del modelo y en la tesis. |
| R5 | Distribución del prototipo: controlada a evaluadores/PO, sin tiendas (E6) **[PO-1]**. |
| R6 | Equipo co-localizado de 2 desarrolladores (< 10 semanas): perfil home ground de Mobile-D. |

---

## 9. Puntos a validar con el PO en la reunión PO-1

Reunión remota (**Off-Site Customer**), fecha propuesta: semana del 9–13/11/2026 (S2) **[por confirmar]**. Agenda cerrada:

1. Ratificar el **texto normativo** de la advertencia médica (§7) y del aviso de dominio (RF-13).
2. Política ante V3: ¿bloquear la inferencia con imagen < 600×450 (recomendado) o permitir con advertencia? (RF-11/12)
3. ¿Resultado con solo TA declarada y sin NFS/PEO? (RF-18; detalle en `S1_plan_evaluacion.md` §6)
4. Formato del resultado: binario + probabilidad cruda + umbral visibles (RF-15).
5. ¿Confirmar que la app no persiste imágenes ni resultados? (RF-20, E9)
6. Ratificar el **proceso as-is** y el punto de inserción de la app (`docs/bpmn/proceso_as_is_deteccion_bcc.md`).
7. Aceptar la propuesta de **modo evaluación** con exportación CSV local sin etiquetas (para el grupo GE).
8. Dispositivos objetivo y versiones mínimas de SO (RNF-03).
9. Umbral de rendimiento aceptable (RNF-02).
10. Contenido visible del Registro del modelo (TA de referencia, atribución ISIC/CC BY-NC-SA 4.0).
11. Confirmar distribución controlada sin tiendas (E6).

---

## 10. Trazabilidad con la tesis

| Requisito / grupo | Sostiene |
|---|---|
| A2, A3, A4, RNF-02, RNF-09 | Variable independiente «uso de la app» (GE vs. GC) operacionalizable en el experimento |
| RF-11, RF-15 | Medición de TP/TN/FP/FN por imagen → TA, NFS, PEO por subconjunto (marco v2) |
| RF-16, RNF-06 | Salvaguarda ética declarada en la tesis (apoyo, no diagnóstico) |
| RNF-01, E3, RF-20 | Garantía de privacidad declarada en la tesis (inferencia local) |
| RF-21–RF-29, §6 | Reproducibilidad y trazabilidad del modelo usado en el experimento (misma versión para GC/GE) |

---

## 11. Historial de versiones

| Versión | Fecha | Descripción |
|---|---|---|
| v1.0 | 04/11/2026 | Borrador inicial del equipo Dev (agente mobile-d), formalización retroactiva del Sprint 1 (5–16/10/2026). **Pendiente de validación en PO-1.** |

*Documento de requisitos de la fase Explore · Mobile-D · DERM_IAPP · Sprint 1 (retroactivo, 5–16/10/2026).*
