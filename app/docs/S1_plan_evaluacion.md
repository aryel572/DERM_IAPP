# S1 — Plan de evaluación de la aplicación (Fase Explore · Mobile-D)

> **Proyecto:** DERM_IAPP — Aplicación móvil con técnicas de Deep Learning para la detección de carcinoma basocelular (BCC) en Trujillo 2026 (UPAO).
> **Sprint:** 1 (retroactivo, 5–16 de octubre de 2026) · **Fase Mobile-D:** 1 — Explore.
> **Elaborado por:** agente mobile-d (equipo Dev) · **Revisión prevista:** Product Owner (dermatólogo, *Off-Site Customer*) y Scrum Master (Aryel Meza).
> **Estado:** **BORRADOR v1.0 — PENDIENTE DE VALIDACIÓN EN PO-1.** Las decisiones marcadas **[PO-1]** requieren ratificación expresa del dermatólogo.
> **Fuente normativa:** [`model/docs/marco_muestral_v2.md`](../../model/docs/marco_muestral_v2.md) (marco de evaluación aprobado; norma obligatoria). Complementa a [`S1_explore_requisitos_app.md`](S1_explore_requisitos_app.md).

---

## 1. Objetivo y alcance del plan

Definir **cómo se evaluará la aplicación** en tres niveles complementarios:

| Nivel | Qué se mide | Dónde se define |
|---|---|---|
| **E1 — Indicadores de la tesis** | TA, NFS y PEO del proceso de detección **con app (GE)** vs. **sin app (GC)**, sobre el marco muestral v2 | Este documento §§2–6 |
| **E2 — Métricas técnicas de la app** | Tiempo de inferencia, tamaño del modelo, entre otras | Este documento §7 |
| **E3 — Aceptación y prueba de sistema (Mobile-D)** | Acceptance tests en los Release Days y pruebas de sistema en System Test & Fix | Este documento §8 |

El plan **no re-define** las metas numéricas de la tesis (son las de la matriz de consistencia, validadas por el PO el 01/07/2026) ni modifica el diseño estadístico: lo aplica a la mecánica de uso de la app.

---

## 2. Base normativa: el marco muestral v2 (resumen operativo)

| Elemento | Valor normativo (marco v2) |
|---|---|
| Estructura | `dataset/TEST/{TA,NFS,PEO}/subconjunto_01..30/` — 90 subconjuntos en total |
| Pruebas | 3 familias (una por indicador) × 30 subconjuntos = **90 pruebas; 30 pruebas por indicador** |
| Composición de cada prueba | 30 imágenes planas: **15 BCC + 15 no-BCC**, con **melanoma presente en cada prueba** (mezcla ≈7 NV / ≈4 MEL / ≈2 BKL / ≈1 AK + resto variable) |
| Etiquetas | Solo en el **manifiesto CSV** de cada subconjunto (`image_id`, `es_bcc`, `lesion_id`, `origen`, `sha256`, …); las carpetas no se dividen por clase |
| Disyunción | Intra-familia por imagen y por `lesion_id` (obligatoria); solapamiento entre familias permitido y esperado |
| Reserva | 2 700 imágenes únicas (1 350 BCC + 1 350 no-BCC) |
| Semilla | 2026; regeneración bit a bit |
| Suelo de resolución | 600×450 px → **todas las imágenes del marco superan la validación V3 de la app** |

El grupo (GC o GE) **es la condición del experimento, no una propiedad del dataset**: ambos grupos evalúan exactamente el mismo marco.

---

## 3. Diseño experimental (de la tesis, no se modifica)

| Elemento | Definición |
|---|---|
| Unidad de análisis | El **subconjunto** (una fila de ficha por prueba) |
| Grupos | **GC** (detección sin app) vs. **GE** (detección con la app DERM_IAPP) |
| Tamaño | 30 filas por familia por grupo (n = 30 vs. 30) |
| Comparación | **U de Mann-Whitney** por familia (TA, NFS, PEO), α = 0,05 |
| Potencia | El diseño detecta un efecto de ≈5 pp de TA con DE ≈ 3,5 pp (MDE ≈ 4,0 pp con n = 30) |
| Prevalencia | Artificial (50 % BCC por diseño): la TA **no es extrapolable** a la prevalencia real de Trujillo; los contrastes GC vs. GE sí son válidos — se declara en la tesis y en la app (§6) |

---

## 4. Indicadores y su medición con la app

### 4.1 Clasificación por imagen

Para cada imagen de un subconjunto se contrasta la **decisión final del evaluador** (variable del estudio) contra la etiqueta del manifiesto (`es_bcc`):

| Etiqueta \ Decisión | «Sospecha compatible con BCC» | «Sin sospecha de BCC» |
|---|---|---|
| **BCC** (`es_bcc = true`) | **TP** | **FN** (omisión) |
| **no-BCC** (`es_bcc = false`) | **FP** (falso sospechoso) | **TN** |

En el grupo GE se registra además la **salida bruta de la app** (predicción, probabilidad, versión del modelo) para trazabilidad y análisis; la unidad de registro del indicador es la **decisión final del evaluador** — **[PO-1]** ratificar esta convención.

### 4.2 Fórmulas por subconjunto (30 imágenes: 15 BCC + 15 no-BCC)

| Indicador | Fórmula oficial | Forma por subconjunto | Rango |
|---|---|---|---|
| **TA** (tasa de acierto) | ((TP+TN)/(TP+TN+FP+FN))×100 | (TP+TN)/30×100 | 0–100 % |
| **NFS** (nº de falsos sospechosos) | NFS = FP | FP | 0–15 |
| **PEO** (% de error de omisión) | (FN/(TP+FN))×100 | FN/15×100 | 0–100 % |

**Ejemplo ilustrativo (no es dato real):** TP=12, FN=3, FP=2, TN=13 → TA = 25/30×100 = **83,3 %**; NFS = **2**; PEO = 3/15×100 = **20,0 %**.

**No se usa accuracy aislada ni promedios globales sin prueba por familia** (norma de la Fase 1 CRISP-DM).

---

## 5. Protocolo de ejecución

### 5.1 Grupo experimental GE (con la app)

1. El evaluador recibe el subconjunto (familia + `subconjunto_id`) **sin el manifiesto de etiquetas** (cegamiento).
2. Para cada imagen del subconjunto: la carga por la pantalla **Entrada** (galería o cámara), la app valida (V1–V5) y muestra en **Resultado** la salida binaria con probabilidad, la **TA declarada del modelo** y la advertencia médica.
3. El evaluador registra su **decisión final** (con el apoyo de la app) en la ficha (§5.3). Se anota también la salida bruta de la app (§4.1).
4. Se repite para los 30 subconjuntos de cada familia (900 imágenes por familia; 2 700 evaluaciones de imagen por grupo en total).

**Propuesta de apoyo opcional (solo para el estudio): «modo evaluación»** — una sección restringida de la app que: (a) organiza la carga imagen por imagen del subconjunto activo; (b) registra localmente cada evaluación (imagen `image_id`/nombre de archivo, predicción binaria de la app, probabilidad, versión del modelo, decisión final del evaluador, marca de tiempo); (c) **exporta un CSV local sin etiquetas** para cruzar offline contra el manifiesto. Esto elimina errores de transcripción. **Decisión [PO-1]**: aceptar (recomendado) o evaluar con ficha manual externa.

### 5.2 Grupo control GC (sin app)

1. Mismas imágenes, mismo orden aleatorizado, mismo evaluador y condiciones equivalentes de visualización (visor de imágenes estándar del equipo de cómputo definido **[PO-1]**).
2. El evaluador registra su decisión final en la ficha **sin ninguna salida del modelo**.
3. Misma duración estimada de sesión y mismos descansos que en GE (control de fatiga) — **[PO-1]** protocolo.

### 5.3 Ficha de recolección (plantilla)

Una fila por subconjunto; columnas mínimas:

`familia | subconjunto_id | grupo (GC/GE) | evaluador | fecha | TP | FN | FP | TN | TA | NFS | PEO | observaciones`

Y, solo para GE, un anexo por imagen: `familia | subconjunto_id | image_id | prediccion_app | probabilidad_app | version_modelo | decision_final_evaluador | timestamp`.

### 5.4 Controles de validez

| Control | Medida |
|---|---|
| Cegamiento | El evaluador nunca ve el manifiesto de etiquetas ni los conteos parciales |
| Efecto de orden/aprendizaje | Orden aleatorizado de imágenes y de subconjuntos por evaluador (semilla 2026) |
| Consistencia inter-evaluador | El mismo evaluador cubre pares GC/GE de una familia cuando sea posible — **[PO-1]** |
| Integridad | Verificación SHA-256 de los subconjuntos usados (herencia del marco v2) |
| Trazabilidad del modelo | GE fija la **misma versión del modelo** para todo el experimento (Registro del modelo; sin actualizaciones a mitad de estudio) |

---

## 6. Qué muestra la app de los indicadores (decisión propuesta)

**Propuesta del equipo Dev — decisión a ratificar en PO-1:**

| Indicador | Dónde se calcula | Dónde se muestra |
|---|---|---|
| **TA** | Offline, por subconjunto, desde la ficha del estudio | En **Resultado**: la **TA declarada del modelo activo** (campo `ta_referencia` del manifiesto), siempre acompañada de la advertencia médica. También en **Registro del modelo** |
| **NFS** | Offline, por subconjunto, desde la ficha del estudio | **No se expone** al usuario final (métrica del estudio) |
| **PEO** | Offline, por subconjunto, desde la ficha del estudio | **No se expone** al usuario final (métrica del estudio) |

**Justificación:** el usuario final es el dermatólogo en consulta; la TA declarada da un contexto honesto y agregado del desempeño del modelo, mientras que NFS y PEO son métricas **agregadas del experimento** (por subconjunto y por grupo) que no tienen sentido para un resultado individual y podrían inducir falsa seguridad (TA alta) o alarma (PEO alto) si se expusieran. La advertencia médica permanente (§7 de los requisitos) es el contrapeso obligatorio de cualquier cifra mostrada.

**Nota de coordinación con CRISP-DM:** el campo `ta_referencia` del manifiesto debe ser producido por el pipeline del modelo (evaluación técnica del modelo solo, notebook 07) y congelado con cada versión — por coordinar con el agente crisp-dm **[PO-1]**.

---

## 7. Métricas técnicas de la app (E2)

| Métrica | Definición | Instrumento | Objetivo propuesto **[PO-1]** |
|---|---|---|---|
| Tiempo de inferencia | `invoke` del intérprete TFLite, sin E/S de imagen ni UI (p50/p95) | Instrumentación en la app (cronómetro alrededor de la inferencia) | p95 ≤ 1 000 ms (gama media); ≤ 500 ms (gama alta) |
| Tiempo de validación + preprocesamiento | V1–V5 + resize + normalización (p95) | Instrumentación | p95 ≤ 300 ms |
| Tiempo total pantalla→resultado | Desde confirmación en Entrada hasta Resultado | Instrumentación | p95 ≤ 2 000 ms (gama media) |
| Tamaño del modelo | Bytes del `.tflite` (campo `size_bytes` del manifiesto) | Manifiesto | ≤ 10 MB fp32 (MobileNetV3-Small ≈ 10 MB; int8 menor) — el valor real lo fija CRISP-DM |
| Tamaño de la app instalada | MB instalados | Dispositivo de prueba | Se registra como métrica informativa |
| Memoria pico (opcional) | RSS durante la inferencia | Instrumentación | Informativa |

**Procedimiento de medición:** (1) 3 imágenes de referencia (1024×1024, 600×450 y una del límite exacto); (2) **N ≥ 30 repeticiones** por imagen y dispositivo, tras descartar la primera ejecución (calentamiento); (3) dispositivos de prueba: 1 de gama media y 1 de gama baja **[PO-1 lista]**; (4) resultados registrados en una **ficha técnica por versión del modelo** y reportados en los Release Days. La medición formal se realiza en S3 (primera inferencia integrada) y se repite en cada Release Day.

---

## 8. Evaluación dentro del ciclo Mobile-D (E3)

### 8.1 Release Days (Productionize, S3–S4) — acceptance testing con el PO

**Piloto de aceptación:** las 30 imágenes de `TEST/TA/subconjunto_01/` + un lote de imágenes inválidas de prueba. Criterios de aceptación preliminares (se formalizan como acceptance tests en los Planning Days):

- [ ] A1: las 30 imágenes del piloto se procesan sin crash; **el 100 % de los resultados muestra la advertencia médica completa**.
- [ ] A2: las imágenes inválidas (formato no admitido, archivo corrupto, 480×360, color no convertible) son rechazadas con el mensaje correcto (tests MTDD de V1–V5).
- [ ] A3: el resultado muestra la versión del modelo y coincide con el Registro del modelo.
- [ ] A4: actualización simulada: manifiesto con hash alterado → rechazo + rollback; hash y firma correctos → activación atómica.
- [ ] A5: modo avión: captura → análisis → resultado funciona sin red.
- [ ] A6: tiempo de inferencia p95 dentro del objetivo en el dispositivo de prueba.

### 8.2 System Test & Fix (S5)

Prueba del sistema contra los requisitos de `S1_explore_requisitos_app.md` y el protocolo de este documento (subconjuntos piloto de las 3 familias); los defectos se documentan y se corrigen en la iteración Fix. La **evaluación formal de la tesis** (90 pruebas × 2 grupos, Mann-Whitney) se ejecuta como experimento de tesis con la app ya estable.

---

## 9. Riesgos de la evaluación y mitigaciones

| # | Riesgo | Mitigación |
|---|---|---|
| 1 | El evaluador sobre-confía en la app (anclaje) | Advertencia permanente + probabilidad cruda visible + capacitación breve estandarizada **[PO-1]** |
| 2 | Errores de transcripción en fichas | Modo evaluación con export CSV (§5.1) o doble captura |
| 3 | Efecto de orden/aprendizaje | Aleatorización con semilla 2026; descansos entre familias |
| 4 | Prevalencia artificial (50 % BCC) | Declaración explícita en tesis y en Registro del modelo; solo se contrastan GC vs. GE |
| 5 | Cambio de versión del modelo a mitad del estudio | Versión congelada por protocolo (§5.4) |
| 6 | Carga operativa (2 700 evaluaciones por grupo) | Sesiones por familia; modo evaluación; subconjuntos autónomos |
| 7 | Imágenes de dominio no dermatoscópico en la práctica real | Aviso de dominio (RF-13 de los requisitos); la evaluación usa las imágenes del marco (dermoscópicas) |

---

## 10. Preguntas para PO-1 (específicas de la evaluación)

1. ¿Ratifica que en Resultado se muestre **solo la TA declarada** del modelo y nunca NFS/PEO? (§6)
2. ¿Acepta el **modo evaluación** con export CSV local sin etiquetas para el grupo GE? (§5.1)
3. ¿Confirma la convención de registro: decisión final del evaluador como variable del estudio y salida bruta de la app como trazabilidad? (§4.1)
4. ¿Protocolo GC: visor y condiciones equivalentes? (§5.2)
5. ¿Lista de dispositivos de prueba y umbrales de rendimiento aceptables? (§7)
6. ¿Capacitación breve estandarizada de los evaluadores? (§9-1)

---

## 11. Referencias

- `model/docs/marco_muestral_v2.md` — marco de evaluación (norma obligatoria; §§2–5, 7, 10).
- `model/docs/S1_fases_1_2.md` — indicadores TA/NFS/PEO, protocolo de medición y Mann-Whitney (§§1.2–1.3).
- `app/docs/S1_explore_requisitos_app.md` — requisitos de la app (validación V1–V5, advertencia, contrato de inferencia).
- `docs/bpmn/proceso_as_is_deteccion_bcc.md` — proceso as-is y punto de inserción de la app.
- `PRODUCTO/metodologias/MOBILE_D/CONOCIMIENTO_MOBILE_D.md` — prácticas Mobile-D (Metrics, Release Days).

---

## 12. Historial de versiones

| Versión | Fecha | Descripción |
|---|---|---|
| v1.0 | 04/11/2026 | Borrador inicial del equipo Dev (agente mobile-d), formalización retroactiva del Sprint 1 (5–16/10/2026). **Pendiente de validación en PO-1.** |

*Plan de evaluación de la fase Explore · Mobile-D · DERM_IAPP · Sprint 1 (retroactivo, 5–16/10/2026).*
