# Sprint 1 — Registro de las Fases 1 y 2 (CRISP-DM): Business Understanding y Data Understanding

> **Proyecto:** Aplicación móvil con técnicas de Deep Learning para la detección de carcinoma
> basocelular en Trujillo 2026 (DERM_IAPP — UPAO).
> **Sprint:** 1 (retroactivo, 5–16 de octubre de 2026) · **Fases CRISP-DM:** 1 y 2.
> **Elaborado por:** agente crisp-dm · **Revisión:** PO (dermatólogo) y Scrum Master (Aryel Meza).
> **Fuentes citadas:** planteamiento de la tesis (problema general, objetivo general, matriz de
> consistencia e indicadores **validados por el PO el 1 de julio de 2026**),
> `PRODUCTO/DATA/ANALISIS_DATASET_ISIC2019.md` (entendimiento de datos verificado),
> [`marco_muestral_v2.md`](marco_muestral_v2.md) (diseño de datos aprobado) y
> `PRODUCTO/metodologias/CRISP_DM/CONOCIMIENTO_CRISP_DM.md`.
> **Nota de registro:** este documento consolida en un solo registro de fase los aportes de
> Business Understanding y Data Understanding del Sprint 1 y es la versión vigente de los
> borradores `S1_business_understanding.md` y `S1_data_understanding.md` (retirados al
> reubicar la documentación del modelo en `model/docs/`, según la convención del README del repo).

---

## 1. Fase 1 — Business Understanding

### 1.1 Objetivos (parten de la tesis; no se re-definen)

| Elemento | Contenido (citado de la tesis) |
|---|---|
| **Problema general** | «¿De qué manera el uso de una aplicación móvil con técnicas de Deep Learning influye en la detección de carcinoma basocelular en Trujillo durante el 2026?» |
| **Variable independiente** | Uso de la aplicación móvil con técnicas de Deep Learning (GC: sin app · GE: con app) |
| **Variable dependiente** | Detección de carcinoma basocelular, medida con los indicadores TA, NFS y PEO |
| **Objetivo de negocio** | Mejorar la detección del BCC en Trujillo 2026 mediante una app móvil con **inferencia local** (sin conexión), como apoyo a la decisión y nunca como sustituto del criterio médico |
| **Definición técnica del problema** | Clasificación binaria de imagen: **BCC vs. no-BCC** (MEL/NV/AK/BKL/DF/VASC/SCC = no-BCC; UNK excluido) |

### 1.2 Criterios de éxito (indicadores de la matriz de consistencia, validados por el PO)

| Indicador | Fórmula oficial | Lectura clínica |
|---|---|---|
| **TA** (tasa de acierto) | TA = ((TP + TN) / (TP + TN + FP + FN)) × 100 | Proporción de decisiones correctas de la prueba |
| **NFS** (nº de falsos sospechosos) | NFS = FP | Carga de falsas alarmas (derivaciones/costos innecesarios) |
| **PEO** (% de error de omisión) | PEO = (FN / (TP + FN)) × 100 | Riesgo clínico máximo: BCC reales no detectados |

**Protocolo de medición:** cada indicador se mide **por subconjunto** (una fila por prueba).
Cada familia produce 30 filas por grupo (GC y GE); comparación entre grupos con **U de
Mann-Whitney** (n = 30 vs. 30, α = 0,05). **No se usa accuracy aislada.** Las metas numéricas
son las de la matriz de consistencia de la tesis (validadas por el PO); este pipeline no las
re-define. El diseño detecta un efecto de ≈5 pp de TA con DE ≈ 3,5 pp (MDE ≈ 4,0 pp con n = 30).

### 1.3 Requisitos y restricciones clave de la fase

| Tipo | Requisito / restricción |
|---|---|
| Datos | Usar exclusivamente ISIC 2019 (sin fuentes externas); etiqueta binaria derivada del one-hot oficial |
| Diseño | Partición train/validación **por `lesion_id`** y tratamiento del desbalance 1:6,6: **decisiones de diseño, no opcionales** |
| Modelo | Arquitecturas livianas para móvil (MobileNetV3-Small, EfficientNet-Lite0); sin modelos pesados ni Transformers en la ruta crítica |
| Producto | Inferencia **local** (TFLite); backend FastAPI solo versiona el modelo (excepción única de `.py`) |
| Entorno | Notebooks `.ipynb` Colab-ready autónomos (disco efímero, sin Drive); trabajo en `/content/derm_iapp` |
| Legal/ética | Licencia CC BY-NC-SA 4.0 (no comercial, con atribución); advertencia médica permanente en la app |

---

## 2. Fase 2 — Data Understanding

### 2.1 Resumen del entendimiento (citando `ANALISIS_DATASET_ISIC2019.md`)

El análisis completo y verificado (33 569 imágenes leídas, 0 corruptas, 0 errores CRC) está en
dicho documento; **sus §1–§7 están vigentes** y son la base de esta fase. Hallazgos que
gobiernan el pipeline:

| # | Hallazgo (sección del análisis) | Cifra | Implicación |
|---|---|---|---|
| 1 | Composición 9 clases (§3, §4) | Train: NV 12 875 · MEL 4 522 · BCC 3 323 · BKL 2 624 · AK 867 · SCC 628 · VASC 253 · DF 239. Test: NV 2 495 · UNK 2 047 · MEL 1 327 · BCC 975 · BKL 660 · AK 374 · SCC 165 · VASC 104 · DF 91 | Partición oficial ≈3:1; clase única derivable del one-hot sin ambigüedad |
| 2 | Vista binaria (§3, §4) | Train: BCC 3 323 (13,12 %) vs. no-BCC 22 008 (86,88 %) → **1:6,6**. Test evaluable: BCC 975 (15,75 %) vs. 5 216 (84,25 %) | Desbalance de la tarea: exige balanceo/ponderación; accuracy sola no válida |
| 3 | UNK del test (§4) | 2 047 imágenes (24,85 %) sin etiqueta → pool evaluable del test = 6 191 | Exclusión obligatoria; no hay TP/TN/FP/FN sin etiqueta |
| 4 | Calidad de metadatos (§3.1, §4.1) | Faltantes reales: sitio 10,4 % (train) / 8,0 % (test); sexo 1,5 % / 4,1 %; edad 0,4 % (113 ceros) | Metadatos para trazabilidad y EDA; **nunca entrada del modelo** |
| 5 | `lesion_id` del train (§3.2) | 23 247 imágenes con id (91,8 %); **11 847 lesiones**; **5 059 multi-imagen** (16 459 imágenes, máx. 31); **2 084 sin id** | Split train/val **por lesión**; sin id = lesión propia |
| 6 | Test sin `lesion_id` (§4.3) | Columna inexistente (limitación estructural) | Imágenes de origen test = lesiones propias |
| 7 | Duplicados y fuga (§6) | 50 duplicados exactos en train (25 pares); 0 ids comunes y 0 MD5 cruzados train↔test; 3 casi-duplicados pHash (`ISIC_0034511`, `ISIC_0034619`, `ISIC_0068690`, ninguno BCC) | Eliminar/excluir antes de preparar; sin fuga de contenido |
| 8 | Dimensiones (§3.3, §4.2) | Train: 1024×1024 (49 %) + 600×450 (40 %) + cola; test: solo 2 tamaños | Preprocesamiento: redimensionar a la entrada del modelo |
| 9 | Demografía del BCC (§7) | Edad media 65,7 años (mediana 70); 60,2 % hombres; cabeza/cuello 34,0 % (+ torso 33,5 %) | Señal clínica real **y** riesgo de atajo; el modelo solo recibe píxel |
| 10 | Proporciones train/test (§5) | ≈75/25 % en todas las clases etiquetadas (BCC 77,3 % en train) | Fusión train+test coherente para el marco v2 |

### 2.2 Limitaciones estructurales a declarar en la tesis

El test no trae `lesion_id` (independencia train↔test no verificable por identificador) ·
2 047 UNK no evaluables · 50 duplicados eliminados · desbalance 1:6,6 · sesgo demográfico del
BCC · prevalencia artificial del marco (50 % BCC, no extrapolable a Trujillo) · imágenes
dermoscópicas (una foto de celular no es equivalente) · 2 084 imágenes sin `lesion_id` ·
**adicionales del marco v2:** el marco de evaluación ya no es el test oficial aislado (pool
fusionado), el descarte trazado de ~22 873 no-BCC y las imágenes de origen test no agrupables
por lesión (detalle en `marco_muestral_v2.md` §10).

---

## 3. Decisiones del Sprint 1 (registro)

| # | Decisión | Contenido aprobado | Sustento |
|---|---|---|---|
| D1 | **Adopción del marco muestral v2** | 90 subconjuntos = 3 familias (TA/NFS/PEO) × 30 pruebas × 30 imágenes (15 BCC + 15 no-BCC); disyunción intra-familia, solapamiento inter-familias; etiqueta solo en manifiesto CSV | `marco_muestral_v2.md` (aprueba el equipo con el PO). El marco v1 (60 subconjuntos GC/GE de solo-test) queda **obsoleto** |
| D2 | **Pool fusionado etiquetado** | Train (25 331) + test evaluable (6 191) − 50 duplicados − 3 casi-duplicados = **31 469** (BCC **4 298**, no-BCC 27 171). **El TEST es el marco de evaluación, no un test tradicional** | Techo de BCC del test (975) insuficiente para 90 pruebas disjuntas |
| D3 | **Reserva del marco antes del split** | Orden determinista: limpieza → reserva TEST (1 350 BCC + 1 350 no-BCC únicas) → balanceo → split | Congela la evaluación antes de tocar los datos de entrenamiento |
| D4 | **Balanceo 1:1 del remanente** | Undersampling estratificado de no-BCC por diagnóstico, preservando la mezcla aprobada **≈48 % NV, ≈26 % MEL, ≈12 % BKL, ≈7 % AK, resto variable**; remanente 28 769 → 5 896 balanceadas; ~22 873 no-BCC trazadas como `no_usadas` | Desbalance 1:6,6; TA de validación interpretable (prevalencia 50 %) |
| D5 | **Split TRAIN 80 % / VAL 20 %** | Estratificado y **agrupado por `lesion_id`** (sin id y origen test = lesiones propias); `VAL_FRACTION = 0.20` configurable y registrada | 5 059 lesiones multi-imagen: fuga de identidad si no se agrupa |
| D6 | **Semilla global única 2026** | `parametros.json` + `semilla.txt`; regeneración bit a bit; auditoría por SHA-256 | Reproducibilidad total y anti p-hacking |
| D7 | **Tecnologías del modelo** | TensorFlow/Keras; MobileNetV3-Small (baseline) vs. EfficientNet-Lite0 (comparador); transfer learning ImageNet; export **TFLite** versionado con manifiesto | Livianos para inferencia local en móvil |
| D8 | **Estrategia de código** | Todo el pipeline en notebooks `.ipynb` Colab-ready autónomos (descargan los 6 archivos oficiales si falta alguno con tamaño byte-exacto; trabajo en `/content/derm_iapp`); única excepción `.py`: backend FastAPI | Disco efímero de Colab, sin Drive |
| D9 | **Manifiesto único** | `dataset_etiquetado.parquet` (11 columnas, incl. `destino_asignado`) como única fuente de verdad | Trazabilidad completa de las 31 469 imágenes |

---

## 4. Estado de las fases y entregables del Sprint 1

| Entregable | Estado | Ubicación |
|---|---|---|
| 1.1–1.4 Objetivos, situación, criterios y plan (Fase 1) | **Completada** | Este documento §1; criterios operativos en `marco_muestral_v2.md` |
| 2.1–2.4 Recopilación, descripción, exploración y calidad (Fase 2) | **Completada** | `PRODUCTO/DATA/ANALISIS_DATASET_ISIC2019.md` §1–§7 (vigentes) |
| Diseño de datos v2 (norma del pipeline) | **Aprobado** | `model/docs/marco_muestral_v2.md` |
| Análisis de datos actualizado (obsolescencia del marco v1 en §8.4, §8.5 y anexo) | **Completada** | `PRODUCTO/DATA/ANALISIS_DATASET_ISIC2019.md` (nota 2026-11-04) |
| EDA reproducible en Colab (complemento de la Fase 2) | En curso | `model/notebooks/02_analisis_exploratorio.ipynb` (prompt generado este sprint) |

**Decisión de fase: proseguir a la Fase 3 (Data Preparation)** con los notebooks
`03_preparacion_datos.ipynb` y `04_marco_evaluacion.ipynb`, bajo la norma de
`marco_muestral_v2.md`.

---

## 5. Trazabilidad de decisiones hacia las siguientes fases

| Decisión | Fase que la ejecuta | Notebook |
|---|---|---|
| D1–D3, D6, D9 | Fase 3 (reserva del marco) | `04_marco_evaluacion.ipynb` |
| D4–D6, D9 | Fase 3 (balanceo y split) | `03_preparacion_datos.ipynb` |
| D7 | Fase 4 (modelado) y Fase 6 (deployment) | `05`–`06` |
| D1, D6 | Fase 5 (evaluación TA/NFS/PEO por subconjunto; Mann-Whitney) | `07_evaluacion.ipynb` |

*Registro de las Fases 1–2 del pipeline CRISP-DM · DERM_IAPP · Sprint 1 (retroactivo,
5–16/10/2026) · Formalizado el 04/11/2026.*
