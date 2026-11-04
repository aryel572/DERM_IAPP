# ADR-002 — Estructura de carpetas y navegación de la app Flutter (DERM_IAPP)

> Práctica Mobile-D: **Architecture Line** (capturar las decisiones arquitectónicas para usarlas cuando se necesiten).

| Campo | Valor |
|---|---|
| **ADR** | 002 |
| **Estado** | Aceptada |
| **Fecha** | 04/11/2026 (formalización retroactiva del Sprint 2, 19–30/10/2026 — fase Initialize) |
| **Decide** | Agente mobile-d (equipo Dev) |
| **Alcance** | Estructura de carpetas de la app Flutter, navegación y gestión de estado del esqueleto (S2) y su evolución a Productionize (S3–S4) |
| **Relacionados** | `app/docs/S1_explore_requisitos_app.md` (RF-01, RF-04–RF-26, §6, §7) · `app/docs/S2_initialize.md` (DE-12–DE-17) · ADR-001 (**pendiente de formalización**: selección del stack tecnológico — Flutter, TFLite local, FastAPI; decisión DE-11 de S1) |

---

## 1. Contexto

- La app tiene exactamente **4 pantallas** (Inicio, Entrada, Resultado, Registro del modelo; RF-01), inferencia **100 % local** con TFLite (A2 de S1), validación de entrada previa (V1–V5) y una advertencia médica **permanente** (RF-16, §7 de S1).
- Equipo de **2 desarrolladores co-localizados** con **< 10 semanas** (perfil home ground de Mobile-D); el código lo produce un agente coder a partir de prompts precisos.
- En S2 **no hay Flutter SDK ni Dart en la máquina de desarrollo**: el esqueleto se construye a mano como proyecto Flutter convencional mínimo y se verifica por inspección (checklist diferida cuando haya SDK).
- El `.tflite` **aún no existe** (CRISP-DM está en Fase 3): la app debe desarrollarse contra el **contrato de inferencia** (manifiesto), no contra un binario concreto (riesgo R1 de S1).
- Restricción del proyecto: en S2 **ninguna dependencia externa** (`tflite_flutter`, `image_picker`, paquetes de estado/navegación entran en S3 o después, decididos en Planning Days).

## 2. Decisión

1. **Estructura minimalista y convencional** (sin capas de arquitectura formal ni *feature-first* en S2):

   ```text
   app/lib/
   ├── main.dart                    # composición: MaterialApp + tema + rutas (sin lógica)
   ├── pantallas/                   # un archivo por pantalla; 4 widgets sin estado
   │   ├── pantalla_inicio.dart         → HomeScreen
   │   ├── pantalla_entrada.dart        → EntryScreen
   │   ├── pantalla_resultado.dart      → ResultScreen
   │   └── pantalla_registro_modelo.dart → ModelRegistryScreen
   ├── modelo/
   │   └── modelo_tflite_stub.dart  # contrato de inferencia local (interfaz, sin implementar)
   ├── (S3) servicios/              # inference_service.dart, validacion_entrada.dart, …
   ├── (S3) constantes/             # advertencia_medica.dart (única fuente del texto)
   └── (S3) assets → assets/models/ # .tflite versionado + manifiesto (cuando CRISP-DM lo entregue)
   ```

   - `main.dart` **solo compone** (tema + rutas). La lógica de negocio entra en S3 en `lib/servicios/`.
   - Los nombres de clase son en inglés convencional; comentarios y textos de UI en español; cada archivo lleva doc comment que lo mapea a los RF de S1.

2. **Navegación con rutas nombradas de `MaterialApp`**: `/` (Inicio, ruta inicial), `/entrada`, `/resultado`, `/registro`. Sin paquete de navegación externo. Inicio ofrece acceso directo a Entrada y Registro (RF-05) y un acceso demo a Resultado marcado como placeholder de S2 (en S3, Resultado solo se alcanza con una imagen validada, RF-14).

3. **Estado local simple, sin paquetes**: `setState`/`ValueNotifier` de Flutter. Para pasar la imagen validada de Entrada a Resultado (S3) se usarán argumentos de ruta; no se adoptan `provider`/`bloc`/`riverpod`.

4. **El contrato de inferencia existe desde S2 como interfaz stub** (`modelo_tflite_stub.dart`): `loadFromManifest`, `preprocess` (al `input_size` y normalización del manifiesto), `infer` → `{es_bcc, confianza}` (semántica: probabilidad de BCC + umbral del manifiesto), `unload`. S3 lo implementa (`inference_service.dart` con `tflite_flutter`) sin cambiar la interfaz.

5. **La advertencia médica textual (3 oraciones normativas) ya es visible en el esqueleto de Resultado** (estática) y se centraliza en S3 en **una sola constante** (`lib/constantes/advertencia_medica.dart`) reutilizada por Resultado e Inicio (RF-16, RF-07).

## 3. Opciones consideradas

| Opción | Pros | Contras | Veredicto |
|---|---|---|---|
| **A. Estructura minimalista `pantallas/` + `modelo/`** (elegida) | Convencional, legible, mínima superficie de error al compilar «a ciegas» (sin SDK); refleja 1:1 las 4 pantallas de los requisitos | Si las pantallas crecen, habrá que reorganizar | **Aceptada** — revisión en el Planning Day de S3 |
| B. *Feature-first* `lib/features/<pantalla>/` (widgets + lógica por pantalla) | Escala mejor si cada pantalla acumula widgets/servicios | Sobre-ingeniería para 4 pantallas placeholder; más archivos/movimientos antes de saber el peso real de cada pantalla | Diferida: solo si el Planning Day de S3 la justifica (se documentaría en un ADR nuevo) |
| C. Arquitectura en capas formal (data/domain/presentation + DI) | Robustez, testabilidad máxima | Inasumible con 2 devs y < 10 semanas; contradice el minimalismo de Mobile-D para apps pequeñas | Descartada |
| **A. Rutas nombradas** (elegida) | Nativo de Flutter, 4 rutas fijas, cero dependencias | No soporta deep links ni guards avanzados | **Aceptada** — deep links fuera de alcance (E8 de S1) |
| B. `Navigator.push` directo con widgets | Sin mapa central de rutas | Navegación dispersa; RF-01 exige un mapa claro | Descartada |
| C. `go_router` | Rutas tipadas, guards, deep links | Dependencia externa prohibida en S2; innecesaria para 4 rutas sin deep links | Descartada (re-evaluable en S4 solo si apareciera un requisito de deep link, que no existe) |
| **A. Estado local sin paquetes** (elegida) | Cero dependencias; suficiente para un flujo lineal de 4 pantallas | Manejo manual del paso de datos entre rutas | **Aceptada** |
| B. `provider`/`riverpod`/`bloc` | Estado compartido elegante | Dependencias externas en S2 prohibidas; complejidad no justificada | Descartada por ahora (Planning Day de S3 decide si algo la justifica) |

## 4. Consecuencias

**Positivas**
- El esqueleto es un proyecto Flutter estándar: `flutter pub get` + `flutter run` funciona al instalar el SDK; `flutter create .` regenera solo lo faltante (carpetas de plataforma).
- La advertencia normativa entra al producto **desde el primer widget de Resultado**: el requisito más sensible (RF-16) nace visible y verificable.
- El contrato de inferencia queda fijado como interfaz antes de que exista el `.tflite`: la app puede avanzar (y testearse con MTDD) sin acoplarse al modelo, y CRISP-DM puede congelar el manifiesto sin esperar a la UI.
- Cero dependencias externas en S2: menor riesgo de conflictos de versiones al instalar el SDK con posterioridad.

**Negativas / riesgos asumidos**
- Sin compilación en S2, los errores de sintaxis solo se detectarán al instalar el SDK (mitigación: inspección documentada del coder + checklist de `app/docs/S2_initialize.md` §7).
- Rutas nombradas globales escalan peor que `go_router` con muchos flujos — irrelevante con 4 rutas; se re-evalúa solo ante un requisito nuevo.
- La migración a `features/` (si ocurre en S3) implicará churn de imports — acotado a 10 archivos.

**Neutras**
- Sin i18n (solo español, E7 de S1) y sin notificaciones/push (E8 de S1): no condicionan esta decisión.

## 5. Cumplimiento de las reglas duras del proyecto

| Regla dura | Cumplimiento en esta decisión |
|---|---|
| **La imagen nunca sale del dispositivo** | No existe código de red en el esqueleto; cuando entre red (S4, Registro del modelo) será exclusivamente manifiesto/`.tflite` — nunca imágenes ni resultados (RNF-01, RF-29) |
| **La advertencia médica siempre se muestra** | Resultado placeholder ya la contiene íntegra y estática (3 oraciones de S1 §7); en S3 será constante única y no descartable |
| **El backend no recibe imágenes ni hace inferencia** | La estructura reserva `backend/` para versiones del modelo únicamente; la app consume el manifiesto vía contrato |

## 6. Notas de numeración de ADRs

`docs/adr/` estaba vacío al crear este ADR. Este documento se numera **ADR-002** por ser la decisión de arquitectura nº 2 de la serie del proyecto (la nº 1 corresponde a la selección del stack tecnológico — Flutter/Dart, TFLite local, FastAPI — ratificada como DE-2/DE-3 en Explore y pendiente de formalización como **ADR-001**). No crear otros ADR-001 en paralelo.

## 7. Referencias

- `app/docs/S1_explore_requisitos_app.md` — requisitos y contrato de inferencia (§4, §6, §7).
- `app/docs/S2_initialize.md` — registro de la fase y decisiones DE-12–DE-17.
- `app/docs/S1_plan_evaluacion.md` — métricas técnicas (E2) que condicionan la estructura de servicios en S3.
- `PRODUCTO/metodologias/MOBILE_D/CONOCIMIENTO_MOBILE_D.md` — práctica Architecture Line.
