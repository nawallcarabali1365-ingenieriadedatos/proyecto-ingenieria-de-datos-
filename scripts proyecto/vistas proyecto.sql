-- 04 Vistas y procedimientos almacenados
use colegio_mzo;

-- Vista 1: asistencia con todos sus datos 
create or replace view v_asistenciadetalle as
select a.idasistencia,
       a.fecha,
       concat(e.nombres, ' ', e.apellidos) as estudiante,
       c.nombre as curso,
       n.nombre as nivel,
       j.nombre as jornada,
       b.nombre as bloque,
       a.categoria,
       a.justificada,
       a.justificacion,
       concat(u.nombres, ' ', u.apellidos) as registrado_por,
       a.fecha_hora_registro,
       a.idcitacion
from asistencia a
join estudiante e on e.idestudiante = a.idestudiante
join curso c on c.idcurso = a.idcurso
join nivel n on n.idnivel = c.idnivel
join jornada j on j.idjornada = c.idjornada
join bloque b  on b.idbloque = a.idbloque
join usuario u on u.idusuario = a.idusuario;

-- Vista 2: estudiantes que requieren citación 
create or replace view v_alertacitacion as
select e.idestudiante,
       concat(e.nombres, ' ', e.apellidos)  as estudiante,
       c.nombre as curso,
       count(*) as novedades_sin_citar,
       sum(a.categoria = 'FALTO') as faltas,
       sum(a.categoria = 'RETARDO') as retardos,
       sum(a.categoria = 'EVASION') as evasiones,
       concat(ac.nombres, ' ', ac.apellidos) as acudiente,
       ac.parentesco,
       ac.telefono,
       ac.correo
from asistencia a
join estudiante e  on e.idestudiante = a.idestudiante
join curso c on c.idcurso      = e.idcurso
join acudiente ac on ac.idacudiente = e.idacudiente
where a.categoria <> 'ASISTIO'
  and a.justificada = false
  and a.idcitacion is null
group by e.idestudiante, e.nombres, e.apellidos, c.nombre,
         ac.nombres, ac.apellidos, ac.parentesco, ac.telefono, ac.correo
having count(*) >= 3;

-- Vista 3: total de inasistencias por curso y jornada 
create or replace view v_inasistencias_curso as
select c.idcurso,
       c.nombre as curso,
       j.nombre as jornada,
       count(a.idasistencia) as registros,
       sum(a.categoria = 'FALTO') as inasistencias,
       sum(a.categoria = 'RETARDO') as retardos,
       sum(a.categoria = 'EVASION') as evasiones
from curso c
join jornada j on j.idjornada = c.idjornada
join asistencia a on a.idcurso = c.idcurso
group by c.idcurso, c.nombre, j.nombre;

-- Vista 4: tasa de ausentismo por curso, de mayor a menor 
create or replace view v_tasa_ausentismo as
select idcurso,
       curso,
       jornada,
       registros,
       inasistencias,
       round(100 * inasistencias / registros, 2) as tasa_ausentismo_pct
from v_inasistencias_curso
order by tasa_ausentismopct desc;

-- Vista 5: quién cambió qué y por qué 
create or replace view v_auditoriadetalle as
select au.idauditoria,
       au.fechahora,
       concat(u.nombres, ' ', u.apellidos) as responsable,
       u.rol,
       au.accion,
       au.campomodificado,
       au.valoranterior,
       au.valornuevo,
       au.motivo,
       au.idasistencia,
       a.fecha as fecha_asistencia,
       e.idestudiante,
       concat(e.nombres, ' ', e.apellidos) as estudiante,
       c.idcurso,
       c.nombre as curso
from auditoria_asistencia au
join usuario u on u.idusuario = au.idusuario
join estudiante e on e.idestudiante = au.idestudiante
left join asistencia a on a.idasistencia = au.idasistencia
left join curso c on c.idcurso = coalesce(a.idcurso, e.idcurso);