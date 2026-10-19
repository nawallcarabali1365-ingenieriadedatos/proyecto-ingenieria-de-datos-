-- 03 TRIGGERS  para Auditoría 
use colegio_mzo;

-- Tabla de auditoría: Guarda quién modificó o eliminó un registro
drop table if exists auditoria_asistencia;
create table auditoria_asistencia (
    idauditoria int primary key auto_increment not null ,
    accion enum('MODIFICAR','ELIMINAR') not null,
    campomodificado varchar(50)   not null,
    valoranterior varchar(255)  null,
    valornuevo varchar(255)  null,
    motivo varchar(255)  not null,
    fechahora datetime not null default current_timestamp,
    idasistencia  int not null,
    idestudiante int not null,
    idusuario int not null,
    constraint fk_auditoriausuario foreign key (idusuario) references usuario (idusuario)
) ;

create index ix_auditoria_fechahora on auditoria_asistencia (fechahora);

-- Cambios anteriores a la puesta en marcha (datos de prueba)
insert into auditoria_asistencia (accion, campomodificado, valoranterior, valornuevo, motivo, fechahora, idasistencia, idestudiante, idusuario) values
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente presentó incapacidad médica', '2026-08-03 10:35:00', 102, 11, 3),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-03 11:37:00', 282, 29, 1),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-03 22:36:00', 132, 14, 2),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-03 23:42:00', 231, 24, 1),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-04 04:39:00', 472, 48, 3),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-04 08:45:00', 293, 30, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente presentó incapacidad médica', '2026-08-04 08:45:00', 412, 42, 1),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente presentó incapacidad médica', '2026-08-04 12:46:00', 223, 23, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-04 14:48:00', 311, 32, 5),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-04 18:39:00', 134, 14, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-04 20:47:00', 373, 38, 5),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-04 21:45:00', 454, 46, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-04 23:49:00', 473, 48, 2),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-05 01:38:00', 194, 20, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-05 04:39:00', 54, 6, 5),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-05 05:37:00', 304, 31, 3),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-05 05:45:00', 93, 10, 1),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente presentó incapacidad médica', '2026-08-05 08:39:00', 174, 18, 1),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-05 11:45:00', 324, 33, 2),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-05 12:37:00', 146, 15, 4),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-05 12:43:00', 464, 47, 5),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente presentó incapacidad médica', '2026-08-05 13:41:00', 155, 16, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-05 14:40:00', 206, 21, 1),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-05 15:38:00', 396, 40, 3),
  ('MODIFICAR', 'categoria', 'FALTO', 'RETARDO', 'El estudiante llegó después del primer llamado de lista', '2026-08-05 19:45:00', 215, 22, 32),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-05 23:41:00', 245, 25, 1),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-05 23:41:00', 126, 13, 2),
  ('MODIFICAR', 'categoria', 'FALTO', 'RETARDO', 'El estudiante llegó después del primer llamado de lista', '2026-08-05 23:42:00', 25, 3, 41),
  ('MODIFICAR', 'categoria', 'FALTO', 'RETARDO', 'El estudiante llegó después del primer llamado de lista', '2026-08-06 01:50:00', 465, 47, 50),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-06 09:45:00', 196, 20, 2),
  ('MODIFICAR', 'categoria', 'FALTO', 'RETARDO', 'El estudiante llegó después del primer llamado de lista', '2026-08-06 11:43:00', 237, 24, 28),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-06 12:42:00', 258, 26, 3),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-06 14:40:00', 418, 42, 2),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente presentó incapacidad médica', '2026-08-06 14:43:00', 297, 30, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-06 15:40:00', 406, 41, 3),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-06 18:38:00', 498, 50, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-06 19:43:00', 87, 9, 1),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-07 04:40:00', 348, 35, 2),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-07 05:37:00', 48, 5, 5),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-07 10:42:00', 269, 27, 3),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente presentó incapacidad médica', '2026-08-07 16:35:00', 240, 24, 2),
  ('MODIFICAR', 'categoria', 'FALTO', 'RETARDO', 'El estudiante llegó después del primer llamado de lista', '2026-08-07 16:43:00', 19, 2, 47),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente informó calamidad doméstica', '2026-08-07 17:47:00', 337, 34, 1),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-07 19:44:00', 310, 31, 3),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-07 21:44:00', 489, 49, 3),
  ('MODIFICAR', 'categoria', 'ASISTIO', 'EVASION', 'Otro docente reportó que no estaba en clase', '2026-08-08 04:48:00', 389, 39, 3),
  ('MODIFICAR', 'justificada', '0', '1', 'El acudiente presentó incapacidad médica', '2026-08-08 07:42:00', 130, 13, 1),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-08 07:50:00', 279, 28, 4),
  ('MODIFICAR', 'justificada', '0', '1', 'Salida autorizada por coordinación', '2026-08-08 09:44:00', 449, 45, 3),
  ('MODIFICAR', 'categoria', 'FALTO', 'RETARDO', 'El estudiante llegó después del primer llamado de lista', '2026-08-08 11:40:00', 399, 40, 10);

-- ---------------------------------------------------------------------
-- Cómo se indica quién hace el cambio y por qué:
-- antes de modificar o eliminar  el procedimiento  fija   set @usuario_actual = <idusuario>  set @motivo_cambio  = '<razón del cambio>';
-- Si no, se usa el usuario que registró la asistencia y el motivo 'Sin motivo registrado'.

drop trigger if exists trg_asistenciavalidar; -- trigger 1 : valida un registro de asistencia antes de guardarlo
drop trigger if exists trg_asistencia_alertacitacion; -- trigger 2 : alerta por muchas faltas, retardos o evasiones.
drop trigger if exists trg_auditoria_modificacion; -- trigger 3:Guarda una fila por cada campo que cambie, con quién lo cambió y por qué.
drop trigger if exists trg_auditoria_eliminacion; -- trigger 4 :Deja constancia del registro borrado, quién lo borró y por qué.
-- --------
delimiter //
create trigger trg_asistenciavalidar
before insert on asistencia
for each row
begin
    declare v_est_activo boolean;
    declare v_usu_activo boolean;
    declare v_coincide   int;

    select activo into v_est_activo from estudiante where idestudiante = new.idestudiante;
    if v_est_activo = false then
        signal sqlstate '45000' set message_text = 'El estudiante está inactivo y no se le puede registrar asistencia';
    end if;

    select activo into v_usu_activo from usuario where idusuario = new.idusuario;
    if v_usu_activo = false then
        signal sqlstate '45000' set message_text = 'El usuario está inactivo y no puede registrar asistencia';
    end if;

    select count(*) into v_coincide
    from curso c
    join bloque b on b.idnivel = c.idnivel and b.idjornada = c.idjornada
    where c.idcurso = new.idcurso and b.idbloque = new.idbloque;
    if v_coincide = 0 then
        signal sqlstate '45000' set message_text = 'El bloque no corresponde al nivel y la jornada del curso';
    end if;

    if new.fecha > curdate() then
        signal sqlstate '45000' set message_text = 'No se puede registrar asistencia en una fecha futura';
    end if;
end //
-- ------

delimiter //
create trigger trg_asistencia_alertacitacion
after insert on asistencia
for each row
begin
    declare v_novedades  int;
    declare v_pendientes int;

    if new.categoria <> 'ASISTIO' and new.justificada = false then
        select count(*) into v_novedades
        from asistencia
        where idestudiante = new.idestudiante
          and categoria <> 'ASISTIO'
          and justificada = false
          and idcitacion is null;

        select count(*) into v_pendientes
        from citacion
        where idestudiante = new.idestudiante and estado = 'PENDIENTE';

        if v_novedades >= 3 and v_pendientes = 0 then
            insert into citacion (fechacitacion, motivo, estado, idestudiante)
            values (date_add(new.fecha, interval 3 day),
                    concat('Alerta automática: ', v_novedades, ' novedades sin justificar'),
                    'PENDIENTE', new.idestudiante);
        end if;
    end if;
end //

-- ------
delimiter //
create trigger trg_auditoria_modificacion
after update on asistencia
for each row
begin
    declare v_usuario int;
    declare v_motivo  varchar(255);
    set v_usuario = coalesce(@usuario_actual, new.idusuario);
    set v_motivo  = coalesce(@motivo_cambio, 'Sin motivo registrado');

    if not (old.categoria <=> new.categoria) then
        insert into auditoria_asistencia (accion, campomodificado, valoranterior, valornuevo, motivo, idasistencia, idestudiante, idusuario)
        values ('MODIFICAR', 'categoria', old.categoria, new.categoria, v_motivo, new.idasistencia, new.idestudiante, v_usuario);
    end if;
    if not (old.justificada <=> new.justificada) then
        insert into auditoria_asistencia (accion, campomodificado, valoranterior, valornuevo, motivo, idasistencia, idestudiante, idusuario)
        values ('MODIFICAR', 'justificada', old.justificada, new.justificada, v_motivo, new.idasistencia, new.idestudiante, v_usuario);
    end if;
    if not (old.justificacion <=> new.justificacion) then
        insert into auditoria_asistencia (accion, campomodificado, valoranterior, valornuevo, motivo, idasistencia, idestudiante, idusuario)
        values ('MODIFICAR', 'justificacion', old.justificacion, new.justificacion, v_motivo, new.idasistencia, new.idestudiante, v_usuario);
    end if;
    if not (old.idcitacion <=> new.idcitacion) then
        insert into auditoria_asistencia (accion, campomodificado, valoranterior, valornuevo, motivo, idasistencia, idestudiante, idusuario)
        values ('MODIFICAR', 'idcitacion', old.idcitacion, new.idcitacion, v_motivo, new.idasistencia, new.idestudiante, v_usuario);
    end if;
end //
-- --------
delimiter //
create trigger trg_auditoria_eliminacion
after delete on asistencia
for each row
begin
    insert into auditoria_asistencia (accion, campomodificado, valoranterior, valornuevo, motivo, idasistencia, idestudiante, idusuario)
    values ('ELIMINAR', 'registro completo',
            concat(old.fecha, ' | bloque ', old.idbloque, ' | ', old.categoria),
            null,
            coalesce(@motivo_cambio, 'Sin motivo registrado'),
            old.idasistencia, old.idestudiante,
            coalesce(@usuario_actual, old.idusuario));
end //

delimiter ;
