# Proceso as-is de detección de carcinoma basocelular en Trujillo (propuesta v1.0)

> **Proyecto:** DERM_IAPP — Aplicación móvil con técnicas de Deep Learning para la detección de carcinoma basocelular (BCC) en Trujillo 2026 (UPAO).
> **Sprint:** 1 (retroactivo, 5–16 de octubre de 2026) · **Fase Mobile-D:** 1 — Explore (establecimiento del proceso).
> **Elaborado por:** equipo Dev (agente mobile-d).
> **Estado:** ⚠️ **BORRADOR PROPUESTO — NO VALIDADO POR EL PO.** Este documento es una **propuesta del equipo Dev** reconstruida a partir de la práctica dermatológica general y del planteamiento de la tesis. **El PO (dermatólogo de Trujillo) no ha sido consultado todavía en esta formalización del Sprint 1**; no se levantó información primaria en Trujillo para redactarlo. Su **validación es un objetivo explícito de la reunión PO-1** (§8); hasta entonces no debe citarse como descripción validada del proceso real.

---

## 1. Propósito

Documentar el proceso **actual (as-is)** con el que se detecta y confirma el carcinoma basocelular en la consulta dermatológica de Trujillo, para que la app DERM_IAPP se diseñe como **apoyo a ese proceso real** y no como proceso paralelo. Este entendimiento es el entregable «establecimiento del proceso» de la fase Explore de Mobile-D y la base del futuro diagrama to-be (con la app integrada).

## 2. Alcance y participantes

| Elemento | Descripción |
|---|---|
| Disparador | Paciente acude a consulta dermatológica por una lesión cutánea sospechosa (nueva, cambiante, sangrante, no cicatrizante) o con un hallazgo en control de rutina |
| Fin | Conducta definida: tratamiento tras confirmación histopatológica **o** vigilancia estructurada de la lesión |
| Participantes | Paciente · Dermatólogo · Laboratorio de histopatología (patología) |
| Exclusiones | Otros cánceres cutáneos (melanoma, SCC) siguen su propio proceso; el BCC es el foco de la tesis |

## 3. Narrativa del proceso as-is (propuesta)

1. **Consulta dermatológica.** El paciente acude por una lesión cutánea que le preocupa o detectada en control.
2. **Anamnesis y examen clínico.** Historia de la lesión (duración, cambios, sangrado, exposición solar), examen clínico y exploración de la región.
3. **Dermatoscopia.** Examen de la lesión con dermatoscopio (no invasivo). Es el paso con **mayor variabilidad**: depende del equipo disponible y del entrenamiento del profesional en dermatoscopia.
4. **Juicio clínico-dermatoscópico.** El dermatólogo integra hallazgos y formula una sospecha diagnóstica. Aquí se concentran los dos errores clínicos que la tesis mide: **no sospechar un BCC real** (falso negativo → omisión) y **sospechar un BCC inexistente** (falso positivo → falsa alarma).
5. **Decisión (gateway).**
   - **Sospecha alta de BCC** → toma de biopsia (punch, shave o excisión según el caso) y remisión a histopatología.
   - **Sospecha baja o incierta** → vigilancia y control periódico de la lesión, con re-evaluación en la siguiente visita (nueva anamnesis/examen). Una lesión BCC mal clasificada aquí permanece oculta hasta una visita posterior (riesgo de omisión).
6. **Histopatología.** El estudio histopatológico es el **patrón de referencia (gold standard)** que confirma o descarta el BCC. Los tiempos de respuesta pueden demorar el diagnóstico.
7. **Decisión terapéutica y tratamiento.** Con el informe, el dermatólogo define la conducta (cirugía, curetaje, tratamientos tópicos u otras opciones según el caso) y el seguimiento.

### Puntos de dolor declarados (propuesta, a confirmar con el PO)

| # | Punto de dolor | Indicador de la tesis relacionado |
|---|---|---|
| 1 | Variabilidad del juicio imagen-dependiente entre profesionales (dermatoscopia depende de entrenamiento/equipo) | **TA** (proporción de decisiones correctas) |
| 2 | Falsas alarmas: lesiones no-BCC sospechadas de BCC → biopsias/derivaciones innecesarias y costos | **NFS** (nº de falsos sospechosos = FP) |
| 3 | Omisiones: BCC vigilados como benignos → diagnóstico tardío | **PEO** (% de error de omisión = FN/(TP+FN)) |
| 4 | Demoras de la confirmación histopatológica | Contexto del proceso (no medido por la tesis) |

## 4. Punto de inserción de la app (apoyo, no reemplazo)

La app DERM_IAPP se inserta como **apoyo al juicio clínico-dermatoscópico** (paso 4): el dermatólogo puede obtener una **segunda opinión automatizada** sobre la imagen dermatoscópica de la lesión, con el desempeño del modelo **declarado** (TA de referencia; NFS y PEO son métricas del estudio, no se exponen) y bajo advertencia médica permanente.

**Reglas de inserción (normativas para el diseño):**

1. La app **apoya, no decide**: la sospecha y la conducta siguen siendo del dermatólogo.
2. La app **no reemplaza** la biopsia ni la histopatología (gold standard).
3. La imagen **nunca sale del dispositivo** (inferencia local TFLite).
4. El resultado **siempre** va acompañado de la advertencia médica normativa.
5. El modelo espera **imágenes dermatoscópicas**; una fotografía de celular no es equivalente (aviso de dominio en la app).

## 5. Diagrama BPMN 2.0 (XML versionable)

Modelo del proceso **as-is sin la app**; el punto de inserción se marca como anotación (`Annotation_InsercionApp`) para no alterar el as-is. El XML es importable en [bpmn.io](https://demo.bpmn.io/), Camunda Modeler o bpmn-js y queda versionado en este repositorio. Un solo proceso, 8 tareas + 1 gateway exclusivo + 3 lanes.

```xml
<?xml version="1.0" encoding="UTF-8"?>
<bpmn:definitions xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL"
                  xmlns:bpmndi="http://www.omg.org/spec/BPMN/20100524/DI"
                  xmlns:dc="http://www.omg.org/spec/DD/20100524/DC"
                  xmlns:di="http://www.omg.org/spec/DD/20100524/DI"
                  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
                  id="Definitions_ProcesoAsIs_BCC"
                  targetNamespace="https://derm-iapp.upao.edu.pe/bpmn/proceso-as-is-bcc"
                  exporter="DERM_IAPP (agente mobile-d)" exporterVersion="1.0">

  <bpmn:collaboration id="Collaboration_AsIs_BCC">
    <bpmn:participant id="Participant_Dermatologia" name="Servicio de dermatologia (Trujillo)" processRef="Process_AsIs_Deteccion_BCC" />
  </bpmn:collaboration>

  <bpmn:process id="Process_AsIs_Deteccion_BCC" name="Proceso as-is de deteccion de carcinoma basocelular" isExecutable="false">

    <bpmn:laneSet id="LaneSet_AsIs">
      <bpmn:lane id="Lane_Paciente" name="Paciente">
        <bpmn:flowNodeRef>StartEvent_LesionSospechosa</bpmn:flowNodeRef>
      </bpmn:lane>
      <bpmn:lane id="Lane_Dermatologo" name="Dermatologo">
        <bpmn:flowNodeRef>Task_ConsultaDermatologica</bpmn:flowNodeRef>
        <bpmn:flowNodeRef>Task_AnamnesisExamenClinico</bpmn:flowNodeRef>
        <bpmn:flowNodeRef>Task_Dermatoscopia</bpmn:flowNodeRef>
        <bpmn:flowNodeRef>Task_JuicioClinicoImagen</bpmn:flowNodeRef>
        <bpmn:flowNodeRef>Gateway_SospechaBCC</bpmn:flowNodeRef>
        <bpmn:flowNodeRef>Task_TomaBiopsia</bpmn:flowNodeRef>
        <bpmn:flowNodeRef>Task_DecisionTerapeutica</bpmn:flowNodeRef>
        <bpmn:flowNodeRef>Task_VigilanciaSeguimiento</bpmn:flowNodeRef>
        <bpmn:flowNodeRef>EndEvent_CasoDefinido</bpmn:flowNodeRef>
      </bpmn:lane>
      <bpmn:lane id="Lane_Laboratorio" name="Laboratorio de histopatologia">
        <bpmn:flowNodeRef>Task_HistopatologiaInforme</bpmn:flowNodeRef>
      </bpmn:lane>
    </bpmn:laneSet>

    <bpmn:startEvent id="StartEvent_LesionSospechosa" name="Paciente acude con lesion cutanea sospechosa">
      <bpmn:outgoing>Flow_01_Start_Consulta</bpmn:outgoing>
    </bpmn:startEvent>

    <bpmn:task id="Task_ConsultaDermatologica" name="Consulta dermatologica">
      <bpmn:documentation>Consulta por lesion pigmentada o erosionada nueva, cambiante o sangrante, o hallazgo en control de rutina.</bpmn:documentation>
      <bpmn:incoming>Flow_01_Start_Consulta</bpmn:incoming>
      <bpmn:outgoing>Flow_02_Consulta_Anamnesis</bpmn:outgoing>
    </bpmn:task>

    <bpmn:task id="Task_AnamnesisExamenClinico" name="Anamnesis y examen clinico de la lesion">
      <bpmn:incoming>Flow_02_Consulta_Anamnesis</bpmn:incoming>
      <bpmn:outgoing>Flow_03_Anamnesis_Dermatoscopia</bpmn:outgoing>
    </bpmn:task>

    <bpmn:task id="Task_Dermatoscopia" name="Dermatoscopia (examen con dermatoscopio)">
      <bpmn:documentation>Paso con mayor variabilidad entre profesionales: depende del equipo disponible y del entrenamiento en dermatoscopia.</bpmn:documentation>
      <bpmn:incoming>Flow_03_Anamnesis_Dermatoscopia</bpmn:incoming>
      <bpmn:outgoing>Flow_04_Dermatoscopia_Juicio</bpmn:outgoing>
    </bpmn:task>

    <bpmn:task id="Task_JuicioClinicoImagen" name="Juicio clinico-dermatoscopico de la lesion">
      <bpmn:documentation>PUNTO DE INSERCION DE LA APP (to-be): apoyo como segunda opinion automatizada sobre la imagen dermatoscopica, con desempeno declarado y advertencia medica permanente. No reemplaza la biopsia ni el criterio del dermatologo.</bpmn:documentation>
      <bpmn:incoming>Flow_04_Dermatoscopia_Juicio</bpmn:incoming>
      <bpmn:outgoing>Flow_05_Juicio_Gateway</bpmn:outgoing>
    </bpmn:task>

    <bpmn:exclusiveGateway id="Gateway_SospechaBCC" name="Sospecha alta de BCC?">
      <bpmn:incoming>Flow_05_Juicio_Gateway</bpmn:incoming>
      <bpmn:outgoing>Flow_06_Alta_Biopsia</bpmn:outgoing>
      <bpmn:outgoing>Flow_07_Baja_Vigilancia</bpmn:outgoing>
    </bpmn:exclusiveGateway>

    <bpmn:task id="Task_TomaBiopsia" name="Toma de biopsia (punch / shave / escision)">
      <bpmn:incoming>Flow_06_Alta_Biopsia</bpmn:incoming>
      <bpmn:outgoing>Flow_08_Biopsia_Histopatologia</bpmn:outgoing>
    </bpmn:task>

    <bpmn:task id="Task_HistopatologiaInforme" name="Estudio histopatologico e informe">
      <bpmn:documentation>Patron de referencia (gold standard) del diagnostico de BCC.</bpmn:documentation>
      <bpmn:incoming>Flow_08_Biopsia_Histopatologia</bpmn:incoming>
      <bpmn:outgoing>Flow_09_Histo_Decision</bpmn:outgoing>
    </bpmn:task>

    <bpmn:task id="Task_DecisionTerapeutica" name="Decision terapeutica y tratamiento">
      <bpmn:incoming>Flow_09_Histo_Decision</bpmn:incoming>
      <bpmn:outgoing>Flow_10_Decision_End</bpmn:outgoing>
    </bpmn:task>

    <bpmn:task id="Task_VigilanciaSeguimiento" name="Vigilancia y control periodico de la lesion">
      <bpmn:incoming>Flow_07_Baja_Vigilancia</bpmn:incoming>
      <bpmn:outgoing>Flow_11_Vigilancia_Anamnesis</bpmn:outgoing>
    </bpmn:task>

    <bpmn:endEvent id="EndEvent_CasoDefinido" name="Caso con conducta definida">
      <bpmn:incoming>Flow_10_Decision_End</bpmn:incoming>
    </bpmn:endEvent>

    <bpmn:textAnnotation id="Annotation_InsercionApp">
      <bpmn:text>La app DERM_IAPP (to-be) apoya este juicio como segunda opinion automatizada (TA declarada; NFS y PEO del estudio); el dermatologo decide. La imagen nunca sale del dispositivo.</bpmn:text>
    </bpmn:textAnnotation>
    <bpmn:association id="Association_App_Juicio" sourceRef="Annotation_InsercionApp" targetRef="Task_JuicioClinicoImagen" />

    <bpmn:sequenceFlow id="Flow_01_Start_Consulta" sourceRef="StartEvent_LesionSospechosa" targetRef="Task_ConsultaDermatologica" />
    <bpmn:sequenceFlow id="Flow_02_Consulta_Anamnesis" sourceRef="Task_ConsultaDermatologica" targetRef="Task_AnamnesisExamenClinico" />
    <bpmn:sequenceFlow id="Flow_03_Anamnesis_Dermatoscopia" sourceRef="Task_AnamnesisExamenClinico" targetRef="Task_Dermatoscopia" />
    <bpmn:sequenceFlow id="Flow_04_Dermatoscopia_Juicio" sourceRef="Task_Dermatoscopia" targetRef="Task_JuicioClinicoImagen" />
    <bpmn:sequenceFlow id="Flow_05_Juicio_Gateway" sourceRef="Task_JuicioClinicoImagen" targetRef="Gateway_SospechaBCC" />
    <bpmn:sequenceFlow id="Flow_06_Alta_Biopsia" name="Sospecha alta de BCC" sourceRef="Gateway_SospechaBCC" targetRef="Task_TomaBiopsia">
      <bpmn:conditionExpression xsi:type="bpmn:tFormalExpression">sospecha_clinica == 'alta'</bpmn:conditionExpression>
    </bpmn:sequenceFlow>
    <bpmn:sequenceFlow id="Flow_07_Baja_Vigilancia" name="Sospecha baja o incierta" sourceRef="Gateway_SospechaBCC" targetRef="Task_VigilanciaSeguimiento">
      <bpmn:conditionExpression xsi:type="bpmn:tFormalExpression">sospecha_clinica in ('baja','incierta')</bpmn:conditionExpression>
    </bpmn:sequenceFlow>
    <bpmn:sequenceFlow id="Flow_08_Biopsia_Histopatologia" name="Muestra remitida" sourceRef="Task_TomaBiopsia" targetRef="Task_HistopatologiaInforme" />
    <bpmn:sequenceFlow id="Flow_09_Histo_Decision" sourceRef="Task_HistopatologiaInforme" targetRef="Task_DecisionTerapeutica" />
    <bpmn:sequenceFlow id="Flow_10_Decision_End" sourceRef="Task_DecisionTerapeutica" targetRef="EndEvent_CasoDefinido" />
    <bpmn:sequenceFlow id="Flow_11_Vigilancia_Anamnesis" name="Nueva visita (re-evaluacion)" sourceRef="Task_VigilanciaSeguimiento" targetRef="Task_AnamnesisExamenClinico" />
  </bpmn:process>

  <bpmndi:BPMNDiagram id="BPMNDiagram_AsIs">
    <bpmndi:BPMNPlane id="BPMNPlane_AsIs" bpmnElement="Collaboration_AsIs_BCC">
      <bpmndi:BPMNShape id="Participant_Dermatologia_di" bpmnElement="Participant_Dermatologia" isHorizontal="true">
        <dc:Bounds x="140" y="80" width="1360" height="560" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Lane_Paciente_di" bpmnElement="Lane_Paciente" isHorizontal="true">
        <dc:Bounds x="160" y="80" width="1340" height="140" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Lane_Dermatologo_di" bpmnElement="Lane_Dermatologo" isHorizontal="true">
        <dc:Bounds x="160" y="220" width="1340" height="260" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Lane_Laboratorio_di" bpmnElement="Lane_Laboratorio" isHorizontal="true">
        <dc:Bounds x="160" y="480" width="1340" height="160" />
      </bpmndi:BPMNShape>

      <bpmndi:BPMNShape id="StartEvent_LesionSospechosa_di" bpmnElement="StartEvent_LesionSospechosa">
        <dc:Bounds x="210" y="132" width="36" height="36" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_ConsultaDermatologica_di" bpmnElement="Task_ConsultaDermatologica">
        <dc:Bounds x="290" y="260" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_AnamnesisExamenClinico_di" bpmnElement="Task_AnamnesisExamenClinico">
        <dc:Bounds x="450" y="260" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_Dermatoscopia_di" bpmnElement="Task_Dermatoscopia">
        <dc:Bounds x="610" y="260" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_JuicioClinicoImagen_di" bpmnElement="Task_JuicioClinicoImagen">
        <dc:Bounds x="770" y="260" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Gateway_SospechaBCC_di" bpmnElement="Gateway_SospechaBCC" isMarkerVisible="true">
        <dc:Bounds x="915" y="275" width="50" height="50" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_TomaBiopsia_di" bpmnElement="Task_TomaBiopsia">
        <dc:Bounds x="1020" y="260" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_DecisionTerapeutica_di" bpmnElement="Task_DecisionTerapeutica">
        <dc:Bounds x="1230" y="260" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="EndEvent_CasoDefinido_di" bpmnElement="EndEvent_CasoDefinido">
        <dc:Bounds x="1390" y="282" width="36" height="36" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_VigilanciaSeguimiento_di" bpmnElement="Task_VigilanciaSeguimiento">
        <dc:Bounds x="610" y="380" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Task_HistopatologiaInforme_di" bpmnElement="Task_HistopatologiaInforme">
        <dc:Bounds x="1020" y="520" width="100" height="80" />
      </bpmndi:BPMNShape>
      <bpmndi:BPMNShape id="Annotation_InsercionApp_di" bpmnElement="Annotation_InsercionApp">
        <dc:Bounds x="700" y="120" width="240" height="70" />
      </bpmndi:BPMNShape>

      <bpmndi:BPMNEdge id="Flow_01_Start_Consulta_di" bpmnElement="Flow_01_Start_Consulta">
        <di:waypoint x="246" y="150" />
        <di:waypoint x="268" y="150" />
        <di:waypoint x="268" y="300" />
        <di:waypoint x="290" y="300" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_02_Consulta_Anamnesis_di" bpmnElement="Flow_02_Consulta_Anamnesis">
        <di:waypoint x="390" y="300" />
        <di:waypoint x="450" y="300" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_03_Anamnesis_Dermatoscopia_di" bpmnElement="Flow_03_Anamnesis_Dermatoscopia">
        <di:waypoint x="550" y="300" />
        <di:waypoint x="610" y="300" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_04_Dermatoscopia_Juicio_di" bpmnElement="Flow_04_Dermatoscopia_Juicio">
        <di:waypoint x="710" y="300" />
        <di:waypoint x="770" y="300" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_05_Juicio_Gateway_di" bpmnElement="Flow_05_Juicio_Gateway">
        <di:waypoint x="870" y="300" />
        <di:waypoint x="915" y="300" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_06_Alta_Biopsia_di" bpmnElement="Flow_06_Alta_Biopsia">
        <di:waypoint x="965" y="300" />
        <di:waypoint x="1020" y="300" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_07_Baja_Vigilancia_di" bpmnElement="Flow_07_Baja_Vigilancia">
        <di:waypoint x="940" y="325" />
        <di:waypoint x="940" y="420" />
        <di:waypoint x="710" y="420" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_08_Biopsia_Histopatologia_di" bpmnElement="Flow_08_Biopsia_Histopatologia">
        <di:waypoint x="1070" y="340" />
        <di:waypoint x="1070" y="520" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_09_Histo_Decision_di" bpmnElement="Flow_09_Histo_Decision">
        <di:waypoint x="1120" y="560" />
        <di:waypoint x="1280" y="560" />
        <di:waypoint x="1280" y="340" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_10_Decision_End_di" bpmnElement="Flow_10_Decision_End">
        <di:waypoint x="1330" y="300" />
        <di:waypoint x="1390" y="300" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Flow_11_Vigilancia_Anamnesis_di" bpmnElement="Flow_11_Vigilancia_Anamnesis">
        <di:waypoint x="610" y="420" />
        <di:waypoint x="500" y="420" />
        <di:waypoint x="500" y="340" />
      </bpmndi:BPMNEdge>
      <bpmndi:BPMNEdge id="Association_App_Juicio_di" bpmnElement="Association_App_Juicio">
        <di:waypoint x="820" y="190" />
        <di:waypoint x="820" y="260" />
      </bpmndi:BPMNEdge>
    </bpmndi:BPMNPlane>
  </bpmndi:BPMNDiagram>
</bpmn:definitions>
```

> Nota: los nombres de los elementos del XML van sin tildes por compatibilidad con algunos modeladores BPMN; la redacción con tildes de este documento es la normativa.

## 6. Diccionario de elementos del diagrama

| ID | Elemento | Significado |
|---|---|---|
| `StartEvent_LesionSospechosa` | Evento de inicio | Paciente acude con lesión cutánea sospechosa |
| `Task_ConsultaDermatologica` | Tarea (T1) | Consulta dermatológica |
| `Task_AnamnesisExamenClinico` | Tarea (T2) | Anamnesis y examen clínico de la lesión |
| `Task_Dermatoscopia` | Tarea (T3) | Dermatoscopia con dermatoscopio |
| `Task_JuicioClinicoImagen` | Tarea (T4) | Juicio clínico-dermatoscópico (punto de inserción de la app) |
| `Gateway_SospechaBCC` | Gateway exclusivo (G1) | ¿Sospecha alta de BCC? |
| `Task_TomaBiopsia` | Tarea (T5) | Toma de biopsia (punch/shave/excisión) |
| `Task_HistopatologiaInforme` | Tarea (T6) | Estudio histopatológico e informe (gold standard) |
| `Task_DecisionTerapeutica` | Tarea (T7) | Decisión terapéutica y tratamiento |
| `Task_VigilanciaSeguimiento` | Tarea (T8) | Vigilancia y control periódico (bucle de re-evaluación) |
| `EndEvent_CasoDefinido` | Evento de fin | Caso con conducta definida |
| `Annotation_InsercionApp` | Anotación | Donde la app apoyará como segunda opinión (to-be) |

## 7. Diagrama to-be (pendiente)

Tras la validación del as-is en PO-1 se elaborará el **diagrama to-be** (el mismo proceso con la app integrada como servicio de apoyo en T4, sin modificar la biopsia ni la histopatología). Se ubicará en esta misma carpeta (`docs/bpmn/`) y se registrará en el historial.

## 8. Validación pendiente en PO-1 (preguntas sobre el proceso)

1. ¿Este flujo refleja la práctica real de la consulta dermatológica en Trujillo? ¿Faltan o sobran pasos?
2. ¿La dermatoscopia está disponible en la primera consulta o es derivada? ¿Con dermatoscopio óptico o digital?
3. ¿Quién toma la biopsia y qué técnica predomina? ¿Dónde se procesa la muestra y con qué tiempos típicos?
4. ¿El seguimiento de lesiones inciertas es estructurado (agenda/pauta) o depende del paciente?
5. ¿Dónde percibe el PO que la app aporta más valor: reducir omisiones (PEO), reducir falsas alarmas (NFS) o ambas?
6. ¿Ratifica el punto de inserción de la app en el juicio imagen (T4) y las reglas de inserción del §4?

## 9. Historial de versiones

| Versión | Fecha | Descripción |
|---|---|---|
| v1.0 (propuesta) | 04/11/2026 | Borrador del equipo Dev (agente mobile-d), formalización retroactiva del Sprint 1 (5–16/10/2026). **No validado por el PO**; validación prevista en PO-1. |

*Propuesta de proceso as-is · fase Explore · Mobile-D · DERM_IAPP · Sprint 1 (retroactivo, 5–16/10/2026).*
