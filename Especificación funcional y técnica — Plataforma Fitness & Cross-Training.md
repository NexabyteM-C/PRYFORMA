Especificación funcional y técnica — Plataforma Fitness & Cross-Training
Versión 1.0 · Documento base de arquitectura y requisitos · 6 de noviembre de 2026
Estado de la propuesta
Diseño inicial

PlataformasAndroid · iOS · Web

Tecnología principalFlutter + Dart

UsuariosAtletas y boxes

Modelo comercialFreemium + SaaS

OrganizacionesMulti-box

Comunicación inicialAnuncios + notificaciones



1. Visión y alcance del producto
Desarrollaremos una plataforma de rendimiento deportivo que conecte la experiencia individual de los atletas con la operación de gimnasios, boxes y entrenadores.

El principio arquitectónico fundamental es:

El atleta es propietario de su historial deportivo; las organizaciones administran la experiencia de entrenamiento, las clases y la comunidad a la que el atleta decide vincularse.

La aplicación estará enfocada inicialmente en CrossFit, entrenamiento funcional, halterofilia, fuerza y gimnasia. Su estructura permitirá incorporar otras disciplinas sin modificar los fundamentos de la base de datos.
Los cuatro pilares del producto
Rendimiento personal

Registrar marcas, entrenamientos, habilidades y objetivos medibles.


Programación deportiva

Conocer anticipadamente clases, movimientos, enfoques y cargas sugeridas.


Comunidad multi-box

Participar en varios gimnasios, recibir anuncios y conservar la identidad deportiva.


Evolución y analítica

Comparar resultados, descubrir mejoras y visualizar metas alcanzadas.



2. Requisitos funcionales detallados
Los identificadores RF servirán para relacionar pantallas, historias de usuario, desarrollo y pruebas de aceptación.
Código	Requisito funcional	Prioridad
RF-001	Registro, autenticación y recuperación de cuenta	P0
RF-002	Perfil deportivo, preferencias y unidades kg/lb	P0
RF-003	Biblioteca de ejercicios por disciplina	P0
RF-004	Registro de series, repeticiones y cargas	P0
RF-005	Registro de RM reales y estimados	P0
RF-006	Historial de resultados y récords personales	P0
RF-007	Objetivos individuales con seguimiento	P0
RF-008	Registro y evaluación de WOD	P0
RF-009	Creación y administración de boxes	P0
RF-010	Vinculación de un atleta a múltiples boxes	P0
RF-011	Gestión de membresías y roles	P0
RF-012	Programación diaria y semanal de clases	P0
RF-013	Publicación anticipada de entrenamientos	P0
RF-014	Notificaciones de nuevas programaciones	P0
RF-015	Visualización de clases de todos los boxes asociados	P0
RF-016	Cargas sugeridas según RM individuales	P0
RF-017	Anuncios institucionales del box	P0
RF-018	Panel web de coaches y administradores	P0
RF-019	Comparación histórica de WOD repetidos	P1
RF-020	Comentarios en anuncios y clases	P1
RF-021	Reservas de clases y control de cupos	P1
RF-022	Rankings deportivos por organización	P1
RF-023	Suscripciones Premium y planes para boxes	P1
RF-024	Sincronización offline de registros deportivos	P1
RF-025	Asistencia, confirmación y listas de espera	P2
RF-026	Mensajería individual y grupal	P2
RF-027	Recomendaciones inteligentes de entrenamiento	P2

P0 significa indispensable para el lanzamiento, P1 siguiente incremento y P2 evolución futura. Como el modelo comercial será híbrido, la infraestructura de suscripciones se diseña desde el principio, aunque el cobro automatizado pueda habilitarse después del lanzamiento inicial.

3. Módulo central: programación diaria de clases
Este es uno de los componentes estratégicos de la plataforma. No será simplemente un calendario ni un muro de publicaciones.

Cada box tendrá un sistema profesional para planificar, estructurar, publicar y comunicar su programación de entrenamiento.
3.1. Estructura de una clase
Una programación estará compuesta por:
- Datos generales: fecha, horario, sede, entrenador, duración y nivel.
- Objetivo de la clase: fuerza máxima, técnica, potencia, resistencia, gimnasia, recuperación, etc.
- Bloques configurables: calentamiento, fuerza, skill, WOD, movilidad y enfriamiento.
- Movimientos: nombre, series, repeticiones, duración, cargas y variantes.
- Recomendaciones del coach: accesorios, equipamiento, preparación y opciones de escalado.
- Publicación: fecha y hora en que los atletas podrán consultar la programación.
El coach podrá crear una clase para una fecha específica o utilizar una plantilla semanal reutilizable.
Ejemplo visual de programación para el atleta
EJEMPLO DE PROGRAMACIÓN
Viernes · Strength & Skill
Box Alpha · 6:00 a. m. · Coach asignado


Fuerza
Gimnasia
60 min

Objetivo del día

Trabajar fuerza de piernas y progresión de movimientos gimnásticos, priorizando calidad técnica.

01 · Warm-up
10 min
3 rondas de 10 air squats, 10 lunges y 200 m de carrera.
02 · Strength
20 min
Back Squat · 5 series × 3 repeticiones · 80% del 1RM.Carga personalizada de ejemploRM disponible

96 kg
Calculado con un 1RM personal hipotético de 120 kg

03 · Gymnastics Skill
15 min
Progresiones de Handstand Push-up y trabajo de control corporal.
04 · Conditioning
10 min
AMRAP 10: 10 dumbbell snatches, 10 box jumps y 100 m run.
05 · Cool-down
5 min
Movilidad de tobillos y hombros.
Recomendaciones del coach

Llevar grips para el trabajo gimnástico, utilizar calzado estable y preparar los pesos de trabajo antes de iniciar.


3.2. Flujo de publicación y notificación
Coach crea programación
Selecciona fecha, enfoque, bloques y movimientos

Guarda borrador y revisa
Puede programar publicación automática

Publicación de la clase
Se genera la versión visible para los atletas

Notificación
Push e inbox de la app

Calendario
Disponible en su box y agenda



Atleta consulta y se prepara
Visualiza enfoque, movimientos, cargas y materiales

Entrena y registra resultados
Los resultados alimentan su historial personal

3.3. Reglas de publicación
Propongo las siguientes reglas de negocio:
Regla	Comportamiento
RN-CL-01	Solo administradores y coaches autorizados publican clases.
RN-CL-02	La programación puede guardarse como borrador, programarse o publicarse inmediatamente.
RN-CL-03	Una clase puede reutilizar una plantilla, pero conserva su propia versión publicada.
RN-CL-04	Solo atletas con membresía activa y acceso autorizado ven las clases privadas del box.
RN-CL-05	Al publicar, se generan notificaciones para los destinatarios elegibles de ese box, respetando sus preferencias.
RN-CL-06	Si un atleta pertenece a tres boxes, puede consultar las clases publicadas de los tres, sin fusionar sus calendarios internos.
RN-CL-07	Las modificaciones importantes después de la publicación pueden generar una alerta de actualización.
RN-CL-08	Las notificaciones se deduplican por publicación y destinatario.
RN-CL-09	Los resultados del atleta siempre permanecen asociados a su identidad deportiva.
RN-CL-10	La hora de publicación se interpreta según la zona horaria de la sede del box.

La programación debe diferenciar tres conceptos: plantilla de entrenamiento, programación del día y sesión de clase en un horario específico. Por ejemplo, el mismo WOD puede ser impartido a las 6:00 a. m., 7:00 a. m. y 6:00 p. m. sin tener que crearlo tres veces.
3.4. Ejemplo de notificación

Box Alpha
Ahora
¡La programación de mañana está disponible!

Enfoque: Fuerza + Gimnasia. Back Squat al 80%, progresiones de HSPU y AMRAP 10. Consulta la clase y prepárate.



Para que esta función sea confiable, una publicación debe persistirse primero en la base de datos. Después, un proceso de notificaciones procesa los destinatarios sin bloquear la publicación. Si falla el envío push, el atleta aún podrá encontrar la clase y la notificación dentro de la aplicación.
3.5. Criterios de aceptación de programación
Una entrega de este módulo se considerará aprobada cuando:
1. Un coach autorizado pueda crear, editar, previsualizar y publicar una programación.
2. El sistema admita al menos cinco bloques y múltiples ejercicios por bloque.
3. Se pueda programar una publicación futura y verificar que no sea visible antes de su fecha.
4. Los atletas autorizados reciban un aviso y encuentren la programación en la aplicación.
5. Los cálculos de porcentaje de RM utilicen la marca personal correcta de cada atleta.
6. Un atleta inscrito en dos boxes pueda consultar ambas programaciones sin confundir sedes o entrenadores.
7. La edición posterior conserve trazabilidad y no genere notificaciones duplicadas.
8. La publicación de un box no sea accesible por usuarios sin autorización.

4. Gestión deportiva: fuerza, gimnasia y WOD
Este módulo estará desacoplado de las organizaciones.
4.1. Movimientos y métricas
Movimiento	Métrica principal	Métricas complementarias
Snatch	Carga máxima	Reps, intentos, variante
Clean & Jerk	Carga máxima	Reps, técnica
Back Squat	RM	Series, RPE, volumen
Deadlift	RM	Series, repeticiones
Pull-up	Repeticiones	Estrictas, kipping, lastre
Muscle-up	Repeticiones	Ring/bar, asistencia
Handstand Walk	Distancia	Tiempo, tramos
L-Sit	Tiempo	Variante, asistencia
Row	Tiempo o distancia	Ritmo, calorías
Fran	Tiempo	RX/Scaled, peso
AMRAP	Rondas y repeticiones	Duración, categoría

Cada ejercicio tendrá una definición de mediciones permitidas. Así evitaremos registrar resultados incompatibles, como aplicar automáticamente fórmulas de 1RM a ejercicios de resistencia o gimnasia.
4.2. Registro de RM y progreso
Ejemplo: evolución de Back Squat
Serie de datos ilustrativa · 1RM real en kg


60 kg80 kg100 kg120 kg140 kgEneFebMarAbrMayJunJulAgo









Valores de demostración, no registros reales.





Primer registro80 kg

Récord actual120 kg

Progresión+50%



El sistema debe distinguir entre marcas reales, estimadas, resultados con lastre y resultados asistidos. Además, un PR no se convertirá en una marca certificada simplemente por haber sido registrado: la validación por coach podría incorporarse posteriormente.
4.3. Objetivos
Un objetivo puede ser:
- Numérico: alcanzar 140 kg de Back Squat.
- Temporal: completar Fran en menos de cuatro minutos.
- Por habilidad: conseguir el primer Ring Muscle-up.
- Por volumen: realizar 20 pull-ups estrictas consecutivas.
- Por constancia: completar 16 sesiones durante un mes.
Cada meta tendrá fecha de creación, valor inicial, valor objetivo, fecha prevista opcional, estado e hitos. Los objetivos asociados a movimientos registrados podrán actualizar su progreso automáticamente; los relacionados con habilidades podrán requerir confirmación del atleta.

5. Roles, usuarios y permisos
La identidad de una persona será única en toda la plataforma, pero podrá tener roles diferentes en distintas organizaciones.

Ejemplo: una persona puede ser atleta del Box Alpha, coach del Box Beta y administrador del Box Gamma.
5.1. Roles propuestos
Rol	Responsabilidades
Superadministrador	Configuración global, catálogos, soporte y control de plataforma
Propietario de box	Administración de la organización, plan, sedes y responsables
Administrador de box	Miembros, roles, programación, anuncios y configuración
Coach	Crear clases, publicar programaciones, consultar datos deportivos autorizados
Atleta	Gestionar su historial, consultar programaciones y participar en boxes
Visitante	Consultar información pública y solicitar inscripción

El rol Superadministrador no implica acceso irrestricto a datos privados de atletas. Las operaciones excepcionales de soporte deben estar justificadas y auditadas.
5.2. Matriz de permisos
Funcionalidad	Atleta	Coach	Admin box
Registrar resultados propios	Sí	Sí	Sí
Consultar clases publicadas	Sí	Sí	Sí
Crear programación	No	Sí	Sí
Publicar programación	No	Sí*	Sí
Publicar anuncios	No	Sí*	Sí
Gestionar miembros	No	No	Sí
Gestionar roles	No	No	Sí
Consultar RM de otros atletas	Con permiso	Con permiso	Con permiso
Configurar la organización	No	No	Sí

* Permisos configurables por organización. La consulta de información privada requiere autorización específica, además del rol.6. Flujos de usuario
Flujo A. Registro de atleta independiente
1. El usuario crea su cuenta y verifica su correo electrónico.
2. Configura su perfil deportivo, unidades de peso y disciplinas de interés.
3. Selecciona sus objetivos iniciales.
4. Registra sus primeras marcas o decide completarlas después.
5. Accede al dashboard y comienza a registrar entrenamientos.
6. Posteriormente puede buscar boxes sin perder sus datos.
Flujo B. Vinculación a múltiples boxes
1. El atleta busca un box por nombre, código o enlace de invitación.
2. Consulta su información pública y solicita ingreso.
3. El administrador aprueba la solicitud o el sistema acepta una invitación válida.
4. Se crea la membresía con su respectivo rol y estado.
5. El atleta comienza a recibir programaciones y anuncios autorizados.
6. Puede seleccionar un box principal sin perder acceso a los demás.
Flujo C. Programación anticipada de clases
1. El coach entra al panel de programación de su organización.
2. Selecciona una fecha, sede y grupo de clases.
3. Elige el enfoque deportivo y construye los bloques de entrenamiento.
4. Registra movimientos, cargas, series, tiempos, niveles y recomendaciones.
5. Previsualiza cómo verán la programación los atletas.
6. Define publicación inmediata o programada, por ejemplo, el día anterior a las 6:00 p. m.
7. El sistema publica la programación y genera notificaciones.
8. Los atletas consultan la clase, revisan sus cargas y llegan preparados.
Flujo D. Registro de resultados después de entrenar
Al finalizar una clase, el atleta entra a su programación y selecciona Registrar resultados.

El sistema crea un borrador de sesión con los movimientos de la clase y permite completar las series, cargas, tiempos y resultados reales. Al guardar, actualiza el historial y recalcula los récords, sin modificar el resultado original de la programación ni los registros de otros atletas.

7. Arquitectura técnica definitiva
Recomiendo mantener Flutter como tecnología principal de presentación y usar Supabase como plataforma de backend para la primera etapa.

La recomendación se apoya en la compatibilidad multiplataforma de Flutter y en su arquitectura por capas, así como en la integración de Supabase con Flutter, PostgreSQL y políticas de seguridad a nivel de fila. 
docs.flutter.dev+3

Arquitectura lógica de la plataforma
Capa de clientes Flutter
Android


iOS


Web



Riverpod · GoRouter · Repositorios · Caché local

Backend y lógica de negocio
Autenticación


Rendimiento y RM


Organizaciones


Programación


Objetivos y progreso


Notificaciones


Planes y permisos


Auditoría



Supabase Auth · PostgREST · RPC · Edge Functions

Persistencia y servicios

PostgreSQL + RLS · Supabase Storage · Realtime · Cron


Integraciones externas

FCM · APNs · Pagos · Analítica · Monitoreo


7.1. Estructura Flutter propuesta
Utilizaría una arquitectura feature-first, con componentes de presentación, dominio y datos organizados por funcionalidad.
fitness_platform/
├── apps/
│   └── fitness_app/
│       ├── lib/
│       │   ├── app/
│       │   │   ├── app.dart
│       │   │   ├── router/
│       │   │   └── theme/
│       │   ├── core/
│       │   │   ├── config/
│       │   │   ├── errors/
│       │   │   ├── networking/
│       │   │   ├── storage/
│       │   │   └── utils/
│       │   ├── features/
│       │   │   ├── authentication/
│       │   │   ├── athletes/
│       │   │   ├── exercises/
│       │   │   ├── performances/
│       │   │   ├── personal_records/
│       │   │   ├── workouts/
│       │   │   ├── goals/
│       │   │   ├── organizations/
│       │   │   ├── memberships/
│       │   │   ├── programming/
│       │   │   ├── announcements/
│       │   │   ├── notifications/
│       │   │   ├── analytics/
│       │   │   └── subscriptions/
│       │   └── shared/
│       │       ├── widgets/
│       │       └── extensions/
│       ├── test/
│       ├── integration_test/
│       ├── android/
│       ├── ios/
│       └── web/
├── packages/
│   ├── design_system/
│   └── domain_models/
└── supabase/
    ├── migrations/
    ├── functions/
    ├── seed.sql
    └── tests/


Dentro de cada módulo implementaría la misma estructura general:
features/programming/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/
│   └── usecases/
└── presentation/
    ├── controllers/
    ├── screens/
    └── widgets/


Esto permitirá trabajar en programación de clases, registros deportivos o membresías sin mezclar la lógica de un módulo con otro.
7.2. Dependencias propuestas
Responsabilidad	Tecnología
Estado y dependencias	flutter_riverpod
Navegación	go_router
Backend	supabase_flutter
Modelos inmutables	freezed / json_serializable
Base de datos local	drift
Gráficas	fl_chart
Fechas e internacionalización	intl
Notificaciones	firebase_messaging
Manejo de permisos	permission_handler
Errores y observabilidad	Sentry
Pruebas	Flutter Test / Integration Test

Las versiones exactas se fijarán y verificarán durante la inicialización del repositorio, en lugar de introducir dependencias con versiones supuestas.
7.3. Decisiones de diseño relevantes
Offline-first deportivo: las sesiones, marcas y resultados podrán almacenarse localmente para sincronizarse después. La publicación de clases, cambios de roles y operaciones de pago requerirán conexión. Flutter documenta patrones de repositorios para unificar fuentes locales y remotas. 
docs.flutter.dev


Notificaciones: utilizaría Firebase Cloud Messaging para Android y web compatible, y FCM integrado con APNs para iOS. La configuración de iOS requiere capacidades de notificaciones y ajustes específicos de Xcode. 
Firebase


Publicaciones programadas: una tarea de Supabase Cron procesará las programaciones pendientes y activará una Edge Function con control de concurrencia. La plataforma admite este mecanismo mediante pg_cron y funciones programadas. 
Supabase Docs


Seguridad: no confiar únicamente en controles de interfaz. El aislamiento entre organizaciones se realizará mediante políticas RLS y validaciones transaccionales para las operaciones sensibles.

8. Modelo de datos relacional
La base de datos se diseñará en PostgreSQL, con UUID como identificador principal y columnas de auditoría.

La autenticación se apoyará en auth.users, mientras que el resto de información de negocio estará en tablas propias.
8.1. Dominio de identidad y organizaciones
Tabla	Campos principales
profiles	id, display_name, avatar_url, created_at
athlete_profiles	user_id, experience_level, preferred_unit, primary_sport
organizations	id, name, slug, status, owner_user_id
organization_locations	id, organization_id, name, timezone, address
organization_members	id, organization_id, user_id, role, status, joined_at
organization_invitations	id, organization_id, token_hash, expires_at, status
organization_permissions	organization_id, role, permission_code
organization_announcements	id, organization_id, author_id, title, body, published_at

Regla de integridad: una misma persona no debe tener dos membresías activas duplicadas en la misma organización. Una restricción única sobre (organization_id, user_id) garantizará esa condición.
8.2. Dominio deportivo
Tabla	Campos principales
exercises	id, name, category, metric_type, status
exercise_variants	id, exercise_id, name, variant_type
exercise_metric_definitions	id, exercise_id, metric_code, value_type, unit
workout_sessions	id, athlete_id, organization_id nullable, performed_at, status
workout_exercises	id, session_id, exercise_id, variant_id
performance_sets	id, workout_exercise_id, set_number, weight_kg, reps, duration_ms, rpe
performance_attempts	id, workout_exercise_id, target_weight_kg, success, performed_at
personal_records	id, athlete_id, exercise_id, record_type, result_id, achieved_at
goals	id, athlete_id, exercise_id nullable, metric_code, target_value, status
goal_milestones	id, goal_id, achieved_value, achieved_at

Los pesos se almacenarán en una unidad canónica, por ejemplo kilogramos, usando NUMERIC y convirtiéndolos para presentación. Los tiempos se almacenarán como duraciones enteras, evitando errores de precisión.

Los récords serán índices derivados del historial; no deben ser la única fuente de verdad. Si un usuario corrige un resultado anterior, el sistema debe poder recalcular el PR.
8.3. Dominio de programación de clases
Esta es la parte más importante de la estructura relacional para tu nuevo requerimiento.
Tabla	Responsabilidad
program_templates	Plantillas de clases reutilizables
program_template_blocks	Bloques de una plantilla
class_programs	Programación deportiva de una fecha o período
class_program_versions	Versiones y modificaciones
class_program_blocks	Warm-up, Strength, Skill, WOD, etc.
class_block_exercises	Movimientos de cada bloque
class_sessions	Horarios específicos asociados al programa
class_session_coaches	Coaches responsables
class_program_audiences	Destinatarios elegibles
class_publication_events	Historial de publicación
athlete_class_results	Resultados realizados por atleta
notification_deliveries	Entregas por destinatario y canal

Relaciones principales
Modelo conceptual simplificado
#chatgpt-mermaid-_r_pc_{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,Segoe UI,Helvetica,Apple Color Emoji,Arial,sans-serif,Segoe UI Emoji,Segoe UI Symbol;font-size:16px;fill:rgb(237, 237, 237);}@keyframes edge-animation-frame{from{stroke-dashoffset:0;}}@keyframes dash{to{stroke-dashoffset:0;}}#chatgpt-mermaid-_r_pc_ .edge-animation-slow{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 50s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-_r_pc_ .edge-animation-fast{stroke-dasharray:9,5!important;stroke-dashoffset:900;animation:dash 20s linear infinite;stroke-linecap:round;}#chatgpt-mermaid-_r_pc_ .error-icon{fill:rgb(48, 48, 48);}#chatgpt-mermaid-_r_pc_ .error-text{fill:rgb(237, 237, 237);stroke:rgb(237, 237, 237);}#chatgpt-mermaid-_r_pc_ .edge-thickness-normal{stroke-width:1px;}#chatgpt-mermaid-_r_pc_ .edge-thickness-thick{stroke-width:3.5px;}#chatgpt-mermaid-_r_pc_ .edge-pattern-solid{stroke-dasharray:0;}#chatgpt-mermaid-_r_pc_ .edge-thickness-invisible{stroke-width:0;fill:none;}#chatgpt-mermaid-_r_pc_ .edge-pattern-dashed{stroke-dasharray:3;}#chatgpt-mermaid-_r_pc_ .edge-pattern-dotted{stroke-dasharray:2;}#chatgpt-mermaid-_r_pc_ .marker{fill:rgb(175, 175, 175);stroke:rgb(175, 175, 175);}#chatgpt-mermaid-_r_pc_ .marker.cross{stroke:rgb(175, 175, 175);}#chatgpt-mermaid-_r_pc_ svg{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,Segoe UI,Helvetica,Apple Color Emoji,Arial,sans-serif,Segoe UI Emoji,Segoe UI Symbol;font-size:16px;}#chatgpt-mermaid-_r_pc_ p{margin:0;}#chatgpt-mermaid-_r_pc_ .entityBox{fill:rgb(19, 33, 54);stroke:rgb(31, 78, 148);}#chatgpt-mermaid-_r_pc_ .relationshipLabelBox{fill:rgb(48, 48, 48);opacity:0.7;background-color:rgb(48, 48, 48);}#chatgpt-mermaid-_r_pc_ .relationshipLabelBox rect{opacity:0.5;}#chatgpt-mermaid-_r_pc_ .labelBkg{background-color:rgba(48, 48, 48, 0.5);}#chatgpt-mermaid-_r_pc_ .edgeLabel{background-color:rgb(14, 14, 14);}#chatgpt-mermaid-_r_pc_ .edgeLabel .label rect{fill:rgb(14, 14, 14);}#chatgpt-mermaid-_r_pc_ .edgeLabel .label text{fill:rgb(237, 237, 237);}#chatgpt-mermaid-_r_pc_ .edgeLabel .label{fill:rgb(31, 78, 148);font-size:14px;}#chatgpt-mermaid-_r_pc_ .label{font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,Segoe UI,Helvetica,Apple Color Emoji,Arial,sans-serif,Segoe UI Emoji,Segoe UI Symbol;color:rgb(237, 237, 237);}#chatgpt-mermaid-_r_pc_ .edge-pattern-dashed{stroke-dasharray:8,8;}#chatgpt-mermaid-_r_pc_ .node rect,#chatgpt-mermaid-_r_pc_ .node circle,#chatgpt-mermaid-_r_pc_ .node ellipse,#chatgpt-mermaid-_r_pc_ .node polygon{fill:rgb(19, 33, 54);stroke:rgb(31, 78, 148);stroke-width:1px;}#chatgpt-mermaid-_r_pc_ .relationshipLine{stroke:rgb(175, 175, 175);stroke-width:1px;fill:none;}#chatgpt-mermaid-_r_pc_ .marker{fill:none!important;stroke:rgb(175, 175, 175)!important;stroke-width:1;}#chatgpt-mermaid-_r_pc_ [data-look=neo].labelBkg{background-color:rgba(48, 48, 48, 0.5);}#chatgpt-mermaid-_r_pc_ .node .neo-node{stroke:rgb(31, 78, 148);}#chatgpt-mermaid-_r_pc_ [data-look="neo"].node rect,#chatgpt-mermaid-_r_pc_ [data-look="neo"].cluster rect,#chatgpt-mermaid-_r_pc_ [data-look="neo"].node polygon{stroke:url(#chatgpt-mermaid-_r_pc_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-_r_pc_ [data-look="neo"].swimlane.cluster rect{filter:none;}#chatgpt-mermaid-_r_pc_ [data-look="neo"].node path{stroke:url(#chatgpt-mermaid-_r_pc_-gradient);stroke-width:1px;}#chatgpt-mermaid-_r_pc_ [data-look="neo"].node .outer-path{filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-_r_pc_ [data-look="neo"].node .neo-line path{stroke:rgb(31, 78, 148);filter:none;}#chatgpt-mermaid-_r_pc_ [data-look="neo"].node circle{stroke:url(#chatgpt-mermaid-_r_pc_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-_r_pc_ [data-look="neo"].node circle .state-start{fill:#000000;}#chatgpt-mermaid-_r_pc_ [data-look="neo"].icon-shape .icon{fill:url(#chatgpt-mermaid-_r_pc_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-_r_pc_ [data-look="neo"].icon-shape .icon-neo path{stroke:url(#chatgpt-mermaid-_r_pc_-gradient);filter:drop-shadow( 1px 2px 2px rgba(185,185,185,1));}#chatgpt-mermaid-_r_pc_ :root{--mermaid-font-family:-apple-system-body,ui-sans-serif,-apple-system,system-ui,Segoe UI,Helvetica,Apple Color Emoji,Arial,sans-serif,Segoe UI Emoji,Segoe UI Symbol;}PROFILESATHLETE_PROFILESORGANIZATION_MEMBERSORGANIZATIONSORGANIZATION_LOCATIONSCLASS_PROGRAMSCLASS_PROGRAM_VERSIONSCLASS_SESSIONSCLASS_PROGRAM_BLOCKSCLASS_BLOCK_EXERCISESEXERCISESWORKOUT_SESSIONSPERFORMANCE_SETSPERSONAL_RECORDSGOALSATHLETE_CLASS_RESULTShasjoinscontainshaspublishesversionsschedulescontainscontainsreferenced_byrecordscontainsachievespursuesreceivessubmits





Diagrama lógico de alto nivel. Las tablas intermedias, claves compuestas y relaciones de resultados se detallarán en las migraciones SQL.
8.4. Estados de una programación
1

Borrador

Editable y no visible para atletas



2

Programada

Esperando fecha de publicación



3

Publicada

Visible para destinatarios autorizados



4

Actualizada

Nueva versión publicada y trazable



5

Cancelada

No disponible para nuevas sesiones



Actualizada se entenderá preferiblemente como un evento o una nueva versión de una programación publicada, no como un estado que elimine la condición de publicación. Una clase también podrá cancelarse directamente desde Programada.
8.5. Transacción de publicación
Una programación futura no debe publicarse mediante un temporizador del teléfono del coach.

La operación será gestionada en servidor:
1. Buscar programas cuya fecha de publicación ya se cumplió.
2. Bloquear o reclamar atómicamente cada publicación pendiente para evitar doble ejecución.
3. Confirmar que la versión y la organización siguen activas.
4. Cambiar el estado a published y registrar el evento.
5. Insertar un evento en una tabla de salida (outbox).
6. Resolver destinatarios autorizados y crear notificaciones persistentes.
7. Despachar notificaciones push de manera asíncrona y registrar sus resultados.
El procesamiento debe ser idempotente. Una restricción única por evento, usuario y canal evitará duplicados incluso si el proceso se reintenta después de un error.

Además, las notificaciones podrán configurarse para enviarse en el momento de la publicación, al día anterior o antes del inicio de la clase. No se garantizará la recepción instantánea del push porque depende también del dispositivo y del servicio de mensajería.

9. Diseño de pantallas y navegación
Para las tres plataformas utilizaremos una misma base de componentes, con una interfaz adaptable a pantallas móviles y escritorio.

En móvil, el registro de entrenamientos debe tener prioridad. En web, el espacio adicional se aprovechará para calendarios, tablas, edición de programaciones y estadísticas.
9.1. Pantallas del atleta
Código	Pantalla	Funcionalidad
ATH-01	Bienvenida y registro	Inicio de sesión, onboarding
ATH-02	Inicio	Resumen, clase próxima, objetivos y PR
ATH-03	Mi calendario	Programaciones de todos los boxes
ATH-04	Detalle de clase	Enfoque, bloques, movimientos, recomendaciones
ATH-05	Entrenar	Crear y registrar sesiones
ATH-06	Catálogo de movimientos	Buscar ejercicios y variantes
ATH-07	Detalle de movimiento	Historial, PR y progresión
ATH-08	Mis récords	Tabla de marcas personales
ATH-09	Mis objetivos	Crear metas y consultar evolución
ATH-10	Estadísticas	Gráficas e indicadores
ATH-11	Mis boxes	Organizaciones vinculadas
ATH-12	Explorar boxes	Buscar y solicitar ingreso
ATH-13	Comunicados	Publicaciones de organizaciones
ATH-14	Notificaciones	Inbox de actividades
ATH-15	Mi perfil	Información y preferencias

9.2. Pantallas del box y del coach
Código	Pantalla	Funcionalidad
BOX-01	Dashboard	Actividad, próximas clases y miembros
BOX-02	Calendario semanal	Visualizar y organizar programaciones
BOX-03	Editor de programación	Crear y editar clases
BOX-04	Biblioteca de plantillas	Guardar sesiones reutilizables
BOX-05	Gestión de horarios	Horarios, sedes y coaches
BOX-06	Publicaciones	Programaciones pendientes y publicadas
BOX-07	Gestión de atletas	Solicitudes, membresías y roles
BOX-08	Anuncios	Comunicados y noticias internas
BOX-09	Resultados de clases	Consultar registros compartidos
BOX-10	Configuración	Datos, permisos y sedes
BOX-11	Plan y facturación	Suscripción y funcionalidades contratadas

9.3. Navegación propuesta
Navegación principal del atleta
Inicio


Entrenar


Clases


Progreso


Perfil




Menú lateral de administración web
Dashboard


Programación


Atletas


Comunicados


Resultados


Configuración




9.4. Pantalla principal del atleta
La primera pantalla mostrará prioritariamente:
- Próxima clase y box de procedencia.
- Enfoque deportivo del entrenamiento.
- Acceso para ver y registrar resultados.
- Objetivos activos y su avance.
- Últimos récords personales.
- Notificaciones importantes de los boxes.
Cuando el usuario pertenezca a varios boxes, tendrá un selector para ver un box individual o la agenda consolidada, identificando claramente el origen de cada clase.

10. Modelo comercial híbrido
Propondría un esquema de monetización con tres tipos de productos. Los precios quedan pendientes de validación comercial.
Característica	Atleta Free	Atleta Premium	Box Pro
Registro de entrenamientos	Sí	Sí	—
Historial y RM	Sí	Sí	—
Objetivos básicos	Sí	Sí	—
Asociación a múltiples boxes	Sí	Sí	—
Recibir clases y anuncios	Sí	Sí	Para miembros
Estadísticas avanzadas	Limitadas	Sí	Agregadas
Comparativas históricas avanzadas	Limitadas	Sí	Según permiso
Exportación avanzada de datos	Básica	Sí	Según permiso
Gestión de programación	—	—	Sí
Gestión de miembros	—	—	Sí
Publicación anticipada	—	—	Sí
Plantillas avanzadas	—	—	Sí
Panel administrativo	—	—	Sí

Decisión recomendada: las funciones esenciales del atleta —registrar entrenamientos, consultar sus RM, conservar su historial y recibir clases— deben seguir siendo gratuitas.

El modelo Premium debe aportar herramientas avanzadas y comodidad, no restringir el acceso a los datos que el usuario ya registró.
Arquitectura comercial
Se añadirán estas entidades:
- plans: catálogo de planes.
- plan_features: capacidades de cada plan.
- subscriptions: suscripciones de atletas u organizaciones.
- subscription_events: renovaciones, cambios y cancelaciones.
- billing_accounts: datos de facturación.
- payment_provider_events: eventos verificados de pasarela.
- entitlements: permisos efectivos derivados de planes.
Los permisos comerciales se comprobarán en el backend, no solo ocultando botones en Flutter.

Para Premium digital dentro de las aplicaciones móviles, se deben contemplar las reglas de compras y suscripciones de las tiendas. Apple, por ejemplo, exige compra integrada para determinadas funcionalidades digitales y contempla condiciones especiales para servicios multiplataforma y ventas empresariales. 
Apple Developer


La implementación exacta de pagos deberá distinguir entre suscripciones personales, software empresarial para boxes y eventuales pagos por clases presenciales.

11. Requisitos no funcionales y seguridad
Estos valores serán objetivos iniciales de diseño, no características ya medidas.
Categoría	Objetivo propuesto
Disponibilidad	99,9% mensual para el servicio de producción
Rendimiento	Consultas comunes con p95 menor a 800 ms de procesamiento de backend bajo carga objetivo
Publicación programada	Activación dentro de 60 segundos de la hora establecida, bajo operación normal
Escalabilidad	Validar inicialmente 10.000 atletas registrados y 100 boxes
Compatibilidad	Android, iOS y navegadores soportados por Flutter
Seguridad	TLS, RLS, mínimo privilegio y aislamiento de organizaciones
Auditoría	Registrar operaciones críticas y cambios de programación
Persistencia	Backups automáticos y pruebas de restauración
Accesibilidad	Objetivo WCAG 2.2 AA en flujos principales
Offline	Captura local de entrenamientos con sincronización posterior
Calidad	Pruebas automatizadas, CI/CD y entornos separados

Reglas críticas de seguridad
Aislamiento multi-tenant. Cada organización tendrá un organization_id y las políticas RLS comprobarán la membresía y los permisos del usuario. La existencia de un identificador de organización en una solicitud no debe otorgar acceso por sí misma.

Privacidad deportiva. El atleta decidirá si comparte sus marcas con coaches y miembros de cada box. Se definirán permisos diferenciados para historial, objetivos y resultados públicos.

Historial protegido. Una organización no podrá borrar o apropiarse de los registros personales del atleta cuando este se desvincule. La retención de resultados compartidos en competiciones o clases se establecerá mediante políticas claras.

Publicaciones auditables. Crear, publicar, cancelar y modificar una programación debe registrar responsable, fecha, versión y detalle del cambio.

Sincronización confiable. Los registros offline usarán identificadores únicos de operación para impedir duplicados, con manejo de conflictos por versión y sin sobrescribir silenciosamente datos de otro dispositivo.

12. Roadmap de implementación
Propongo organizar el desarrollo en siete etapas. La duración es una estimación de planificación para un equipo pequeño con experiencia en Flutter y backend; debe recalcularse según la disponibilidad real de desarrolladores, diseñadores y testers.
01



Fundamentos y diseño

Semanas 1–2

Diseño UX/UI, arquitectura, repositorio, autenticación, esquema base, CI/CD y design system.


02



Motor deportivo

Semanas 3–6

Catálogo de movimientos, registro de series, RM, récords, objetivos e historial.


03



Organizaciones

Semanas 7–9

Creación de boxes, roles, membresías múltiples, solicitudes e invitaciones.


04



Programación y clases

Semanas 10–13

Editor de clases, plantillas, calendario, publicación, destinatarios y notificaciones.


05



Integración deportiva

Semanas 14–15

Cargas personalizadas, registro desde clases, anuncios y pruebas multi-box.


06



Calidad y lanzamiento

Semanas 16–19

Seguridad, pruebas E2E, accesibilidad, monitoreo, rendimiento y distribución en Android, iOS y web.


07


Monetización avanzada

Después del MVP

Planes de pago, analítica Premium, reservas, rankings y nuevas funciones comunitarias.



Horizonte orientativo: 19 semanas para el MVP completo, suponiendo recursos suficientes y ausencia de bloqueos importantes. La publicación en tiendas depende también de los procesos de revisión externos.

13. Backlog priorizado
Este backlog es la propuesta inicial para alimentar Jira, GitHub Projects u otra herramienta de gestión ágil.
Backlog del proyecto
26 historias · estimación preliminar
 Copiar CSV
PrioridadTodos


FaseTodas



FIT-001 · Plataforma
5 SP
P0


Inicializar monorepositorio Flutter y entornos


FIT-002 · Identidad
5 SP
P0


Autenticación y recuperación de cuenta


FIT-003 · Atletas
3 SP
P0


Perfil deportivo y preferencias


FIT-004 · Rendimiento
5 SP
P0


Catálogo de movimientos y variantes


FIT-005 · Rendimiento
8 SP
P0


Registro de series y resultados


FIT-006 · Rendimiento
8 SP
P0


Cálculo y mantenimiento de RM y PR


FIT-007 · Rendimiento
5 SP
P0


Historial y gráficos deportivos


FIT-008 · Objetivos
5 SP
P0


Gestión de objetivos personales


FIT-009 · WOD
8 SP
P0


Registro de WOD y resultados


FIT-010 · Boxes
5 SP
P0


Crear y administrar organizaciones


FIT-011 · Boxes
8 SP
P0


Membresías multi-box, invitaciones y roles


FIT-012 · Programación
5 SP
P0


Sedes, grupos y horarios de clase


FIT-013 · Programación
13 SP
P0


Editor estructurado de programación


FIT-014 · Programación
5 SP
P0


Plantillas y reutilización de clases


FIT-015 · Programación
8 SP
P0


Publicación inmediata y programada


FIT-016 · Notificaciones
8 SP
P0


Notificaciones push e inbox


FIT-017 · Programación
8 SP
P0


Calendario y detalle de clases del atleta


FIT-018 · Rendimiento
5 SP
P0


Cargas personalizadas basadas en RM


FIT-019 · WOD
8 SP
P0


Registro deportivo desde una clase


FIT-020 · Comunidad
5 SP
P0


Anuncios de organizaciones


FIT-021 · Seguridad
8 SP
P0


Pruebas RLS multi-tenant y auditoría


FIT-022 · Plataforma
13 SP
P0


Pruebas de integración y despliegue


FIT-023 · Comercial
13 SP
P1


Suscripciones y entitlements


FIT-024 · Programación
8 SP
P1


Reservas y cupos de clases


FIT-025 · Analítica
8 SP
P1


Estadísticas Premium y comparativas


FIT-026 · Plataforma
13 SP
P1


Sincronización offline de registros


Estimación filtrada
193 SP

Story points orientativos sujetos al refinamiento técnico. No equivalen directamente a horas o semanas.

Historias de usuario críticas
HU-013 · Crear una programación de clase

Como coach, quiero estructurar una clase con bloques y ejercicios para que mis atletas conozcan exactamente qué van a entrenar.

Aceptación: permite crear, editar, ordenar, guardar como borrador y previsualizar todos los bloques de entrenamiento.


HU-015 · Publicación anticipada

Como coach, quiero definir una fecha y hora de publicación para que la programación llegue automáticamente a los atletas antes de la clase.

Aceptación: se publica en servidor en el momento programado, registra auditoría y crea las notificaciones sin duplicados.


HU-017 · Consultar clases de múltiples boxes

Como atleta, quiero consultar la agenda de mis organizaciones para organizar mi entrenamiento sin tener que entrar por separado a cada box.

Aceptación: se muestran únicamente las clases autorizadas de las organizaciones activas y cada clase identifica su procedencia.


HU-018 · Calcular las cargas de trabajo

Como atleta, quiero consultar el peso correspondiente al porcentaje de mi RM indicado por el coach para preparar mi entrenamiento correctamente.

Aceptación: se usa el RM del movimiento y variante correctos, se indica el origen de la marca, y se muestra una advertencia cuando no existe información suficiente.


HU-019 · Registrar resultados desde una clase

Como atleta, quiero registrar mi desempeño directamente desde la programación de hoy para actualizar automáticamente mis resultados y mi historial.

Aceptación: se puede crear la sesión desde la clase sin duplicar entrenamientos por reintentos y se recalculan los récords cuando corresponde.



14. Estrategia de pruebas y entrega
Antes del lanzamiento deberán cubrirse los siguientes escenarios:
Área	Prueba obligatoria
Identidad	Registro, inicio, cierre y recuperación de sesión
Multi-box	Un atleta en dos organizaciones con roles diferentes
Seguridad	Intento de leer o editar datos de una organización ajena
RM	Conversión kg/lb y diferenciación entre real y estimado
Programación	Creación, edición, publicación diferida y cancelación
Notificaciones	Usuario con varios dispositivos y varios boxes
Concurrencia	Dos procesos intentando publicar la misma clase
Historial	Corrección de un resultado y recálculo de un PR
Offline	Registro local y sincronización sin duplicados
Plataforma	Pruebas E2E en Android, iOS y web
Facturación	Activación, vencimiento y pérdida de derechos Premium

El desarrollo tendrá entornos development, staging y production, con migraciones SQL versionadas, pruebas de políticas RLS y despliegues controlados.
15. Resultado esperado del MVP
Al finalizar la primera etapa, deberíamos poder ejecutar de principio a fin este escenario:
Escenario integral de validación

1. Un atleta crea su cuenta, registra sus marcas de fuerza y define dos objetivos deportivos.
2. Se vincula a Box Alpha y Box Beta con una única cuenta.
3. Un coach de Box Alpha prepara la programación del viernes y decide publicarla el jueves a las 6:00 p. m.
4. El jueves, el sistema publica la clase y genera las notificaciones para los atletas autorizados.
5. El atleta recibe la alerta, consulta la clase y ve las cargas de trabajo calculadas con sus RM.
6. Al finalizar, registra resultados, actualiza sus marcas y visualiza el progreso de sus objetivos.
7. Posteriormente consulta la programación de Box Beta, sin perder el historial creado durante su entrenamiento en Box Alpha.

Si este recorrido funciona correctamente en Android, iOS y web, tendremos un producto base con una propuesta de valor clara.
16. Próxima etapa técnica
La arquitectura funcional está definida a nivel de propuesta. Lo que sigue para convertirla en un proyecto ejecutable es:
1. Modelo PostgreSQL detallado: script de creación de tablas, claves foráneas, índices, restricciones, políticas RLS, auditoría y funciones.
2. Contratos de backend: operaciones de membresías, resultados, programación, publicación y notificaciones.
3. Prototipos de interfaz: pantallas móviles y web, navegación, componentes y estados visuales.
4. Backlog de implementación: historias desglosadas en tareas Flutter, SQL, funciones, pruebas y despliegue.
Mi decisión técnica más importante sería construir primero una vertical completa de atleta + box + programación + registro deportivo, antes de ampliar el proyecto a redes sociales, inteligencia artificial o funciones de competición.

Esto nos permitirá comprobar desde una etapa temprana que las tres capacidades esenciales —rendimiento personal, organización de clases y comunicación anticipada— funcionan de forma integrada, que es precisamente lo que puede diferenciar la plataforma.