# Sprint 2 — Registro de la Fase 3 (CRISP-DM): Data Preparation

> **Proyecto:** Aplicación móvil con técnicas de Deep Learning para la detección de carcinoma
> basocelular en Trujillo 2026 (DERM_IAPP — UPAO).
> **Sprint:** 2 (retroactivo, 19–30 de octubre de 2026) · **Fase CRISP-DM:** 3 (Data Preparation).
> **Elaborado por:** agente crisp-dm · **Revisión:** PO (dermatólogo) y Scrum Master (Aryel Meza).
> **Fuentes citadas:** [`marco_muestral_v2.md`](marco_muestral_v2.md) (norma obligatoria del
> pipeline), `PRODUCTO/DATA/ANALISIS_DATASET_ISIC2019.md` (§1–§7 vigentes; limpiezas de §8.3),
> [`S1_fases_1_2.md`](S1_fases_1_2.md) (decisiones D1–D9 del Sprint 1) y el mensaje de
> coordinación del agente **mobile-d** sobre el manifiesto del modelo (§5 de este documento).
> **Nota de registro:** este documento consolida las decisiones D10–D17 de la fase, la
> estructura exacta que producirá el NB04, el diseño cerrado del manifiesto del modelo (con
> `ta_referencia`) y los criterios de aceptación de cada notebook. Los notebooks NO se escriben
> en esta fase documental: se especifican y su código lo genera el agente coder (regla 3 del
> agente crisp-dm).

---

## 1. Alcance de la fase y mapa de notebooks

La Fase 3 transforma los 6 archivos oficiales (2 ZIP + 4 CSV de ISIC 2019) en el dataset final
del proyecto: el **pool fusionado etiquetado** (`dataset_etiquetado.parquet`, 31 469 imágenes) y
el **árbol físico** `dataset/` (marco de evaluación de 90 subconjuntos + TRAIN/VAL balanceados),
todo bajo la norma de `marco_muestral_v2.md`.

| Notebook | Estado | Rol en la Fase 3 | Consume | Produce |
|---|---|---|---|---|
| `01_descarga_verificacion.ipynb` | **Especificado este sprint** | Descarga autónoma y verificación de los 6 archivos oficiales (R1, marco §5.1); extracción a `data_cruda/` | Nada (los descarga si falta) | `data_cruda/{train,test}/`, `metadata/`, `inventario_descarga.json` |
| `02_analisis_exploratorio.ipynb` | Completado (S1) | EDA de la Fase 2 (no forma parte del pipeline de preparación) | `data_cruda/`, `metadata/` | Evidencia del EDA |
| `03_limpieza_etiquetado.ipynb` | **Especificado este sprint** | Limpiezas obligatorias (§8.3), derivación de etiqueta binaria, SHA-256 por imagen, construcción del parquet maestro | `data_cruda/`, `metadata/` | `dataset_etiquetado.parquet` (11 columnas), `limpieza_log.csv`, cachés de hash |
| `04_particionado_90_subconjuntos.ipynb` | **Especificado este sprint** | Reserva del marco TEST (3 familias), balanceo 1:1, split TRAIN/VAL por lesión, árbol físico y manifiestos | `dataset_etiquetado.parquet` | `dataset/` completo, `asignacion_global.csv`, `parametros.json`, `semilla.txt`, parquet actualizado |
| `05_entrenamiento.ipynb` · `06_export_tflite.ipynb` | Futuro (S3, Fase 4/6) | Fuera del alcance del S2 | — | — |
| `07_evaluacion.ipynb` | Futuro (Fase 5) | Fuera del alcance del S2 | — | — |

**Mapeo con los nombres de referencia del marco v2 (§8):** el par `03_preparacion_datos.ipynb` +
`04_marco_evaluacion.ipynb` del marco se materializa como **NB03** (pool) + **NB04** (marco,
balanceo y split); la numeración 02 queda ocupada por el EDA del S1. Los números de regla del
marco («Aplica a 01–07», «03, 04, 07», etc.) conservan validez con esta numeración. Esta
correspondencia quedó anotada en el propio marco (historial v2.2).

---

## 2. Decisiones de la fase (D10–D17, continúan la numeración D1–D9 del S1)

| # | Decisión | Contenido aprobado | Sustento |
|---|---|---|---|
| **D10** | **Arquitectura de notebooks de la Fase 3** | Tres notebooks nuevos: `01_descarga_verificacion` (descarga + extracción + inventario), `03_limpieza_etiquetado` (limpieza §8.3 + parquet) y `04_particionado_90_subconjuntos` (reserva TEST → balanceo → split → árbol → manifiestos → invariantes). Separación explícita «datos crudos → tabla maestra → dataset físico», con el parquet como única frontera (P2) | marco v2 P2, R1–R2; orden determinista de §5 |
| **D11** | **SHA-256 como hash estándar del pipeline** | La integridad y la detección de duplicados exactos usan **SHA-256 por imagen** (el análisis §6 usó MD5; para duplicados exactos son equivalentes). Ante un grupo de duplicados se conserva **determinísticamente la de `image_id` menor** y el resto se marca `duplicado_eliminado` | ANALISIS §6 (50 duplicados en train); marco v2 §5 (auditoría por SHA-256); reproducibilidad P3 |
| **D12** | **Los excluidos del pool se trazan fuera del parquet** | `dataset_etiquetado.parquet` contiene **exactamente las 31 469 filas del pool final** (I1) con `destino_asignado = 'pendiente'` hasta que NB04 lo resuelva. Las exclusiones (2 047 UNK, 50 duplicados, 3 casi-duplicados) se registran en **`limpieza_log.csv`** (motivo + detalle), no como filas del parquet: así el dominio de §6 queda intacto y el parquet es 1 fila = 1 imagen del pool | marco v2 §6, I1, I9, P4; ANALISIS §8.3 |
| **D13** | **Reserva del marco por dibujo secuencial con exclusión entre familias** | Las 3 familias (TA → NFS → PEO, orden fijo) dibujan **secuencialmente**: cada familia consume sus 900 slots (450 BCC + 450 no-BCC) sobre imágenes/lesiones **aún no reservadas** por las familias anteriores. Resultado: reserva única exacta **1 350 BCC + 1 350 no-BCC = 2 700** (I5), remanente 28 769 (I6) y **cero solapamiento inter-familias** en esta implementación. P5 declara el solapamiento entre familias *permitido* (no exigido): la disyunción total entre familias es un caso particular que cumple I3–I6 por construcción y maximiza la diversidad de las 90 pruebas. Cualquier cambio a la variante de «pool compartido» del §3.2 solo afectaría al PASO 1 del NB04 | marco v2 P5, §3.2–§3.4, I4–I6; R5 |
| **D14** | **Cuota operativa de no-BCC instanciada por subconjunto** | Cada subconjunto de 15 no-BCC lleva **7 NV + 4 MEL + 2 BKL + 1 AK + 1 rotativo** con rotación determinista **SCC → VASC → DF** según el índice del subconjunto (subconjunto *k* → `ROTATIVO[(k−1) mod 3]`). Reproduce la mezcla aprobada ≈48/26/12/7 % (§3.5/R6) y garantiza melanoma en las 90 pruebas. Sobre 30 subconjuntos por familia: 10 SCC, 10 VASC y 10 DF por familia | marco v2 §3.5, R6; ANALISIS §8.5 (proporciones ≈47,8/25,4/12,7/7,2/3,2/2,0/1,7 %) |
| **D15** | **Asserts en dos capas para permitir smoke tests** | Capa 1 — **invariantes estructurales SIEMPRE duros** (disyunciones, sumas por configuración, 1 destino por fila, determinismo, manifiestos completos). Capa 2 — **cifras absolutas del dataset real** (31 469, 4 298, 27 171, 50, 3, 2 047, 25 331, 8 238, 2 948, 2 358/590, ≈22 873) activadas solo con `FULL_DATASET=True` (por defecto `True`; la fixture sintética la apaga). Así el pipeline se prueba de punta a punta sin los 12,7 GB | marco v2 §7 (I1–I10); necesidad de un smoke test local sin Colab |
| **D16** | **Diseño del manifiesto del modelo con `ta_referencia` (respuesta formal a mobile-d)** | El manifiesto JSON que acompañará a cada `.tflite` versionado incorpora el campo **`ta_referencia`** (float 0–100: TA media de las 30 pruebas de la familia TA de esa versión, 1 decimal) además de versión, input size, normalización, umbral, SHA-256 y firma. Especificación completa y cerrada en §5 de este documento; implementación en NB06 (S3) | Solicitud formal de mobile-d (contrato app/backend); marco v2 R12 |
| **D17** | **Determinismo: un solo RNG y orden fijo de sorteos** | Cada notebook crea **un único generador** `np.random.default_rng(2026)` y los sorteos se consumen en un orden fijo y documentado (limpieza → reserva TA → NFS → PEO → balanceo → split). Prohibido crear RNGs ad hoc dentro de funciones (el rng se pasa por parámetro). NB04 verifica el determinismo con una **segunda pasada en memoria** comparada bit a bit | marco v2 P3, §5, R3; D6 del S1 |

---

## 3. Reglas del marco v2 aplicadas en esta fase

| Regla | Contenido | Notebook que la ejecuta |
|---|---|---|
| R1 | Descarga autónoma con tamaños de control; nunca re-descargar si el tamaño coincide | NB01 (guard compacto también en NB03) |
| R2 | Leer solo del parquet (o construirlo si no existe); nunca de `data_cruda` directo | NB03 (lo construye), NB04 (lo consume; solo **copia archivos** según su `ruta`, nunca deduce etiquetas) |
| R3 | Semilla global 2026 en cada sorteo; orden determinista de §5 | NB03 (procesos deterministas sin azar), NB04 (único rng, D17) |
| R4 | Verificar I1–I10 con asserts y fallar con mensaje claro | NB03 (I1, I2), NB04 (I1–I10, dos capas según D15) |
| R5 | Disyunción intra-familia por imagen y `lesion_id` | NB04 PASO 1 |
| R6 | Cuotas ≈7 NV / ≈4 MEL / ≈2 BKL / ≈1 AK + resto variable; melanoma en cada prueba | NB04 PASO 1 (D14) |
| R7 | Etiquetas del marco solo en el manifiesto CSV; carpetas planas | NB04 PASO 4–5 |
| R8 | `VAL_FRACTION = 0.20` constante configurable y registrada | NB04 PASO 3 (y `parametros.json`) |
| R9 | Split estratificado y agrupado por `lesion_id`; sin id y origen test = lesiones propias | NB04 PASO 3 |
| R10 | Toda exclusión/descarte trazada (nada se borra silenciosamente) | NB03 (`limpieza_log.csv`, D12), NB04 (`no_usadas` en el parquet) |
| R11–R12 | Metadatos nunca entrada de la red; export `.tflite` con manifiesto | NB05–NB06 (S3): manifiesto ya especificado en §5 (D16) |

---

## 4. Estructura exacta que produce el NB04

### 4.1 Árbol de trabajo completo (`BASE_DIR`)

```text
/content/derm_iapp/                        (BASE_DIR; en pruebas locales: otro valor vía DERM_IAPP_BASE)
├── metadata/                              (4 CSV oficiales; NB01 los descarga/verifica)
├── data_cruda/
│   ├── train/ISIC_2019_Training_Input/    (25 331 JPG — extraídos del ZIP de train)
│   └── test/ISIC_2019_Test_Input/         (8 238 JPG — extraídos del ZIP de test)
├── dataset_etiquetado.parquet             (NB03; NB04 actualiza destino_asignado y ruta)
├── limpieza_log.csv                       (NB03: 2 100 exclusiones trazadas)
├── hashes_cache_train.csv / hashes_cache_test.csv   (NB03: caché de SHA-256, tolerante a re-ejecución)
├── inventario_descarga.json               (NB01: estado de los 6 archivos)
└── dataset/                               (NB04)
    ├── TEST/
    │   ├── TA/
    │   │   ├── subconjunto_01/            (30 JPG planos + subconjunto_01.csv)
    │   │   ├── …
    │   │   └── subconjunto_30/
    │   ├── NFS/  (ídem, 30 subconjuntos)
    │   └── PEO/  (ídem, 30 subconjuntos)
    ├── TRAIN/
    │   ├── BCC/      (~2 358 JPG)
    │   └── NOBCC/    (~2 358 JPG)
    ├── VAL/
    │   ├── BCC/      (~590 JPG)
    │   └── NOBCC/    (~590 JPG)
    ├── asignacion_global.csv              (las 2 700 imágenes reservadas, fila por slot)
    ├── parametros.json                    (toda la configuración + semilla + tamaños esperados)
    └── semilla.txt                        (2026)
```

Copias físicas totales del NB04: 2 700 (marco) + 5 896 (TRAIN+VAL) = **8 596 JPG**; las
~22 873 `no_usadas` **no se copian** (quedan trazadas en el parquet con su ruta de origen).

### 4.2 Formato de los manifiestos

**`subconjunto_XX.csv`** (uno por cada uno de los 90 subconjuntos, dentro de su carpeta; fuente
única de verdad de las etiquetas — P6/R7; cumple el mínimo del §3.6 del marco y la solicitud del
orquestador):

```text
image_id,familia,subconjunto_id,es_bcc,clase_9,lesion_id,origen,ruta,sha256
ISIC_0052537,TA,1,True,BCC,,test,TEST/TA/subconjunto_01/ISIC_0052537.jpg,af3c…
```

**`asignacion_global.csv`** (raíz de `dataset/`): una fila por slot de la reserva —
`familia, subconjunto_id, slot, image_id, es_bcc, clase_9, lesion_id, origen, ruta, sha256,
sha256_subconjunto` (2 700 filas).

**SHA-256 de subconjunto** (auditoría, herencia del marco v1): `sha256_subconjunto = SHA-256` de
la cadena UTF-8 que concatena con `\n` los pares `image_id:sha256_de_imagen` de las 30 imágenes,
ordenados lexicográficamente por `image_id`. Definición fija para que un tercero pueda
recomputarla.

**`parametros.json`** (raíz de `dataset/`, claves ordenadas): `semilla=2026`, `val_fraction`,
`familias`, `subconjuntos_por_familia`, `img_bcc_por_subconjunto`, `img_nobcc_por_subconjunto`,
`cuota_nobcc` (D14), `orden_rotativo`, `full_dataset`, tamaños esperados de los 6 archivos de
entrada, conteos esperados de I1–I10, `sha256_parquet_entrada`, versión del marco (`v2`),
notebook y fecha de generación.

**`semilla.txt`**: `2026`.

### 4.3 Convención de la columna `ruta` del parquet (precisa §6 del marco)

- Imágenes con copia física (TEST/TRAIN/VAL): `ruta` = ruta relativa **dentro de `dataset/`**
  (p. ej. `TEST/TA/subconjunto_01/ISIC_0052537.jpg`, `TRAIN/BCC/ISIC_0000000.jpg`).
- Imágenes `no_usadas` (sin copia física): `ruta` = ruta relativa **dentro de `data_cruda/`**
  (p. ej. `train/ISIC_2019_Training_Input/ISIC_0000002.jpg`), su única copia existente.
- En NB03 (antes de que exista el árbol) la columna se llena provisionalmente con la ruta de
  `data_cruda/`; NB04 la consolida según el destino final (P2: el parquet manda).

---

## 5. Diseño del manifiesto del modelo — respuesta formal a mobile-d (D16)

> **Contexto:** mobile-d solicitó por el mensajero: «el manifiesto JSON de cada versión del
> modelo (.tflite) debe incluir el campo `ta_referencia` (float 0-100: TA media de las 30 pruebas
> de la familia TA de esa versión, 1 decimal), junto con versión, input size, normalización,
> umbral, SHA-256 y firma; el preprocesamiento local debe ser idéntico al del entrenamiento».
> **Respuesta: ACEPTADO e incorporado al diseño.** La implementación corresponde al NB06
> (Sprint 3), pero la especificación queda **cerrada en esta fase** con este registro.

### 5.1 Contrato del manifiesto (JSON, un archivo por versión del `.tflite`)

| Campo | Tipo | Obligatorio | Descripción |
|---|---|---|---|
| `version` | str | ✅ | Versión del modelo (semver, p. ej. `1.0.0`; incremental por export) |
| `fecha_compilacion` | str ISO-8601 | ✅ | Fecha de la exportación |
| `arquitectura` | str | ✅ | `mobilenetv3_small` \| `efficientnet_lite0` (ganador del S3) |
| `formato` | str | ✅ | `tflite` |
| `input_size` | [int, int] | ✅ | Tamaño de entrada del modelo (p. ej. `[224, 224]`), idéntico al entrenamiento |
| `canales` | int | ✅ | 3 (RGB) |
| `normalizacion` | objeto | ✅ | P. ej. `{"tipo": "rescale", "escala": 0.00392156862745098}` o `{"tipo": "mean_std", "mean": [...], "std": [...]}` — **debe ser idéntico al preprocesamiento de entrenamiento** |
| `preprocesamiento` | objeto | ✅ | `{"redimensionado": "bilinear", "color": "RGB", "recorte": "none"}` — contrato de preprocesamiento local de la app |
| `umbral_decision` | float | ✅ | Umbral sobre la probabilidad de BCC |
| `etiqueta_positiva` | str | ✅ | `BCC` (la salida del modelo es P(BCC)) |
| **`ta_referencia`** | **float 0–100** | ✅ | **TA media de las 30 pruebas de la familia TA de esa versión del modelo, redondeada a 1 decimal.** Se calcula en el flujo de evaluación (NB07) sobre los 30 subconjuntos TA del marco v2 y se registra al exportar (NB06). Validación en NB06: `0 ≤ ta_referencia ≤ 100` y `round(x, 1) == x` |
| `ta_detalle` | objeto | ⭕ | Procedencia: `{"familia": "TA", "n_pruebas": 30, "marco": "v2"}` (opcional, trazabilidad) |
| `sha256_modelo` | str | ✅ | SHA-256 del archivo `.tflite` exacto que acompaña al manifiesto |
| `dataset_build` | objeto | ✅ | `{"semilla": 2026, "marco": "v2", "sha256_parquet": "…"}` — con qué dataset se entrenó |
| `nota_medica` | str | ✅ | Texto de advertencia permanente: herramienta de apoyo, no sustituye el criterio médico |
| `firma` | str | ✅ | `SHA-256` de la **serialización canónica** del manifiesto (JSON con claves ordenadas, separadores compactos, UTF-8) **sin el campo `firma`**. La app lo recalcula para verificar integridad del paquete |

### 5.2 Ejemplo canónico

```json
{
  "arquitectura": "mobilenetv3_small",
  "canales": 3,
  "dataset_build": {"marco": "v2", "semilla": 2026, "sha256_parquet": "…"},
  "etiqueta_positiva": "BCC",
  "fecha_compilacion": "2026-11-20T10:00:00",
  "formato": "tflite",
  "firma": "…",
  "input_size": [224, 224],
  "normalizacion": {"escala": 0.00392156862745098, "tipo": "rescale"},
  "nota_medica": "Herramienta de apoyo a la decisión; no sustituye el criterio médico.",
  "preprocesamiento": {"color": "RGB", "recorte": "none", "redimensionado": "bilinear"},
  "sha256_modelo": "…",
  "ta_detalle": {"familia": "TA", "marco": "v2", "n_pruebas": 30},
  "ta_referencia": 87.4,
  "umbral_decision": 0.5,
  "version": "1.0.0"
}
```

### 5.3 Nota para el backend (S4 — Mobile-D)

- El versionado del modelo en el backend debe **servir el manifiesto tal cual** (incluido
  `ta_referencia`, sin recalcularlo ni alterarlo): es un dato de evaluación congelado por
  versión, no una métrica en vivo.
- La app muestra `ta_referencia` como «rendimiento de referencia de esta versión» y valida la
  `firma` antes de cargar el `.tflite`.
- La firma actual garantiza **integridad** (detección de alteración). Si el PO exige
  **autenticidad** (que solo el backend pueda firmar), la evolución natural es HMAC-SHA-256 con
  clave en el backend; decisión pendiente del PO, no bloquea el S3.

---

## 6. Limpiezas obligatorias y trazabilidad (NB03)

Aplicación literal del §8.3 del análisis, con el registro de D11/D12:

| # | Limpieza | Mecánica en NB03 | Trazabilidad |
|---|---|---|---|
| 1 | Excluir 2 047 UNK del test | Filas con `UNK=1.0` en el one-hot → fuera del pool | `limpieza_log.csv` motivo `UNK_sin_etiqueta` |
| 2 | Eliminar 50 duplicados exactos del train | SHA-256 por imagen (D11); grupo con >1 → conserva `image_id` menor | motivo `duplicado_eliminado` (+ id conservado) |
| 3 | Excluir 3 casi-duplicados del test | Baja por ID (`ISIC_0034511`, `ISIC_0034619`, `ISIC_0068690`) | motivo `excluido_casi_duplicado` |
| 4 | Lesiones propias | `lesion_id` nulo (origen test y las 2 084 de train sin id) → unidad muestral propia | columna `lesion_id` (nulo) del parquet |

`limpieza_log.csv`: `image_id, origen, clase_9, motivo, detalle` → 2 100 filas en el dataset
real (2 047 + 50 + 3; cifra de verificación en capa FULL, D15). Verificación adicional de NB03:
el número de JPG extraídos por partición debe igualar al número de filas de los CSV oficiales
(25 331 / 8 238 en el dataset real) — falla si no coincide.

---

## 7. Criterios de aceptación de los notebooks (fase)

### 7.1 `01_descarga_verificacion.ipynb`

- [ ] Los 4 CSV se aceptan solo con tamaño **byte-exacto** (1 214 351 / 1 291 479 / 293 638 / 464 810 B); tamaño distinto → error con mensaje claro. Si existen con tamaño correcto **no se re-descargan** (R1).
- [ ] Los 2 ZIP: si existen localmente, su tamaño local se registra como tamaño esperado y se compara contra el `Content-Length`; si no existen, descarga por streaming (`requests`, chunks, barra simple, 3 reintentos).
- [ ] `VERIFY_CRC` (por defecto `False`, documentado por su costo en Colab) ejecuta `zipfile.testzip()` opcional; `DELET_ZIPS_AFTER_EXTRACT` (por defecto `False`, documentado que liberaría ≈12,7 GB en Colab).
- [ ] Extracción a `data_cruda/{train,test}/` con guardia anti path-traversal; inventario final con conteo real de JPG por carpeta, contra 25 331 / 8 238 en capa FULL.
- [ ] Escribe `inventario_descarga.json` (nombre, url, tamaño esperado/observado, estado).

### 7.2 `03_limpieza_etiquetado.ipynb`

- [ ] Deriva `clase_9` (one-hot → una clase; assert de exactamente un 1 por fila; ignora `score_weight`/`validation_weight` del GroundTruth del test) y `es_bcc`.
- [ ] Verifica extracción vs CSV antes de hashear (falla si no coincide).
- [ ] SHA-256 por imagen con caché tolerante a re-ejecución (valida `size_bytes`).
- [ ] Duplicados: conserva `image_id` menor; asserts de capa FULL (50, todos de train); exclusión de los 3 IDs; exclusión UNK; asserts finales 31 469 / 4 298 / 27 171 / 0 UNK / 0 duplicados / 0 de los 3 (capa FULL).
- [ ] Parquet con las 11 columnas exactas de §6 del marco y `destino_asignado='pendiente'`; `limpieza_log.csv` completo; orden canónico por `image_id`; re-ejecución → parquet idéntico.

### 7.3 `04_particionado_90_subconjuntos.ipynb`

- [ ] PASO 1: reserva secuencial TA→NFS→PEO con exclusión (D13); cuotas D14; disyunción intra-familia por imagen y lesión; slots exactos.
- [ ] PASO 2: todos los BCC del remanente + undersampling estratificado de no-BCC hasta 2 948 con mezcla ≈48/26/12/7 (assert de mezcla en capa FULL).
- [ ] PASO 3: split 80/20 configurable agrupado por lesión, estratificado por `es_bcc` a nivel lesión; VAL ≈590+590 (tolerancia ±3, desvío real documentado).
- [ ] PASO 4: árbol físico exacto de §4.1 (carpetas TA/NFS/PEO en mayúsculas, subcarpetas planas).
- [ ] PASO 5: `subconjunto_XX.csv` (9 columnas), `asignacion_global.csv`, `parametros.json`, `semilla.txt`.
- [ ] PASO 6: invariantes I1–I10 (dos capas, D15) + determinismo por segunda pasada bit a bit; parquet actualizado (`destino_asignado` + `ruta` según §4.3).

### 7.4 Común a los tres

- [ ] Celda 0 markdown con propósito y la nota «consume … / produce … según `marco_muestral_v2.md`».
- [ ] `BASE_DIR = os.environ.get('DERM_IAPP_BASE', '/content/derm_iapp')`; todas las rutas relativas a `BASE_DIR`.
- [ ] Bloque `CONFIG` único que lee variables de entorno (D15) con valores por defecto del dataset real.
- [ ] Notebooks generados **sin outputs**; `nbformat.validate` OK; todas las celdas compilables; español; asserts con mensajes claros.
- [ ] Smoke test con fixture sintética en `D:\TEMP\opencode\derm_iapp_fixture\` en verde (la fixture **no se commitea**).

---

## 8. Actualizaciones documentales realizadas en este sprint

| Documento | Cambio |
|---|---|
| `model/docs/S1_fases_1_2.md` | Estado del EDA (NB02): «En curso» → «**Completada**» (el notebook ya existe) |
| `model/docs/marco_muestral_v2.md` | v2.2: nombres de los notebooks de referencia actualizados a la numeración real (NB01/NB03/NB04/NB07) y semántica de la columna `ruta` precisada (§4.3 de este documento). Sin cambios en reglas ni invariantes |
| `PRODUCTO/metodologias/CRISP_DM/CONOCIMIENTO_CRISP_DM.md` (fuera del repo) | Referencias al marco v1 (60 subconjuntos GC/GE) actualizadas a v2 (90 subconjuntos, 3 familias TA/NFS/PEO, 30 pruebas por indicador) en Fase 1.2, Fase 3, Fase 4, Fase 5 y regla 7 del agente |

**Decisión de fase:** la Fase 3 queda especificada y lista para codificación (prompts enviados al
coder por el mensajero). La Fase 4 (Modeling) proseguirá en el S3 con NB05–NB06 bajo D7 del S1 y
el manifiesto de §5.

---

*Registro de la Fase 3 del pipeline CRISP-DM · DERM_IAPP · Sprint 2 (retroactivo, 19–30/10/2026) ·
Formalizado el 04/11/2026. Cualquier desviación de `marco_muestral_v2.md` debe aprobarse con el PO
y registrarse en este documento y en el historial del marco.*
