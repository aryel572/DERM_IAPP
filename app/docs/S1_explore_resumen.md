# S1 — Resumen de la fase Explore (Mobile-D)

> **Proyecto:** DERM_IAPP — Aplicación móvil con técnicas de Deep Learning para la detección de carcinoma basocelular (BCC) en Trujillo 2026 (UPAO).
> **Sprint:** 1 (retroactivo, 5–16 de octubre de 2026) · **Fase Mobile-D:** 1 — Explore.
> **Elaborado por:** agente mobile-d (equipo Dev) · **Revisión prevista:** Product Owner (dermatólogo, *Off-Site Customer*) y Scrum Master (Aryel Meza).
> **Estado:** fase **ejecutada por el equipo Dev y pendiente de cierre con PO-1** (reunión con el PO; fecha propuesta: semana del 9–13/11/2026 **[por confirmar]**).

---

## 1. Ejecución de la fase (las 3 etapas de Explore)

| Etapa de Explore | Resultado | Evidencia |
|---|---|---|
| **Stakeholder establishment** | Identificados PO (dermatólogo, *Off-Site Customer*), Scrum Master, Dev Team, usuarios finales (dermatólogos de Trujillo), pacientes (indirectos), UPAO, equipo CRISP-DM y restricciones de plataforma | `S1_explore_requisitos_app.md` §2 |
| **Scope definition** | Alcance dentro/fuera definido: 4 pantallas, inferencia TFLite local, validación de entrada, backend solo-versiones; exclusiones explícitas (no diagnóstico, no app de pacientes, sin nube de imágenes) | `S1_explore_requisitos_app.md` §3 |
| **Project establishment** | Requisitos funcionales (RF-01–RF-29) y no funcionales (RNF-01–RNF-10), contrato de inferencia, advertencia normativa, plan de evaluación (E1–E3) y proceso as-is propuesto | Los 4 entregables de §2 |

**Reglas duras fijadas en la fase** (inviolables para todo el proyecto): la imagen **nunca sale del dispositivo**; la advertencia médica **siempre** se muestra; el backend **no recibe imágenes ni hace inferencia**.

## 2. Entregables producidos en Explore

| # | Archivo | Contenido | Estado |
|---|---|---|---|
| 1 | `app/docs/S1_explore_requisitos_app.md` | Stakeholders, alcance, RF por pantalla (4), RNF, contrato de inferencia, advertencia médica normativa, puntos a validar en PO-1 | Borrador v1.0 — pendiente PO-1 |
| 2 | `app/docs/S1_plan_evaluacion.md` | Cómo se medirán TA/NFS/PEO sobre el marco muestral v2 (90 subconjuntos), protocolo GC/GE, métricas técnicas, qué muestra la app, acceptance tests preliminares | Borrador v1.0 — pendiente PO-1 |
| 3 | `docs/bpmn/proceso_as_is_deteccion_bcc.md` | Proceso as-is de detección de BCC (propuesta) con diagrama BPMN 2.0 XML versionable (8 tareas + gateway + 3 lanes) y punto de inserción de la app | **Propuesta del equipo Dev — NO validada por el PO** |
| 4 | `app/docs/S1_explore_resumen.md` | Este documento: decisiones, riesgos y preguntas abiertas | — |

**No se escribió código de aplicación ni de pipeline** (regla de Explore: documentar y decidir, no implementar). Los archivos quedan **sin commitear**, a la espera del flujo de commits del proyecto.

## 3. Decisiones tomadas en la fase

| # | Decisión | Tipo | Sustento |
|---|---|---|---|
| DE-1 | La app es **apoyo a la decisión** (segunda opinión automatizada para el dermatólogo), nunca diagnóstico ni sustituto de biopsia/histopatología | Tesis (ratificar PO-1) | Planteamiento de la tesis; advertencia normativa |
| DE-2 | Producto = **4 pantallas** (Inicio, Entrada, Resultado, Registro del modelo) + backend FastAPI **solo-versiones** | Proyecto (ratificar PO-1) | Definición del proyecto |
| DE-3 | **Inferencia 100 % local** con TFLite (`tflite_flutter`/LiteRT) en Android e iOS; imagen nunca sale del dispositivo | Técnica — regla dura | Privacidad declarada en la tesis |
| DE-4 | Actualización del modelo: consentimiento explícito → descarga temporal → **SHA-256 + firma** → **activación atómica** → **rollback** | Técnica | Seguridad y trazabilidad del experimento |
| DE-5 | Validación de entrada V1–V5 (legible; JPEG/PNG; **≥ 600×450 px** tras corrección EXIF — suelo real del dataset; orientación; RGB), con **recomendación de bloquear** la inferencia si V3 falla | Técnica — **política [PO-1]** | `marco_muestral_v2.md` (suelo 600×450) |
| DE-6 | **Advertencia médica textual íntegra, permanente y no descartable** en Resultado; accesible desde Inicio | Normativa — regla dura | Ética de la tesis |
| DE-7 | La evaluación de la app usa el **marco muestral v2** (90 subconjuntos; 30 pruebas por indicador; ficha por subconjunto; Mann-Whitney GC vs. GE) | Normativa | `marco_muestral_v2.md` (aprobado) |
| DE-8 | En Resultado se muestra **solo la TA declarada del modelo** (campo `ta_referencia` del manifiesto) + advertencia; **NFS y PEO no se exponen** al usuario final (métricas del estudio) | **Propuesta — [PO-1]** | Ver `S1_plan_evaluacion.md` §6 |
| DE-9 | Propuesta de **modo evaluación** (solo estudio): carga organizada por subconjunto y **export CSV local sin etiquetas** | **Propuesta — [PO-1]** | `S1_plan_evaluacion.md` §5.1 |
| DE-10 | Proceso **as-is propuesto** (BPMN) con inserción de la app en el juicio imagen (T4); to-be tras PO-1 | **Propuesta — [PO-1]** | `docs/bpmn/proceso_as_is_deteccion_bcc.md` |
| DE-11 | Los **ADRs** (por qué Flutter, por qué TFLite local, por qué FastAPI) se formalizan en **Initialize** en `docs/adr/` (Architecture Line) | Planificación | Práctica Mobile-D |

## 4. Riesgos identificados

| # | Riesgo | Impacto | Mitigación |
|---|---|---|---|
| R1 | El `.tflite` aún no existe en S1 (CRISP-DM en Fase 3): riesgo de integración en S3 | Alto | **Contrato de inferencia congelado desde S1** (manifiesto como interfaz); la app se desarrolla contra el contrato con modelos de prueba |
| R2 | Uso sobre fotos de celular (fuera del dominio dermatoscópico) → resultados sin sustento | Alto | Aviso de dominio en Entrada + advertencia permanente; la app no promete desempeño en fotos |
| R3 | Prevalencia artificial del marco (50 % BCC): TA no extrapolable a Trujillo | Medio | Declaración en tesis y en Registro del modelo; solo se contrastan GC vs. GE |
| R4 | Rendimiento insuficiente en dispositivos de gama baja | Medio | Arquitecturas livianas (MobileNetV3-Small / EfficientNet-Lite0); medición temprana en S3 (§7 del plan) |
| R5 | Disponibilidad limitada del PO (Off-Site Customer) → retrasos de validación | Medio | Agenda PO-1 cerrada con decisiones binarias (§5); validaciones por escrito |
| R6 | Carga operativa de la evaluación (2 700 evaluaciones por grupo) | Medio | Modo evaluación con export CSV; sesiones por familia |
| R7 | Licencia CC BY-NC-SA 4.0 (no comercial) mal gestionada | Bajo | Atribución visible en Registro del modelo; sin uso comercial |
| R8 | Errores de transcripción en fichas GC/GE | Medio | Export CSV sin etiquetas; doble captura si no hay modo evaluación |
| R9 | Conectividad limitada en consultorios (actualización de modelo) | Bajo | La función clínica es 100 % offline; la actualización es opcional y diferida |
| R10 | Sobreconfianza del usuario final en el resultado | Alto | Advertencia permanente + probabilidad cruda + versión visible + capacitación breve **[PO-1]** |

## 5. Preguntas abiertas para el PO (reunión PO-1)

1. ¿Ratifica el texto de la **advertencia médica** y del aviso de dominio? (requisitos §7, RF-13)
2. ¿Política ante imagen < 600×450: **bloquear** (recomendado) o permitir con advertencia? (RF-11/12)
3. ¿Ratifica que Resultado muestre **solo la TA declarada** y nunca NFS/PEO? (DE-8)
4. ¿Formato del resultado: binario + probabilidad cruda + umbral visibles? (RF-15)
5. ¿Confirma que la app **no persiste** imágenes ni resultados? (RF-20)
6. ¿Ratifica el **proceso as-is** (BPMN) y el punto de inserción de la app? (DE-10; preguntas específicas en el documento BPMN §8)
7. ¿Acepta el **modo evaluación** con export CSV local sin etiquetas? (DE-9)
8. ¿Dispositivos objetivo y versiones mínimas de SO (Android 8+ / iOS 13+ propuestos)? (RNF-03)
9. ¿Umbrales de rendimiento aceptables (p95 ≤ 1 000 ms gama media, propuesto)? (RNF-02)
10. ¿Contenido del Registro del modelo (TA de referencia, atribución ISIC/CC BY-NC-SA 4.0) y distribución controlada sin tiendas? (RF-21/26, E6)

## 6. Criterios de salida de la fase y paso a Initialize

La fase Explore queda **ejecutada** con los 4 entregables; su **cierre formal** requiere PO-1 (ratificación de los puntos [PO-1] y del as-is). Con PO-1 cerrado: (1) los requisitos pasan a línea base para Initialize; (2) se elaboran los ADRs (DE-11); (3) se elabora el BPMN to-be; (4) Initialize (S2) configura Flutter, el repo y el esqueleto con **Trial Day**, bajo las reglas duras DE-3 y DE-6.

## 7. Handoffs

| Destino | Qué se transfiere |
|---|---|
| **Documentador** | Los 4 entregables para su registro en Notion (estructura: App Mobile-D, fase Explore; Presentación de Avances — semana S1) |
| **crisp-dm** | Solicitud del campo `ta_referencia` en el manifiesto TFLite (DE-8) y confirmación del contrato de inferencia (requisitos §6) |
| **coder** | No aplica en Explore (sin código). El primer prompt de código (esqueleto Flutter) se generará en Initialize |
| **commiter-muga** | Los 4 archivos nuevos quedan sin commitear; commits cuando el orquestador lo ordene (scopes sugeridos: `app`, `docs`) |

## 8. Historial de versiones

| Versión | Fecha | Descripción |
|---|---|---|
| v1.0 | 04/11/2026 | Resumen de la fase Explore (formalización retroactiva del Sprint 1, 5–16/10/2026). Pendiente de cierre con PO-1. |

*Resumen de fase Explore · Mobile-D · DERM_IAPP · Sprint 1 (retroactivo, 5–16/10/2026).*
