
-- SISTEMA DE GESTIÓN DE ASISTENCIA · Colegio Manuel Zapata Olivella IED
-- 01 DDL
drop database if exists colegio_mzo;
create database colegio_mzo;
use colegio_mzo;


create table jornada (
    idjornada int  primary key  auto_increment not null,
    nombre varchar(20) unique not null,
    horainicioJor  time not null,
    horafinJor time not null,
    constraint ck_jornadahoras check (horafinJor > horainicioJor)
);


create table nivel (
    idnivel int primary key auto_increment not null,
    nombre varchar(30) unique  not null,
    cantidadbloques  int not null,
    constraint ck_nivelbloques check (cantidadbloques > 0)
) ;


create table curso (
    idcurso int primary key auto_increment not null ,
    nombre varchar(20)  not null,
    grado int not null,
    aniolectivo  year not null,
    activo boolean not null default true,
    idnivel int  not null,
    idjornada int  not null,
    constraint uq_curso  unique (nombre, idjornada, aniolectivo),
    constraint ck_cursogrado check (grado between 1 and 11),
    constraint fk_cursonivel foreign key (idnivel) references nivel (idnivel),
    constraint fk_cursojornada foreign key (idjornada) references jornada (idjornada)
) ;


create table bloque (
    idbloque  int primary key auto_increment not null,
    nombre  varchar(30)  not null,
    numero int  not null,
    horainicioBlo time not null,
    horafinBlo time not null,
    idnivel int  not null,
    idjornada int  not null,
    constraint uq_bloque unique (idnivel, idjornada, numero),
    constraint ck_bloquenumero check (numero > 0),
    constraint ck_bloquehoras check (horafinBlo > horainicioBlo),
    constraint fk_bloquenivel foreign key (idnivel) references nivel (idnivel),
    constraint fk_bloquejornada foreign key (idjornada) references jornada (idjornada)
) ;

create table acudiente (
    idacudiente int primary key auto_increment not null,
    tipodocumentoAcu varchar(5)    not null,
    numerodocumentoAcu varchar(20) unique   not null,
    nombres varchar(60)   not null,
    apellidos varchar(60)   not null,
    parentesco varchar(30)   not null,
    telefono varchar(15)   not null,
    correo varchar(100)  null,
    direccion varchar(120)  null
) ;

create table estudiante (
    idestudiante int primary key auto_increment not null,
    tipodocumentoEst  varchar(5)   not null,
    numerodocumentoEst  varchar(20) unique  not null,
    nombres varchar(60)  not null,
    apellidos varchar(60)  not null,
    fechanacimiento date   not null,
    activo  boolean  not null default true,
    idcurso  int  not null,
    idacudiente int  not null,
    constraint fk_estudiantecurso foreign key (idcurso) references curso (idcurso),
    constraint fk_estudianteacudiente foreign key (idacudiente) references acudiente (idacudiente)
) ;

create table usuario (
    idusuario int primary key auto_increment not null,
    numerodocumentoUsu varchar(20) unique not null,
    nombres varchar(60)   not null,
    apellidos varchar(60)   not null,
    correo varchar(100) unique  not null,
    contrasena varchar(255)  not null,  
    rol enum('COORDINADOR','MAESTRO') not null,
    activo boolean not null default true,
    constraint uq_usuario unique (numerodocumentoUsu, correo)
) ;


create table citacion (
    idcitacion   int primary key auto_increment not null,
    fechacitacion  date not null,
    motivo varchar(255)  not null,
    estado enum('PENDIENTE','REALIZADA') not null default 'PENDIENTE',
    fecharegistro  datetime not null default current_timestamp,
    idestudiante   int not null,
    constraint fk_citacionestudiante foreign key (idestudiante) references estudiante (idestudiante)
) ;
drop table if exists asistencia;
create table asistencia (
    idasistencia  int primary key auto_increment not null,
    fecha date not null,
    categoria  enum('ASISTIO','FALTO','RETARDO','EVASION') not null,
    justificada  boolean   not null default false,
    justificacion enum('CALAMIDAD','MEDICA','PERMITIDA','NINGUNA') not null default 'NINGUNA',
    fecha_hora_registro datetime  not null default current_timestamp,
    idestudiante int  not null,
    idcurso int  not null,
    idbloque int   not null,
    idusuario int not null,
    idcitacion int null,         
    constraint uq_asistencia unique (fecha,idestudiante,idbloque),
    constraint ck_asistenciajustificacion check ( (justificada = false and justificacion = 'NINGUNA') or (justificada = true  and justificacion <> 'NINGUNA' and categoria <> 'ASISTIO')),
    constraint fk_asistencia_estudiante foreign key (idestudiante) references estudiante (idestudiante),
    constraint fk_asistencia_curso foreign key (idcurso) references curso (idcurso),
    constraint fk_asistencia_bloque foreign key (idbloque) references bloque (idbloque),
    constraint fk_asistencia_usuario foreign key (idusuario) references usuario (idusuario),
    constraint fk_asistencia_citacion foreign key (idcitacion) references citacion (idcitacion)
        on delete set null
) ;

create index ix_asistencia_fecha     on asistencia (fecha);
create index ix_asistencia_categoria on asistencia (categoria);

-- 02 Inserts por tablita -  Datos de prueba 
use colegio_mzo;

insert into jornada (nombre, horainicioJor, horafinJor) values -- no podemos tener 50 registros porque el colegio solo maneja jornada mañana y tarde
  ('Mañana', '06:30:00', '12:30:00'),
  ('Tarde', '12:30:00', '18:30:00');

insert into nivel (nombre, cantidadbloques) values -- lo mismo aqui, el colegio solo maneja nivel primaria y bachillerato
  ('Primaria', 5),
  ('Bachillerato', 4);

insert into bloque (nombre, numero, horainicioBlo, horafinBlo, idnivel, idjornada) values -- los bloques solo pueden ser de 1-4 bachi y 1-5 prim  y se insertan todos los posibles de ambas jornadas
  ('Bloque 1', 1, '06:30:00', '07:25:00', 1, 1),
  ('Bloque 2', 2, '07:25:00', '08:20:00', 1, 1),
  ('Bloque 3', 3, '08:40:00', '09:35:00', 1, 1),
  ('Bloque 4', 4, '09:35:00', '10:30:00', 1, 1),
  ('Bloque 5', 5, '10:30:00', '11:25:00', 1, 1),
  ('Bloque 1', 1, '12:30:00', '13:25:00', 1, 2),
  ('Bloque 2', 2, '13:25:00', '14:20:00', 1, 2),
  ('Bloque 3', 3, '14:40:00', '15:35:00', 1, 2),
  ('Bloque 4', 4, '15:35:00', '16:30:00', 1, 2),
  ('Bloque 5', 5, '16:30:00', '17:25:00', 1, 2),
  ('Bloque 1', 1, '06:30:00', '07:25:00', 2, 1),
  ('Bloque 2', 2, '07:25:00', '08:20:00', 2, 1),
  ('Bloque 3', 3, '08:40:00', '09:35:00', 2, 1),
  ('Bloque 4', 4, '09:35:00', '10:30:00', 2, 1),
  ('Bloque 1', 1, '12:30:00', '13:25:00', 2, 2),
  ('Bloque 2', 2, '13:25:00', '14:20:00', 2, 2),
  ('Bloque 3', 3, '14:40:00', '15:35:00', 2, 2),
  ('Bloque 4', 4, '15:35:00', '16:30:00', 2, 2);

insert into curso (nombre, grado, aniolectivo, activo, idnivel, idjornada) values
  ('101', 1, 2026, true, 1, 1),
  ('102', 1, 2026, true, 1, 1),
  ('201', 2, 2026, true, 1, 1),
  ('202', 2, 2026, true, 1, 1),
  ('301', 3, 2026, true, 1, 1),
  ('302', 3, 2026, true, 1, 1),
  ('401', 4, 2026, true, 1, 1),
  ('402', 4, 2026, true, 1, 1),
  ('501', 5, 2026, true, 1, 1),
  ('502', 5, 2026, true, 1, 1),
  ('601', 6, 2026, true, 2, 1),
  ('602', 6, 2026, true, 2, 1),
  ('701', 7, 2026, true, 2, 1),
  ('702', 7, 2026, true, 2, 1),
  ('801', 8, 2026, true, 2, 1),
  ('802', 8, 2026, true, 2, 1),
  ('901', 9, 2026, true, 2, 1),
  ('902', 9, 2026, true, 2, 1),
  ('1001', 10, 2026, true, 2, 1),
  ('1002', 10, 2026, true, 2, 1),
  ('1101', 11, 2026, true, 2, 1),
  ('1102', 11, 2026, true, 2, 1),
  ('603', 6, 2026, true, 2, 1),
  ('703', 7, 2026, true, 2, 1),
  ('803', 8, 2026, true, 2, 1),
  ('101', 1, 2026, true, 1, 2),
  ('102', 1, 2026, true, 1, 2),
  ('201', 2, 2026, true, 1, 2),
  ('202', 2, 2026, true, 1, 2),
  ('301', 3, 2026, true, 1, 2),
  ('302', 3, 2026, true, 1, 2),
  ('401', 4, 2026, true, 1, 2),
  ('402', 4, 2026, true, 1, 2),
  ('501', 5, 2026, true, 1, 2),
  ('502', 5, 2026, true, 1, 2),
  ('601', 6, 2026, true, 2, 2),
  ('602', 6, 2026, true, 2, 2),
  ('701', 7, 2026, true, 2, 2),
  ('702', 7, 2026, true, 2, 2),
  ('801', 8, 2026, true, 2, 2),
  ('802', 8, 2026, true, 2, 2),
  ('901', 9, 2026, true, 2, 2),
  ('902', 9, 2026, true, 2, 2),
  ('1001', 10, 2026, true, 2, 2),
  ('1002', 10, 2026, true, 2, 2),
  ('1101', 11, 2026, true, 2, 2),
  ('1102', 11, 2026, true, 2, 2),
  ('603', 6, 2026, true, 2, 2),
  ('703', 7, 2026, true, 2, 2),
  ('803', 8, 2026, true, 2, 2);

insert into acudiente (tipodocumentoAcu, numerodocumentoAcu, nombres, apellidos, parentesco, telefono, correo, direccion) values
  ('CC', '52000000', 'Gabriela', 'Ortiz Palacios', 'Madre', '3269236009', 'gabriela.ortiz1@correo.com', 'Carrera 58 Sur # 79-80, Kennedy'),
  ('CC', '52013771', 'Samuel', 'Vargas Sánchez', 'Padre', '3109225646', 'samuel.vargas2@correo.com', 'Calle 8 Sur # 69-13, Kennedy'),
  ('CC', '52027542', 'Diana', 'Torres Ramírez', 'Tía', '3216710873', 'diana.torres3@correo.com', 'Diagonal 52 Sur # 72-96, Kennedy'),
  ('CC', '52041313', 'Yolanda', 'Pérez Vargas', 'Abuela', '3158735513', null, 'Diagonal 2 Sur # 87-91, Kennedy'),
  ('CC', '52055084', 'Mariana', 'Mena Jiménez', 'Hermana mayor', '3277679821', 'mariana.mena5@correo.com', 'Calle 28 Sur # 76-97, Kennedy'),
  ('CC', '52068855', 'Luis', 'Asprilla Rojas', 'Tutor legal', '3281425740', 'luis.asprilla6@correo.com', null),
  ('CC', '52082626', 'Manuela', 'Cuesta Gómez', 'Madre', '3018663770', 'manuela.cuesta7@correo.com', 'Transversal 31 Sur # 64-62, Kennedy'),
  ('CC', '52096397', 'Luz Marina', 'Suárez Torres', 'Tía', '3135938778', 'luz.suarez8@correo.com', 'Transversal 52 Sur # 88-52, Kennedy'),
  ('CC', '52110168', 'Miguel', 'Gómez García', 'Tutor legal', '3178829190', 'miguel.gomez9@correo.com', 'Transversal 24 Sur # 89-26, Kennedy'),
  ('CC', '52123939', 'Salomé', 'Quintero Rojas', 'Madre', '3185342466', 'salome.quintero10@correo.com', 'Diagonal 21 Sur # 74-13, Kennedy'),
  ('CC', '52137710', 'Martina', 'Rojas Cuesta', 'Hermana mayor', '3114264621', null, 'Calle 42 Sur # 68-64, Kennedy'),
  ('CC', '52151481', 'Wilson', 'García Vargas', 'Padre', '3214335171', 'wilson.garcia12@correo.com', 'Calle 1 Sur # 74-75, Kennedy'),
  ('CC', '52165252', 'Camila', 'Murillo Suárez', 'Tía', '3299254204', 'camila.murillo13@correo.com', 'Diagonal 10 Sur # 60-41, Kennedy'),
  ('CC', '52179023', 'Manuela', 'Suárez Sánchez', 'Hermana mayor', '3242416554', 'manuela.suarez14@correo.com', 'Carrera 39 Sur # 88-89, Kennedy'),
  ('CC', '52192794', 'Martina', 'Perea García', 'Tía', '3237308337', 'martina.perea15@correo.com', 'Transversal 25 Sur # 85-20, Kennedy'),
  ('CC', '52206565', 'Ana María', 'Torres Mena', 'Madre', '3101429199', 'ana.torres16@correo.com', 'Calle 54 Sur # 71-83, Kennedy'),
  ('CC', '52220336', 'Carolina', 'Rentería Pérez', 'Hermana mayor', '3119347833', 'carolina.renteria17@correo.com', null),
  ('CC', '52234107', 'Samuel', 'Mosquera Quintero', 'Abuelo', '3196644171', null, 'Carrera 38 Sur # 76-27, Kennedy'),
  ('CC', '52247878', 'Sandra', 'Rentería Córdoba', 'Madre', '3001808451', 'sandra.renteria19@correo.com', 'Transversal 3 Sur # 66-83, Kennedy'),
  ('CC', '52261649', 'Diana', 'Castro Córdoba', 'Madre', '3223690909', 'diana.castro20@correo.com', 'Carrera 42 Sur # 76-28, Kennedy'),
  ('CC', '52275420', 'Martina', 'Torres Ramírez', 'Hermana mayor', '3126772469', 'martina.torres21@correo.com', 'Transversal 56 Sur # 62-50, Kennedy'),
  ('CC', '52289191', 'Isabella', 'Castro Murillo', 'Hermana mayor', '3278458863', 'isabella.castro22@correo.com', 'Diagonal 30 Sur # 65-42, Kennedy'),
  ('CC', '52302962', 'Gabriela', 'Quintero Ramírez', 'Madre', '3157845145', 'gabriela.quintero23@correo.com', 'Carrera 15 Sur # 60-12, Kennedy'),
  ('CC', '52316733', 'Martina', 'Rodríguez Moreno', 'Abuela', '3232840351', 'martina.rodriguez24@correo.com', 'Diagonal 36 Sur # 81-74, Kennedy'),
  ('CC', '52330504', 'Luz Marina', 'Suárez Murillo', 'Abuela', '3222702144', null, 'Diagonal 37 Sur # 68-86, Kennedy'),
  ('CC', '52344275', 'Diego', 'Rojas López', 'Padre', '3019499785', 'diego.rojas26@correo.com', 'Calle 49 Sur # 71-93, Kennedy'),
  ('CC', '52358046', 'Paula', 'Pérez Perea', 'Tía', '3065312449', 'paula.perez27@correo.com', 'Carrera 17 Sur # 68-9, Kennedy'),
  ('CC', '52371817', 'Natalia', 'Gómez Martínez', 'Abuela', '3043063938', 'natalia.gomez28@correo.com', null),
  ('CC', '52385588', 'Valentina', 'Díaz Murillo', 'Hermana mayor', '3238762311', 'valentina.diaz29@correo.com', 'Calle 60 Sur # 72-41, Kennedy'),
  ('CC', '52399359', 'Ana María', 'Rentería Moreno', 'Tía', '3061397004', 'ana.renteria30@correo.com', 'Transversal 19 Sur # 90-46, Kennedy'),
  ('CC', '52413130', 'Carolina', 'Pérez Valencia', 'Madre', '3206745925', 'carolina.perez31@correo.com', 'Diagonal 50 Sur # 73-41, Kennedy'),
  ('CC', '52426901', 'Camila', 'Valencia Martínez', 'Abuela', '3256070765', null, 'Calle 8 Sur # 61-17, Kennedy'),
  ('CC', '52440672', 'Manuela', 'Moreno Rojas', 'Hermana mayor', '3233100642', 'manuela.moreno33@correo.com', 'Transversal 16 Sur # 84-54, Kennedy'),
  ('CC', '52454443', 'Natalia', 'Rentería Córdoba', 'Hermana mayor', '3005644462', 'natalia.renteria34@correo.com', 'Diagonal 51 Sur # 64-30, Kennedy'),
  ('CC', '52468214', 'Sofía', 'Ramírez Díaz', 'Abuela', '3085449700', 'sofia.ramirez35@correo.com', 'Calle 54 Sur # 65-71, Kennedy'),
  ('CC', '52481985', 'Gabriela', 'Murillo Valencia', 'Tía', '3238894436', 'gabriela.murillo36@correo.com', 'Calle 43 Sur # 86-2, Kennedy'),
  ('CC', '52495756', 'Sandra', 'Rentería Ortiz', 'Abuela', '3246766126', 'sandra.renteria37@correo.com', 'Transversal 46 Sur # 71-30, Kennedy'),
  ('CC', '52509527', 'Óscar', 'Moreno Vargas', 'Tutor legal', '3244152477', 'oscar.moreno38@correo.com', 'Transversal 58 Sur # 85-87, Kennedy'),
  ('CC', '52523298', 'Sofía', 'García Castro', 'Madre', '3187850588', null, null),
  ('CC', '52537069', 'Matías', 'López González', 'Tío', '3011307902', 'matias.lopez40@correo.com', 'Diagonal 35 Sur # 83-34, Kennedy'),
  ('CC', '52550840', 'Yolanda', 'Jiménez Gómez', 'Hermana mayor', '3229535601', 'yolanda.jimenez41@correo.com', 'Transversal 35 Sur # 90-67, Kennedy'),
  ('CC', '52564611', 'Manuela', 'Valencia Torres', 'Tía', '3233721443', 'manuela.valencia42@correo.com', 'Diagonal 20 Sur # 61-95, Kennedy'),
  ('CC', '52578382', 'Luis', 'Suárez Pérez', 'Tío', '3209053266', 'luis.suarez43@correo.com', 'Carrera 25 Sur # 66-96, Kennedy'),
  ('CC', '52592153', 'Óscar', 'Quintero Murillo', 'Abuelo', '3021476776', 'oscar.quintero44@correo.com', 'Calle 12 Sur # 70-70, Kennedy'),
  ('CC', '52605924', 'Santiago', 'Rentería Mena', 'Padre', '3083587483', 'santiago.renteria45@correo.com', 'Diagonal 5 Sur # 71-39, Kennedy'),
  ('CC', '52619695', 'Sandra', 'García Martínez', 'Tía', '3065405213', null, 'Transversal 7 Sur # 87-94, Kennedy'),
  ('CC', '52633466', 'Ana María', 'Moreno Castro', 'Hermana mayor', '3176790134', 'ana.moreno47@correo.com', 'Calle 36 Sur # 76-32, Kennedy'),
  ('CC', '52647237', 'Paula', 'Quintero Castro', 'Tía', '3058257766', 'paula.quintero48@correo.com', 'Diagonal 49 Sur # 81-29, Kennedy'),
  ('CC', '52661008', 'Carolina', 'Díaz Perea', 'Hermana mayor', '3136847641', 'carolina.diaz49@correo.com', 'Transversal 21 Sur # 65-26, Kennedy'),
  ('CC', '52674779', 'Óscar', 'Rojas Cuesta', 'Tutor legal', '3028410022', 'oscar.rojas50@correo.com', null);

insert into estudiante (tipodocumentoEst, numerodocumentoEst, nombres, apellidos, fechanacimiento, activo, idcurso, idacudiente) values
  ('RC', '1010000000', 'Sebastián', 'Ortiz Rojas', '2019-05-18', true, 1, 1),
  ('RC', '1010007919', 'Isabella', 'Vargas Díaz', '2019-05-17', true, 1, 2),
  ('RC', '1010015838', 'Julián', 'Torres Ramírez', '2019-03-16', true, 1, 3),
  ('RC', '1010023757', 'David', 'Pérez Sánchez', '2019-06-19', true, 1, 4),
  ('RC', '1010031676', 'Jerónimo', 'Mena Murillo', '2019-03-05', true, 1, 5),
  ('TI', '1010039595', 'Manuela', 'Asprilla Vargas', '2017-11-21', true, 5, 6),
  ('TI', '1010047514', 'Valentina', 'Cuesta Suárez', '2017-06-18', true, 5, 7),
  ('TI', '1010055433', 'Emiliano', 'Suárez Martínez', '2017-12-14', true, 5, 8),
  ('TI', '1010063352', 'Esteban', 'Gómez Perea', '2017-12-14', true, 5, 9),
  ('TI', '1010071271', 'Jerónimo', 'Quintero Ortiz', '2017-04-18', true, 5, 10),
  ('TI', '1010079190', 'Antonella', 'Rojas Gómez', '2015-07-24', true, 9, 11),
  ('TI', '1010087109', 'Juan', 'García Ramírez', '2015-10-14', true, 9, 12),
  ('TI', '1010095028', 'Sebastián', 'Murillo Díaz', '2015-10-24', true, 9, 13),
  ('TI', '1010102947', 'Camilo', 'Suárez Cuesta', '2015-09-01', true, 9, 14),
  ('TI', '1010110866', 'Esteban', 'Perea Díaz', '2015-01-07', true, 9, 15),
  ('TI', '1010118785', 'Valeria', 'Torres Palacios', '2014-03-03', true, 11, 16),
  ('TI', '1010126704', 'David', 'Rentería Díaz', '2014-01-10', true, 11, 17),
  ('TI', '1010134623', 'Julián', 'Mosquera Ortiz', '2014-05-22', false, 11, 18),
  ('TI', '1010142542', 'Felipe', 'Rentería González', '2014-10-12', true, 11, 19),
  ('TI', '1010150461', 'Jerónimo', 'Castro Murillo', '2014-01-06', true, 11, 20),
  ('TI', '1010158380', 'Sebastián', 'Torres Díaz', '2012-04-22', true, 15, 21),
  ('TI', '1010166299', 'Alejandro', 'Castro Mosquera', '2012-12-10', true, 15, 22),
  ('TI', '1010174218', 'Luciana', 'Quintero González', '2012-10-17', true, 15, 23),
  ('TI', '1010182137', 'Paula', 'Rodríguez Rentería', '2012-10-28', true, 15, 24),
  ('TI', '1010190056', 'Matías', 'Suárez Rodríguez', '2012-05-18', true, 15, 25),
  ('TI', '1010197975', 'Santiago', 'Rojas López', '2010-10-09', true, 19, 26),
  ('TI', '1010205894', 'Daniel', 'Pérez Perea', '2010-08-30', true, 19, 27),
  ('TI', '1010213813', 'Emiliano', 'Gómez Díaz', '2010-06-27', true, 19, 28),
  ('TI', '1010221732', 'Camila', 'Díaz Ramírez', '2010-09-08', true, 19, 29),
  ('TI', '1010229651', 'David', 'Rentería Gómez', '2010-11-26', true, 19, 30),
  ('TI', '1010237570', 'Valentina', 'Pérez Castro', '2018-07-07', true, 28, 31),
  ('TI', '1010245489', 'Natalia', 'Valencia Hernández', '2018-07-08', true, 28, 32),
  ('TI', '1010253408', 'Laura', 'Moreno Pérez', '2018-04-22', true, 28, 33),
  ('TI', '1010261327', 'Camilo', 'Rentería Asprilla', '2018-02-03', true, 28, 34),
  ('TI', '1010269246', 'Mateo', 'Ramírez Rentería', '2018-09-30', true, 28, 35),
  ('TI', '1010277165', 'Tomás', 'Murillo Castro', '2013-11-12', true, 38, 36),
  ('TI', '1010285084', 'Paula', 'Rentería Ortiz', '2013-11-02', true, 38, 37),
  ('TI', '1010293003', 'Antonella', 'Moreno Rentería', '2013-06-23', true, 38, 38),
  ('TI', '1010300922', 'Sofía', 'García Suárez', '2013-03-31', true, 38, 39),
  ('TI', '1010308841', 'Mateo', 'López Ortiz', '2013-07-16', true, 38, 40),
  ('TI', '1010316760', 'Diego', 'Jiménez Hernández', '2011-01-15', true, 42, 41),
  ('TI', '1010324679', 'Daniela', 'Valencia Rojas', '2011-09-18', false, 42, 42),
  ('TI', '1010332598', 'Sebastián', 'Suárez Ortiz', '2011-04-19', true, 42, 43),
  ('TI', '1010340517', 'David', 'Quintero Murillo', '2011-09-08', true, 42, 44),
  ('TI', '1010348436', 'Antonella', 'Rentería Moreno', '2011-11-30', true, 42, 45),
  ('TI', '1010356355', 'Martina', 'García Valencia', '2009-10-04', true, 46, 46),
  ('TI', '1010364274', 'Martina', 'Moreno Suárez', '2009-12-27', true, 46, 47),
  ('TI', '1010372193', 'Sebastián', 'Quintero García', '2009-12-03', true, 46, 48),
  ('TI', '1010380112', 'Santiago', 'Ortiz Ramírez', '2009-06-03', true, 46, 1),
  ('TI', '1010388031', 'Nicolás', 'Vargas García', '2009-05-17', true, 46, 2);

insert into usuario (numerodocumentoUsu, nombres, apellidos, correo, contrasena, rol, activo) values
  ('79000000', 'Luis', 'Moreno García', 'luis.moreno1@colegiomzo.edu.co', sha2('Clave01*', 256), 'COORDINADOR', true),
  ('79010007', 'Gabriela', 'Córdoba Gómez', 'gabriela.cordoba2@colegiomzo.edu.co', sha2('Clave02*', 256), 'COORDINADOR', true),
  ('79020014', 'Jorge', 'García Rojas', 'jorge.garcia3@colegiomzo.edu.co', sha2('Clave03*', 256), 'COORDINADOR', true),
  ('79030021', 'Esteban', 'Perea Suárez', 'esteban.perea4@colegiomzo.edu.co', sha2('Clave04*', 256), 'COORDINADOR', true),
  ('79040028', 'Tomás', 'Sánchez Ortiz', 'tomas.sanchez5@colegiomzo.edu.co', sha2('Clave05*', 256), 'COORDINADOR', true),
  ('79050035', 'Ana María', 'González Vargas', 'ana.gonzalez6@colegiomzo.edu.co', sha2('Clave06*', 256), 'MAESTRO', true),
  ('79060042', 'Camilo', 'García Mena', 'camilo.garcia7@colegiomzo.edu.co', sha2('Clave07*', 256), 'MAESTRO', true),
  ('79070049', 'Luz Marina', 'Ortiz Gómez', 'luz.ortiz8@colegiomzo.edu.co', sha2('Clave08*', 256), 'MAESTRO', true),
  ('79080056', 'Mariana', 'Martínez Moreno', 'mariana.martinez9@colegiomzo.edu.co', sha2('Clave09*', 256), 'MAESTRO', true),
  ('79090063', 'Luis', 'Córdoba Cuesta', 'luis.cordoba10@colegiomzo.edu.co', sha2('Clave10*', 256), 'MAESTRO', true),
  ('79100070', 'Emiliano', 'Murillo Rodríguez', 'emiliano.murillo11@colegiomzo.edu.co', sha2('Clave11*', 256), 'MAESTRO', true),
  ('79110077', 'Daniela', 'Asprilla Cuesta', 'daniela.asprilla12@colegiomzo.edu.co', sha2('Clave12*', 256), 'MAESTRO', true),
  ('79120084', 'Sandra', 'Rojas Hernández', 'sandra.rojas13@colegiomzo.edu.co', sha2('Clave13*', 256), 'MAESTRO', true),
  ('79130091', 'Nicolás', 'Sánchez Sánchez', 'nicolas.sanchez14@colegiomzo.edu.co', sha2('Clave14*', 256), 'MAESTRO', true),
  ('79140098', 'Esteban', 'Hernández Moreno', 'esteban.hernandez15@colegiomzo.edu.co', sha2('Clave15*', 256), 'MAESTRO', true),
  ('79150105', 'Juliana', 'Valencia Rojas', 'juliana.valencia16@colegiomzo.edu.co', sha2('Clave16*', 256), 'MAESTRO', true),
  ('79160112', 'María José', 'Córdoba Hernández', 'maria.cordoba17@colegiomzo.edu.co', sha2('Clave17*', 256), 'MAESTRO', true),
  ('79170119', 'Carlos', 'Valencia Vargas', 'carlos.valencia18@colegiomzo.edu.co', sha2('Clave18*', 256), 'MAESTRO', true),
  ('79180126', 'Jerónimo', 'Mosquera Castro', 'jeronimo.mosquera19@colegiomzo.edu.co', sha2('Clave19*', 256), 'MAESTRO', true),
  ('79190133', 'Daniela', 'Valencia Hernández', 'daniela.valencia20@colegiomzo.edu.co', sha2('Clave20*', 256), 'MAESTRO', true),
  ('79200140', 'Sofía', 'Moreno Córdoba', 'sofia.moreno21@colegiomzo.edu.co', sha2('Clave21*', 256), 'MAESTRO', true),
  ('79210147', 'Luis', 'López Martínez', 'luis.lopez22@colegiomzo.edu.co', sha2('Clave22*', 256), 'MAESTRO', true),
  ('79220154', 'Diana', 'Rojas Hernández', 'diana.rojas23@colegiomzo.edu.co', sha2('Clave23*', 256), 'MAESTRO', true),
  ('79230161', 'Camilo', 'Rodríguez Suárez', 'camilo.rodriguez24@colegiomzo.edu.co', sha2('Clave24*', 256), 'MAESTRO', true),
  ('79240168', 'Carlos', 'Mena Perea', 'carlos.mena25@colegiomzo.edu.co', sha2('Clave25*', 256), 'MAESTRO', true),
  ('79250175', 'David', 'Pérez Valencia', 'david.perez26@colegiomzo.edu.co', sha2('Clave26*', 256), 'MAESTRO', true),
  ('79260182', 'Valentina', 'Castro Ortiz', 'valentina.castro27@colegiomzo.edu.co', sha2('Clave27*', 256), 'MAESTRO', true),
  ('79270189', 'Sara', 'Cuesta Moreno', 'sara.cuesta28@colegiomzo.edu.co', sha2('Clave28*', 256), 'MAESTRO', true),
  ('79280196', 'Salomé', 'Martínez Quintero', 'salome.martinez29@colegiomzo.edu.co', sha2('Clave29*', 256), 'MAESTRO', true),
  ('79290203', 'Valeria', 'Moreno Vargas', 'valeria.moreno30@colegiomzo.edu.co', sha2('Clave30*', 256), 'MAESTRO', true),
  ('79300210', 'Diana', 'Jiménez Gómez', 'diana.jimenez31@colegiomzo.edu.co', sha2('Clave31*', 256), 'MAESTRO', true),
  ('79310217', 'Jorge', 'Suárez Díaz', 'jorge.suarez32@colegiomzo.edu.co', sha2('Clave32*', 256), 'MAESTRO', true),
  ('79320224', 'Jorge', 'González Vargas', 'jorge.gonzalez33@colegiomzo.edu.co', sha2('Clave33*', 256), 'MAESTRO', true),
  ('79330231', 'Ana María', 'Cuesta Quintero', 'ana.cuesta34@colegiomzo.edu.co', sha2('Clave34*', 256), 'MAESTRO', true),
  ('79340238', 'Paula', 'Martínez Cuesta', 'paula.martinez35@colegiomzo.edu.co', sha2('Clave35*', 256), 'MAESTRO', true),
  ('79350245', 'Mariana', 'González Jiménez', 'mariana.gonzalez36@colegiomzo.edu.co', sha2('Clave36*', 256), 'MAESTRO', true),
  ('79360252', 'Paula', 'Perea Vargas', 'paula.perea37@colegiomzo.edu.co', sha2('Clave37*', 256), 'MAESTRO', true),
  ('79370259', 'Andrés', 'Quintero Palacios', 'andres.quintero38@colegiomzo.edu.co', sha2('Clave38*', 256), 'MAESTRO', true),
  ('79380266', 'Julián', 'Mosquera Castro', 'julian.mosquera39@colegiomzo.edu.co', sha2('Clave39*', 256), 'MAESTRO', true),
  ('79390273', 'Salomé', 'Mena Díaz', 'salome.mena40@colegiomzo.edu.co', sha2('Clave40*', 256), 'MAESTRO', true),
  ('79400280', 'Isabella', 'Torres González', 'isabella.torres41@colegiomzo.edu.co', sha2('Clave41*', 256), 'MAESTRO', true),
  ('79410287', 'Sara', 'Rodríguez Gómez', 'sara.rodriguez42@colegiomzo.edu.co', sha2('Clave42*', 256), 'MAESTRO', true),
  ('79420294', 'Samuel', 'Murillo Mosquera', 'samuel.murillo43@colegiomzo.edu.co', sha2('Clave43*', 256), 'MAESTRO', true),
  ('79430301', 'Yolanda', 'Asprilla Mena', 'yolanda.asprilla44@colegiomzo.edu.co', sha2('Clave44*', 256), 'MAESTRO', true),
  ('79440308', 'Salomé', 'Pérez Castro', 'salome.perez45@colegiomzo.edu.co', sha2('Clave45*', 256), 'MAESTRO', true),
  ('79450315', 'Luz Marina', 'Mena Vargas', 'luz.mena46@colegiomzo.edu.co', sha2('Clave46*', 256), 'MAESTRO', true),
  ('79460322', 'Andrés', 'Sánchez Ortiz', 'andres.sanchez47@colegiomzo.edu.co', sha2('Clave47*', 256), 'MAESTRO', true),
  ('79470329', 'Emiliano', 'Rojas Gómez', 'emiliano.rojas48@colegiomzo.edu.co', sha2('Clave48*', 256), 'MAESTRO', true),
  ('79480336', 'Martina', 'López Vargas', 'martina.lopez49@colegiomzo.edu.co', sha2('Clave49*', 256), 'MAESTRO', false),
  ('79490343', 'Isabella', 'Jiménez Castro', 'isabella.jimenez50@colegiomzo.edu.co', sha2('Clave50*', 256), 'MAESTRO', true);

insert into citacion (fechacitacion, motivo, estado, fecharegistro, idestudiante) values
  ('2026-08-07', 'Acumula 3 novedades sin justificar (evasion, falto)', 'REALIZADA', '2026-08-04 17:00:00', 8),
  ('2026-08-09', 'Acumula 3 novedades sin justificar (evasion, retardo)', 'PENDIENTE', '2026-08-06 17:00:00', 14),
  ('2026-08-08', 'Acumula 3 novedades sin justificar (evasion, falto)', 'PENDIENTE', '2026-08-05 17:00:00', 33),
  ('2026-08-09', 'Acumula 3 novedades sin justificar (evasion, falto, retardo)', 'PENDIENTE', '2026-08-06 17:00:00', 47),
  ('2026-08-09', 'Acumula 3 novedades sin justificar (evasion, falto)', 'PENDIENTE', '2026-08-06 17:00:00', 50),
  ('2026-08-08', 'Seguimiento por retardo reportada por docente', 'PENDIENTE', '2026-08-06 17:30:00', 4),
  ('2026-08-06', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 46),
  ('2026-08-09', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-07 17:30:00', 17),
  ('2026-08-07', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-05 17:30:00', 40),
  ('2026-08-06', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 34),
  ('2026-08-07', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-05 17:30:00', 39),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 15),
  ('2026-08-06', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 1),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 16),
  ('2026-08-08', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-06 17:30:00', 33),
  ('2026-08-05', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 48),
  ('2026-08-07', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-05 17:30:00', 41),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 36),
  ('2026-08-08', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-06 17:30:00', 12),
  ('2026-08-08', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-06 17:30:00', 8),
  ('2026-08-05', 'Seguimiento por retardo reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 18),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 42),
  ('2026-08-07', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-05 17:30:00', 45),
  ('2026-08-05', 'Seguimiento por retardo reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 32),
  ('2026-08-05', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 6),
  ('2026-08-07', 'Seguimiento por evasion reportada por docente', 'PENDIENTE', '2026-08-05 17:30:00', 13),
  ('2026-08-06', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 23),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 28),
  ('2026-08-07', 'Seguimiento por retardo reportada por docente', 'PENDIENTE', '2026-08-05 17:30:00', 22),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 27),
  ('2026-08-06', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 30),
  ('2026-08-07', 'Seguimiento por retardo reportada por docente', 'PENDIENTE', '2026-08-05 17:30:00', 3),
  ('2026-08-05', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 29),
  ('2026-08-06', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 38),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 43),
  ('2026-08-07', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-05 17:30:00', 37),
  ('2026-08-06', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 20),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 2),
  ('2026-08-06', 'Seguimiento por retardo reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 10),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 24),
  ('2026-08-06', 'Seguimiento por retardo reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 9),
  ('2026-08-09', 'Seguimiento por falto reportada por docente', 'PENDIENTE', '2026-08-07 17:30:00', 47),
  ('2026-08-09', 'Seguimiento por evasion reportada por docente', 'PENDIENTE', '2026-08-07 17:30:00', 50),
  ('2026-08-05', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 11),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 26),
  ('2026-08-06', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-04 17:30:00', 25),
  ('2026-08-08', 'Seguimiento por evasion reportada por docente', 'PENDIENTE', '2026-08-06 17:30:00', 35),
  ('2026-08-05', 'Seguimiento por falto reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 21),
  ('2026-08-05', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 5),
  ('2026-08-05', 'Seguimiento por evasion reportada por docente', 'REALIZADA', '2026-08-03 17:30:00', 49);

insert into asistencia (fecha, categoria, justificada, justificacion, fecha_hora_registro, idestudiante, idcurso, idbloque, idusuario, idcitacion) values
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:47:00', 1, 1, 1, 39, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:38:00', 1, 1, 2, 30, null),
  ('2026-08-04', 'FALTO', false, 'NINGUNA', '2026-08-04 06:42:00', 1, 1, 1, 24, 13),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:43:00', 1, 1, 2, 26, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:46:00', 1, 1, 1, 43, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:44:00', 1, 1, 2, 39, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:48:00', 1, 1, 1, 13, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:38:00', 1, 1, 2, 43, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:42:00', 1, 1, 1, 35, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:36:00', 1, 1, 2, 12, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 06:40:00', 2, 1, 1, 21, 38),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:39:00', 2, 1, 2, 16, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:45:00', 2, 1, 1, 11, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:35:00', 2, 1, 2, 19, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:50:00', 2, 1, 1, 41, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:42:00', 2, 1, 2, 41, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:45:00', 2, 1, 1, 50, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:43:00', 2, 1, 2, 46, null),
  ('2026-08-07', 'RETARDO', false, 'NINGUNA', '2026-08-07 06:43:00', 2, 1, 1, 47, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:42:00', 2, 1, 2, 9, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:42:00', 3, 1, 1, 47, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:38:00', 3, 1, 2, 6, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:50:00', 3, 1, 1, 8, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:39:00', 3, 1, 2, 10, null),
  ('2026-08-05', 'RETARDO', false, 'NINGUNA', '2026-08-05 06:42:00', 3, 1, 1, 41, 32),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:44:00', 3, 1, 2, 40, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:40:00', 3, 1, 1, 40, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:43:00', 3, 1, 2, 31, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:43:00', 3, 1, 1, 8, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:41:00', 3, 1, 2, 41, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:50:00', 4, 1, 1, 45, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:38:00', 4, 1, 2, 16, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:48:00', 4, 1, 1, 27, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:45:00', 4, 1, 2, 47, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:41:00', 4, 1, 1, 7, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:37:00', 4, 1, 2, 42, null),
  ('2026-08-06', 'RETARDO', false, 'NINGUNA', '2026-08-06 06:47:00', 4, 1, 1, 50, 6),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:40:00', 4, 1, 2, 17, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:41:00', 4, 1, 1, 14, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:41:00', 4, 1, 2, 11, null),
  ('2026-08-03', 'EVASION', false, 'NINGUNA', '2026-08-03 06:46:00', 5, 1, 1, 48, 49),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:43:00', 5, 1, 2, 28, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:50:00', 5, 1, 1, 43, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:39:00', 5, 1, 2, 21, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:43:00', 5, 1, 1, 25, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:44:00', 5, 1, 2, 49, null),
  ('2026-08-06', 'EVASION', true, 'PERMITIDA', '2026-08-06 06:48:00', 5, 1, 1, 6, null),
  ('2026-08-06', 'EVASION', false, 'NINGUNA', '2026-08-06 07:37:00', 5, 1, 2, 35, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:43:00', 5, 1, 1, 48, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:37:00', 5, 1, 2, 44, null),
  ('2026-08-03', 'EVASION', false, 'NINGUNA', '2026-08-03 06:47:00', 6, 5, 1, 13, 25),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:35:00', 6, 5, 2, 45, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:42:00', 6, 5, 1, 32, null),
  ('2026-08-04', 'EVASION', true, 'PERMITIDA', '2026-08-04 07:39:00', 6, 5, 2, 15, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:50:00', 6, 5, 1, 6, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:36:00', 6, 5, 2, 12, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:45:00', 6, 5, 1, 34, null),
  ('2026-08-06', 'FALTO', false, 'NINGUNA', '2026-08-06 07:39:00', 6, 5, 2, 34, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 06:44:00', 6, 5, 1, 22, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:44:00', 6, 5, 2, 32, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:45:00', 7, 5, 1, 16, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:43:00', 7, 5, 2, 7, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:44:00', 7, 5, 1, 31, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:45:00', 7, 5, 2, 26, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:41:00', 7, 5, 1, 20, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:44:00', 7, 5, 2, 27, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:46:00', 7, 5, 1, 19, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:39:00', 7, 5, 2, 40, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:46:00', 7, 5, 1, 50, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:42:00', 7, 5, 2, 21, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:44:00', 8, 5, 1, 8, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 07:39:00', 8, 5, 2, 16, 1),
  ('2026-08-04', 'FALTO', false, 'NINGUNA', '2026-08-04 06:42:00', 8, 5, 1, 34, 1),
  ('2026-08-04', 'EVASION', false, 'NINGUNA', '2026-08-04 07:45:00', 8, 5, 2, 9, 1),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:40:00', 8, 5, 1, 44, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:43:00', 8, 5, 2, 25, null),
  ('2026-08-06', 'FALTO', true, 'PERMITIDA', '2026-08-06 06:50:00', 8, 5, 1, 40, 20),
  ('2026-08-06', 'EVASION', false, 'NINGUNA', '2026-08-06 07:43:00', 8, 5, 2, 24, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 06:49:00', 8, 5, 1, 38, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:40:00', 8, 5, 2, 30, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:40:00', 9, 5, 1, 32, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:41:00', 9, 5, 2, 45, null),
  ('2026-08-04', 'RETARDO', false, 'NINGUNA', '2026-08-04 06:43:00', 9, 5, 1, 41, 41),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:40:00', 9, 5, 2, 7, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:43:00', 9, 5, 1, 17, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:41:00', 9, 5, 2, 36, null),
  ('2026-08-06', 'EVASION', true, 'PERMITIDA', '2026-08-06 06:43:00', 9, 5, 1, 29, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:36:00', 9, 5, 2, 12, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:46:00', 9, 5, 1, 13, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:40:00', 9, 5, 2, 46, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:50:00', 10, 5, 1, 12, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:40:00', 10, 5, 2, 25, null),
  ('2026-08-04', 'RETARDO', true, 'CALAMIDAD', '2026-08-04 06:45:00', 10, 5, 1, 48, 39),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:45:00', 10, 5, 2, 32, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:41:00', 10, 5, 1, 18, null),
  ('2026-08-05', 'EVASION', false, 'NINGUNA', '2026-08-05 07:42:00', 10, 5, 2, 27, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:41:00', 10, 5, 1, 11, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:37:00', 10, 5, 2, 34, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:41:00', 10, 5, 1, 41, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 07:37:00', 10, 5, 2, 11, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:47:00', 11, 9, 1, 33, null),
  ('2026-08-03', 'EVASION', true, 'MEDICA', '2026-08-03 07:35:00', 11, 9, 2, 34, 44),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:41:00', 11, 9, 1, 9, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:41:00', 11, 9, 2, 46, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:48:00', 11, 9, 1, 39, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:36:00', 11, 9, 2, 28, null),
  ('2026-08-06', 'EVASION', true, 'CALAMIDAD', '2026-08-06 06:49:00', 11, 9, 1, 44, null),
  ('2026-08-06', 'FALTO', false, 'NINGUNA', '2026-08-06 07:41:00', 11, 9, 2, 12, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:45:00', 11, 9, 1, 10, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:45:00', 11, 9, 2, 11, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:49:00', 12, 9, 1, 22, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:44:00', 12, 9, 2, 43, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:49:00', 12, 9, 1, 39, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:41:00', 12, 9, 2, 22, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:49:00', 12, 9, 1, 22, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:39:00', 12, 9, 2, 32, null),
  ('2026-08-06', 'FALTO', false, 'NINGUNA', '2026-08-06 06:43:00', 12, 9, 1, 43, 19),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:40:00', 12, 9, 2, 39, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:44:00', 12, 9, 1, 25, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:44:00', 12, 9, 2, 21, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:43:00', 13, 9, 1, 44, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:40:00', 13, 9, 2, 46, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:45:00', 13, 9, 1, 31, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:44:00', 13, 9, 2, 35, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:50:00', 13, 9, 1, 12, null),
  ('2026-08-05', 'EVASION', false, 'NINGUNA', '2026-08-05 07:41:00', 13, 9, 2, 49, 26),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:45:00', 13, 9, 1, 42, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:35:00', 13, 9, 2, 28, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:45:00', 13, 9, 1, 22, null),
  ('2026-08-07', 'FALTO', true, 'MEDICA', '2026-08-07 07:42:00', 13, 9, 2, 8, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:44:00', 14, 9, 1, 40, null),
  ('2026-08-03', 'EVASION', false, 'NINGUNA', '2026-08-03 07:36:00', 14, 9, 2, 27, 2),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:46:00', 14, 9, 1, 25, null),
  ('2026-08-04', 'EVASION', false, 'NINGUNA', '2026-08-04 07:39:00', 14, 9, 2, 6, 2),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:40:00', 14, 9, 1, 10, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:35:00', 14, 9, 2, 29, null),
  ('2026-08-06', 'RETARDO', false, 'NINGUNA', '2026-08-06 06:48:00', 14, 9, 1, 35, 2),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:44:00', 14, 9, 2, 40, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:49:00', 14, 9, 1, 9, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:36:00', 14, 9, 2, 32, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:41:00', 15, 9, 1, 12, null),
  ('2026-08-03', 'FALTO', true, 'PERMITIDA', '2026-08-03 07:41:00', 15, 9, 2, 8, 12),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:48:00', 15, 9, 1, 7, null),
  ('2026-08-04', 'FALTO', false, 'NINGUNA', '2026-08-04 07:41:00', 15, 9, 2, 29, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:47:00', 15, 9, 1, 18, null),
  ('2026-08-05', 'EVASION', false, 'NINGUNA', '2026-08-05 07:37:00', 15, 9, 2, 23, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:48:00', 15, 9, 1, 16, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:35:00', 15, 9, 2, 10, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:49:00', 15, 9, 1, 32, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 07:45:00', 15, 9, 2, 15, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 06:41:00', 16, 11, 11, 14, 14),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:39:00', 16, 11, 12, 35, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:42:00', 16, 11, 11, 19, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:39:00', 16, 11, 12, 7, null),
  ('2026-08-05', 'RETARDO', true, 'MEDICA', '2026-08-05 06:41:00', 16, 11, 11, 29, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:36:00', 16, 11, 12, 6, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:50:00', 16, 11, 11, 11, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:38:00', 16, 11, 12, 18, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:41:00', 16, 11, 11, 25, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:36:00', 16, 11, 12, 40, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:43:00', 17, 11, 11, 35, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:37:00', 17, 11, 12, 16, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:48:00', 17, 11, 11, 22, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:41:00', 17, 11, 12, 22, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:47:00', 17, 11, 11, 29, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:37:00', 17, 11, 12, 29, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:50:00', 17, 11, 11, 44, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:39:00', 17, 11, 12, 40, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:48:00', 17, 11, 11, 28, null),
  ('2026-08-07', 'FALTO', true, 'MEDICA', '2026-08-07 07:42:00', 17, 11, 12, 46, 8),
  ('2026-08-03', 'RETARDO', false, 'NINGUNA', '2026-08-03 06:42:00', 18, 11, 11, 23, 21),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:36:00', 18, 11, 12, 19, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:44:00', 18, 11, 11, 49, null),
  ('2026-08-04', 'FALTO', true, 'MEDICA', '2026-08-04 07:39:00', 18, 11, 12, 25, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:40:00', 18, 11, 11, 10, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:41:00', 18, 11, 12, 11, null),
  ('2026-08-06', 'RETARDO', false, 'NINGUNA', '2026-08-06 06:48:00', 18, 11, 11, 6, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:40:00', 18, 11, 12, 18, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:45:00', 18, 11, 11, 12, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:43:00', 18, 11, 12, 32, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:48:00', 19, 11, 11, 45, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:40:00', 19, 11, 12, 49, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:47:00', 19, 11, 11, 49, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:41:00', 19, 11, 12, 9, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:45:00', 19, 11, 11, 29, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:39:00', 19, 11, 12, 41, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:45:00', 19, 11, 11, 31, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:36:00', 19, 11, 12, 46, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:40:00', 19, 11, 11, 33, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:45:00', 19, 11, 12, 9, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:40:00', 20, 11, 11, 36, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:45:00', 20, 11, 12, 36, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:50:00', 20, 11, 11, 28, null),
  ('2026-08-04', 'EVASION', false, 'NINGUNA', '2026-08-04 07:38:00', 20, 11, 12, 33, 37),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:43:00', 20, 11, 11, 23, null),
  ('2026-08-05', 'EVASION', false, 'NINGUNA', '2026-08-05 07:45:00', 20, 11, 12, 6, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:48:00', 20, 11, 11, 36, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:41:00', 20, 11, 12, 47, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:43:00', 20, 11, 11, 50, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:37:00', 20, 11, 12, 25, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 06:46:00', 21, 15, 11, 41, 48),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:36:00', 21, 15, 12, 31, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:45:00', 21, 15, 11, 19, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:44:00', 21, 15, 12, 42, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 06:44:00', 21, 15, 11, 26, null),
  ('2026-08-05', 'EVASION', true, 'PERMITIDA', '2026-08-05 07:40:00', 21, 15, 12, 41, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:43:00', 21, 15, 11, 23, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:42:00', 21, 15, 12, 17, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:43:00', 21, 15, 11, 25, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:42:00', 21, 15, 12, 35, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:44:00', 22, 15, 11, 24, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:45:00', 22, 15, 12, 8, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:47:00', 22, 15, 11, 27, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:36:00', 22, 15, 12, 30, null),
  ('2026-08-05', 'RETARDO', false, 'NINGUNA', '2026-08-05 06:45:00', 22, 15, 11, 32, 29),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:45:00', 22, 15, 12, 23, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:40:00', 22, 15, 11, 39, null),
  ('2026-08-06', 'EVASION', true, 'MEDICA', '2026-08-06 07:44:00', 22, 15, 12, 26, null),
  ('2026-08-07', 'EVASION', false, 'NINGUNA', '2026-08-07 06:50:00', 22, 15, 11, 23, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:39:00', 22, 15, 12, 16, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:44:00', 23, 15, 11, 36, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:43:00', 23, 15, 12, 10, null),
  ('2026-08-04', 'FALTO', true, 'MEDICA', '2026-08-04 06:46:00', 23, 15, 11, 6, 27),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:36:00', 23, 15, 12, 45, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:48:00', 23, 15, 11, 50, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:43:00', 23, 15, 12, 6, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:40:00', 23, 15, 11, 8, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:45:00', 23, 15, 12, 14, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:47:00', 23, 15, 11, 9, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 07:36:00', 23, 15, 12, 34, null),
  ('2026-08-03', 'FALTO', true, 'PERMITIDA', '2026-08-03 06:42:00', 24, 15, 11, 37, 40),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:38:00', 24, 15, 12, 8, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:40:00', 24, 15, 11, 18, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:43:00', 24, 15, 12, 38, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:48:00', 24, 15, 11, 50, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 07:41:00', 24, 15, 12, 10, null),
  ('2026-08-06', 'RETARDO', false, 'NINGUNA', '2026-08-06 06:43:00', 24, 15, 11, 28, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:35:00', 24, 15, 12, 17, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:48:00', 24, 15, 11, 21, null),
  ('2026-08-07', 'EVASION', true, 'MEDICA', '2026-08-07 07:35:00', 24, 15, 12, 46, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:40:00', 25, 15, 11, 25, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:38:00', 25, 15, 12, 34, null),
  ('2026-08-04', 'EVASION', false, 'NINGUNA', '2026-08-04 06:47:00', 25, 15, 11, 12, 46),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:40:00', 25, 15, 12, 17, null),
  ('2026-08-05', 'FALTO', true, 'CALAMIDAD', '2026-08-05 06:41:00', 25, 15, 11, 14, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:35:00', 25, 15, 12, 38, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:42:00', 25, 15, 11, 44, null),
  ('2026-08-06', 'EVASION', false, 'NINGUNA', '2026-08-06 07:35:00', 25, 15, 12, 27, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 06:42:00', 25, 15, 11, 43, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:37:00', 25, 15, 12, 19, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:48:00', 26, 19, 11, 10, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 07:38:00', 26, 19, 12, 37, 45),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:42:00', 26, 19, 11, 37, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:36:00', 26, 19, 12, 38, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:45:00', 26, 19, 11, 41, null),
  ('2026-08-05', 'EVASION', true, 'PERMITIDA', '2026-08-05 07:44:00', 26, 19, 12, 44, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:44:00', 26, 19, 11, 37, null),
  ('2026-08-06', 'EVASION', false, 'NINGUNA', '2026-08-06 07:42:00', 26, 19, 12, 27, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:48:00', 26, 19, 11, 26, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:41:00', 26, 19, 12, 20, null),
  ('2026-08-03', 'FALTO', true, 'MEDICA', '2026-08-03 06:46:00', 27, 19, 11, 39, 30),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:40:00', 27, 19, 12, 43, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:44:00', 27, 19, 11, 41, null),
  ('2026-08-04', 'FALTO', true, 'CALAMIDAD', '2026-08-04 07:42:00', 27, 19, 12, 49, null),
  ('2026-08-05', 'EVASION', false, 'NINGUNA', '2026-08-05 06:46:00', 27, 19, 11, 22, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:41:00', 27, 19, 12, 31, null),
  ('2026-08-06', 'FALTO', false, 'NINGUNA', '2026-08-06 06:42:00', 27, 19, 11, 42, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:45:00', 27, 19, 12, 45, null),
  ('2026-08-07', 'FALTO', true, 'PERMITIDA', '2026-08-07 06:42:00', 27, 19, 11, 25, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:37:00', 27, 19, 12, 7, null),
  ('2026-08-03', 'FALTO', true, 'CALAMIDAD', '2026-08-03 06:48:00', 28, 19, 11, 20, 28),
  ('2026-08-03', 'EVASION', false, 'NINGUNA', '2026-08-03 07:35:00', 28, 19, 12, 49, null),
  ('2026-08-04', 'FALTO', false, 'NINGUNA', '2026-08-04 06:45:00', 28, 19, 11, 8, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:45:00', 28, 19, 12, 13, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:48:00', 28, 19, 11, 43, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:42:00', 28, 19, 12, 6, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:45:00', 28, 19, 11, 13, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:43:00', 28, 19, 12, 9, null),
  ('2026-08-07', 'FALTO', true, 'PERMITIDA', '2026-08-07 06:50:00', 28, 19, 11, 15, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:37:00', 28, 19, 12, 30, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:46:00', 29, 19, 11, 18, null),
  ('2026-08-03', 'EVASION', false, 'NINGUNA', '2026-08-03 07:37:00', 29, 19, 12, 35, 33),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 06:40:00', 29, 19, 11, 47, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:36:00', 29, 19, 12, 50, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 06:41:00', 29, 19, 11, 17, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 07:43:00', 29, 19, 12, 28, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 06:47:00', 29, 19, 11, 8, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:37:00', 29, 19, 12, 19, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:49:00', 29, 19, 11, 31, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:40:00', 29, 19, 12, 19, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 06:42:00', 30, 19, 11, 37, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 07:41:00', 30, 19, 12, 26, null),
  ('2026-08-04', 'FALTO', true, 'CALAMIDAD', '2026-08-04 06:45:00', 30, 19, 11, 13, 31),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 07:35:00', 30, 19, 12, 33, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 06:47:00', 30, 19, 11, 10, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 07:42:00', 30, 19, 12, 10, null),
  ('2026-08-06', 'EVASION', true, 'MEDICA', '2026-08-06 06:43:00', 30, 19, 11, 21, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 07:36:00', 30, 19, 12, 32, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 06:45:00', 30, 19, 11, 8, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 07:43:00', 30, 19, 12, 47, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:48:00', 31, 28, 6, 7, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 13:38:00', 31, 28, 7, 12, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:40:00', 31, 28, 6, 18, null),
  ('2026-08-04', 'EVASION', false, 'NINGUNA', '2026-08-04 13:37:00', 31, 28, 7, 17, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:42:00', 31, 28, 6, 12, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:37:00', 31, 28, 7, 6, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:41:00', 31, 28, 6, 11, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:37:00', 31, 28, 7, 44, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:41:00', 31, 28, 6, 38, null),
  ('2026-08-07', 'EVASION', false, 'NINGUNA', '2026-08-07 13:44:00', 31, 28, 7, 7, null),
  ('2026-08-03', 'RETARDO', true, 'CALAMIDAD', '2026-08-03 12:48:00', 32, 28, 6, 31, 24),
  ('2026-08-03', 'FALTO', true, 'CALAMIDAD', '2026-08-03 13:40:00', 32, 28, 7, 14, null),
  ('2026-08-04', 'FALTO', false, 'NINGUNA', '2026-08-04 12:42:00', 32, 28, 6, 17, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:38:00', 32, 28, 7, 50, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 12:50:00', 32, 28, 6, 50, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:42:00', 32, 28, 7, 40, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:46:00', 32, 28, 6, 8, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:35:00', 32, 28, 7, 29, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:42:00', 32, 28, 6, 24, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 13:40:00', 32, 28, 7, 24, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:44:00', 33, 28, 6, 14, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 13:36:00', 33, 28, 7, 46, 3),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:49:00', 33, 28, 6, 46, null),
  ('2026-08-04', 'EVASION', false, 'NINGUNA', '2026-08-04 13:45:00', 33, 28, 7, 34, 3),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:40:00', 33, 28, 6, 23, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 13:42:00', 33, 28, 7, 11, 3),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:43:00', 33, 28, 6, 31, null),
  ('2026-08-06', 'FALTO', false, 'NINGUNA', '2026-08-06 13:40:00', 33, 28, 7, 7, 15),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:46:00', 33, 28, 6, 29, null),
  ('2026-08-07', 'EVASION', true, 'MEDICA', '2026-08-07 13:35:00', 33, 28, 7, 27, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:43:00', 34, 28, 6, 20, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:42:00', 34, 28, 7, 49, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:46:00', 34, 28, 6, 40, null),
  ('2026-08-04', 'FALTO', false, 'NINGUNA', '2026-08-04 13:35:00', 34, 28, 7, 45, 10),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 12:44:00', 34, 28, 6, 22, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:44:00', 34, 28, 7, 25, null),
  ('2026-08-06', 'FALTO', true, 'CALAMIDAD', '2026-08-06 12:47:00', 34, 28, 6, 17, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:41:00', 34, 28, 7, 40, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:42:00', 34, 28, 6, 32, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:45:00', 34, 28, 7, 6, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:46:00', 35, 28, 6, 38, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:41:00', 35, 28, 7, 28, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:44:00', 35, 28, 6, 40, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:43:00', 35, 28, 7, 39, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:50:00', 35, 28, 6, 21, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:37:00', 35, 28, 7, 17, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:50:00', 35, 28, 6, 40, null),
  ('2026-08-06', 'EVASION', false, 'NINGUNA', '2026-08-06 13:40:00', 35, 28, 7, 21, 47),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 12:49:00', 35, 28, 6, 37, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:35:00', 35, 28, 7, 7, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 12:47:00', 36, 38, 15, 32, 18),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:35:00', 36, 38, 16, 17, null),
  ('2026-08-04', 'FALTO', false, 'NINGUNA', '2026-08-04 12:42:00', 36, 38, 15, 6, null),
  ('2026-08-04', 'FALTO', true, 'CALAMIDAD', '2026-08-04 13:45:00', 36, 38, 16, 33, null),
  ('2026-08-05', 'EVASION', true, 'PERMITIDA', '2026-08-05 12:48:00', 36, 38, 15, 22, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:42:00', 36, 38, 16, 39, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:46:00', 36, 38, 15, 15, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:39:00', 36, 38, 16, 19, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:47:00', 36, 38, 15, 34, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:41:00', 36, 38, 16, 23, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:50:00', 37, 38, 15, 19, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:42:00', 37, 38, 16, 34, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:42:00', 37, 38, 15, 11, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:40:00', 37, 38, 16, 19, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 12:44:00', 37, 38, 15, 25, 36),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:44:00', 37, 38, 16, 48, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:42:00', 37, 38, 15, 47, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:37:00', 37, 38, 16, 10, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:49:00', 37, 38, 15, 42, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:38:00', 37, 38, 16, 19, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:42:00', 38, 38, 15, 33, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:43:00', 38, 38, 16, 32, null),
  ('2026-08-04', 'EVASION', true, 'CALAMIDAD', '2026-08-04 12:47:00', 38, 38, 15, 11, 34),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:38:00', 38, 38, 16, 13, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:49:00', 38, 38, 15, 23, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 13:40:00', 38, 38, 16, 48, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:50:00', 38, 38, 15, 14, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:44:00', 38, 38, 16, 29, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:42:00', 38, 38, 15, 9, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:37:00', 38, 38, 16, 27, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:45:00', 39, 38, 15, 37, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:38:00', 39, 38, 16, 36, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:46:00', 39, 38, 15, 19, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:37:00', 39, 38, 16, 33, null),
  ('2026-08-05', 'FALTO', true, 'MEDICA', '2026-08-05 12:44:00', 39, 38, 15, 26, 11),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:36:00', 39, 38, 16, 10, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:49:00', 39, 38, 15, 24, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:44:00', 39, 38, 16, 33, null),
  ('2026-08-07', 'EVASION', false, 'NINGUNA', '2026-08-07 12:48:00', 39, 38, 15, 24, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:35:00', 39, 38, 16, 7, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:44:00', 40, 38, 15, 39, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:39:00', 40, 38, 16, 40, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:40:00', 40, 38, 15, 13, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:38:00', 40, 38, 16, 10, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 12:40:00', 40, 38, 15, 22, 9),
  ('2026-08-05', 'FALTO', true, 'PERMITIDA', '2026-08-05 13:38:00', 40, 38, 16, 35, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:41:00', 40, 38, 15, 44, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:45:00', 40, 38, 16, 50, null),
  ('2026-08-07', 'RETARDO', false, 'NINGUNA', '2026-08-07 12:40:00', 40, 38, 15, 10, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:44:00', 40, 38, 16, 27, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:44:00', 41, 42, 15, 22, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:36:00', 41, 42, 16, 29, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:45:00', 41, 42, 15, 37, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:45:00', 41, 42, 16, 21, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:50:00', 41, 42, 15, 14, null),
  ('2026-08-05', 'FALTO', true, 'CALAMIDAD', '2026-08-05 13:40:00', 41, 42, 16, 24, 17),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:40:00', 41, 42, 15, 46, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:37:00', 41, 42, 16, 47, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 12:48:00', 41, 42, 15, 45, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 13:39:00', 41, 42, 16, 43, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:43:00', 42, 42, 15, 10, null),
  ('2026-08-03', 'FALTO', true, 'MEDICA', '2026-08-03 13:45:00', 42, 42, 16, 20, 22),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:46:00', 42, 42, 15, 47, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:42:00', 42, 42, 16, 42, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:41:00', 42, 42, 15, 32, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:39:00', 42, 42, 16, 15, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:44:00', 42, 42, 15, 22, null),
  ('2026-08-06', 'EVASION', false, 'NINGUNA', '2026-08-06 13:40:00', 42, 42, 16, 43, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:49:00', 42, 42, 15, 38, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:41:00', 42, 42, 16, 29, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:45:00', 43, 42, 15, 33, null),
  ('2026-08-03', 'FALTO', false, 'NINGUNA', '2026-08-03 13:40:00', 43, 42, 16, 17, 35),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:45:00', 43, 42, 15, 33, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:43:00', 43, 42, 16, 32, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:44:00', 43, 42, 15, 7, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:41:00', 43, 42, 16, 11, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:47:00', 43, 42, 15, 29, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:44:00', 43, 42, 16, 50, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:46:00', 43, 42, 15, 47, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:44:00', 43, 42, 16, 40, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:50:00', 44, 42, 15, 25, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:38:00', 44, 42, 16, 10, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:41:00', 44, 42, 15, 23, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:35:00', 44, 42, 16, 37, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:47:00', 44, 42, 15, 34, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:45:00', 44, 42, 16, 41, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:46:00', 44, 42, 15, 47, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:43:00', 44, 42, 16, 6, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:44:00', 44, 42, 15, 10, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:36:00', 44, 42, 16, 20, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:50:00', 45, 42, 15, 22, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:41:00', 45, 42, 16, 45, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:46:00', 45, 42, 15, 20, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:39:00', 45, 42, 16, 18, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 12:45:00', 45, 42, 15, 23, 23),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 13:36:00', 45, 42, 16, 38, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:47:00', 45, 42, 15, 28, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:43:00', 45, 42, 16, 13, null),
  ('2026-08-07', 'RETARDO', true, 'PERMITIDA', '2026-08-07 12:44:00', 45, 42, 15, 50, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:39:00', 45, 42, 16, 10, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:42:00', 46, 46, 15, 6, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:39:00', 46, 46, 16, 41, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:50:00', 46, 46, 15, 27, null),
  ('2026-08-04', 'FALTO', true, 'CALAMIDAD', '2026-08-04 13:45:00', 46, 46, 16, 29, 7),
  ('2026-08-05', 'RETARDO', false, 'NINGUNA', '2026-08-05 12:49:00', 46, 46, 15, 49, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:36:00', 46, 46, 16, 37, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:48:00', 46, 46, 15, 37, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:44:00', 46, 46, 16, 42, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:46:00', 46, 46, 15, 48, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:44:00', 46, 46, 16, 35, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:50:00', 47, 46, 15, 28, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:40:00', 47, 46, 16, 32, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:45:00', 47, 46, 15, 29, null),
  ('2026-08-04', 'EVASION', false, 'NINGUNA', '2026-08-04 13:43:00', 47, 46, 16, 18, 4),
  ('2026-08-05', 'RETARDO', false, 'NINGUNA', '2026-08-05 12:50:00', 47, 46, 15, 50, 4),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:45:00', 47, 46, 16, 32, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:48:00', 47, 46, 15, 40, null),
  ('2026-08-06', 'FALTO', false, 'NINGUNA', '2026-08-06 13:38:00', 47, 46, 16, 10, 4),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:42:00', 47, 46, 15, 22, null),
  ('2026-08-07', 'FALTO', false, 'NINGUNA', '2026-08-07 13:42:00', 47, 46, 16, 10, 42),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:44:00', 48, 46, 15, 39, null),
  ('2026-08-03', 'EVASION', true, 'PERMITIDA', '2026-08-03 13:39:00', 48, 46, 16, 8, 16),
  ('2026-08-04', 'FALTO', true, 'CALAMIDAD', '2026-08-04 12:49:00', 48, 46, 15, 11, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 13:37:00', 48, 46, 16, 45, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:45:00', 48, 46, 15, 35, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:40:00', 48, 46, 16, 39, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:47:00', 48, 46, 15, 35, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:40:00', 48, 46, 16, 50, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:47:00', 48, 46, 15, 43, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:36:00', 48, 46, 16, 30, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:49:00', 49, 46, 15, 17, null),
  ('2026-08-03', 'EVASION', true, 'PERMITIDA', '2026-08-03 13:43:00', 49, 46, 16, 18, 50),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:41:00', 49, 46, 15, 36, null),
  ('2026-08-04', 'EVASION', false, 'NINGUNA', '2026-08-04 13:36:00', 49, 46, 16, 23, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:41:00', 49, 46, 15, 13, null),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 13:38:00', 49, 46, 16, 37, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:47:00', 49, 46, 15, 18, null),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 13:42:00', 49, 46, 16, 50, null),
  ('2026-08-07', 'EVASION', false, 'NINGUNA', '2026-08-07 12:44:00', 49, 46, 15, 35, null),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 13:38:00', 49, 46, 16, 11, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 12:44:00', 50, 46, 15, 29, null),
  ('2026-08-03', 'ASISTIO', false, 'NINGUNA', '2026-08-03 13:43:00', 50, 46, 16, 37, null),
  ('2026-08-04', 'ASISTIO', false, 'NINGUNA', '2026-08-04 12:43:00', 50, 46, 15, 17, null),
  ('2026-08-04', 'FALTO', false, 'NINGUNA', '2026-08-04 13:35:00', 50, 46, 16, 24, 5),
  ('2026-08-05', 'ASISTIO', false, 'NINGUNA', '2026-08-05 12:40:00', 50, 46, 15, 42, null),
  ('2026-08-05', 'FALTO', false, 'NINGUNA', '2026-08-05 13:43:00', 50, 46, 16, 16, 5),
  ('2026-08-06', 'ASISTIO', false, 'NINGUNA', '2026-08-06 12:43:00', 50, 46, 15, 13, null),
  ('2026-08-06', 'EVASION', false, 'NINGUNA', '2026-08-06 13:38:00', 50, 46, 16, 27, 5),
  ('2026-08-07', 'ASISTIO', false, 'NINGUNA', '2026-08-07 12:48:00', 50, 46, 15, 19, null),
  ('2026-08-07', 'EVASION', true, 'MEDICA', '2026-08-07 13:44:00', 50, 46, 16, 27, 43);


-- Tabla de auditoría 
drop table if exists auditoria_asistencia;
create table auditoria_asistencia (
    idauditoria      int           not null auto_increment,
    accion           enum('MODIFICAR','ELIMINAR') not null,
    campomodificado  varchar(50)   not null,
    valoranterior    varchar(255)  null,
    valornuevo       varchar(255)  null,
    motivo           varchar(255)  not null,
    fechahora        datetime      not null default current_timestamp,
    idasistencia     int           not null,
    idestudiante     int           not null,
    idusuario        int           not null,
    constraint pk_auditoria primary key (idauditoria),
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

-- 03 TRIGGERS
drop trigger if exists trg_asistenciavalidar;
drop trigger if exists trg_asistencia_alertacitacion;
drop trigger if exists trg_auditoria_modificacion;
drop trigger if exists trg_auditoria_eliminacion;

-- Trigger 1 : valida el registro antes de guardarlo
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
delimiter ;

-- Trigger 2 : cuenta las novedades no justificadas que aún no cubre ninguna citación y, al llegar a 3, crea una citación PENDIENTE como alerta

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
delimiter ;

-- Trigger 3: una fila de auditoría por cada campo que cambie
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
delimiter ;

-- Trigger 4 : deja constancia del registro borrado, quién lo borró y por qué
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

-- 04 PROCEDIMIENTOS
drop procedure if exists sp_verificarrol;
drop procedure if exists sp_autenticar;
drop procedure if exists sp_crearusuario;
drop procedure if exists sp_asignarrol;
drop procedure if exists sp_cambiarestadousuario;
drop procedure if exists sp_consultarestadousuario;
drop procedure if exists sp_actualizarusuario;
drop procedure if exists sp_actualizaracudiente;
drop procedure if exists sp_actualizarestudiante;
drop procedure if exists sp_cambiarcurso;
drop procedure if exists sp_cambiarestadoestudiante;
drop procedure if exists sp_desactivar_estudiante;
drop procedure if exists sp_registrarasistencia;
drop procedure if exists sp_actualizarasistencia;
drop procedure if exists sp_justificarasistencia;
drop procedure if exists sp_eliminarasistencia;
drop procedure if exists sp_crearcitacion;
drop procedure if exists sp_realizarcitacion;
drop procedure if exists sp_inasistenciasporcurso;
drop procedure if exists sp_cursomasinasistencias;
drop procedure if exists sp_rankingausentismo;

-- 4.1 Control de acceso 
-- verifica que haya un usuario autenticado, activo y con el rol pedido

delimiter //
create procedure sp_verificarrol(in p_rol varchar(20))
begin
    declare v_rol    varchar(20);
    declare v_activo boolean;

    if @usuario_actual is null then
        signal sqlstate '45000' set message_text = 'Debe autenticarse antes de realizar esta operación', mysql_errno = 5001;
    end if;

    select rol, activo into v_rol, v_activo from usuario where idusuario = @usuario_actual;

    if v_rol is null or v_activo = false then
        signal sqlstate '45000' set message_text = 'El usuario autenticado no existe o está inactivo', mysql_errno = 5002;
    end if;
    if p_rol = 'COORDINADOR' and v_rol <> 'COORDINADOR' then
        signal sqlstate '45000' set message_text = 'Operación permitida solo para coordinadores', mysql_errno = 5003;
    end if;
end //
delimiter ;

-- autentica por correo y contraseña y ademas fija la sesión
delimiter //
create procedure sp_autenticar(in p_correo varchar(100), in p_clave varchar(100))
begin
    declare v_id  int;
    declare v_rol varchar(20);

    select idusuario, rol into v_id, v_rol
    from usuario
    where correo = p_correo and contrasena = sha2(p_clave, 256) and activo = true;

    if v_id is null then
        set @usuario_actual = null;
        set @rol_actual = null;
        signal sqlstate '45000' set message_text = 'Credenciales inválidas o usuario inactivo', mysql_errno = 5004;
    end if;

    set @usuario_actual = v_id;
    set @rol_actual = v_rol;
    select v_id as idusuario, v_rol as rol, 'Sesión iniciada' as mensaje;
end //
delimiter ;

-- 4.2 Usuarios · 
-- crea el usuario con validación de datos y únicos
delimiter //
create procedure sp_crearusuario(
    in p_documento varchar(20),
    in p_nombres   varchar(60),
    in p_apellidos varchar(60),
    in p_correo    varchar(100),
    in p_clave     varchar(100))
begin
    call sp_verificarrol('COORDINADOR');

    if coalesce(trim(p_documento), '') = '' or coalesce(trim(p_nombres), '') = ''
       or coalesce(trim(p_apellidos), '') = '' or coalesce(trim(p_correo), '') = ''
       or coalesce(trim(p_clave), '') = '' then
        signal sqlstate '45000' set message_text = 'Faltan datos obligatorios del usuario', mysql_errno = 5103;
    end if;
    if p_correo not like '%_@_%._%' then
        signal sqlstate '45000' set message_text = 'El correo no es válido', mysql_errno = 5104;
    end if;
    if exists (select 1 from usuario where numerodocumentoUsu = p_documento) then
        signal sqlstate '45000' set message_text = 'El usuario ya se encuentra registrado', mysql_errno = 5101;
    end if;
    if exists (select 1 from usuario where correo = p_correo) then
        signal sqlstate '45000' set message_text = 'Ya existe un usuario con ese correo', mysql_errno = 5102;
    end if;

    insert into usuario (numerodocumentoUsu, nombres, apellidos, correo, contrasena, rol, activo)
    values (p_documento, p_nombres, p_apellidos, p_correo, sha2(p_clave, 256), 'MAESTRO', true);
end //
delimiter ;

-- asigna o modifica el rol (solo coordinador)
delimiter //
create procedure sp_asignarrol(in p_documento varchar(20), in p_rol varchar(20))
begin
    call sp_verificarrol('COORDINADOR');

    if not exists (select 1 from usuario where numerodocumentoUsu = p_documento) then
        signal sqlstate '45000' set message_text = 'El usuario no existe', mysql_errno = 5106;
    end if;
    if p_rol is null or p_rol not in ('COORDINADOR', 'MAESTRO') then
        signal sqlstate '45000' set message_text = 'Rol no válido: use COORDINADOR o MAESTRO', mysql_errno = 5105;
    end if;

    update usuario set rol = p_rol where numerodocumentoUsu = p_documento;
end //
delimiter ;

-- activa (true) o desactiva (false) la cuenta
delimiter //
create procedure sp_cambiarestadousuario(in p_documento varchar(20), in p_activo boolean)
begin
    call sp_verificarrol('COORDINADOR');

    if not exists (select 1 from usuario where numerodocumentoUsu = p_documento) then
        signal sqlstate '45000' set message_text = 'El usuario no existe', mysql_errno = 5106;
    end if;

    update usuario set activo = p_activo where numerodocumentoUsu = p_documento;
end //
delimiter ;

--  consulta rol y estado del usuario
delimiter //
create procedure sp_consultarestadousuario(in p_documento varchar(20))
begin
    call sp_verificarrol('CUALQUIERA');

    if not exists (select 1 from usuario where numerodocumentoUsu = p_documento) then
        signal sqlstate '45000' set message_text = 'El usuario no existe', mysql_errno = 5106;
    end if;

    select numerodocumentoUsu as documento,
           concat(nombres, ' ', apellidos) as usuario,
           rol,
           if(activo, 'ACTIVO', 'INACTIVO') as estado
    from usuario
    where numerodocumentoUsu = p_documento;
end //
delimiter ;

-- actualiza datos del usuario (null = conservar el valor actual)
delimiter //
create procedure sp_actualizarusuario(
    in p_documento varchar(20),
    in p_nombres   varchar(60),
    in p_apellidos varchar(60),
    in p_correo    varchar(100))
begin
    call sp_verificarrol('COORDINADOR');

    if not exists (select 1 from usuario where numerodocumentoUsu = p_documento) then
        signal sqlstate '45000' set message_text = 'El usuario no existe', mysql_errno = 5106;
    end if;
    if p_correo is not null and p_correo not like '%_@_%._%' then
        signal sqlstate '45000' set message_text = 'El correo no es válido', mysql_errno = 5104;
    end if;
    if p_correo is not null and exists (select 1 from usuario
                                        where correo = p_correo and numerodocumentoUsu <> p_documento) then
        signal sqlstate '45000' set message_text = 'Ya existe un usuario con ese correo', mysql_errno = 5102;
    end if;

    update usuario
    set nombres   = coalesce(nullif(trim(p_nombres), ''), nombres),
        apellidos = coalesce(nullif(trim(p_apellidos), ''), apellidos),
        correo    = coalesce(p_correo, correo)
    where numerodocumentoUsu = p_documento;
end //
delimiter ;

-- 4.3 Estudiantes y acudientes ·
--  actualiza datos personales y de contacto del acudiente
delimiter //
create procedure sp_actualizaracudiente(
    in p_documento  varchar(20),
    in p_nombres    varchar(60),
    in p_apellidos  varchar(60),
    in p_parentesco varchar(30),
    in p_telefono   varchar(15),
    in p_correo     varchar(100),
    in p_direccion  varchar(120))
begin
    call sp_verificarrol('COORDINADOR');

    if not exists (select 1 from acudiente where numerodocumentoAcu = p_documento) then
        signal sqlstate '45000' set message_text = 'El acudiente no existe', mysql_errno = 5201;
    end if;
    if p_correo is not null and p_correo not like '%_@_%._%' then
        signal sqlstate '45000' set message_text = 'El correo no es válido', mysql_errno = 5104;
    end if;

    update acudiente
    set nombres = coalesce(nullif(trim(p_nombres), ''), nombres),
        apellidos = coalesce(nullif(trim(p_apellidos), ''), apellidos),
        parentesco = coalesce(nullif(trim(p_parentesco), ''), parentesco),
        telefono = coalesce(nullif(trim(p_telefono), ''), telefono),
        correo  = coalesce(p_correo, correo),
        direccion = coalesce(p_direccion, direccion)
    where numerodocumentoAcu = p_documento;
end //
delimiter ;

-- actualiza datos personales del estudiante (y su acudiente asociado)
delimiter //
create procedure sp_actualizarestudiante(
    in p_idestudiante  int,
    in p_nombres varchar(60),
    in p_apellidos varchar(60),
    in p_fechanacimiento date,
    in p_idacudiente int)
begin
    call sp_verificarrol('COORDINADOR');

    if not exists (select 1 from estudiante where idestudiante = p_idestudiante) then
        signal sqlstate '45000' set message_text = 'El estudiante no existe', mysql_errno = 5202;
    end if;
    if p_idacudiente is not null and not exists (select 1 from acudiente where idacudiente = p_idacudiente) then
        signal sqlstate '45000' set message_text = 'El acudiente no existe', mysql_errno = 5201;
    end if;

    update estudiante
    set nombres = coalesce(nullif(trim(p_nombres), ''), nombres),
        apellidos = coalesce(nullif(trim(p_apellidos), ''), apellidos),
        fechanacimiento = coalesce(p_fechanacimiento, fechanacimiento),
        idacudiente = coalesce(p_idacudiente, idacudiente)
    where idestudiante = p_idestudiante;
end //
delimiter ;

--  cambia el curso del estudiante la asistencia ya registrada conserva el curso en que se tomó
delimiter //
create procedure sp_cambiarcurso(in p_idestudiante int, in p_idcurso int)
begin
    declare v_cursoactual int;

    call sp_verificarrol('COORDINADOR');

    select idcurso into v_cursoactual from estudiante where idestudiante = p_idestudiante;
    if v_cursoactual is null then
        signal sqlstate '45000' set message_text = 'El estudiante no existe', mysql_errno = 5202;
    end if;
    if not exists (select 1 from curso where idcurso = p_idcurso and activo = true) then
        signal sqlstate '45000' set message_text = 'El curso no existe o está inactivo', mysql_errno = 5203;
    end if;
    if v_cursoactual = p_idcurso then
        signal sqlstate '45000' set message_text = 'El estudiante ya pertenece a ese curso', mysql_errno = 5204;
    end if;

    update estudiante set idcurso = p_idcurso where idestudiante = p_idestudiante;
end //
delimiter ;

--  activa o desactiva al estudiante conservando su historial
delimiter //
create procedure sp_cambiarestadoestudiante(in p_idestudiante int, in p_activo boolean)
begin
    call sp_verificarrol('COORDINADOR');

    if not exists (select 1 from estudiante where idestudiante = p_idestudiante) then
        signal sqlstate '45000' set message_text = 'El estudiante no existe', mysql_errno = 5202;
    end if;

    update estudiante set activo = p_activo where idestudiante = p_idestudiante;
end //
delimiter ;

-- se conserva el procedimiento original para no romper llamadas existentes
delimiter //
create procedure sp_desactivar_estudiante(in p_idestudiante int)
begin
    call sp_cambiarestadoestudiante(p_idestudiante, false);
end //
delimiter ;

-- 4.4 Asistencia  
-- registra la asistencia; el curso se toma del estudiante  y la fecha/hora de registro la pone la base de datos
delimiter //
create procedure sp_registrarasistencia(
    in p_idestudiante int,
    in p_fecha   date,
    in p_idbloque int,
    in p_categoria varchar(10),
    in p_idusuario int)
begin
    if not exists (select 1 from estudiante where idestudiante = p_idestudiante) then
        signal sqlstate '45000' set message_text = 'El estudiante no existe', mysql_errno = 5202;
    end if;
    if p_categoria is null or p_categoria not in ('ASISTIO', 'FALTO', 'RETARDO', 'EVASION') then
        signal sqlstate '45000' set message_text = 'Categoría no válida: ASISTIO, FALTO, RETARDO o EVASION', mysql_errno = 5301;
    end if;

    insert into asistencia (fecha, categoria, idestudiante, idcurso, idbloque, idusuario)
    select p_fecha, p_categoria, e.idestudiante, e.idcurso, p_idbloque, p_idusuario
    from estudiante e
    where e.idestudiante = p_idestudiante;
end //
delimiter ;

-- modifica categoría y/o justificación (null = conservar)  exige motivo y el trigger 3 deja la auditoría
delimiter //
create procedure sp_actualizarasistencia(
    in p_idasistencia  int,
    in p_categoria varchar(10),
    in p_justificada boolean,
    in p_justificacion varchar(10),
    in p_motivo varchar(255))
begin
    declare v_cat varchar(10);
    declare v_jus boolean;
    declare v_tipo varchar(10);
    declare exit handler for sqlexception
    begin
        set @motivo_cambio = null;
        resignal;
    end;

    call sp_verificarrol('CUALQUIERA');

    select categoria, justificada, justificacion into v_cat, v_jus, v_tipo
    from asistencia where idasistencia = p_idasistencia;

    if v_cat is null then
        signal sqlstate '45000' set message_text = 'El registro de asistencia no existe', mysql_errno = 5302;
    end if;
    if coalesce(trim(p_motivo), '') = '' then
        signal sqlstate '45000' set message_text = 'Debe indicar el motivo del cambio', mysql_errno = 5303;
    end if;
    if p_categoria is not null and p_categoria not in ('ASISTIO', 'FALTO', 'RETARDO', 'EVASION') then
        signal sqlstate '45000' set message_text = 'Categoría no válida: ASISTIO, FALTO, RETARDO o EVASION', mysql_errno = 5301;
    end if;
    if p_justificacion is not null and p_justificacion not in ('CALAMIDAD', 'MEDICA', 'PERMITIDA', 'NINGUNA') then
        signal sqlstate '45000' set message_text = 'Justificación no válida: CALAMIDAD, MEDICA, PERMITIDA o NINGUNA', mysql_errno = 5304;
    end if;

    set v_cat  = coalesce(p_categoria, v_cat);
    set v_jus  = coalesce(p_justificada, v_jus);
    set v_tipo = coalesce(p_justificacion, v_tipo);
    if v_jus = false then
        set v_tipo = 'NINGUNA';
    end if;
    if v_jus = true and (v_tipo = 'NINGUNA' or v_cat = 'ASISTIO') then
        signal sqlstate '45000' set message_text = 'Una justificación requiere tipo (CALAMIDAD, MEDICA o PERMITIDA) y una categoría distinta de ASISTIO', mysql_errno = 5305;
    end if;

    set @motivo_cambio = p_motivo;
    update asistencia
    set categoria = v_cat, justificada = v_jus, justificacion = v_tipo
    where idasistencia = p_idasistencia;
    set @motivo_cambio = null;
end //
delimiter ;

-- atajo para justificar una novedad ya registrada
delimiter //
create procedure sp_justificarasistencia(
    in p_idasistencia  int,
    in p_justificacion varchar(10),
    in p_motivo varchar(255))
begin
    call sp_actualizarasistencia(p_idasistencia, null, true, p_justificacion, p_motivo);
end //
delimiter ;

-- elimina un registro (solo coordinador) con motivo y el trigger 4 audita
-- los duplicados exactos los impide uq_asistencia (fecha, idestudiante, idbloque)
delimiter //
create procedure sp_eliminarasistencia(in p_idasistencia int, in p_motivo varchar(255))
begin
    declare exit handler for sqlexception
    begin
        set @motivo_cambio = null;
        resignal;
    end;

    call sp_verificarrol('COORDINADOR');

    if not exists (select 1 from asistencia where idasistencia = p_idasistencia) then
        signal sqlstate '45000' set message_text = 'El registro de asistencia no existe', mysql_errno = 5302;
    end if;
    if coalesce(trim(p_motivo), '') = '' then
        signal sqlstate '45000' set message_text = 'Debe indicar el motivo de la eliminación', mysql_errno = 5303;
    end if;

    set @motivo_cambio = p_motivo;
    delete from asistencia where idasistencia = p_idasistencia;
    set @motivo_cambio = null;
end //
delimiter ;

-- 4.5 Citaciones 
-- crea la citación (PENDIENTE) y devuelve el contacto del acudiente
delimiter //
create procedure sp_crearcitacion(in p_idestudiante int, in p_fecha date, in p_motivo varchar(255))
begin
    declare v_id int;

    call sp_verificarrol('COORDINADOR');

    if not exists (select 1 from estudiante where idestudiante = p_idestudiante) then
        signal sqlstate '45000' set message_text = 'El estudiante no existe', mysql_errno = 5202;
    end if;
    if p_fecha is null or coalesce(trim(p_motivo), '') = '' then
        signal sqlstate '45000' set message_text = 'La citación requiere fecha y motivo', mysql_errno = 5401;
    end if;

    insert into citacion (fechacitacion, motivo, estado, idestudiante)
    values (p_fecha, p_motivo, 'PENDIENTE', p_idestudiante);
    set v_id = last_insert_id();

    select c.idcitacion, c.fechacitacion, c.motivo, c.estado,
           concat(e.nombres, ' ', e.apellidos) as estudiante,
           concat(a.nombres, ' ', a.apellidos) as acudiente,
           a.parentesco, a.telefono, a.correo
    from citacion c
    join estudiante e on e.idestudiante = c.idestudiante
    join acudiente a on a.idacudiente  = e.idacudiente
    where c.idcitacion = v_id;
end //
delimiter ;

--  marca la citación como REALIZADA y vincula a ella las novedades no justificadas que cubría; así el conteo "desde la últimacitación" vuelve a cero y el trigger 2 no repite la alerta
delimiter //
create procedure sp_realizarcitacion(in p_idcitacion int)
begin
    declare v_est int;
    declare v_fecha date;
    declare v_estado varchar(10);
    declare exit handler for sqlexception
    begin
        set @motivo_cambio = null;
        resignal;
    end;

    call sp_verificarrol('COORDINADOR');

    select idestudiante, fechacitacion, estado into v_est, v_fecha, v_estado
    from citacion where idcitacion = p_idcitacion;

    if v_est is null then
        signal sqlstate '45000' set message_text = 'La citación no existe', mysql_errno = 5402;
    end if;
    if v_estado = 'REALIZADA' then
        signal sqlstate '45000' set message_text = 'La citación ya fue realizada', mysql_errno = 5403;
    end if;

    update citacion set estado = 'REALIZADA' where idcitacion = p_idcitacion;

    set @motivo_cambio = concat('Novedad cubierta por la citación ', p_idcitacion);
    update asistencia
    set idcitacion = p_idcitacion
    where idestudiante = v_est
      and categoria <> 'ASISTIO'
      and justificada = false
      and idcitacion is null
      and fecha <= v_fecha;
    set @motivo_cambio = null;
end //
delimiter ;

-- 4.6 Análisis 
-- total de inasistencias por curso, filtrado por jornada y periodo
delimiter //
create procedure sp_inasistenciasporcurso(in p_idjornada int, in p_desde date, in p_hasta date)
begin
    select c.nombre as curso, j.nombre as jornada, count(*) as inasistencias
    from asistencia a
    join curso c   on c.idcurso   = a.idcurso
    join jornada j on j.idjornada = c.idjornada
    where a.categoria = 'FALTO'
      and a.fecha between p_desde and p_hasta
      and (p_idjornada is null or c.idjornada = p_idjornada)
    group by c.idcurso, c.nombre, j.nombre
    order by inasistencias desc;
end //
delimiter ;

-- curso(s) con más inasistencias (devuelve todos si hay empate)
delimiter //
create procedure sp_cursomasinasistencias(in p_idjornada int, in p_desde date, in p_hasta date)
begin
    select c.nombre as curso, j.nombre as jornada, count(*) as inasistencias
    from asistencia a
    join curso c on c.idcurso   = a.idcurso
    join jornada j on j.idjornada = c.idjornada
    where a.categoria = 'FALTO'
      and a.fecha between p_desde and p_hasta
      and (p_idjornada is null or c.idjornada = p_idjornada)
    group by c.idcurso, c.nombre, j.nombre
    having count(*) = (
        select max(t.total)
        from (select count(*) as total
              from asistencia a2
              join curso c2 on c2.idcurso = a2.idcurso
              where a2.categoria = 'FALTO'
                and a2.fecha between p_desde and p_hasta
                and (p_idjornada is null or c2.idjornada = p_idjornada)
              group by a2.idcurso) t);
end //
delimiter ;

--  tasa de ausentismo por curso, de mayor a menor --> tasa = (faltas / registros de asistencia del periodo)
delimiter //
create procedure sp_rankingausentismo(in p_idjornada int, in p_desde date, in p_hasta date)
begin
    select c.nombre as curso,
           count(*) as registros,
           sum(a.categoria = 'FALTO') as inasistencias,
           round(100 * sum(a.categoria = 'FALTO') / count(*), 2) as tasa_ausentismo_pct
    from asistencia a
    join curso c on c.idcurso = a.idcurso
    where (p_idjornada is null or c.idjornada = p_idjornada)
      and a.fecha between p_desde and p_hasta
    group by c.idcurso, c.nombre
    order by tasa_ausentismo_pct desc;
end //
delimiter ;

-- 05 VISTAS

-- estudiantes activos con su curso, nivel y jornada
create or replace view vw_estudiantes_curso as
select e.idestudiante, e.tipodocumentoEst, e.numerodocumentoEst,
       e.nombres, e.apellidos,
       c.idcurso, c.nombre as curso, c.grado,
       n.idnivel, n.nombre as nivel,
       j.idjornada, j.nombre as jornada
from estudiante e
join curso c on c.idcurso = e.idcurso
join nivel n on n.idnivel = c.idnivel
join jornada j on j.idjornada = c.idjornada
where e.activo = true;

-- estudiantes con 3 o más novedades no justificadas desde su última citación, con el contacto del acudiente
create or replace view vw_alerta_citacion as
select e.idestudiante,
       concat(e.nombres, ' ', e.apellidos) as estudiante,
       c.nombre as curso,
       count(s.idasistencia) as novedades_sin_citar,
       (select count(*) from citacion ci
         where ci.idestudiante = e.idestudiante and ci.estado = 'PENDIENTE') as citaciones_pendientes,
       concat(a.nombres, ' ', a.apellidos) as acudiente,
       a.parentesco, a.telefono, a.correo
from estudiante e
join curso c on c.idcurso = e.idcurso
join acudiente a on a.idacudiente  = e.idacudiente
join asistencia s on s.idestudiante = e.idestudiante
                 and s.categoria <> 'ASISTIO'
                 and s.justificada = false
                 and s.idcitacion is null
group by e.idestudiante, e.nombres, e.apellidos, c.nombre,
         a.nombres, a.apellidos, a.parentesco, a.telefono, a.correo
having count(s.idasistencia) >= 3;

-- historial de cambios con responsable, estudiante y curso, el curso sale del registro de asistencia (no del curso actual del estudiante), así un cambio de curso no cambia el historial
create or replace view vw_historial_cambios as
select au.idauditoria, au.fechahora, au.accion, au.campomodificado,
       au.valoranterior, au.valornuevo, au.motivo,
       au.idasistencia, au.idestudiante,
       concat(e.nombres, ' ', e.apellidos) as estudiante,
       coalesce(s.idcurso, e.idcurso) as idcurso,
       c.nombre as curso,
       au.idusuario,
       concat(u.nombres, ' ', u.apellidos) as responsable,
       u.rol as rol_responsable
from auditoria_asistencia au
join usuario u  on u.idusuario = au.idusuario
left join estudiante e on e.idestudiante = au.idestudiante
left join asistencia s on s.idasistencia = au.idasistencia
left join curso c on c.idcurso = coalesce(s.idcurso, e.idcurso);

-- 06 CONSULTAS POR TABLA (con el RQF que cumple cada una)
-- jornada
-- listar las jornadas para seleccionar una
select * from jornada order by horainicioJor;
-- jornada en curso según la hora actual
select idjornada, nombre from jornada where curtime() between horainicioJor and horafinJor;
--  inasistencias y tasa de ausentismo de cada jornada
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
--  listar los niveles
select * from nivel order by nombre;
--  niveles cuyos bloques no coinciden con cantidadbloques
select n.nombre, b.idjornada, n.cantidadbloques, count(b.idbloque) as bloques_configurados
from nivel n join bloque b on b.idnivel = n.idnivel
group by n.idnivel, n.nombre, n.cantidadbloques, b.idjornada
having count(b.idbloque) <> n.cantidadbloques;

-- curso
-- cursos registrados
select * from curso;
-- cursos del nivel y la jornada seleccionados (primaria, mañana)
select idcurso, nombre, grado from curso
where idnivel = 1 and idjornada = 1 and activo = true order by grado, nombre;
-- cursos activos por jornada y nivel
select j.nombre as jornada, n.nombre as nivel, count(c.idcurso) as cursos
from curso c
join jornada j on j.idjornada = c.idjornada
join nivel n on n.idnivel = c.idnivel
where c.activo = true
group by j.idjornada, j.nombre, n.idnivel, n.nombre;
-- seleccionar un curso por nombre, jornada y año
select * from curso where nombre = '601' and idjornada = 1 and aniolectivo = 2026;
-- estudiantes activos del curso seleccionado 
select idestudiante, nombres, apellidos from vw_estudiantes_curso
where idcurso = 1 order by apellidos, nombres;
--  inasistencias por curso en un periodo y jornada (se agregó el filtro de jornada)
select c.nombre as curso, count(*) as inasistencias
from curso c join asistencia a on a.idcurso = c.idcurso
where a.categoria = 'FALTO' and a.fecha between '2026-08-01' and '2026-08-31'
  and c.idjornada = 1
group by c.idcurso, c.nombre order by inasistencias desc;

-- bloque
-- bloques configurados
select * from bloque;
--  bloques del nivel y la jornada seleccionados (bachillerato, tarde)
select idbloque, nombre, horainicioBlo, horafinBlo from bloque
where idnivel = 2 and idjornada = 2 order by numero;
-- bloque en curso según la hora actual (primaria, mañana)
select idbloque, nombre from bloque
where idnivel = 1 and idjornada = 1 and curtime() between horainicioBlo and horafinBlo;
--  bloques del mismo nivel y jornada que se cruzan
select b1.idbloque, b1.nombre, b2.idbloque as cruza_con, b2.nombre as nombre_cruce
from bloque b1 join bloque b2
  on b1.idnivel = b2.idnivel and b1.idjornada = b2.idjornada and b1.idbloque < b2.idbloque
 and b1.horainicioBlo < b2.horafinBlo and b2.horainicioBlo < b1.horafinBlo;
--  bloques fuera del horario de su jornada
select b.idbloque, b.nombre, j.nombre as jornada
from bloque b join jornada j on j.idjornada = b.idjornada
where b.horainicioBlo < j.horainicioJor or b.horafinBlo > j.horafinJor;

-- acudiente
-- acudientes registrados
select * from acudiente;
-- buscar un acudiente por documento (antes de sp_actualizaracudiente)
select idacudiente, nombres, apellidos, telefono, correo, direccion
from acudiente where numerodocumentoAcu = '52000000';
-- contacto del acudiente de un estudiante
select a.nombres, a.apellidos, a.parentesco, a.telefono, a.correo
from acudiente a join estudiante e on e.idacudiente = a.idacudiente
where e.idestudiante = 23;
-- acudientes sin correo (solo contacto telefónico)
select nombres, apellidos, telefono from acudiente where correo is null;

-- estudiante
-- estudiantes registrados
select * from estudiante;
-- estudiantes que cambiaron de curso
select distinct e.idestudiante, e.nombres, e.apellidos, s.idcurso as curso_anterior, e.idcurso as curso_actual
from estudiante e join asistencia s on s.idestudiante = e.idestudiante
where s.idcurso <> e.idcurso;
-- estudiantes inactivos que conservan su historial
select e.nombres, e.apellidos, count(s.idasistencia) as registros_conservados
from estudiante e left join asistencia s on s.idestudiante = e.idestudiante
where e.activo = false group by e.idestudiante, e.nombres, e.apellidos;
-- novedades sin justificar de cada estudiante desde su última citación
select e.idestudiante, e.nombres, e.apellidos, count(s.idasistencia) as novedades_sin_citar
from estudiante e left join asistencia s
  on s.idestudiante = e.idestudiante and s.categoria <> 'ASISTIO'
 and s.justificada = false and s.idcitacion is null
group by e.idestudiante, e.nombres, e.apellidos order by novedades_sin_citar desc;

-- usuario
-- usuarios registrados (sin la contraseña)
select idusuario, numerodocumentoUsu, nombres, apellidos, correo, rol, activo from usuario;
-- la autenticación ahora se hace con sp_autenticar(correo, clave)
-- usuarios por rol
select rol, count(*) as usuarios from usuario group by rol;
-- cuentas activas e inactivas
select activo, count(*) as usuarios from usuario group by activo;
-- coordinadores activos (pueden modificar roles y registros)
select idusuario, nombres, apellidos from usuario where rol = 'COORDINADOR' and activo = true;
-- usuarios inactivos cuyos registros se conservan
select u.nombres, u.apellidos, count(a.idasistencia) as registros
from usuario u left join asistencia a on a.idusuario = u.idusuario
where u.activo = false group by u.idusuario, u.nombres, u.apellidos;

-- citacion
--  citaciones registradas
select * from citacion;
-- citaciones pendientes
select idcitacion, idestudiante, fechacitacion, motivo from citacion
where estado = 'PENDIENTE' order by fechacitacion;
-- citaciones de un estudiante y su estado
select fechacitacion, motivo, estado from citacion where idestudiante = 26 order by fechacitacion;
-- citaciones realizadas en un periodo
select idcitacion, idestudiante, fechacitacion from citacion
where estado = 'REALIZADA' and fechacitacion between '2026-08-01' and '2026-08-31';
--  última citación de cada estudiante
select idestudiante, max(fechacitacion) as ultima_citacion from citacion group by idestudiante;
-- citaciones por estado
select estado, count(*) as citaciones from citacion group by estado;
-- alerta: estudiantes que requieren citación con datos del acudiente (NUEVA)
select * from vw_alerta_citacion order by novedades_sin_citar desc;

-- asistencia
-- registros de asistencia
select * from asistencia;
-- categorías configuradas
select column_type from information_schema.columns
where table_schema = 'colegio_mzo' and table_name = 'asistencia' and column_name = 'categoria';
--  trazabilidad: fecha, hora y usuario de cada registro
select a.idasistencia, a.fecha_hora_registro, u.nombres, u.apellidos
from asistencia a join usuario u on u.idusuario = a.idusuario order by a.fecha_hora_registro desc;
-- faltas, retardos y evasiones (dejar un solo valor en el IN para una categoría)
select fecha, categoria, idestudiante, idbloque from asistencia
where categoria in ('FALTO', 'RETARDO', 'EVASION') order by categoria, fecha;
-- justificaciones registradas
select fecha, idestudiante, categoria, justificacion from asistencia
where justificada = true order by fecha;
--  detectar duplicados (estudiante, curso, fecha, bloque); vacío gracias a uq_asistencia 
select idestudiante, idcurso, fecha, idbloque, count(*) as veces
from asistencia
group by idestudiante, idcurso, fecha, idbloque
having count(*) > 1;

-- auditoria_asistencia
-- cambios registrados con el nombre del responsable
select * from vw_historial_cambios order by fechahora;
-- cambios de un estudiante 
select fechahora, campomodificado, valoranterior, valornuevo, motivo, responsable
from vw_historial_cambios where idestudiante = 14 order by fechahora;
-- cambios de un curso (usa el curso del registro, no el actual del estudiante)
select fechahora, estudiante, campomodificado, valoranterior, valornuevo, motivo, responsable
from vw_historial_cambios where idcurso = 11 order by fechahora;
-- cambios en un rango de fechas
select * from vw_historial_cambios
where fechahora between '2026-08-04 00:00:00' and '2026-08-06 23:59:59' order by fechahora;
-- campo modificado con su valor anterior y nuevo
select campomodificado, valoranterior, valornuevo, count(*) as veces
from auditoria_asistencia group by campomodificado, valoranterior, valornuevo;
-- registros eliminados, quién y por qué
select idasistencia, valoranterior, motivo, responsable, fechahora
from vw_historial_cambios where accion = 'ELIMINAR';



-- 07 PRUEBAS (historias de usuario)
-- Sesión: coordinador Luis Moreno (idusuario 1)
call sp_autenticar('luis.moreno1@colegiomzo.edu.co', 'Clave01*');

-- gestión de usuarios 
delete from usuario where numerodocumentoUsu = '1023458789';
call sp_crearusuario('1023458789', 'Lau', 'Méndez Rojas', 'lau.mendez@mzo.edu.co', 'Clave2028*');
call sp_asignarrol('1023458789', 'MAESTRO');
call sp_consultarestadousuario('1023458789');   -- MAESTRO | ACTIVO
call sp_actualizarusuario('1023458789', 'Laura', null, 'laura.mendez@mzo.edu.co');
call sp_cambiarestadousuario('1023458789', false);
call sp_consultarestadousuario('1023458789');   -- MAESTRO | INACTIVO
call sp_crearusuario('1023458789', 'Otra', 'Persona', 'otra@mzo.edu.co', 'x'); -- error 5101: ya registrado
call sp_asignarrol('1023458789', 'RECTOR'); -- error 5105: rol no válido
call sp_consultarestadousuario('1015235012'); -- error 5106: no existe

--  un maestro no puede asignar roles
call sp_autenticar('ana.gonzalez6@colegiomzo.edu.co', 'Clave06*');
call sp_asignarrol('79050035', 'COORDINADOR');    -- error 5003: un maestro no puede asignar roles
call sp_autenticar('luis.moreno1@colegiomzo.edu.co', 'Clave01*'); -- para haerlo toca volver al coordinador

--  estudiantes y acudientes
call sp_actualizaracudiente('52000000', null, null, null, '3001112233', null, null);
call sp_cambiarcurso(3, 2);                      -- Julián Torres pasa de 101 a 102 (mañana)
call sp_cambiarestadoestudiante(3, false);  -- desactivar a Julián Mosquera momentaneamente
call sp_cambiarestadoestudiante(18, true);-- reactivar a Julián Mosquera
select idestudiante, nombres, idcurso, activo from estudiante where idestudiante in (3, 18);
-- lista del curso 501 mañana (idcurso 9)
select idestudiante, nombres, apellidos from vw_estudiantes_curso where idcurso = 9;

--  tres novedades generan la citación automática
-- Valentina Cuesta (id 7, curso 5, primaria mañana) no tiene novedades previas
call sp_registrarasistencia(7, '2026-08-10', 3, 'FALTO',   6);
call sp_registrarasistencia(7, '2026-08-10', 4, 'RETARDO', 6);
call sp_registrarasistencia(7, '2026-08-10', 5, 'EVASION', 6);
select * from citacion where idestudiante = 7;          -- citación PENDIENTE automática
select * from vw_alerta_citacion where idestudiante = 7; -- aparece con su acudiente
call sp_registrarasistencia(7, '2026-08-10', 5, 'FALTO', 6);   -- error: duplicado 
call sp_registrarasistencia(7, '2026-08-10', 11, 'FALTO', 6);  -- error: bloque de bachillerato
call sp_registrarasistencia(42, '2026-08-10', 15, 'FALTO', 6); -- error: estudiante inactivo

-- realizar la citación reinicia el conteo
set @cit = (select max(idcitacion) from citacion where idestudiante = 7);
call sp_realizarcitacion(@cit);
select * from vw_alerta_citacion where idestudiante = 7;   -- ya no aparece
select idasistencia, categoria, idcitacion from asistencia where idestudiante = 7 and idcitacion is not null;

-- citación manual con datos del acudiente
call sp_crearcitacion(12, '2026-08-14', 'Seguimiento solicitado por el director de curso');
--  justificar y corregir registros (queda auditado)
call sp_justificarasistencia(3, 'MEDICA', 'El acudiente presentó incapacidad médica');
call sp_actualizarasistencia(2, 'RETARDO', null, null, 'Llegó después del llamado de lista');
call sp_actualizarasistencia(2, null, true, 'NINGUNA', 'x');   -- error 5305

-- eliminar un registro erróneo (solo coordinador)
call sp_registrarasistencia(7, '2026-08-11', 1, 'ASISTIO', 6);
set @borrar = (select idasistencia from asistencia where idestudiante = 7 and fecha = '2026-08-11' and idbloque = 1);
call sp_eliminarasistencia(@borrar, 'Registro tomado en el curso equivocado');

-- historial de lo que se hizo en esta prueba
select fechahora, accion, estudiante, curso, campomodificado, valoranterior, valornuevo, motivo, responsable
from vw_historial_cambios where idestudiante in (1, 7) order by fechahora;

-- análisis de agosto, jornada mañana (null = todas)
call sp_inasistenciasporcurso(1, '2026-08-01', '2026-08-31');
call sp_cursomasinasistencias(1, '2026-08-01', '2026-08-31');
call sp_rankingausentismo(1, '2026-08-01', '2026-08-31');
call sp_cursomasinasistencias(null, '2026-08-01', '2026-08-31');

