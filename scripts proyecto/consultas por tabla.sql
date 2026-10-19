
-- consultas por tabla
use colegio_mzo;

-- jornada
-- 1 consultar y listar las jornadas para seleccionar una
select * from jornada order by horainicioJor;
-- 2 jornada que está en curso según la hora actual
select idjornada, nombre from jornada where curtime() between horainicioJor and horafinJor;
-- 3 inasistencias y tasa de ausentismo de cada jornada en un periodo
select j.nombre as jornada,
       count(*) as registros,
       sum(a.categoria = 'FALTO') as inasistencias,
       round(100 * sum(a.categoria = 'FALTO') / count(*), 2) as tasa_ausentismo_pct
from jornada j
join curso c on c.idjornada = j.idjornada
join asistencia a on a.idcurso = c.idcurso
where a.fecha between '2026-08-01' and '2026-08-31'
group by j.idjornada, j.nombre;

-- nivel 
-- 1 consultar y listar los niveles con sus bloques diarios
select * from nivel order by nombre;
-- 2 niveles cuyos bloques configurados no coinciden con cantidadbloques
select n.nombre, b.idjornada, n.cantidadbloques, count(b.idbloque) as bloques_configurados
from nivel n join bloque b on b.idnivel = n.idnivel
group by n.idnivel, n.nombre, n.cantidadbloques, b.idjornada
having count(b.idbloque) <> n.cantidadbloques;

-- curso
-- 1 consultar los cursos registrados
select * from curso;
-- 2 filtrar los cursos del nivel y la jornada seleccionados (primaria, mañana)
select idcurso, nombre, grado from curso
where idnivel = 1 and idjornada = 1 and activo = true order by grado, nombre;
-- 3 cantidad de cursos activos por jornada y nivel
select j.nombre as jornada, n.nombre as nivel, count(c.idcurso) as cursos
from curso c
join jornada j on j.idjornada = c.idjornada
join nivel n on n.idnivel = c.idnivel
where c.activo = true
group by j.idjornada, j.nombre, n.idnivel, n.nombre;
-- 4 seleccionar un curso por nombre, jornada y año
select * from curso where nombre = '601' and idjornada = 1 and aniolectivo = 2026;
-- 5 total de inasistencias de cada curso en un periodo
select c.nombre as curso, count(*) as inasistencias
from curso c join asistencia a on a.idcurso = c.idcurso
where a.categoria = 'FALTO' and a.fecha between '2026-08-01' and '2026-08-31'
group by c.idcurso, c.nombre order by inasistencias desc;

-- bloque
-- 1 consultar los bloques horarios configurados
select * from bloque;
-- 2 filtrar los bloques del nivel y la jornada seleccionados (bachillerato, tarde)
select idbloque, nombre, horainicioBlo, horafinBlo from bloque
where idnivel = 2 and idjornada = 2 order by numero;
-- 3 bloque que está en curso según la hora actual (primaria, mañana)
select idbloque, nombre from bloque
where idnivel = 1 and idjornada = 1 and curtime() between horainicioBlo and horafinBlo;
-- 4 bloques del mismo nivel y jornada con horarios que se cruzan
select b1.idbloque, b1.nombre, b2.idbloque as cruza_con, b2.nombre as nombre_cruce
from bloque b1 join bloque b2
  on b1.idnivel = b2.idnivel and b1.idjornada = b2.idjornada and b1.idbloque < b2.idbloque
 and b1.horainicioBlo < b2.horafinBlo and b2.horainicioBlo < b1.horafinBlo;
-- 5 bloques configurados fuera del horario de su jornada
select b.idbloque, b.nombre, j.nombre as jornada
from bloque b join jornada j on j.idjornada = b.idjornada
where b.horainicioBlo < j.horainicioJor or b.horafinBlo > j.horafinJor;

-- acudiente
-- 1 consultar los acudientes registrados
select * from acudiente;
-- 2 buscar un acudiente por documento para actualizar sus datos
select idacudiente, nombres, apellidos, telefono, correo, direccion
from acudiente where numerodocumentoAcu = '52000000';
-- 3 datos de contacto del acudiente de un estudiante
select a.nombres, a.apellidos, a.parentesco, a.telefono, a.correo
from acudiente a join estudiante e on e.idacudiente = a.idacudiente
where e.idestudiante = 23;
-- 4 acudientes sin correo, a quienes solo se puede contactar por teléfono
select nombres, apellidos, telefono from acudiente where correo is null;

-- estudiante
-- 1 consultar los estudiantes registrados
select * from estudiante;
-- 2 estudiantes que cambiaron de curso (el curso de su asistencia no es el actual)
select distinct e.idestudiante, e.nombres, e.apellidos, s.idcurso as curso_anterior, e.idcurso as curso_actual
from estudiante e join asistencia s on s.idestudiante = e.idestudiante
where s.idcurso <> e.idcurso;
-- 3 estudiantes inactivos que conservan su historial de asistencia
select e.nombres, e.apellidos, count(s.idasistencia) as registros_conservados
from estudiante e left join asistencia s on s.idestudiante = e.idestudiante
where e.activo = false group by e.idestudiante, e.nombres, e.apellidos;
-- 4 novedades sin justificar de cada estudiante desde su última citación
select e.idestudiante, e.nombres, e.apellidos, count(s.idasistencia) as novedades_sin_citar
from estudiante e left join asistencia s
  on s.idestudiante = e.idestudiante and s.categoria <> 'ASISTIO'
 and s.justificada = false and s.idcitacion is null
group by e.idestudiante, e.nombres, e.apellidos order by novedades_sin_citar desc;

-- usuario
-- 1 consultar los usuarios registrados (sin la contraseña)
select idusuario, numerodocumentoUsu, nombres, apellidos, correo, rol, activo from usuario;
-- 2 autenticar al usuario comparando el hash de la contraseña
select idusuario, nombres, rol from usuario
where idusuario = 1 and contrasena = sha2('Clave01*', 256) and activo = true;
-- 3 usuarios por rol asignado
select rol, count(*) as usuarios from usuario group by rol;
-- 4 estado de las cuentas (activas e inactivas)
select activo, count(*) as usuarios from usuario group by activo;
-- 5 coordinadores activos (pueden modificar roles y registros)
select idusuario, nombres, apellidos from usuario where rol = 'COORDINADOR' and activo = true;
-- 6 usuarios inactivos cuyos registros se conservan
select u.nombres, u.apellidos, count(a.idasistencia) as registros
from usuario u left join asistencia a on a.idusuario = u.idusuario
where u.activo = false group by u.idusuario, u.nombres, u.apellidos;

-- citacion
-- 1 consultar las citaciones registradas
select * from citacion;
-- 2 citaciones en estado pendiente
select idcitacion, idestudiante, fechacitacion, motivo from citacion
where estado = 'PENDIENTE' order by fechacitacion;
-- 3 citaciones de un estudiante y su estado
select fechacitacion, motivo, estado from citacion where idestudiante = 26 order by fechacitacion;
-- 4 citaciones realizadas en un periodo
select idcitacion, idestudiante, fechacitacion from citacion
where estado = 'REALIZADA' and fechacitacion between '2026-08-01' and '2026-08-31';
-- 5 fecha de la última citación de cada estudiante
select idestudiante, max(fechacitacion) as ultima_citacion from citacion group by idestudiante;
-- 6 cantidad de citaciones por estado
select estado, count(*) as citaciones from citacion group by estado;

-- asistencia
-- 1 consultar los registros de asistencia
select * from asistencia;
-- 2 categorías de asistencia configuradas
select column_type from information_schema.columns
where table_schema = 'colegio_mzo' and table_name = 'asistencia' and column_name = 'categoria';
-- 3 trazabilidad: fecha, hora y usuario de cada registro
select a.idasistencia, a.fecha_hora_registro, u.nombres, u.apellidos
from asistencia a join usuario u on u.idusuario = a.idusuario order by a.fecha_hora_registro desc;
-- 4 faltas, retardos y evasiones registradas
--    (para ver una sola categoría se deja un solo valor en el IN)
select fecha, categoria, idestudiante, idbloque from asistencia
where categoria in ('FALTO', 'RETARDO', 'EVASION') order by categoria, fecha;
-- 5 justificaciones registradas
select fecha, idestudiante, categoria, justificacion from asistencia
where justificada = true order by fecha;

-- auditoria_asistencia
-- 1 consultar los cambios registrados
select * from auditoria_asistencia;
-- 2 cambios de un curso
select au.fechahora, au.campomodificado, au.valoranterior, au.valornuevo, au.motivo
from auditoria_asistencia au join estudiante e on e.idestudiante = au.idestudiante where e.idcurso = 11;
-- 3 cambios en un rango de fechas
select * from auditoria_asistencia
where fechahora between '2026-08-04 00:00:00' and '2026-08-06 23:59:59';
-- 4 campo modificado con su valor anterior y nuevo
select campomodificado, valoranterior, valornuevo, count(*) as veces
from auditoria_asistencia group by campomodificado, valoranterior, valornuevo;
-- 5 registros eliminados, quién y por qué
select idasistencia, valoranterior, motivo, idusuario, fechahora
from auditoria_asistencia where accion = 'ELIMINAR';