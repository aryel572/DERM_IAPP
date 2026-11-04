# Marco muestral v2 — documento normativo del diseño de datos

> **Proyecto:** DERM_IAPP — Aplicación móvil con Deep Learning para detección de carcinoma
> basocelular (UPAO, Trujillo 2026).
> **Estado:** **APROBADO** (decisión del equipo con el PO; Sprint 1, 5–16 de octubre de 2026).
> **Alcance:** norma obligatoria para los notebooks del pipeline (preparación de datos, marco de
> evaluación y evaluación) y para cualquier re-generación del dataset. **Es LA referencia de los
> notebooks `03_preparacion_datos.ipynb`, `04_marco_evaluacion.ipynb` y `07_evaluacion.ipynb`.**
> **Reemplaza al marco v1** (60 subconjuntos GC/GE de solo-test, generados con el script
> `PRODUCTO/DATA/03_regenerar_evaluacion.py` en `PRODUCTO/DATA/evaluacion_oficial/`), que queda
> como artefacto histórico.
> **Base de entendimiento de datos:** `PRODUCTO/DATA/ANALISIS_DATASET_ISIC2019.md` (§1–§7 vigentes;
> §8.4, §8.5 y anexo marcados como históricos por este documento).

---

## 1. Principios del diseño

| # | Principio | Enunciado |
|---|---|---|
| P1 | **El test oficial no es un test tradicional: es el marco de evaluación** | Las imágenes del test etiquetado se reservan para sostener las 90 pruebas de los indicadores; el entrenamiento usa el remanente del pool fusionado |
| P2 | **El manifiesto maestro es la única fuente de verdad** | Toda asignación vive en `dataset_etiquetado.parquet`; los notebooks nunca deducen destinos por su cuenta ni leen `data_cruda` directo |
| P3 | **Reproducibilidad total** | Semilla global única **2026**; regenerar los notebooks produce exactamente el mismo dataset, bit a bit |
| P4 | **Trazabilidad completa** | Cada una de las 31 469 imágenes del pool queda con un `destino_asignado`, incluidas las descartadas (`no_usadas`); nada se borra silenciosamente |
| P5 | **Disyunción intra-familia, solapamiento inter-familias** | Dentro de una familia (TA, NFS o PEO) las 30 pruebas no comparten imágenes ni lesiones; entre familias el solapamiento es permitido y esperado |
| P6 | **Etiqueta solo en el manifiesto** | La etiqueta BCC/no-BCC de cada imagen vive en el manifiesto CSV del subconjunto (fuente única de verdad); las carpetas del marco **no** se dividen por clase |

---

## 2. Pool fusionado etiquetado

### 2.1 Composición

| Paso | Operación | Imágenes | BCC | no-BCC |
|---|---|---:|---:|---:|
| 1 | Train oficial (ISIC 2019) | 25 331 | 3 323 | 22 008 |
| 2 | + Test evaluable (test 8 238 − 2 047 UNK) | + 6 191 | + 975 | + 5 216 |
| 3 | = Pool fusionado preliminar | **31 522** | 4 298 | 27 224 |
| 4 | − 50 duplicados exactos (dentro del train) | − 50 | 0 | − 50 |
| 5 | − 3 casi-duplicados train↔test (`ISIC_0034511`, `ISIC_0034619`, `ISIC_0068690`; ninguno es BCC) | − 3 | 0 | − 3 |
| 6 | **= Pool fusionado final** | **31 469** | **4 298** | **27 171** |

### 2.2 Justificación de la fusión

- **Techo de BCC:** el test solo aporta 975 BCC; el marco v1 quedó limitado a 60 pruebas
  (N máx = 32 imágenes). Al fusionar, **el techo de BCC es 4 298, no 975**, y el marco v2 (90
  pruebas) cabe con reserva única de 1 350 BCC y margen para entrenar (§3.4).
- **Homogeneidad del protocolo:** una sola tabla etiquetada gobierna el marco y el entrenamiento;
  la procedencia (train/test oficial) queda trazada en la columna `origen`, no en tratamientos
  distintos.
- **Validez del VAL:** al fusionar, la validación puede contener imágenes de origen test
  (sin `lesion_id`), ampliando la diversidad de lesiones de validación sin tocar el marco.

---

## 3. Marco de evaluación (carpeta `dataset/TEST/`)

### 3.1 Estructura de carpetas

```text
dataset/TEST/
├── TA/
│   ├── subconjunto_01/   (30 imágenes JPG, planas: 15 BCC + 15 no-BCC)
│   ├── subconjunto_02/
│   ├── ...
│   └── subconjunto_30/
├── NFS/
│   ├── subconjunto_01/
│   └── ... (30 subconjuntos)
└── PEO/
    ├── subconjunto_01/
    └── ... (30 subconjuntos)
```

- **3 familias** (una por indicador de la tesis: TA, NFS, PEO) × **30 subconjuntos** ×
  **30 imágenes (15 BCC + 15 no-BCC)** = **90 subconjuntos = 90 pruebas; 30 pruebas por
  indicador**.
- Las imágenes van **planas** dentro de cada subcarpeta. **No hay subcarpetas por clase** (P6):
  la etiqueta de cada imagen está en el manifiesto CSV del subconjunto.
- El grupo control (GC) y el grupo experimental (GE) de la tesis evalúan **el mismo marco**;
  el grupo (y la app) es la condición del experimento, no una propiedad del dataset.

### 3.2 Asignación por familia

| Familia | Indicador medido | Subconjuntos | Imágenes/subconjunto | BCC/subconjunto | no-BCC/subconjunto | Slots de la familia |
|---|---|---:|---:|---:|---:|---:|
| TA | Tasa de acierto | 30 | 30 | 15 | 15 | 900 |
| NFS | Nº de falsos sospechosos (FP) | 30 | 30 | 15 | 15 | 900 |
| PEO | % de error de omisión (FN/(TP+FN)) | 30 | 30 | 15 | 15 | 900 |
| **Total** | — | **90** | — | — | — | **2 700 slots** |

**Demanda de reserva:** 90 × 15 = **1 350 slots BCC** y 90 × 15 = **1 350 slots no-BCC**.
Con solapamiento entre familias, las imágenes **únicas** reservadas son 1 350 BCC + 1 350
no-BCC = **2 700 imágenes** (cada familia consume sus 2 700 slots sobre ese mismo conjunto).

### 3.3 Disyunción intra-familia (obligatoria)

Dentro de cada familia, las 30 pruebas son **mutuamente disjuntas**:

1. **Por imagen:** una imagen no puede aparecer en dos subconjuntos de la misma familia.
2. **Por `lesion_id` cuando exista:** dos tomas de la misma lesión no pueden repartirse entre
   subconjuntos de la misma familia (la unidad muestral es la lesión, no la imagen).
3. Las imágenes de origen test (sin `lesion_id`) se tratan como **lesiones propias**.

*Justificación:* una misma imagen (o lesión) contando dos veces en la misma familia correlaría
las filas del indicador e inflaría artificialmente el n efectivo del análisis.

### 3.4 Solapamiento inter-familias (permitido y esperado)

Las tres familias pueden compartir imágenes entre sí. La cuenta que lo justifica:

| Escenario | BCC únicos exigidos al pool | BCC restantes para TRAIN/VAL | Veredicto |
|---|---:|---:|---|
| Disyunción total entre familias (90 × 15 sin reuso) | 4 050 | 4 298 − 4 050 = **248** | **Inviable**: un fine-tuning con 248 BCC (y 248 no-BCC en balanceo 1:1 = 496 imágenes) no sostiene la Fase 4 |
| **Solapamiento entre familias (diseño v2)** | 1 350 | **2 948** | **Aprobado**: 68,6 % del BCC queda para entrenamiento y validación |

*Justificación estadística:* cada familia es un **experimento independiente con su propio
análisis** (30 pruebas del indicador por grupo, comparación GC vs. GE por familia con U de
Mann-Whitney). La correlación entre familias no contamina ningún contraste intra-familiar, y el
indicador de cada familia se mide siempre sobre sus mismas 30 pruebas pre-definidas.

### 3.5 Estratificación de la mitad no-BCC de cada subconjunto

Cada subconjunto lleva 15 no-BCC estratificados proporcionalmente por diagnóstico, con cuota de
referencia operativa **≈7 NV, ≈4 MEL, ≈2 BKL, ≈1 AK y resto variable (SCC/VASC/DF)**, equivalente
a la **mezcla de referencia aprobada ≈48 % NV, ≈26 % MEL, ≈12 % BKL, ≈7 % AK** del total de
no-BCC, garantizando la presencia de **melanoma en cada prueba**.

*Justificación:* el melanoma es el confusor clínico clave del BCC (lesión pigmentada maligna):
una prueba sin melanoma mediría un rendimiento optimista ante la casuística real. Las
queratosis (AK/BKL) simulan la superficie del BCC y el nevus es el negativo más frecuente. La
mezcla proporcional somete a cada prueba al espectro de confusores del diagnóstico diferencial.

### 3.6 Manifiesto de subconjunto

Cada subconjunto tiene un manifiesto CSV (fuente única de verdad de sus etiquetas) con, al
menos: `image_id`, `clase_9`, `es_bcc`, `lesion_id` (vacío para origen test), `origen`,
`subconjunto_id`, `familia` y `sha256` de la imagen. El SHA-256 del subconjunto completo se
registra para auditoría (herencia del marco v1).

---

## 4. Remanente → TRAIN y VAL (carpetas `dataset/TRAIN/` y `dataset/VAL/`)

### 4.1 Cálculo del remanente y del balanceo

| Paso | Operación | Imágenes | Detalle |
|---|---|---:|---|
| 1 | Pool fusionado final | 31 469 | 4 298 BCC + 27 171 no-BCC |
| 2 | − Reserva del marco (imágenes únicas) | − 2 700 | 1 350 BCC + 1 350 no-BCC |
| 3 | = Remanente | **28 769** | 2 948 BCC + 25 821 no-BCC |
| 4 | **Balanceo 1:1** (undersampling estratificado de no-BCC por diagnóstico; preserva la mezcla aprobada ≈48 % NV, ≈26 % MEL, ≈12 % BKL, ≈7 % AK, resto variable) | 5 896 | 2 948 BCC + 2 948 no-BCC (todos los BCC del remanente se usan) |
| 5 | − no-BCC descartadas (`destino_asignado = no_usadas`) | − 22 873 | Trazadas en el parquet, no eliminadas del registro |
| 6 | **Split TRAIN 80 % / VAL 20 %** (VAL_FRACTION = 0,20, configurable) | 5 896 | TRAIN ≈ 2 358 + 2 358 · VAL ≈ 590 + 590 |

La mezcla preservada por el undersampling se verifica contra la cuota operativa del marco
(§3.5: ≈7 NV / ≈4 MEL / ≈2 BKL / ≈1 AK por cada 15 no-BCC); la composición exacta por
diagnóstico queda registrada en el parquet (columna `clase_9`) para auditoría.

### 4.2 Estructura de carpetas

```text
dataset/TRAIN/
├── BCC/      (~2 358 imágenes)
└── NOBCC/    (~2 358 imágenes)
dataset/VAL/
├── BCC/      (~590 imágenes)
└── NOBCC/    (~590 imágenes)
```

Aquí la carpeta **sí** expresa la clase (los modelos de la Fase 4 consumen `image_dataset_from_directory`-style),
a diferencia del marco de evaluación, que se rige por manifiesto (P6). La columna
`destino_asignado` del parquet distingue los destinos: `TEST_TA/TEST_NFS/TEST_PEO` (slots),
`TRAIN_BCC`, `TRAIN_NOBCC`, `VAL_BCC`, `VAL_NOBCC` y `no_usadas`.

### 4.3 Reglas del split TRAIN/VAL

1. **Estratificado por clase** (BCC y no-BCC se reparten 80/20 cada uno).
2. **Agrupado por `lesion_id`**: todas las imágenes de una misma lesión caen en el mismo lado
   (train o val). Nunca se parte una lesión.
3. **Imágenes sin `lesion_id`** (2 084 del train) e **imágenes de origen test** (sin
   `lesion_id` por diseño del dataset) son **lesiones propias**, indivisibles por definición.
4. **VAL_FRACTION = 0,20** como constante configurable del notebook (cambiarla no invalida el
   resto del diseño; se registra en `parametros.json`).

### 4.4 Justificaciones metodológicas

**Por qué la reserva del marco va primero.** Los indicadores de la tesis (TA, NFS, PEO) solo
son medibles sobre un marco pre-definido y congelado: es el equivalente experimental a fijar el
test antes de mirar los datos. Si el entrenamiento se decidiera primero, la presión por datos
consumiría las imágenes que sostienen el marco y la evaluación quedaría sesgada por
disponibilidad. Reservar primero garantiza además que las 90 pruebas existen siempre, sin
depender de lo que «sobre» tras entrenar.

**Por qué balanceo 1:1 (undersampling de no-BCC).** El desbalance 1:6,6 del pool haría que un
clasificador trivial alcanzara 86,9 % de acierto sin detectar un solo BCC, y que la función de
pérdida estuviera dominada por los no-BCC. El undersampling estratificado de no-BCC
(por diagnóstico, para no sesgar la mezcla de confusores) produce mini-batches equilibrados,
vuelve la TA de validación directamente interpretable (prevalencia 50 %) y elimina la necesidad
de ponderación de clases dentro del experimento principal. El costo — descartar ~22 873 no-BCC
— es aceptable porque la oferta de no-BCC (27 171) excede en casi un orden de magnitud la
demanda (2 948 + 1 350), y las descartadas quedan trazadas como `no_usadas` para auditoría o
experimentos futuros sin regenerar el pool.

**Por qué el split por lesión.** El train tiene 5 059 lesiones con más de una imagen (16 459
imágenes; hasta 31 tomas de una misma lesión). Si imágenes de una misma lesión cayeran en train
y en val, la validación mediría memoria de la lesión (fuga de identidad) y su TA estaría
inflada de forma no replicable en el marco de evaluación, donde las lesiones son ajenas. El
split agrupado por `lesion_id` es, por tanto, una decisión de diseño y no una opción
configurable.

**Por qué estratificar la mitad no-BCC del marco.** Ver §3.5: representar el espectro de
confusores (melanoma, queratosis, nevus) en **cada** prueba para que el indicador mida el
desempeño ante el diagnóstico diferencial real y no ante un negativo «fácil».

**Por qué la semilla 2026.** Un único valor de semilla documentado (`parametros.json` +
`semilla.txt`) hace que cualquier tercero regenere el marco y el split bit a bit, habilita la
auditoría con SHA-256 de subconjuntos, y cierra la puerta a «probar semillas hasta que el
resultado mejore» (p-hacking). 2026 es el año de la tesis: memorable y trazable al proyecto.

---

## 5. Semilla y reproducibilidad

| Elemento | Regla |
|---|---|
| Semilla global | **2026** (única para todos los sorteos: exclusión, reserva, balanceo, split) |
| Orden determinista | 1) limpieza del pool → 2) reserva del marco TEST → 3) balanceo 1:1 → 4) split TRAIN/VAL. Nunca en otro orden |
| Archivos de control | `parametros.json` (todas las constantes del diseño, incluida `VAL_FRACTION`) y `semilla.txt` (2026) |
| Auditoría | SHA-256 por subconjunto (marco) y SHA-256 por imagen (parquet) |
| Regeneración | Los notebooks re-crean el dataset completo desde los 2 ZIP + 4 CSV oficiales, en disco efímero de Colab (`/content/derm_iapp`), sin Drive |

### 5.1 Descarga autónoma (archivos y tamaños de control)

Si un archivo no existe en el entorno con el tamaño byte-exacto indicado, el notebook lo
descarga de los links oficiales del README de `PRODUCTO/DATA/` (`PRODUCTO/DATA/README.txt`);
**nunca re-descarga si el tamaño coincide**:

| Archivo | Tamaño exacto | URL oficial (S3 ISIC Archive) |
|---|---:|---|
| `ISIC_2019_Training_Input.zip` | 9,10 GB (STORE, 0 errores CRC) | `https://isic-archive.s3.amazonaws.com/challenges/2019/ISIC_2019_Training_Input.zip` |
| `ISIC_2019_Test_Input.zip` | 3,56 GB (STORE, 0 errores CRC) | `https://isic-archive.s3.amazonaws.com/challenges/2019/ISIC_2019_Test_Input.zip` |
| `ISIC_2019_Training_Metadata.csv` | **1 214 351 B** | `https://isic-archive.s3.amazonaws.com/challenges/2019/ISIC_2019_Training_Metadata.csv` |
| `ISIC_2019_Training_GroundTruth.csv` | **1 291 479 B** | `https://isic-archive.s3.amazonaws.com/challenges/2019/ISIC_2019_Training_GroundTruth.csv` |
| `ISIC_2019_Test_Metadata.csv` | **293 638 B** | `https://isic-archive.s3.amazonaws.com/challenges/2019/ISIC_2019_Test_Metadata.csv` |
| `ISIC_2019_Test_GroundTruth.csv` | **464 810 B** | `https://isic-archive.s3.amazonaws.com/challenges/2019/ISIC_2019_Test_GroundTruth.csv` |

Un tamaño que no coincida byte a byte es un fallo duro (abortar con mensaje claro).

---

## 6. Manifiesto maestro `dataset_etiquetado.parquet`

Única fuente de verdad (P2). Una fila por imagen del pool fusionado final.

| Columna | Tipo | Dominio / descripción |
|---|---|---|
| `image_id` | str | Identificador oficial ISIC (`ISIC_XXXXXXX`) |
| `origen` | str | `train` \| `test` (partición oficial de procedencia) |
| `clase_9` | str | `MEL` \| `NV` \| `BCC` \| `AK` \| `BKL` \| `DF` \| `VASC` \| `SCC` (UNK excluido del pool) |
| `es_bcc` | bool | Etiqueta binaria de la tesis (True solo si `clase_9 == BCC`) |
| `lesion_id` | str \| nulo | Identificador de lesión del train; **nulo** para origen test y para las 2 084 sin id → lesiones propias |
| `edad` | int \| nulo | `age_approx` (0 → nulo; 0,4 % faltante real) |
| `sexo` | str \| nulo | `female` \| `male` \| nulo (`nan` literal → nulo) |
| `sitio` | str \| nulo | `anatom_site_general` (`nan` literal → nulo) |
| `ruta` | str | Ruta relativa del JPG dentro de `dataset/` |
| `sha256` | str | Hash de la imagen (integridad y auditoría) |
| `destino_asignado` | str | `TEST_TA` \| `TEST_NFS` \| `TEST_PEO` \| `TRAIN_BCC` \| `TRAIN_NOBCC` \| `VAL_BCC` \| `VAL_NOBCC` \| `no_usadas` |

---

## 7. Cuadro resumen de asignaciones (invariantes numéricos)

| Destino | BCC | no-BCC | Total |
|---|---:|---:|---:|
| Marco TEST — slots TA | 450 | 450 | 900 |
| Marco TEST — slots NFS | 450 | 450 | 900 |
| Marco TEST — slots PEO | 450 | 450 | 900 |
| **Marco TEST — imágenes únicas reservadas** | **1 350** | **1 350** | **2 700** |
| TRAIN (80 %) | ~2 358 | ~2 358 | ~4 716 |
| VAL (20 %) | ~590 | ~590 | ~1 180 |
| `no_usadas` (trazadas) | 0 | ~22 873 | ~22 873 |
| **Total pool** | **4 298** | **27 171** | **31 469** |

**Invariantes de verificación (asserts obligatorios en los notebooks):**

- I1: pool = 31 469 = 31 522 − 50 − 3; BCC = 4 298; no-BCC = 27 171.
- I2: UNK excluidas = 2 047.
- I3: marco = 90 subconjuntos; 30 imágenes cada uno; 15 BCC + 15 no-BCC por subconjunto.
- I4: disyunción intra-familia por imagen y por `lesion_id` (0 colisiones).
- I5: reserva única = 1 350 BCC + 1 350 no-BCC (2 700 imágenes únicas).
- I6: remanente = 28 769; balanceado 1:1 → 2 948 + 2 948.
- I7: TRAIN ≈ 2 358 + 2 358; VAL ≈ 590 + 590 (con VAL_FRACTION = 0,20); 2 358 + 590 = 2 948.
- I8: `no_usadas` ≈ 22 873 (todas no-BCC, con diagnóstico trazado).
- I9: toda imagen del pool tiene exactamente un `destino_asignado`.
- I10: ninguna lesión repartida entre TRAIN y VAL (0 `lesion_id` compartidos).

---

## 8. Reglas normativas para los notebooks

| # | Regla | Aplica a |
|---|---|---|
| R1 | Descarga autónoma: si los 2 ZIP o los 4 CSV no existen en `/content/derm_iapp` con tamaño byte-exacto (§5.1), descargarse de los links oficiales del README de `PRODUCTO/DATA/`; nunca re-descargar si el tamaño coincide | 01–07 |
| R2 | Leer solo del parquet (o construirlo si no existe); nunca de `data_cruda` directo | 03, 04, 07 |
| R3 | Semilla global 2026 en cada sorteo; orden determinista de §5 | 03, 04 |
| R4 | Verificar los invariantes I1–I10 con asserts y fallar con mensaje claro si alguno no cumple | 03, 04, 07 |
| R5 | Disyunción intra-familia por imagen y por `lesion_id`; solapamiento entre familias permitido | 04 |
| R6 | Cuotas no-BCC ≈7 NV / ≈4 MEL / ≈2 BKL / ≈1 AK + resto variable (mezcla aprobada ≈48/26/12/7 %), con melanoma presente en cada subconjunto | 04 |
| R7 | Etiquetas del marco solo en el manifiesto CSV; carpetas de subconjunto planas | 04 |
| R8 | `VAL_FRACTION = 0.20` como constante configurable y registrada | 03 |
| R9 | Split TRAIN/VAL estratificado y agrupado por `lesion_id` (lesiones propias: sin id y origen test) | 03 |
| R10 | Toda exclusión/descarte se traza en `destino_asignado` (nada se borra del parquet) | 03, 04 |
| R11 | El modelo solo recibe píxel (imagen): los metadatos del parquet nunca son entrada de la red | 05, 06 |
| R12 | Exportación del modelo ganador a `.tflite` versionado con manifiesto (versión, input size, normalización, umbral, SHA-256) | 06 |

**Notebooks de referencia del diseño:** `03_preparacion_datos.ipynb` (pool, balanceo, split),
`04_marco_evaluacion.ipynb` (90 subconjuntos), `07_evaluacion.ipynb` (TA/NFS/PEO por
subconjunto, GC vs. GE, Mann-Whitney).

---

## 9. Criterios de aceptación del dataset generado

- [ ] Existen `dataset/TEST/{TA,NFS,PEO}/subconjunto_01..30/` con exactamente 30 JPG planos cada uno.
- [ ] Cada subconjunto tiene su manifiesto CSV con etiquetas BCC/no-BCC y SHA-256 de imagen.
- [ ] 15 BCC + 15 no-BCC en cada subconjunto, con melanoma presente en cada prueba (R6).
- [ ] Disyunción intra-familia verificada (I4) registrada en el log de generación.
- [ ] `dataset/TRAIN/{BCC,NOBCC}` y `dataset/VAL/{BCC,NOBCC}` con los conteos de §7 (I7).
- [ ] `dataset_etiquetado.parquet` con las 11 columnas de §6 y las 31 469 filas del pool (I1, I9).
- [ ] `parametros.json` y `semilla.txt` escritos en la raíz de `dataset/`.
- [ ] Segunda ejecución idéntica (bit a bit) en un entorno limpio de Colab.

---

## 10. Limitaciones declaradas (heredadas del dataset)

1. El test oficial no trae `lesion_id`: la independencia de pacientes train↔test no es
   verificable por identificador (verificada solo por contenido: 0 fuga MD5, 3 casi-duplicados
   excluidos).
2. 2 047 imágenes UNK del test quedan fuera de todo el diseño (sin etiqueta de referencia).
3. 2 084 imágenes del train carecen de `lesion_id` y se tratan como lesiones propias.
4. **El marco de evaluación ya no es el test oficial aislado:** al fusionar pools, la población
   de referencia de las pruebas es el pool train+test; esto debe declararse en la tesis al
   describir el experimento.
5. Descarte de ~22 873 no-BCC en el balanceo 1:1: imágenes trazadas (`no_usadas`) pero no
   utilizadas; la información de clase sigue siendo ISIC 2019, sin fuentes externas.
6. **Prevalencia artificial del marco (50 % BCC):** los valores absolutos de TA no son
   extrapolables a la prevalencia real de Trujillo; los contrastes GC vs. GE sí son válidos.
7. **Imágenes de origen test sin `lesion_id`** (y 2 084 de train sin id): no agrupables; se
   tratan como lesiones propias en el split y en la disyunción intra-familia.
8. Las imágenes son dermoscópicas; una foto de celular no es equivalente (la app debe validar
   calidad y advertir la naturaleza del modelo).
9. Sesgo demográfico del BCC (mayores, hombres, cabeza/cuello): el modelo solo recibe píxel,
   pero el fondo de la imagen puede traslucir el sitio anatómico.

---

## 11. Historial de versiones

| Versión | Fecha | Descripción |
|---|---|---|
| v1 (obsoleto) | oct 2026 | 60 subconjuntos GC/GE de solo-test (30 img, 15+15), semilla 2026, script `03_regenerar_evaluacion.py`; techo de BCC 975 |
| **v2 (vigente)** | 16 oct 2026 (aprobado) | Marco normativo de este documento: pool fusionado 31 469 (techo BCC 4 298), 90 subconjuntos en 3 familias TA/NFS/PEO, remanente balanceado 1:1, split 80/20 por lesión, semilla 2026 |
| v2.1 | 04 nov 2026 | Formalización documental del Sprint 1: reubicación del documento a `model/docs/` (convención del repo: `model/` = pipeline CRISP-DM); se añaden la mezcla de balanceo aprobada (≈48/26/12/7 %) a §4.1, la tabla de tamaños byte-exactos de descarga a §5.1 y las limitaciones 4–7 de §10 |

*Documento normativo del diseño de datos v2 · DERM_IAPP · pipeline CRISP-DM · Sprint 1
(retroactivo, 5–16/10/2026). Cualquier desviación de estas reglas debe aprobarse con el PO y
registrarse en este historial.*
