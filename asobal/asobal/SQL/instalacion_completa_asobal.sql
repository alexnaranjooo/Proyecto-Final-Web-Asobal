-- ============================================================
-- INSTALACION COMPLETA ASOBAL
-- Importar este archivo directamente en phpMyAdmin.
-- Crea de cero la base de datos Asobal y carga datos, funciones, procedimientos y triggers.
-- Usuario admin: admin / password
-- ============================================================
SET NAMES utf8mb4;
SET FOREIGN_KEY_CHECKS = 0;


-- ============================================================
-- BASE DE DATOS Y DATOS INICIALES
-- ============================================================
drop database if exists Asobal;
create database Asobal character set utf8mb4 collate utf8mb4_unicode_ci;
use Asobal;

create table temporada (
    id_temporada int primary key auto_increment,
    anio year not null,
    fecha_inicio date not null,
    fecha_fin date not null,
    estado_temporada enum('Acabada','En juego'),
    
    constraint chk_fechas_temporada
        check (fecha_fin > fecha_inicio),
    
    constraint chk_anio_valido
        check (anio >= 1900 and anio <= 2100)
    
);

create table jornada (
    id_jornada int primary key auto_increment,
    numero tinyint not null,
    id_temporada int not null,
    observaciones varchar(150),
    
    constraint chk_numero_jornada_positivo
        check (numero > 0 and numero <= 50),

    constraint fk_id_temporada
        foreign key (id_temporada)
        references temporada(id_temporada)
        on delete cascade
        on update cascade
);

create table equipo (
    id_equipo int primary key auto_increment,
    nombre_club varchar(100) not null,
    ciudad varchar(80),
    presupuesto decimal(12,2),
    anio_fundacion year,
    presidente varchar(100),
    titulos tinyint,
    
    constraint chk_presupuesto_positivo
        check (presupuesto is null or presupuesto >= 0),
    
    constraint chk_titulos_no_negativo
        check (titulos is null or titulos >= 0)
);

create table jugador (
    id_jugador int primary key auto_increment,
    nombre varchar(100) not null,
    dni varchar(12) unique,
    altura decimal(4,2),
    peso decimal(5,2),
    posicion enum('Portero','Extremo','Lateral','Central','Pivote'),
    dorsal tinyint not null,
    fecha_nacimiento date,
    id_equipo int,
    nacionalidad varchar(100),
    
    constraint chk_altura_valida
        check (altura is null or (altura >= 1.50 and altura <= 2.30)),
    
    constraint chk_peso_valido
        check (peso is null or (peso >= 50 and peso <= 150)),
    
    constraint chk_dorsal_valido
        check (dorsal > 0 and dorsal <= 99),
    
    constraint fk_id_equipo
        foreign key (id_equipo)
        references equipo(id_equipo)
);

create table pabellon (
    id_pabellon int primary key auto_increment,
    nombre varchar(100) not null,
    aforo int unsigned,
    ciudad varchar(80),
    direccion varchar(150),
    
    constraint chk_aforo_valido
        check (aforo is null or (aforo >= 100 and aforo <= 50000))
);

create table partido (
    id_partido int primary key auto_increment,
    fecha datetime not null,
    goles_local tinyint not null,
    goles_visitante tinyint not null,
    id_jornada int not null,
    id_pabellon int not null,
    id_equipo_local int not null,
    id_equipo_visitante int not null,
    
    constraint chk_goles_local_valido
        check (goles_local >= 0 and goles_local <= 100),
    
    constraint chk_goles_visitante_valido
        check (goles_visitante >= 0 and goles_visitante <= 100),
    
    constraint chk_equipos_diferentes
        check (id_equipo_local != id_equipo_visitante),

    constraint fk_id_jornada
        foreign key (id_jornada)
        references jornada(id_jornada)
        on delete cascade
        on update cascade,

    constraint fk_id_pabellon
        foreign key (id_pabellon)
        references pabellon(id_pabellon)
        on delete cascade
        on update cascade,
        
    constraint fk_id_equipo_local
        foreign key (id_equipo_local)
        references equipo(id_equipo)
        on delete cascade
        on update cascade,
        
    constraint fk_id_equipo_visitante
        foreign key (id_equipo_visitante)
        references equipo(id_equipo)
        on delete cascade
        on update cascade
);

create table estadisticas (
    id_estadistica int primary key auto_increment,
    goles tinyint unsigned default 0,
    paradas tinyint unsigned default 0,
    sanciones tinyint unsigned default 0,
    tarjetas_amarillas tinyint unsigned default 0,
    tarjetas_rojas tinyint unsigned default 0,
    tarjetas_azul tinyint unsigned default 0,
    dos_minutos tinyint unsigned default 0,
    id_jugador int not null,
    id_partido int not null,
    id_jornada int not null,
    id_equipo int not null, 
    id_temporada int not null,
    
    constraint chk_goles_partido_valido
        check (goles >= 0 and goles <= 30),
    
    constraint chk_paradas_validas
        check (paradas >= 0 and paradas <= 50),
    
    constraint chk_sanciones_validas
        check (sanciones >= 0 and sanciones <= 10),
    
    constraint chk_tarjetas_amarillas_validas
        check (tarjetas_amarillas >= 0 and tarjetas_amarillas <= 3),
    
    constraint chk_tarjetas_rojas_validas
        check (tarjetas_rojas >= 0 and tarjetas_rojas <= 1),
    
    constraint chk_tarjetas_azul_validas
        check (tarjetas_azul >= 0 and tarjetas_azul <= 1),
    
    constraint chk_dos_minutos_validos
        check (dos_minutos >= 0 and dos_minutos <= 5),

    constraint fk_jugador
        foreign key (id_jugador)
        references jugador(id_jugador)
        on delete cascade
        on update cascade,
        
    constraint fk_equipo
        foreign key (id_equipo)
        references equipo(id_equipo)
        on delete cascade
        on update cascade,

    constraint fk_partido
        foreign key (id_partido)
        references partido(id_partido)
        on delete cascade
        on update cascade,
        
    constraint fk_jornada
        foreign key (id_jornada)
        references jornada(id_jornada)
        on delete cascade
        on update cascade,
        
    constraint fk_temporada
        foreign key (id_temporada)
        references temporada(id_temporada)
        on delete cascade
        on update cascade
);

create table sanciones (
    id_sancion int primary key auto_increment,
    id_jugador int not null,
    id_temporada int not null,
    tipo_tarjeta enum('Amarilla','Roja','Azul') not null,
    motivo varchar(200),
    partidos_suspension int not null,
    jornada_inicio int not null,
    jornada_fin int,
    estado enum('Activa','Cumplida','Pendiente') default 'Activa',
    fecha_registro datetime default current_timestamp,
    
    constraint fk_sancion_jugador
        foreign key (id_jugador)
        references jugador(id_jugador)
        on delete cascade
        on update cascade,
        
    constraint fk_sancion_temporada
        foreign key (id_temporada)
        references temporada(id_temporada)
        on delete cascade
        on update cascade,
        
    constraint fk_sancion_jornada_inicio
        foreign key (jornada_inicio)
        references jornada(id_jornada)
        on delete cascade
        on update cascade
);


create table clasificacion (
    id_clasificacion int auto_increment primary key,
    id_temporada int not null,
    id_equipo int not null,
    puntos tinyint default 0,
    victorias int default 0,
    empates int default 0,
    derrotas int default 0,
    goles_favor int default 0,
    goles_contra int default 0,
    diferencia_goles int default 0,
    posicion int,
    
    constraint chk_puntos_no_negativo
        check (puntos >= 0),
    
    constraint chk_victorias_no_negativo
        check (victorias >= 0),
    
    constraint chk_empates_no_negativo
        check (empates >= 0),
    
    constraint chk_derrotas_no_negativo
        check (derrotas >= 0),
    
    constraint chk_goles_favor_no_negativo
        check (goles_favor >= 0),
    
    constraint chk_goles_contra_no_negativo
        check (goles_contra >= 0),
    
    constraint chk_posicion_valida
        check (posicion is null or posicion > 0),

    constraint fk_temporada2
        foreign key (id_temporada)
        references temporada(id_temporada)
        on delete cascade,

    constraint fk_equipo2
        foreign key (id_equipo)
        references equipo(id_equipo)
        on delete cascade
);

create table estadisticas_temporada (
    id_estadistica_temporada int primary key auto_increment,
    id_jugador int not null,
    id_temporada int not null,
    partidos_jugados int default 0,
    goles_totales int default 0,
    paradas_totales int default 0,
    sanciones_totales int default 0,
    tarjetas_amarillas_totales int default 0,
    tarjetas_rojas_totales int default 0,
    tarjetas_azul_totales int default 0,
    dos_minutos_totales int default 0,
    promedio_goles decimal(5,2) default 0,
    porcentaje_paradas decimal(5,2) default 0,
    
    constraint chk_partidos_jugados_no_negativo
        check (partidos_jugados >= 0),
    
    constraint chk_goles_totales_no_negativo
        check (goles_totales >= 0),
    
    constraint chk_paradas_totales_no_negativo
        check (paradas_totales >= 0),
    
    constraint chk_promedio_goles_valido
        check (promedio_goles >= 0),
    
    constraint chk_porcentaje_paradas_valido
        check (porcentaje_paradas >= 0 and porcentaje_paradas <= 100),
    
    constraint fk_jugador_temporada
        foreign key (id_jugador)
        references jugador(id_jugador)
        on delete cascade
        on update cascade,
        
    constraint fk_temporada_estadisticas
        foreign key (id_temporada)
        references temporada(id_temporada)
        on delete cascade
        on update cascade
);

-- ============================================
-- INSERTS PARA LA BASE DE DATOS ASOBAL
-- ============================================

use Asobal;

-- ============================================
-- 1. TEMPORADAS
-- ============================================

insert into temporada (anio, fecha_inicio, fecha_fin, estado_temporada) values
(2023, '2023-09-01', '2024-05-31', 'Acabada'),
(2024, '2024-09-01', '2025-05-31', 'En juego');

-- ============================================
-- 2. EQUIPOS (16 equipos de la Liga ASOBAL)
-- ============================================

insert into equipo (nombre_club, ciudad, presupuesto, anio_fundacion, presidente, titulos) values
('FC Barcelona', 'Barcelona', 15000000.00, 1942, 'Joan Laporta', 28),
('Barça Atlètic Handbol', 'Barcelona', 8000000.00, 1972, 'Joan Laporta', 15),
('Ademar León', 'León', 3500000.00, 1956, 'José Manuel García', 8),
('Fraikin Granollers', 'Granollers', 2800000.00, 1944, 'Josep Maria Vilà', 3),
('Bidasoa Irún', 'Irún', 2500000.00, 1990, 'Josu Izaguirre', 0),
('Abanca Ademar León', 'León', 3200000.00, 1956, 'José García', 7),
('Viveros Herol Nava', 'Nava', 1800000.00, 1975, 'Luis Gutiérrez', 0),
('Liberbank Cuenca', 'Cuenca', 2100000.00, 1975, 'Álvaro Rodríguez', 2),
('Helvetia Anaitasuna', 'Pamplona', 2400000.00, 1990, 'Javier Esparza', 0),
('Frigoríficos Morrazo', 'Cangas', 1600000.00, 1980, 'Antonio Méndez', 0),
('Bathco BM Torrelavega', 'Torrelavega', 1500000.00, 1990, 'Manuel Pérez', 0),
('Incarlopsa Cuenca', 'Cuenca', 1900000.00, 1975, 'Carlos López', 1),
('Ángel Ximénez Avia', 'Puente Genil', 1700000.00, 1995, 'Ángel Ximénez', 0),
('Bada Huesca', 'Huesca', 1400000.00, 1991, 'Antonio Cosculluela', 0),
('Benidorm', 'Benidorm', 2000000.00, 1952, 'Vicente Fenollosa', 2),
('Sinfín Santander', 'Santander', 1300000.00, 2005, 'Pedro Fernández', 0);

-- ============================================
-- 3. PABELLONES
-- ============================================

insert into pabellon (nombre, aforo, ciudad, direccion) values
('Palau Blaugrana', 7585, 'Barcelona', 'Carrer d\'Aristides Maillol, 12'),
('Palacio de los Deportes', 8000, 'León', 'Avenida de Sáenz de Miera, s/n'),
('Palau d\'Esports de Granollers', 5685, 'Granollers', 'Carrer de Francesc Macià, 61'),
('Polideportivo Artaleku', 2500, 'Irún', 'Barrio Behobia, s/n'),
('Pabellón El Sargal', 2000, 'Nava', 'Calle del Deporte, 1'),
('Pabellón Olímpico El Sargal', 3500, 'Cuenca', 'Avenida de los Alfares, 42'),
('Pabellón Anaitasuna', 3000, 'Pamplona', 'Calle Aralar, 37'),
('Pabellón O Gatañal', 2100, 'Cangas', 'Rúa do Gatañal, s/n'),
('Pabellón Vicente Trueba', 2500, 'Torrelavega', 'Calle Vicente Trueba, s/n'),
('Pabellón Ciudad de Puente Genil', 2800, 'Puente Genil', 'Calle Aguilar, 71'),
('Palacio de los Deportes', 5000, 'Huesca', 'Calle Calatayud, 4'),
('Palau d\'Esports l\'Illa', 4500, 'Benidorm', 'Avenida de Filipinas, s/n'),
('Palacio de Deportes de Santander', 5500, 'Santander', 'Calle Marqués de la Hermida, 41'),
('Pabellón Municipal', 1800, 'Guadalajara', 'Calle Francisco Aritio, 16'),
('Pabellón Príncipe Felipe', 8500, 'Zaragoza', 'Paseo Echegaray y Caballero, 18'),
('Pabellón Polideportivo', 2200, 'Logroño', 'Calle Múgica, 19');

-- ============================================
-- 4. JORNADAS TEMPORADA 2024
-- ============================================

insert into jornada (numero, id_temporada, observaciones) values
(1, 2, 'Jornada inaugural temporada 2024-2025'),
(2, 2, null),
(3, 2, null),
(4, 2, null),
(5, 2, null),
(6, 2, null),
(7, 2, null),
(8, 2, null),
(9, 2, null),
(10, 2, null),
(11, 2, null),
(12, 2, null),
(13, 2, null),
(14, 2, null),
(15, 2, null),
(16, 2, null),
(17, 2, null),
(18, 2, null),
(19, 2, null),
(20, 2, null);

-- ============================================
-- 5. JUGADORES FC BARCELONA
-- ============================================

insert into jugador (nombre, dni, altura, peso, posicion, dorsal, fecha_nacimiento, id_equipo) values
('Gonzalo Pérez de Vargas', '12345678A', 1.95, 95.00, 'Portero', 1, '1991-03-12', 1),
('Emil Nielsen', '23456789B', 1.98, 102.00, 'Portero', 16, '1995-06-15', 1),
('Blaz Janc', '34567890C', 1.90, 90.00, 'Extremo', 9, '1996-04-19', 1),
('Aleix Gómez', '45678901D', 1.80, 78.00, 'Extremo', 19, '1992-01-28', 1),
('Dika Mem', '56789012E', 1.88, 88.00, 'Lateral', 24, '1997-09-08', 1),
('Jérémy Toto', '67890123F', 1.82, 82.00, 'Lateral', 7, '1998-08-23', 1),
('Ludovic Fàbregas', '78901234G', 1.92, 95.00, 'Central', 5, '1992-01-12', 1),
('Hampus Wanne', '89012345H', 2.04, 110.00, 'Central', 27, '1994-07-21', 1),
('Luka Cindric', '90123456I', 2.00, 100.00, 'Pivote', 26, '1993-05-03', 1),
('Jonathan Carlsbogard', '01234567J', 1.96, 98.00, 'Pivote', 4, '1989-11-07', 1),
('Antonio Bazán', '11234567K', 1.86, 84.00, 'Lateral', 11, '2001-03-15', 1),
('Thiagus Petrus', '21234567L', 1.88, 86.00, 'Lateral', 17, '1996-12-20', 1),
('Aitor Ariño', '31234567M', 1.95, 93.00, 'Central', 3, '1995-09-14', 1),
('Domen Makuc', '41234567N', 1.98, 96.00, 'Central', 21, '1997-02-28', 1);

-- ============================================
-- 6. JUGADORES ADEMAR LEÃ“N
-- ============================================

insert into jugador (nombre, dni, altura, peso, posicion, dorsal, fecha_nacimiento, id_equipo) values
('Dani Fernández', '51234567O', 1.93, 91.00, 'Portero', 1, '1992-07-18', 3),
('Isaías Guardiola', '61234567P', 1.97, 99.00, 'Portero', 12, '1991-01-25', 3),
('Rubén Marchán', '71234567Q', 1.83, 81.00, 'Extremo', 7, '1998-05-11', 3),
('Sergey Hernández', '81234567R', 1.88, 87.00, 'Lateral', 9, '1995-10-03', 3),
('Bradley Vale', '91234567S', 1.85, 83.00, 'Lateral', 20, '1999-08-29', 3),
('Mateo Macanhan', '02234567T', 2.02, 105.00, 'Central', 5, '1997-03-17', 3),
('Juan Castro', '12234567U', 1.98, 97.00, 'Central', 14, '1993-11-22', 3),
('Diego Piñeiro', '22234567V', 1.94, 92.00, 'Pivote', 19, '1996-06-08', 3),
('Kevin Sánchez', '32234567W', 1.86, 85.00, 'Lateral', 23, '2000-02-14', 3),
('Adrià Martínez', '42234567X', 1.82, 80.00, 'Extremo', 11, '1999-12-05', 3),
('Pablo Paredes', '52234567Y', 1.95, 94.00, 'Central', 6, '1994-04-19', 3),
('Marc Canellas', '62234567Z', 1.91, 89.00, 'Lateral', 18, '1997-09-27', 3);

-- ============================================
-- 7. JUGADORES FRAIKIN GRANOLLERS
-- ============================================

insert into jugador (nombre, dni, altura, peso, posicion, dorsal, fecha_nacimiento, id_equipo) values
('Dejan Peric', '72234568A', 1.96, 96.00, 'Portero', 1, '1993-02-11', 4),
('Marc Guàrdia', '82234568B', 1.91, 90.00, 'Portero', 16, '1998-07-23', 4),
('Antonio García', '92234568C', 1.87, 86.00, 'Extremo', 7, '1996-05-30', 4),
('Ferran Solé', '03234568D', 1.84, 82.00, 'Lateral', 9, '1997-11-14', 4),
('Pol Valera', '13234568E', 1.89, 88.00, 'Lateral', 19, '1999-03-08', 4),
('Mamadou Diocou', '23234568F', 2.01, 103.00, 'Central', 21, '1994-08-19', 4),
('Esteban Salinas', '33234568G', 1.99, 99.00, 'Central', 5, '1992-12-25', 4),
('Adrià Pérez', '43234568H', 1.93, 91.00, 'Pivote', 13, '1998-01-17', 4),
('Marc Cañellas', '53234568I', 1.88, 87.00, 'Lateral', 11, '2000-06-22', 4),
('Eloy Morán', '63234568J', 1.82, 79.00, 'Extremo', 27, '2001-10-09', 4);

-- ============================================
-- 8. JUGADORES BIDASOA IRÃšN
-- ============================================

insert into jugador (nombre, dni, altura, peso, posicion, dorsal, fecha_nacimiento, id_equipo) values
('Ander Torriko', '73234568K', 1.94, 93.00, 'Portero', 1, '1994-04-05', 5),
('Iñaki Peciña', '83234568L', 1.90, 89.00, 'Portero', 12, '1996-09-18', 5),
('Imanol Garciandia', '93234568M', 1.85, 84.00, 'Extremo', 7, '1997-02-27', 5),
('Jon Belaustegui', '04234568N', 1.88, 87.00, 'Lateral', 9, '1995-11-30', 5),
('Iosu Goñi', '14234568O', 1.86, 85.00, 'Lateral', 20, '1998-07-14', 5),
('Mikel Aguirrezabalaga', '24234568P', 2.00, 101.00, 'Central', 5, '1993-03-22', 5),
('Jon Azkue', '34234568Q', 1.97, 96.00, 'Central', 14, '1994-12-08', 5),
('Julen Aguinagalde', '44234568R', 1.95, 94.00, 'Pivote', 19, '1992-05-16', 5),
('Ander Izquierdo', '54234568S', 1.83, 81.00, 'Extremo', 11, '1999-01-29', 5),
('Iñaki Martínez', '64234568T', 1.89, 88.00, 'Lateral', 23, '2000-08-11', 5);

-- ============================================
-- 9. CLASIFICACIÃ“N INICIAL (todos en 0)
-- ============================================

insert into clasificacion (id_temporada, id_equipo, puntos, victorias, empates, derrotas, goles_favor, goles_contra, diferencia_goles, posicion) values
(2, 1, 0, 0, 0, 0, 0, 0, 0, 1),
(2, 2, 0, 0, 0, 0, 0, 0, 0, 2),
(2, 3, 0, 0, 0, 0, 0, 0, 0, 3),
(2, 4, 0, 0, 0, 0, 0, 0, 0, 4),
(2, 5, 0, 0, 0, 0, 0, 0, 0, 5),
(2, 6, 0, 0, 0, 0, 0, 0, 0, 6),
(2, 7, 0, 0, 0, 0, 0, 0, 0, 7),
(2, 8, 0, 0, 0, 0, 0, 0, 0, 8),
(2, 9, 0, 0, 0, 0, 0, 0, 0, 9),
(2, 10, 0, 0, 0, 0, 0, 0, 0, 10),
(2, 11, 0, 0, 0, 0, 0, 0, 0, 11),
(2, 12, 0, 0, 0, 0, 0, 0, 0, 12),
(2, 13, 0, 0, 0, 0, 0, 0, 0, 13),
(2, 14, 0, 0, 0, 0, 0, 0, 0, 14),
(2, 15, 0, 0, 0, 0, 0, 0, 0, 15),
(2, 16, 0, 0, 0, 0, 0, 0, 0, 16);

-- ============================================
-- 10. PARTIDOS JORNADA 1
-- ============================================

insert into partido (fecha, goles_local, goles_visitante, id_jornada, id_pabellon, id_equipo_local, id_equipo_visitante) values
('2024-09-07 18:00:00', 32, 28, 1, 1, 1, 3),
('2024-09-07 19:00:00', 29, 29, 1, 3, 4, 5),
('2024-09-08 17:30:00', 27, 24, 1, 7, 9, 10),
('2024-09-08 18:30:00', 31, 26, 1, 11, 14, 15);

-- ============================================
-- 11. PARTIDOS JORNADA 2
-- ============================================

insert into partido (fecha, goles_local, goles_visitante, id_jornada, id_pabellon, id_equipo_local, id_equipo_visitante) values
('2024-09-14 18:00:00', 35, 30, 2, 2, 3, 4),
('2024-09-14 19:00:00', 28, 31, 2, 4, 5, 1),
('2024-09-15 17:30:00', 26, 27, 2, 9, 10, 14),
('2024-09-15 18:30:00', 30, 28, 2, 12, 15, 9);

-- ============================================
-- 12. PARTIDOS JORNADA 3
-- ============================================

insert into partido (fecha, goles_local, goles_visitante, id_jornada, id_pabellon, id_equipo_local, id_equipo_visitante) values
('2024-09-21 18:00:00', 33, 29, 3, 1, 1, 4),
('2024-09-21 19:00:00', 27, 30, 3, 2, 3, 5),
('2024-09-22 17:30:00', 29, 25, 3, 11, 14, 9),
('2024-09-22 18:30:00', 32, 31, 3, 8, 10, 15);

-- ============================================
-- 13. PARTIDOS JORNADA 4
-- ============================================

insert into partido (fecha, goles_local, goles_visitante, id_jornada, id_pabellon, id_equipo_local, id_equipo_visitante) values
('2024-09-28 18:00:00', 30, 27, 4, 3, 4, 3),
('2024-09-28 19:00:00', 34, 28, 4, 4, 5, 14),
('2024-09-29 17:30:00', 31, 29, 4, 1, 1, 10),
('2024-09-29 18:30:00', 26, 28, 4, 7, 9, 15);

-- ============================================
-- 14. PARTIDOS JORNADA 5
-- ============================================

insert into partido (fecha, goles_local, goles_visitante, id_jornada, id_pabellon, id_equipo_local, id_equipo_visitante) values
('2024-10-05 18:00:00', 36, 31, 5, 1, 1, 5),
('2024-10-05 19:00:00', 28, 29, 5, 2, 3, 14),
('2024-10-06 17:30:00', 30, 27, 5, 3, 4, 10),
('2024-10-06 18:30:00', 25, 33, 5, 7, 9, 15);

-- ============================================
-- 15. ESTADÍSTICAS JORNADA 1 - FC BARCELONA vs ADEMAR (32-28)
-- ============================================

-- estadísticas fc barcelona
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 14, 0, 0, 0, 0, 0, 1, 1, 1, 1, 2),  -- gonzalo pérez (portero)
(7, 0, 0, 1, 0, 0, 0, 3, 1, 1, 1, 2),   -- blaz janc
(5, 0, 0, 0, 0, 0, 0, 4, 1, 1, 1, 2),   -- aleix gómez
(6, 0, 0, 0, 0, 0, 1, 5, 1, 1, 1, 2),   -- dika mem
(4, 0, 0, 0, 0, 0, 0, 6, 1, 1, 1, 2),   -- jérémy toto
(5, 0, 0, 1, 0, 0, 0, 7, 1, 1, 1, 2),   -- ludovic fàbregas
(3, 0, 0, 0, 0, 0, 0, 8, 1, 1, 1, 2),   -- hampus wanne
(2, 0, 0, 0, 0, 0, 1, 9, 1, 1, 1, 2);   -- luka cindric

-- estadísticas ademar león
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 11, 0, 0, 0, 0, 0, 15, 1, 1, 3, 2),  -- dani fernández (portero)
(6, 0, 0, 0, 0, 0, 0, 17, 1, 1, 3, 2),   -- rubén marchán
(5, 0, 0, 1, 0, 0, 0, 18, 1, 1, 3, 2),   -- sergey hernández
(4, 0, 0, 0, 0, 0, 1, 19, 1, 1, 3, 2),   -- bradley vale
(7, 0, 0, 0, 0, 0, 0, 20, 1, 1, 3, 2),   -- mateo macanhan
(3, 0, 0, 1, 0, 0, 0, 21, 1, 1, 3, 2),   -- juan castro
(3, 0, 0, 0, 0, 0, 1, 22, 1, 1, 3, 2);   -- diego piñeiro

-- ============================================
-- 16. ESTADÍSTICAS JORNADA 1 - GRANOLLERS vs IRÃšN (29-29)
-- ============================================

-- estadísticas granollers
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 13, 0, 0, 0, 0, 0, 27, 2, 1, 4, 2),  -- dejan peric (portero)
(6, 0, 0, 0, 0, 0, 0, 29, 2, 1, 4, 2),   -- antonio garcía
(5, 0, 0, 1, 0, 0, 0, 30, 2, 1, 4, 2),   -- ferran solé
(7, 0, 0, 0, 0, 0, 1, 31, 2, 1, 4, 2),   -- pol valera
(5, 0, 0, 0, 0, 0, 0, 32, 2, 1, 4, 2),   -- mamadou diocou
(4, 0, 0, 0, 0, 0, 0, 33, 2, 1, 4, 2),   -- esteban salinas
(2, 0, 0, 1, 0, 0, 0, 34, 2, 1, 4, 2);   -- adrià pérez

-- estadísticas irún
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 12, 0, 0, 0, 0, 0, 37, 2, 1, 5, 2),  -- ander torriko (portero)
(6, 0, 0, 0, 0, 0, 0, 39, 2, 1, 5, 2),   -- imanol garciandia
(5, 0, 0, 1, 0, 0, 1, 40, 2, 1, 5, 2),   -- jon belaustegui
(7, 0, 0, 0, 0, 0, 0, 41, 2, 1, 5, 2),   -- iosu goñi
(5, 0, 0, 0, 0, 0, 0, 42, 2, 1, 5, 2),   -- mikel aguirrezabalaga
(4, 0, 0, 0, 0, 0, 1, 43, 2, 1, 5, 2),   -- jon azkue
(2, 0, 0, 1, 0, 0, 0, 44, 2, 1, 5, 2);   -- julen aguinagalde

-- ============================================
-- 17. ESTADÍSTICAS JORNADA 2 - ADEMAR vs GRANOLLERS (35-30)
-- ============================================

-- estadísticas ademar león
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 13, 0, 0, 0, 0, 0, 15, 5, 2, 3, 2),  -- dani fernández (portero)
(8, 0, 0, 0, 0, 0, 0, 17, 5, 2, 3, 2),   -- rubén marchán
(6, 0, 0, 0, 0, 0, 1, 18, 5, 2, 3, 2),   -- sergey hernández
(5, 0, 0, 1, 0, 0, 0, 19, 5, 2, 3, 2),   -- bradley vale
(8, 0, 0, 0, 0, 0, 0, 20, 5, 2, 3, 2),   -- mateo macanhan
(4, 0, 0, 0, 0, 0, 0, 21, 5, 2, 3, 2),   -- juan castro
(4, 0, 0, 1, 0, 0, 1, 22, 5, 2, 3, 2);   -- diego piñeiro

-- estadísticas granollers
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 10, 0, 0, 0, 0, 0, 27, 5, 2, 4, 2),  -- dejan peric (portero)
(7, 0, 0, 1, 0, 0, 0, 29, 5, 2, 4, 2),   -- antonio garcía
(5, 0, 0, 0, 0, 0, 1, 30, 5, 2, 4, 2),   -- ferran solé
(6, 0, 0, 0, 0, 0, 0, 31, 5, 2, 4, 2),   -- pol valera
(6, 0, 0, 1, 0, 0, 0, 32, 5, 2, 4, 2),   -- mamadou diocou
(4, 0, 0, 0, 0, 0, 0, 33, 5, 2, 4, 2),   -- esteban salinas
(2, 0, 0, 0, 0, 0, 1, 34, 5, 2, 4, 2);   -- adrià pérez

-- ============================================
-- 18. ESTADÍSTICAS JORNADA 2 - IRÃšN vs BARCELONA (28-31)
-- ============================================

-- estadísticas irún
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 14, 0, 0, 0, 0, 0, 37, 6, 2, 5, 2),  -- ander torriko (portero)
(6, 0, 0, 0, 0, 0, 0, 39, 6, 2, 5, 2),   -- imanol garciandia
(5, 0, 0, 0, 0, 0, 0, 40, 6, 2, 5, 2),   -- jon belaustegui
(6, 0, 0, 1, 0, 0, 1, 41, 6, 2, 5, 2),   -- iosu goñi
(5, 0, 0, 0, 0, 0, 0, 42, 6, 2, 5, 2),   -- mikel aguirrezabalaga
(4, 0, 0, 1, 0, 0, 0, 43, 6, 2, 5, 2),   -- jon azkue
(2, 0, 0, 0, 0, 0, 1, 44, 6, 2, 5, 2);   -- julen aguinagalde

-- estadísticas barcelona
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 12, 0, 0, 0, 0, 0, 1, 6, 2, 1, 2),   -- gonzalo pérez (portero)
(6, 0, 0, 0, 0, 0, 0, 3, 6, 2, 1, 2),    -- blaz janc
(6, 0, 0, 1, 0, 0, 0, 4, 6, 2, 1, 2),    -- aleix gómez
(7, 0, 0, 0, 0, 0, 1, 5, 6, 2, 1, 2),    -- dika mem
(4, 0, 0, 0, 0, 0, 0, 6, 6, 2, 1, 2),    -- jérémy toto
(5, 0, 0, 0, 0, 0, 0, 7, 6, 2, 1, 2),    -- ludovic fàbregas
(2, 0, 0, 1, 0, 0, 0, 8, 6, 2, 1, 2),    -- hampus wanne
(1, 0, 0, 0, 0, 0, 0, 9, 6, 2, 1, 2);    -- luka cindric

-- ============================================
-- 19. ESTADÍSTICAS JORNADA 3 - BARCELONA vs GRANOLLERS (33-29)
-- ============================================

-- estadísticas barcelona
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 13, 0, 0, 0, 0, 0, 1, 9, 3, 1, 2),   -- gonzalo pérez (portero)
(8, 0, 0, 0, 0, 0, 0, 3, 9, 3, 1, 2),    -- blaz janc (3ª amarilla - sanción)
(5, 0, 0, 1, 0, 0, 0, 4, 9, 3, 1, 2),    -- aleix gómez
(6, 0, 0, 0, 0, 0, 0, 5, 9, 3, 1, 2),    -- dika mem
(5, 0, 0, 0, 0, 0, 1, 6, 9, 3, 1, 2),    -- jérémy toto
(5, 0, 0, 0, 0, 0, 0, 7, 9, 3, 1, 2),    -- ludovic fàbregas
(3, 0, 0, 0, 0, 0, 0, 8, 9, 3, 1, 2),    -- hampus wanne
(1, 0, 0, 0, 0, 0, 0, 9, 9, 3, 1, 2);    -- luka cindric

-- estadísticas granollers
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 11, 0, 0, 0, 0, 0, 27, 9, 3, 4, 2),  -- dejan peric (portero)
(7, 0, 0, 0, 0, 0, 0, 29, 9, 3, 4, 2),   -- antonio garcía
(5, 0, 0, 1, 0, 0, 0, 30, 9, 3, 4, 2),   -- ferran solé
(6, 0, 0, 0, 0, 0, 1, 31, 9, 3, 4, 2),   -- pol valera
(5, 0, 0, 0, 0, 0, 0, 32, 9, 3, 4, 2),   -- mamadou diocou
(4, 0, 0, 0, 1, 0, 0, 33, 9, 3, 4, 2),   -- esteban salinas (roja - 2 partidos)
(2, 0, 0, 0, 0, 0, 0, 34, 9, 3, 4, 2);   -- adrià pérez

-- ============================================
-- 20. ESTADÍSTICAS JORNADA 3 - ADEMAR vs IRÃšN (27-30)
-- ============================================

-- estadísticas ademar
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 12, 0, 0, 0, 0, 0, 15, 10, 3, 3, 2),  -- dani fernández (portero)
(6, 0, 0, 1, 0, 0, 0, 17, 10, 3, 3, 2),   -- rubén marchán
(5, 0, 0, 0, 0, 0, 0, 18, 10, 3, 3, 2),   -- sergey hernández
(4, 0, 0, 0, 0, 0, 1, 19, 10, 3, 3, 2),   -- bradley vale
(6, 0, 0, 0, 0, 0, 0, 20, 10, 3, 3, 2),   -- mateo macanhan
(3, 0, 0, 0, 0, 0, 0, 21, 10, 3, 3, 2),   -- juan castro
(3, 0, 0, 1, 0, 0, 0, 22, 10, 3, 3, 2);   -- diego piñeiro

-- estadísticas irún
insert into estadisticas (goles, paradas, sanciones, tarjetas_amarillas, tarjetas_rojas, tarjetas_azul, dos_minutos, id_jugador, id_partido, id_jornada, id_equipo, id_temporada) values
(0, 10, 0, 0, 0, 0, 0, 37, 10, 3, 5, 2),  -- ander torriko (portero)
(7, 0, 0, 0, 0, 0, 0, 39, 10, 3, 5, 2),   -- imanol garciandia
(6, 0, 0, 1, 0, 0, 0, 40, 10, 3, 5, 2),   -- jon belaustegui (3ª amarilla)
(6, 0, 0, 0, 0, 0, 1, 41, 10, 3, 5, 2),   -- iosu goñi
(5, 0, 0, 0, 0, 0, 0, 42, 10, 3, 5, 2),   -- mikel aguirrezabalaga
(4, 0, 0, 0, 0, 0, 0, 43, 10, 3, 5, 2),   -- jon azkue
(2, 0, 0, 0, 0, 0, 0, 44, 10, 3, 5, 2);   -- julen aguinagalde

-- ============================================
-- COMENTARIOS FINALES
-- ============================================

-- total de inserts:
-- - 2 temporadas
-- - 16 equipos
-- - 16 pabellones
-- - 20 jornadas
-- - 46 jugadores (14 barcelona + 12 ademar + 10 granollers + 10 irún)
-- - 16 registros clasificación
-- - 12 partidos (jornadas 1-4)
-- - ~90 estadísticas de jugadores

-- los triggers se activarán automáticamente al insertar:
-- - partidos â†’ actualizar clasificación
-- - estadísticas â†’ actualizar estadísticas_temporada
-- - estadísticas con tarjetas â†’ crear sanciones

-- ejemplo de consultas útiles:
-- select * from clasificacion order by puntos desc, diferencia_goles desc;
-- select * from estadisticas_temporada order by goles_totales desc limit 10;
-- select * from sanciones where estado = 'Activa';


-- ============================================================
-- FUNCIONES DE VALIDACION
-- ============================================================
-- FUNCIONES DE VALIDACIÃ“N 
delimiter $$

drop function if exists existe_equipo$$
create function existe_equipo(equipo_id int)
returns boolean
deterministic
begin
    return exists(select 1 from equipo where id_equipo = equipo_id);
end$$

drop function if exists existe_jugador$$
create function existe_jugador(jugador_id int)
returns boolean
deterministic
begin
    return exists(select 1 from jugador where id_jugador = jugador_id);
end$$

drop function if exists existe_jornada$$
create function existe_jornada(jornada_id int)
returns boolean
deterministic
begin
    return exists(select 1 from jornada where id_jornada = jornada_id);
end$$

drop function if exists existe_pabellon$$
create function existe_pabellon(pabellon_id int)
returns boolean
deterministic
begin
    return exists(select 1 from pabellon where id_pabellon = pabellon_id);
end$$

drop function if exists existe_temporada$$
create function existe_temporada(temporada_id int)
returns boolean
deterministic
begin
    return exists(select 1 from temporada where id_temporada = temporada_id);
end$$

drop function if exists existe_partido$$
create function existe_partido(partido_id int)
returns boolean
deterministic
begin
    return exists(select 1 from partido where id_partido = partido_id);
end$$

delimiter ;


-- ============================================================
-- FUNCIONES DE VALIDACION COMPLEJA
-- ============================================================
-- FUNCIONES DE VALIDACIÃ“N COMPLEJA


delimiter $$

drop function if exists fecha_dentro_temporada$$
create function fecha_dentro_temporada(fecha_partido date, jornada_id int)
returns boolean
deterministic
begin
    declare fecha_ini date;
    declare fecha_fin date;
    
    select t.fecha_inicio, t.fecha_fin
    into fecha_ini, fecha_fin
    from temporada t
    inner join jornada j on t.id_temporada = j.id_temporada
    where j.id_jornada = jornada_id;
    
    return fecha_partido between fecha_ini and fecha_fin;
end$$

drop function if exists existe_partido_duplicado$$
create function existe_partido_duplicado(
    jornada_id int, 
    equipo_local int, 
    equipo_visitante int,
    excluir_partido int
)
returns boolean
deterministic
begin
    declare cantidad int;
    
    if excluir_partido is null then
        select count(*) into cantidad
        from partido
        where id_jornada = jornada_id
        and ((id_equipo_local = equipo_local and id_equipo_visitante = equipo_visitante)
        or (id_equipo_local = equipo_visitante and id_equipo_visitante = equipo_local));
    else
        select count(*) into cantidad
        from partido
        where id_jornada = jornada_id
        and id_partido != excluir_partido
        and ((id_equipo_local = equipo_local and id_equipo_visitante = equipo_visitante)
        or (id_equipo_local = equipo_visitante and id_equipo_visitante = equipo_local));
    end if;
    
    return cantidad > 0;
end$$

delimiter ;


-- ============================================================
-- FUNCIONES DE CONSULTA
-- ============================================================
-- FUNCIONES DE OBTENCIÃ“N DE DATOS

delimiter $$

drop function if exists obtener_temporada_de_jornada$$
create function obtener_temporada_de_jornada(jornada_id int)
returns int
deterministic
begin
    declare temp_id int;
    
    select id_temporada into temp_id
    from jornada
    where id_jornada = jornada_id;
    
    return temp_id;
end$$

drop function if exists obtener_jornada_siguiente$$
create function obtener_jornada_siguiente(jornada_actual int)
returns int
deterministic
begin
    declare numero_actual int;
    declare jornada_sig int;
    declare temporada_id int;
    
    select numero, id_temporada 
    into numero_actual, temporada_id
    from jornada
    where id_jornada = jornada_actual;
    
    select id_jornada into jornada_sig
    from jornada
    where id_temporada = temporada_id
    and numero = numero_actual + 1
    limit 1;
    
    if jornada_sig is null then
        return jornada_actual;
    end if;
    
    return jornada_sig;
end$$

drop function if exists obtener_jugador_con_dorsal$$
create function obtener_jugador_con_dorsal(
    equipo_id int, 
    dorsal_num int,
    excluir_jugador int
)
returns varchar(100)
deterministic
begin
    declare nombre_jugador varchar(100);
    
    if excluir_jugador is null then
        select nombre into nombre_jugador
        from jugador
        where id_equipo = equipo_id
        and dorsal = dorsal_num
        and id_equipo is not null
        limit 1;
    else
        select nombre into nombre_jugador
        from jugador
        where id_equipo = equipo_id
        and dorsal = dorsal_num
        and id_jugador != excluir_jugador
        and id_equipo is not null
        limit 1;
    end if;
    
    return nombre_jugador;
end$$

drop function if exists contar_amarillas_temporada$$
create function contar_amarillas_temporada(jugador_id int, temporada_id int)
returns int
deterministic
begin
    declare total int;
    
    select count(*) into total
    from estadisticas
    where id_jugador = jugador_id
    and id_temporada = temporada_id
    and tarjetas_amarillas > 0;
    
    return total;
end$$

delimiter ;


-- ============================================================
-- PROCEDIMIENTOS PARA LA WEB
-- ============================================================
USE Asobal;

CREATE TABLE IF NOT EXISTS usuarios_admin (
    id_admin INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- Usuario de ejemplo:
-- usuario: admin
-- contrasena: password
INSERT INTO usuarios_admin (usuario, password_hash)
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi')
ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash);

DELIMITER $$

DROP PROCEDURE IF EXISTS sp_listar_clasificacion$$
CREATE PROCEDURE sp_listar_clasificacion()
BEGIN
    SELECT
        c.posicion,
        e.nombre_club,
        c.puntos,
        c.victorias,
        c.empates,
        c.derrotas,
        c.goles_favor,
        c.goles_contra,
        c.diferencia_goles
    FROM clasificacion c
    INNER JOIN equipo e ON e.id_equipo = c.id_equipo
    INNER JOIN temporada t ON t.id_temporada = c.id_temporada
    WHERE t.estado_temporada = 'En juego'
    ORDER BY c.posicion ASC, c.puntos DESC, c.diferencia_goles DESC, c.goles_favor DESC;
END$$

DROP PROCEDURE IF EXISTS sp_listar_partidos$$
CREATE PROCEDURE sp_listar_partidos(IN p_tipo VARCHAR(20))
BEGIN
    SELECT
        p.id_partido,
        p.fecha,
        p.goles_local,
        p.goles_visitante,
        j.numero AS jornada,
        pa.nombre AS pabellon,
        el.nombre_club AS equipo_local,
        ev.nombre_club AS equipo_visitante
    FROM partido p
    INNER JOIN jornada j ON j.id_jornada = p.id_jornada
    INNER JOIN pabellon pa ON pa.id_pabellon = p.id_pabellon
    INNER JOIN equipo el ON el.id_equipo = p.id_equipo_local
    INNER JOIN equipo ev ON ev.id_equipo = p.id_equipo_visitante
    WHERE
        p_tipo = 'todos'
        OR (p_tipo = 'jugados' AND p.fecha <= NOW())
        OR (p_tipo = 'proximos' AND p.fecha > NOW())
        OR p_tipo = 'portada'
    ORDER BY
        CASE
            WHEN p_tipo = 'proximos' THEN UNIX_TIMESTAMP(p.fecha)
            WHEN p_tipo = 'jugados' THEN -UNIX_TIMESTAMP(p.fecha)
            ELSE ABS(TIMESTAMPDIFF(HOUR, NOW(), p.fecha))
        END ASC
    LIMIT 50;
END$$

DROP PROCEDURE IF EXISTS sp_listar_equipos$$
CREATE PROCEDURE sp_listar_equipos()
BEGIN
    SELECT
        id_equipo,
        nombre_club,
        ciudad,
        presupuesto,
        `anio_fundacion`,
        presidente,
        `titulos`
    FROM equipo
    ORDER BY nombre_club ASC;
END$$

DROP PROCEDURE IF EXISTS sp_listar_jugadores_equipo$$
CREATE PROCEDURE sp_listar_jugadores_equipo(IN p_id_equipo INT)
BEGIN
    SELECT
        id_jugador,
        nombre,
        dorsal,
        posicion,
        fecha_nacimiento,
        nacionalidad
    FROM jugador
    WHERE id_equipo = p_id_equipo
    ORDER BY dorsal ASC, nombre ASC;
END$$

DROP PROCEDURE IF EXISTS sp_obtener_partido$$
CREATE PROCEDURE sp_obtener_partido(IN p_id_partido INT)
BEGIN
    SELECT
        p.id_partido,
        p.fecha,
        p.goles_local,
        p.goles_visitante,
        j.numero AS jornada,
        pa.nombre AS pabellon,
        el.nombre_club AS equipo_local,
        ev.nombre_club AS equipo_visitante
    FROM partido p
    INNER JOIN jornada j ON j.id_jornada = p.id_jornada
    INNER JOIN pabellon pa ON pa.id_pabellon = p.id_pabellon
    INNER JOIN equipo el ON el.id_equipo = p.id_equipo_local
    INNER JOIN equipo ev ON ev.id_equipo = p.id_equipo_visitante
    WHERE p.id_partido = p_id_partido;
END$$

DROP PROCEDURE IF EXISTS sp_insertar_partido$$
CREATE PROCEDURE sp_insertar_partido(
    IN p_fecha DATETIME,
    IN p_id_jornada INT,
    IN p_id_pabellon INT,
    IN p_id_equipo_local INT,
    IN p_id_equipo_visitante INT
)
BEGIN
    IF p_id_equipo_local = p_id_equipo_visitante THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El equipo local y visitante deben ser diferentes';
    END IF;

    INSERT INTO partido (
        fecha,
        goles_local,
        goles_visitante,
        id_jornada,
        id_pabellon,
        id_equipo_local,
        id_equipo_visitante
    ) VALUES (
        p_fecha,
        0,
        0,
        p_id_jornada,
        p_id_pabellon,
        p_id_equipo_local,
        p_id_equipo_visitante
    );
END$$

DROP PROCEDURE IF EXISTS sp_actualizar_resultado$$
CREATE PROCEDURE sp_actualizar_resultado(
    IN p_id_partido INT,
    IN p_goles_local TINYINT,
    IN p_goles_visitante TINYINT
)
BEGIN
    IF p_goles_local < 0 OR p_goles_local > 100 OR p_goles_visitante < 0 OR p_goles_visitante > 100 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Los goles deben estar entre 0 y 100';
    END IF;

    UPDATE partido
    SET goles_local = p_goles_local,
        goles_visitante = p_goles_visitante
    WHERE id_partido = p_id_partido;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el partido indicado';
    END IF;
END$$

DROP PROCEDURE IF EXISTS sp_eliminar_partido$$
CREATE PROCEDURE sp_eliminar_partido(IN p_id_partido INT)
BEGIN
    DELETE FROM partido
    WHERE id_partido = p_id_partido;

    IF ROW_COUNT() = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'No existe el partido indicado';
    END IF;
END$$

DROP PROCEDURE IF EXISTS sp_insertar_equipo$$
CREATE PROCEDURE sp_insertar_equipo(
    IN p_nombre_club VARCHAR(100),
    IN p_ciudad VARCHAR(80),
    IN p_presupuesto DECIMAL(12,2),
    IN p_anio_fundacion YEAR,
    IN p_presidente VARCHAR(100),
    IN p_titulos TINYINT
)
BEGIN
    DECLARE v_id_equipo INT;
    DECLARE v_id_temporada INT;
    DECLARE v_siguiente_posicion INT;

    IF p_nombre_club IS NULL OR TRIM(p_nombre_club) = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El nombre del club es obligatorio';
    END IF;

    INSERT INTO equipo (
        nombre_club,
        ciudad,
        presupuesto,
        `anio_fundacion`,
        presidente,
        `titulos`
    ) VALUES (
        p_nombre_club,
        p_ciudad,
        p_presupuesto,
        p_anio_fundacion,
        p_presidente,
        p_titulos
    );

    SET v_id_equipo = LAST_INSERT_ID();

    SELECT id_temporada
    INTO v_id_temporada
    FROM temporada
    WHERE estado_temporada = 'En juego'
    ORDER BY fecha_inicio DESC
    LIMIT 1;

    IF v_id_temporada IS NOT NULL THEN
        SELECT COALESCE(MAX(posicion), 0) + 1
        INTO v_siguiente_posicion
        FROM clasificacion
        WHERE id_temporada = v_id_temporada;

        INSERT INTO clasificacion (id_temporada, id_equipo, posicion)
        VALUES (v_id_temporada, v_id_equipo, v_siguiente_posicion);
    END IF;
END$$

DROP PROCEDURE IF EXISTS sp_obtener_admin_por_usuario$$
CREATE PROCEDURE sp_obtener_admin_por_usuario(IN p_usuario VARCHAR(50))
BEGIN
    SELECT id_admin, usuario, password_hash
    FROM usuarios_admin
    WHERE usuario = p_usuario
    LIMIT 1;
END$$

DROP PROCEDURE IF EXISTS sp_listar_maximos_goleadores$$
CREATE PROCEDURE sp_listar_maximos_goleadores(IN p_limite INT)
BEGIN
    SELECT
        j.nombre,
        e.nombre_club,
        et.goles_totales,
        et.partidos_jugados,
        et.promedio_goles
    FROM estadisticas_temporada et
    INNER JOIN jugador j ON j.id_jugador = et.id_jugador
    INNER JOIN equipo e ON e.id_equipo = j.id_equipo
    INNER JOIN temporada t ON t.id_temporada = et.id_temporada
    WHERE t.estado_temporada = 'En juego'
    ORDER BY et.goles_totales DESC, et.promedio_goles DESC
    LIMIT p_limite;
END$$

DROP PROCEDURE IF EXISTS sp_listar_sanciones_activas$$
CREATE PROCEDURE sp_listar_sanciones_activas()
BEGIN
    SELECT
        s.id_sancion,
        j.nombre AS jugador,
        e.nombre_club AS equipo,
        s.tipo_tarjeta,
        s.partidos_suspension,
        s.estado
    FROM sanciones s
    INNER JOIN jugador j ON j.id_jugador = s.id_jugador
    INNER JOIN equipo e ON e.id_equipo = j.id_equipo
    WHERE s.estado IN ('Activa', 'Pendiente')
    ORDER BY s.fecha_registro DESC;
END$$

DELIMITER ;


-- ============================================================
-- PROCEDIMIENTO ACADEMICO 1
-- ============================================================
DELIMITER $$
DROP PROCEDURE IF EXISTS sp_registrar_resultado_partido$$
CREATE PROCEDURE sp_registrar_resultado_partido(
    IN p_id_partido INT,
    IN p_goles_local INT,
    IN p_goles_visitante INT,
    OUT p_resultado VARCHAR(100),
    OUT p_codigo_error INT
)
BEGIN
    -- Variables locales
    DECLARE v_id_equipo_local INT;
    DECLARE v_id_equipo_visitante INT;
    DECLARE v_id_temporada INT;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_puntos_local INT DEFAULT 0;
    DECLARE v_puntos_visitante INT DEFAULT 0;
    DECLARE v_error_ocurrido BOOLEAN DEFAULT FALSE;
    
    -- Handler para errores de integridad
    DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        SET p_codigo_error = 1004;
        SET p_resultado = 'Error de integridad referencial';
        ROLLBACK;
    END;
    
    -- Handler para errores personalizados
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        ROLLBACK;
    END;
    
    -- Inicializar valores de salida
    SET p_codigo_error = 0;
    SET p_resultado = '';
    
    -- Iniciar transacción
    START TRANSACTION;
    
    -- Validación 1: Goles no negativos
    IF p_goles_local < 0 OR p_goles_visitante < 0 THEN
        SET p_codigo_error = 1003;
        SET p_resultado = 'Los goles no pueden ser negativos';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 2: El partido existe
    SELECT id_equipo_local, id_equipo_visitante, estado
    INTO v_id_equipo_local, v_id_equipo_visitante, v_estado
    FROM partido
    WHERE id_partido = p_id_partido;
    
    IF v_id_equipo_local IS NULL THEN
        SET p_codigo_error = 1001;
        SET p_resultado = 'Partido no encontrado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 3: Partido no finalizado previamente
    IF v_estado = 'finalizado' THEN
        SET p_codigo_error = 1002;
        SET p_resultado = 'El partido ya ha sido finalizado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Determinar puntos según resultado
    IF p_goles_local > p_goles_visitante THEN
        SET v_puntos_local = 2;
        SET v_puntos_visitante = 0;
    ELSEIF p_goles_local < p_goles_visitante THEN
        SET v_puntos_local = 0;
        SET v_puntos_visitante = 2;
    ELSE
        SET v_puntos_local = 1;
        SET v_puntos_visitante = 1;
    END IF;
    

    -- Obtener la temporada del partido
    SELECT j.id_temporada INTO v_id_temporada
    FROM partido p
    JOIN jornada j ON p.id_jornada = j.id_jornada
    WHERE p.id_partido = p_id_partido;
    
    -- Actualizar resultado del partido
    UPDATE partido
    SET goles_local = p_goles_local,
        goles_visitante = p_goles_visitante,
        estado = 'finalizado'
    WHERE id_partido = p_id_partido;
    
    -- Actualizar clasificación equipo local
    UPDATE clasificacion
    SET partidos_jugados = partidos_jugados + 1,
        puntos = puntos + v_puntos_local,
        ganados = ganados + IF(v_puntos_local = 2, 1, 0),
        empatados = empatados + IF(v_puntos_local = 1, 1, 0),
        perdidos = perdidos + IF(v_puntos_local = 0, 1, 0),
        goles_favor = goles_favor + p_goles_local,
        goles_contra = goles_contra + p_goles_visitante,
        diferencia = (goles_favor + p_goles_local) - (goles_contra + p_goles_visitante)
    WHERE id_equipo = v_id_equipo_local
      AND id_temporada = v_id_temporada;
    
    -- Actualizar clasificación equipo visitante
    UPDATE clasificacion
    SET partidos_jugados = partidos_jugados + 1,
        puntos = puntos + v_puntos_visitante,
        ganados = ganados + IF(v_puntos_visitante = 2, 1, 0),
        empatados = empatados + IF(v_puntos_visitante = 1, 1, 0),
        perdidos = perdidos + IF(v_puntos_visitante = 0, 1, 0),
        goles_favor = goles_favor + p_goles_visitante,
        goles_contra = goles_contra + p_goles_local,
        diferencia = (goles_favor + p_goles_visitante) - (goles_contra + p_goles_local)
    WHERE id_equipo = v_id_equipo_visitante
      AND id_temporada = v_id_temporada;
    
    -- Si no hubo errores, hacer commit
    IF NOT v_error_ocurrido THEN
        COMMIT;
        SET p_resultado = CONCAT('Resultado registrado: ', p_goles_local, '-', p_goles_visitante);
        SET p_codigo_error = 0;
    END IF;
    
END$$

DELIMITER ;


-- ============================================================
-- PROCEDIMIENTO ACADEMICO 2
-- ============================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_inscribir_jugador_plantilla$$

CREATE PROCEDURE sp_inscribir_jugador_plantilla(
    IN p_id_jugador INT,
    IN p_id_equipo INT,
    IN p_id_temporada INT,
    IN p_dorsal INT,
    IN p_fecha_inicio DATE,
    IN p_fecha_fin DATE,
    OUT p_resultado VARCHAR(200),
    OUT p_codigo_error INT
)
BEGIN
    -- Variables locales
    DECLARE v_count_jugadores INT;
    DECLARE v_dorsal_existente INT;
    DECLARE v_nombre_jugador VARCHAR(200);
    DECLARE v_ya_inscrito INT;
    DECLARE v_error_ocurrido BOOLEAN DEFAULT FALSE;
    
    -- Handler para errores
    DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        SET p_codigo_error = 2009;
        SET p_resultado = 'Error de integridad referencial';
        ROLLBACK;
    END;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        ROLLBACK;
    END;
    
    -- Inicializar salida
    SET p_codigo_error = 0;
    SET p_resultado = '';
    
    START TRANSACTION;
    
    -- Validación 1: Dorsal en rango válido
    IF p_dorsal < 1 OR p_dorsal > 99 THEN
        SET p_codigo_error = 2004;
        SET p_resultado = 'El dorsal debe estar entre 1 y 99';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 2: Fechas coherentes
    IF p_fecha_fin IS NOT NULL AND p_fecha_inicio > p_fecha_fin THEN
        SET p_codigo_error = 2008;
        SET p_resultado = 'La fecha de fin debe ser posterior a la fecha de inicio';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 3: Jugador existe
    IF NOT EXISTS (SELECT 1 FROM jugador WHERE id_jugador = p_id_jugador) THEN
        SET p_codigo_error = 2001;
        SET p_resultado = 'Jugador no encontrado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 4: Equipo existe
    IF NOT EXISTS (SELECT 1 FROM equipo WHERE id_equipo = p_id_equipo) THEN
        SET p_codigo_error = 2002;
        SET p_resultado = 'Equipo no encontrado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 5: Temporada existe
    IF NOT EXISTS (SELECT 1 FROM temporada WHERE id_temporada = p_id_temporada) THEN
        SET p_codigo_error = 2003;
        SET p_resultado = 'Temporada no encontrada';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 6: Límite de 16 jugadores
    SELECT COUNT(*) INTO v_count_jugadores
    FROM plantilla
    WHERE id_equipo = p_id_equipo
      AND id_temporada = p_id_temporada;
    
    IF v_count_jugadores >= 16 THEN
        SET p_codigo_error = 2006;
        SET p_resultado = 'El equipo ha alcanzado el límite de 16 jugadores';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 7: Dorsal no ocupado
    SELECT COUNT(*), MAX(CONCAT(j.nombre, ' ', j.apellidos))
    INTO v_dorsal_existente, v_nombre_jugador
    FROM plantilla pl
    JOIN jugador j ON pl.id_jugador = j.id_jugador
    WHERE pl.id_equipo = p_id_equipo
      AND pl.id_temporada = p_id_temporada
      AND pl.numero_dorsal = p_dorsal;
    
    IF v_dorsal_existente > 0 THEN
        SET p_codigo_error = 2005;
        SET p_resultado = CONCAT('El dorsal ', p_dorsal, ' ya está asignado a ', v_nombre_jugador);
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 8: Jugador no inscrito ya
    SELECT COUNT(*) INTO v_ya_inscrito
    FROM plantilla
    WHERE id_jugador = p_id_jugador
      AND id_equipo = p_id_equipo
      AND id_temporada = p_id_temporada;
    
    IF v_ya_inscrito > 0 THEN
        SET p_codigo_error = 2007;
        SET p_resultado = 'El jugador ya está inscrito en este equipo para esta temporada';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Insertar en plantilla
    INSERT INTO plantilla (id_jugador, id_equipo, id_temporada, numero_dorsal, fecha_inicio, fecha_fin)
    VALUES (p_id_jugador, p_id_equipo, p_id_temporada, p_dorsal, p_fecha_inicio, p_fecha_fin);
    
    -- Commit si todo OK
    IF NOT v_error_ocurrido THEN
        COMMIT;
        SET p_resultado = CONCAT('Jugador inscrito correctamente con dorsal ', p_dorsal);
        SET p_codigo_error = 0;
    END IF;
    
END$$

DELIMITER ;


-- ============================================================
-- PROCEDIMIENTO ACADEMICO 3
-- ============================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_registrar_estadisticas_partido$$

CREATE PROCEDURE sp_registrar_estadisticas_partido(
    IN p_id_participacion INT,
    IN p_goles INT,
    IN p_lanzamientos INT,
    IN p_asistencias INT,
    IN p_paradas INT,
    IN p_exclusiones_2min INT,
    OUT p_resultado VARCHAR(100),
    OUT p_codigo_error INT
)
BEGIN
    -- Variables
    DECLARE v_id_jugador INT;
    DECLARE v_id_partido INT;
    DECLARE v_estado_partido VARCHAR(20);
    DECLARE v_id_posicion INT;
    DECLARE v_existe_stats INT;
    DECLARE v_error_ocurrido BOOLEAN DEFAULT FALSE;
    
    -- Handlers
    DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        SET p_codigo_error = 3009;
        SET p_resultado = 'Error de integridad';
        ROLLBACK;
    END;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        ROLLBACK;
    END;
    
    SET p_codigo_error = 0;
    SET p_resultado = '';
    
    START TRANSACTION;
    
    -- Validación 1: Valores no negativos
    IF p_goles < 0 OR p_lanzamientos < 0 OR p_asistencias < 0 OR 
       (p_paradas IS NOT NULL AND p_paradas < 0) OR p_exclusiones_2min < 0 THEN
        SET p_codigo_error = 3002;
        SET p_resultado = 'Los valores estadísticos no pueden ser negativos';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 2: Goles <= Lanzamientos
    IF p_goles > p_lanzamientos THEN
        SET p_codigo_error = 3003;
        SET p_resultado = 'Los goles no pueden superar los lanzamientos';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 3: Participación existe
    SELECT id_jugador, id_partido INTO v_id_jugador, v_id_partido
    FROM participa
    WHERE id_participacion = p_id_participacion;
    
    IF v_id_jugador IS NULL THEN
        SET p_codigo_error = 3001;
        SET p_resultado = 'Participación no encontrada';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 4: Partido finalizado
    SELECT estado INTO v_estado_partido
    FROM partido
    WHERE id_partido = v_id_partido;
    
    IF v_estado_partido != 'finalizado' THEN
        SET p_codigo_error = 3004;
        SET p_resultado = 'No se pueden registrar estadísticas de un partido no finalizado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 5: Solo porteros tienen paradas
    SELECT id_posicion INTO v_id_posicion
    FROM jugador
    WHERE id_jugador = v_id_jugador;
    
    -- Asumiendo que la posición 1 es portero (ajusta según tu BD)
    IF v_id_posicion != 1 AND p_paradas IS NOT NULL AND p_paradas > 0 THEN
        SET p_codigo_error = 3005;
        SET p_resultado = 'Solo los porteros pueden tener paradas';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 6: No duplicados
    SELECT COUNT(*) INTO v_existe_stats
    FROM estadisticas_partido
    WHERE id_participacion = p_id_participacion;
    
    IF v_existe_stats > 0 THEN
        SET p_codigo_error = 3006;
        SET p_resultado = 'Ya existen estadísticas para esta participación';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Insertar estadísticas
    INSERT INTO estadisticas_partido 
        (id_participacion, goles, lanzamientos, asistencias, paradas, exclusiones_2min)
    VALUES 
        (p_id_participacion, p_goles, p_lanzamientos, p_asistencias, p_paradas, p_exclusiones_2min);
    
    IF NOT v_error_ocurrido THEN
        COMMIT;
        SET p_resultado = 'Estadísticas registradas correctamente';
        SET p_codigo_error = 0;
    END IF;
    
END$$

DELIMITER ;


-- ============================================================
-- PROCEDIMIENTO ACADEMICO 4
-- ============================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_registrar_sancion$$

CREATE PROCEDURE sp_registrar_sancion(
    IN p_id_jugador INT,
    IN p_id_partido INT,
    IN p_tipo ENUM('amarilla','roja','azul'),
    IN p_minuto INT,
    IN p_motivo VARCHAR(200),
    OUT p_suspension_generada BOOLEAN,
    OUT p_partidos_suspension INT,
    OUT p_resultado VARCHAR(150),
    OUT p_codigo_error INT
)
BEGIN
    -- Variables
    DECLARE v_count_amarillas INT;
    DECLARE v_id_temporada INT;
    DECLARE v_siguiente_jornada INT;
    DECLARE v_error_ocurrido BOOLEAN DEFAULT FALSE;
    
    -- Handlers
    DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        SET p_codigo_error = 4006;
        SET p_resultado = 'Error de integridad';
        ROLLBACK;
    END;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        ROLLBACK;
    END;
    
    SET p_codigo_error = 0;
    SET p_resultado = '';
    SET p_suspension_generada = FALSE;
    SET p_partidos_suspension = 0;
    
    START TRANSACTION;
    
    -- Validación 1: Minuto válido
    IF p_minuto < 0 OR p_minuto > 60 THEN
        SET p_codigo_error = 4003;
        SET p_resultado = 'Minuto inválido (debe estar entre 0 y 60)';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 2: Jugador existe
    IF NOT EXISTS (SELECT 1 FROM jugador WHERE id_jugador = p_id_jugador) THEN
        SET p_codigo_error = 4001;
        SET p_resultado = 'Jugador no encontrado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 3: Partido existe
    IF NOT EXISTS (SELECT 1 FROM partido WHERE id_partido = p_id_partido) THEN
        SET p_codigo_error = 4002;
        SET p_resultado = 'Partido no encontrado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Insertar sanción
    INSERT INTO sancion (id_jugador, id_partido, tipo, minuto, motivo)
    VALUES (p_id_jugador, p_id_partido, p_tipo, p_minuto, p_motivo);
    
    -- Obtener temporada
    SELECT j.id_temporada INTO v_id_temporada
    FROM partido p
    JOIN jornada j ON p.id_jornada = j.id_jornada
    WHERE p.id_partido = p_id_partido;
    
    -- Lógica según tipo de sanción
    IF p_tipo = 'amarilla' THEN
        -- Contar amarillas en la temporada
        SELECT COUNT(*) INTO v_count_amarillas
        FROM sancion s
        JOIN partido p ON s.id_partido = p.id_partido
        JOIN jornada j ON p.id_jornada = j.id_jornada
        WHERE s.id_jugador = p_id_jugador
          AND s.tipo = 'amarilla'
          AND j.id_temporada = v_id_temporada;
        
        -- Si llega a 3, crear suspensión
        IF v_count_amarillas >= 3 THEN
            SET p_suspension_generada = TRUE;
            SET p_partidos_suspension = 1;
            -- Aquí podrías INSERT en una tabla SUSPENSION si existe
            SET p_resultado = CONCAT('Sanción registrada. Suspensión automática: 1 partido por acumulación de 3 amarillas');
        ELSE
            SET p_resultado = CONCAT('Tarjeta amarilla registrada (', v_count_amarillas, '/3 acumuladas)');
        END IF;
        
    ELSEIF p_tipo = 'roja' THEN
        SET p_suspension_generada = TRUE;
        SET p_partidos_suspension = 2;
        SET p_resultado = 'Tarjeta roja registrada. Suspensión: 2 partidos';
        
    ELSEIF p_tipo = 'azul' THEN
        SET p_suspension_generada = TRUE;
        SET p_partidos_suspension = NULL; -- Indefinida
        SET p_resultado = 'Tarjeta azul registrada. Suspensión indefinida (requiere comité)';
    END IF;
    
    IF NOT v_error_ocurrido THEN
        COMMIT;
        SET p_codigo_error = 0;
    END IF;
    
END$$

DELIMITER ;


-- ============================================================
-- PROCEDIMIENTO ACADEMICO 5
-- ============================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_convocar_jugador_partido$$

CREATE PROCEDURE sp_convocar_jugador_partido(
    IN p_id_jugador INT,
    IN p_id_partido INT,
    IN p_titular BOOLEAN,
    OUT p_resultado VARCHAR(150),
    OUT p_codigo_error INT
)
BEGIN
    -- Variables
    DECLARE v_id_equipo_local INT;
    DECLARE v_id_equipo_visitante INT;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_equipo_jugador INT;
    DECLARE v_count_convocados INT;
    DECLARE v_ya_convocado INT;
    DECLARE v_error_ocurrido BOOLEAN DEFAULT FALSE;
    
    -- Handlers
    DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        SET p_codigo_error = 5008;
        SET p_resultado = 'Error de integridad';
        ROLLBACK;
    END;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        ROLLBACK;
    END;
    
    SET p_codigo_error = 0;
    SET p_resultado = '';
    
    START TRANSACTION;
    
    -- Validación 1: Partido existe
    SELECT id_equipo_local, id_equipo_visitante, estado
    INTO v_id_equipo_local, v_id_equipo_visitante, v_estado
    FROM partido
    WHERE id_partido = p_id_partido;
    
    IF v_id_equipo_local IS NULL THEN
        SET p_codigo_error = 5001;
        SET p_resultado = 'Partido no encontrado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 2: Partido no finalizado
    IF v_estado = 'finalizado' THEN
        SET p_codigo_error = 5002;
        SET p_resultado = 'No se puede convocar para un partido ya finalizado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 3: Jugador en plantilla activa
    SELECT pl.id_equipo INTO v_equipo_jugador
    FROM plantilla pl
    WHERE pl.id_jugador = p_id_jugador
      AND (pl.fecha_fin IS NULL OR pl.fecha_fin >= CURDATE())
    LIMIT 1;
    
    IF v_equipo_jugador IS NULL THEN
        SET p_codigo_error = 5003;
        SET p_resultado = 'Jugador no encontrado en ninguna plantilla activa';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 4: Jugador pertenece a uno de los equipos
    IF v_equipo_jugador != v_id_equipo_local AND v_equipo_jugador != v_id_equipo_visitante THEN
        SET p_codigo_error = 5004;
        SET p_resultado = 'El jugador no pertenece a ninguno de los equipos del partido';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 5: Límite de 16 convocados
    SELECT COUNT(*) INTO v_count_convocados
    FROM participa part
    JOIN plantilla pl ON part.id_jugador = pl.id_jugador
    WHERE part.id_partido = p_id_partido
      AND pl.id_equipo = v_equipo_jugador;
    
    IF v_count_convocados >= 16 THEN
        SET p_codigo_error = 5006;
        SET p_resultado = 'Límite de 16 jugadores convocados alcanzado para este equipo';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 6: No duplicados
    SELECT COUNT(*) INTO v_ya_convocado
    FROM participa
    WHERE id_jugador = p_id_jugador
      AND id_partido = p_id_partido;
    
    IF v_ya_convocado > 0 THEN
        SET p_codigo_error = 5007;
        SET p_resultado = 'El jugador ya está convocado para este partido';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Insertar convocatoria
    INSERT INTO participa (id_jugador, id_partido, minutos_jugados, titular)
    VALUES (p_id_jugador, p_id_partido, 0, p_titular);
    
    IF NOT v_error_ocurrido THEN
        COMMIT;
        SET p_resultado = CONCAT('Jugador convocado correctamente como ', IF(p_titular, 'titular', 'suplente'));
        SET p_codigo_error = 0;
    END IF;
    
END$$

DELIMITER ;


-- ============================================================
-- PROCEDIMIENTO ACADEMICO 6
-- ============================================================
DELIMITER $$

DROP PROCEDURE IF EXISTS sp_finalizar_partido$$

CREATE PROCEDURE sp_finalizar_partido(
    IN p_id_partido INT,
    OUT p_resultado VARCHAR(150),
    OUT p_codigo_error INT
)
BEGIN
    -- Variables
    DECLARE v_goles_local INT;
    DECLARE v_goles_visitante INT;
    DECLARE v_estado VARCHAR(20);
    DECLARE v_count_convocados INT;
    DECLARE v_count_estadisticas INT;
    DECLARE v_faltantes INT;
    DECLARE v_error_ocurrido BOOLEAN DEFAULT FALSE;
    
    -- Handlers
    DECLARE CONTINUE HANDLER FOR SQLSTATE '23000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        SET p_codigo_error = 7005;
        SET p_resultado = 'Error de integridad';
        ROLLBACK;
    END;
    
    DECLARE CONTINUE HANDLER FOR SQLSTATE '45000'
    BEGIN
        SET v_error_ocurrido = TRUE;
        ROLLBACK;
    END;
    
    SET p_codigo_error = 0;
    SET p_resultado = '';
    
    START TRANSACTION;
    
    -- Validación 1: Partido existe
    SELECT goles_local, goles_visitante, estado
    INTO v_goles_local, v_goles_visitante, v_estado
    FROM partido
    WHERE id_partido = p_id_partido;
    
    IF v_goles_local IS NULL AND v_goles_visitante IS NULL THEN
        SET p_codigo_error = 7001;
        SET p_resultado = 'Partido no encontrado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 2: No ya finalizado
    IF v_estado = 'finalizado' THEN
        SET p_codigo_error = 7002;
        SET p_resultado = 'El partido ya está finalizado';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 3: Tiene resultado
    IF v_goles_local IS NULL OR v_goles_visitante IS NULL THEN
        SET p_codigo_error = 7003;
        SET p_resultado = 'Debe registrar el resultado antes de finalizar el partido';
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Validación 4: Estadísticas completas
    SELECT COUNT(*) INTO v_count_convocados
    FROM participa
    WHERE id_partido = p_id_partido;
    
    SELECT COUNT(*) INTO v_count_estadisticas
    FROM estadisticas_partido ep
    JOIN participa p ON ep.id_participacion = p.id_participacion
    WHERE p.id_partido = p_id_partido;
    
    SET v_faltantes = v_count_convocados - v_count_estadisticas;
    
    IF v_faltantes > 0 THEN
        SET p_codigo_error = 7004;
        SET p_resultado = CONCAT('Faltan estadísticas de ', v_faltantes, ' jugador(es)');
        SIGNAL SQLSTATE '45000';
    END IF;
    
    -- Finalizar partido
    UPDATE partido
    SET estado = 'finalizado'
    WHERE id_partido = p_id_partido;
    
    IF NOT v_error_ocurrido THEN
        COMMIT;
        SET p_resultado = 'Partido finalizado correctamente';
        SET p_codigo_error = 0;
    END IF;
    
END$$

DELIMITER ;


-- ============================================================
-- TRIGGER ESTADISTICAS TEMPORADA
-- ============================================================
delimiter $$

drop trigger if exists calcular_estadisticas_temporada_insert$$
create trigger calcular_estadisticas_temporada_insert
after insert on estadisticas
for each row
begin
    -- validaciones usando funciones
    if not existe_jugador(new.id_jugador) then
        signal sqlstate '45000'
        set message_text = 'Error: el jugador especificado no existe';
    end if;
    
    if not existe_temporada(new.id_temporada) then
        signal sqlstate '45000'
        set message_text = 'Error: la temporada especificada no existe';
    end if;
    
    if not existe_partido(new.id_partido) then
        signal sqlstate '45000'
        set message_text = 'Error: el partido especificado no existe';
    end if;
    
    -- crear o actualizar estadísticas
    if not exists (
        select 1 
        from estadisticas_temporada 
        where id_jugador = new.id_jugador 
        and id_temporada = new.id_temporada
    ) then
        -- crear nuevo registro
        insert into estadisticas_temporada (
            id_jugador,
            id_temporada,
            partidos_jugados,
            goles_totales,
            paradas_totales,
            sanciones_totales,
            tarjetas_amarillas_totales,
            tarjetas_rojas_totales,
            tarjetas_azul_totales,
            dos_minutos_totales
        ) values (
            new.id_jugador,
            new.id_temporada,
            1,
            new.goles,
            new.paradas,
            new.sanciones,
            new.tarjetas_amarillas,
            new.tarjetas_rojas,
            new.tarjetas_azul,
            new.dos_minutos
        );
    else
        -- actualizar registro existente
        update estadisticas_temporada
        set partidos_jugados = partidos_jugados + 1,
            goles_totales = goles_totales + new.goles,
            paradas_totales = paradas_totales + new.paradas,
            sanciones_totales = sanciones_totales + new.sanciones,
            tarjetas_amarillas_totales = tarjetas_amarillas_totales + new.tarjetas_amarillas,
            tarjetas_rojas_totales = tarjetas_rojas_totales + new.tarjetas_rojas,
            tarjetas_azul_totales = tarjetas_azul_totales + new.tarjetas_azul,
            dos_minutos_totales = dos_minutos_totales + new.dos_minutos
        where id_jugador = new.id_jugador 
        and id_temporada = new.id_temporada;
    end if;
    
    -- calcular indicadores derivados
    update estadisticas_temporada
    set promedio_goles = goles_totales / partidos_jugados,
        porcentaje_paradas = if(paradas_totales > 0, (paradas_totales * 100.0) / (paradas_totales + goles_totales), 0)
    where id_jugador = new.id_jugador 
    and id_temporada = new.id_temporada;
end$$

delimiter ;

delimiter $$

drop trigger if exists calcular_estadisticas_temporada_update$$
create trigger calcular_estadisticas_temporada_update
after update on estadisticas
for each row
begin
    -- validaciones usando funciones
    if not existe_jugador(new.id_jugador) then
        signal sqlstate '45000'
        set message_text = 'Error: el jugador especificado no existe';
    end if;
    
    if not existe_temporada(new.id_temporada) then
        signal sqlstate '45000'
        set message_text = 'Error: la temporada especificada no existe';
    end if;
    
    -- actualizar estadísticas (revertir old y aplicar new)
    update estadisticas_temporada
    set goles_totales = goles_totales - old.goles + new.goles,
        paradas_totales = paradas_totales - old.paradas + new.paradas,
        sanciones_totales = sanciones_totales - old.sanciones + new.sanciones,
        tarjetas_amarillas_totales = tarjetas_amarillas_totales - old.tarjetas_amarillas + new.tarjetas_amarillas,
        tarjetas_rojas_totales = tarjetas_rojas_totales - old.tarjetas_rojas + new.tarjetas_rojas,
        tarjetas_azul_totales = tarjetas_azul_totales - old.tarjetas_azul + new.tarjetas_azul,
        dos_minutos_totales = dos_minutos_totales - old.dos_minutos + new.dos_minutos
    where id_jugador = new.id_jugador 
    and id_temporada = new.id_temporada;
    
    -- recalcular indicadores derivados
    update estadisticas_temporada
    set promedio_goles = goles_totales / partidos_jugados,
        porcentaje_paradas = if(paradas_totales > 0, (paradas_totales * 100.0) / (paradas_totales + goles_totales), 0)
    where id_jugador = new.id_jugador 
    and id_temporada = new.id_temporada;
end$$

delimiter ;


-- ============================================================
-- TRIGGER VALIDAR PARTIDO
-- ============================================================
delimiter $$

drop trigger if exists trg_validar_partido_insert$$
create trigger trg_validar_partido_insert
before insert on partido
for each row
begin
    -- validar goles no negativos
    if new.goles_local < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo local no pueden ser negativos';
    end if;
    
    if new.goles_visitante < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo visitante no pueden ser negativos';
    end if;
    
    -- validar equipos diferentes
    if new.id_equipo_local = new.id_equipo_visitante then
        signal sqlstate '45000'
        set message_text = 'El equipo local y visitante deben ser diferentes';
    end if;
    
    -- validar existencias usando funciones
    if not existe_equipo(new.id_equipo_local) then
        signal sqlstate '45000'
        set message_text = 'El equipo local no existe en la base de datos';
    end if;
    
    if not existe_equipo(new.id_equipo_visitante) then
        signal sqlstate '45000'
        set message_text = 'El equipo visitante no existe en la base de datos';
    end if;
    
    if not existe_jornada(new.id_jornada) then
        signal sqlstate '45000'
        set message_text = 'La jornada asignada no existe';
    end if;
    
    if not existe_pabellon(new.id_pabellon) then
        signal sqlstate '45000'
        set message_text = 'El pabellón asignado no existe';
    end if;
    
    -- validar fecha usando función
    if not fecha_dentro_temporada(date(new.fecha), new.id_jornada) then
        signal sqlstate '45000'
        set message_text = 'La fecha del partido debe estar dentro del periodo de la temporada';
    end if;
    
    -- validar partido no duplicado usando función
    if existe_partido_duplicado(new.id_jornada, new.id_equipo_local, new.id_equipo_visitante, null) then
        signal sqlstate '45000'
        set message_text = 'Ya existe un partido entre estos equipos en esta jornada';
    end if;
end$$

delimiter ;

delimiter $$

drop trigger if exists trg_validar_partido_update$$
create trigger trg_validar_partido_update
before update on partido
for each row
begin
    -- validar goles no negativos
    if new.goles_local < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo local no pueden ser negativos';
    end if;
    
    if new.goles_visitante < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo visitante no pueden ser negativos';
    end if;
    
    -- validar equipos diferentes
    if new.id_equipo_local = new.id_equipo_visitante then
        signal sqlstate '45000'
        set message_text = 'El equipo local y visitante deben ser diferentes';
    end if;
    
    -- validar existencias usando funciones
    if not existe_equipo(new.id_equipo_local) then
        signal sqlstate '45000'
        set message_text = 'El equipo local no existe en la base de datos';
    end if;
    
    if not existe_equipo(new.id_equipo_visitante) then
        signal sqlstate '45000'
        set message_text = 'El equipo visitante no existe en la base de datos';
    end if;
    
    if not existe_jornada(new.id_jornada) then
        signal sqlstate '45000'
        set message_text = 'La jornada asignada no existe';
    end if;
    
    if not existe_pabellon(new.id_pabellon) then
        signal sqlstate '45000'
        set message_text = 'El pabellón asignado no existe';
    end if;
    
    -- validar fecha usando función
    if not fecha_dentro_temporada(date(new.fecha), new.id_jornada) then
        signal sqlstate '45000'
        set message_text = 'La fecha del partido debe estar dentro del periodo de la temporada';
    end if;
    
    -- validar partido no duplicado usando función (excluyendo el actual)
    if existe_partido_duplicado(new.id_jornada, new.id_equipo_local, new.id_equipo_visitante, new.id_partido) then
        signal sqlstate '45000'
        set message_text = 'Ya existe un partido entre estos equipos en esta jornada';
    end if;
end$$

delimiter ;


-- ============================================================
-- TRIGGER CONTROLAR DORSALES
-- ============================================================
delimiter $$

drop trigger if exists trg_controlar_dorsales_insert$$
create trigger trg_controlar_dorsales_insert
before insert on jugador
for each row
begin
    declare nombre_existente varchar(100);
    declare mensaje_error varchar(255);
    
    -- validar rango del dorsal
    if new.dorsal < 1 or new.dorsal > 99 then
        signal sqlstate '45000'
        set message_text = 'El dorsal debe estar entre 1 y 99';
    end if;
    
    -- buscar jugador con ese dorsal usando función
    set nombre_existente = obtener_jugador_con_dorsal(new.id_equipo, new.dorsal, null);
    
    -- si existe, lanzar error
    if nombre_existente is not null then
        set mensaje_error = concat('El dorsal ', new.dorsal, ' ya está asignado al jugador ', nombre_existente);
        signal sqlstate '45000'
        set message_text = mensaje_error;
    end if;
end$$

delimiter ;


-- ============================================================
-- TRIGGER GESTIONAR SANCIONES
-- ============================================================
delimiter $$

drop trigger if exists trg_gestionar_sanciones_insert$$
create trigger trg_gestionar_sanciones_insert
after insert on estadisticas
for each row
begin
    declare amarillas_acumuladas int;
    declare jornada_siguiente int;
    
    -- obtener siguiente jornada usando función
    set jornada_siguiente = obtener_jornada_siguiente(new.id_jornada);
    
    -- gestionar tarjetas amarillas
    if new.tarjetas_amarillas > 0 then
        -- contar amarillas acumuladas usando función
        set amarillas_acumuladas = contar_amarillas_temporada(new.id_jugador, new.id_temporada);
        
        -- si llega a 3, crear sanción
        if amarillas_acumuladas >= 3 then
            insert into sanciones (
                id_jugador,
                id_temporada,
                tipo_tarjeta,
                motivo,
                partidos_suspension,
                jornada_inicio,
                estado
            ) values (
                new.id_jugador,
                new.id_temporada,
                'Amarilla',
                'Acumulación de 3 tarjetas amarillas',
                1,
                jornada_siguiente,
                'Activa'
            );
        end if;
    end if;
    
    -- gestionar tarjetas rojas
    if new.tarjetas_rojas > 0 then
        insert into sanciones (
            id_jugador,
            id_temporada,
            tipo_tarjeta,
            motivo,
            partidos_suspension,
            jornada_inicio,
            estado
        ) values (
            new.id_jugador,
            new.id_temporada,
            'Roja',
            'Tarjeta roja directa',
            2,
            jornada_siguiente,
            'Activa'
        );
    end if;
    
    -- gestionar tarjetas azules
    if new.tarjetas_azul > 0 then
        insert into sanciones (
            id_jugador,
            id_temporada,
            tipo_tarjeta,
            motivo,
            partidos_suspension,
            jornada_inicio,
            estado
        ) values (
            new.id_jugador,
            new.id_temporada,
            'Azul',
            'Conducta grave - Pendiente resolución comité disciplinario',
            999,
            jornada_siguiente,
            'Pendiente'
        );
    end if;
end$$

delimiter ;


-- ============================================================
-- TRIGGER ACTUALIZAR CLASIFICACION
-- ============================================================
delimiter $$

drop trigger if exists actualizar_clasificacion_update$$
create trigger actualizar_clasificacion_update
after update on partido
for each row
begin
    declare temporada int;
    
    -- obtener temporada una sola vez (usando función)
    set temporada = obtener_temporada_de_jornada(new.id_jornada);
    
    -- revertir resultado anterior
    if old.goles_local > old.goles_visitante then
        -- revertir victoria local
        update clasificacion
        set puntos = puntos - 2,
            victorias = victorias - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_local 
        and id_temporada = temporada;
        
        -- revertir derrota visitante
        update clasificacion
        set derrotas = derrotas - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = temporada;
        
    elseif old.goles_visitante > old.goles_local then
        -- revertir victoria visitante
        update clasificacion
        set puntos = puntos - 2,
            victorias = victorias - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = temporada;
        
        -- revertir derrota local
        update clasificacion
        set derrotas = derrotas - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_local 
        and id_temporada = temporada;
        
    else
        -- revertir empate
        update clasificacion
        set puntos = puntos - 1,
            empates = empates - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_local 
        and id_temporada = temporada;
        
        update clasificacion
        set puntos = puntos - 1,
            empates = empates - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = temporada;
    end if;
    
    -- aplicar nuevo resultado
    if new.goles_local > new.goles_visitante then
        -- victoria local
        update clasificacion
        set puntos = puntos + 2,
            victorias = victorias + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_local 
        and id_temporada = temporada;
        
        -- derrota visitante
        update clasificacion
        set derrotas = derrotas + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_visitante 
        and id_temporada = temporada;
        
    elseif new.goles_visitante > new.goles_local then
        -- victoria visitante
        update clasificacion
        set puntos = puntos + 2,
            victorias = victorias + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_visitante 
        and id_temporada = temporada;
        
        -- derrota local
        update clasificacion
        set derrotas = derrotas + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_local 
        and id_temporada = temporada;
        
    else
        -- empate
        update clasificacion
        set puntos = puntos + 1,
            empates = empates + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_local 
        and id_temporada = temporada;
        
        update clasificacion
        set puntos = puntos + 1,
            empates = empates + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_visitante 
        and id_temporada = temporada;
    end if;
    
    -- reordenar posiciones
    set @posicion = 0;
    update clasificacion c
    join (
        select id_clasificacion,
               @posicion := @posicion + 1 as nueva_posicion
        from clasificacion
        where id_temporada = temporada
        order by puntos desc, diferencia_goles desc, goles_favor desc
    ) as ranking on c.id_clasificacion = ranking.id_clasificacion
    set c.posicion = ranking.nueva_posicion;
end$$

delimiter ;


-- ============================================================
-- RECALCULAR CLASIFICACION
-- ============================================================
USE Asobal;

DELIMITER $$

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- PROCEDIMIENTO: sp_recalcular_clasificacion
-- Recalcula toda la clasificación desde cero mirando los partidos.
-- Ãšsalo cuando los datos estén desincronizados o al importar datos.
-- Uso: CALL sp_recalcular_clasificacion();
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

DROP PROCEDURE IF EXISTS sp_recalcular_clasificacion$$
CREATE PROCEDURE sp_recalcular_clasificacion()
BEGIN
    DECLARE v_id_temporada INT;

    -- Obtener la temporada activa
    SELECT id_temporada INTO v_id_temporada
    FROM temporada
    WHERE estado_temporada = 'En juego'
    ORDER BY fecha_inicio DESC
    LIMIT 1;

    IF v_id_temporada IS NULL THEN
        SIGNAL SQLSTATE '45000'
            SET MESSAGE_TEXT = 'No hay ninguna temporada en estado En juego';
    END IF;

    -- Paso 1: Resetear todo a 0
    UPDATE clasificacion
    SET victorias        = 0,
        empates          = 0,
        derrotas         = 0,
        goles_favor      = 0,
        goles_contra     = 0,
        diferencia_goles = 0,
        puntos           = 0
    WHERE id_temporada = v_id_temporada;

    -- Paso 2: Victorias del equipo LOCAL
    UPDATE clasificacion c
    INNER JOIN (
        SELECT p.id_equipo_local          AS id_equipo,
               COUNT(*)                   AS victorias,
               SUM(p.goles_local)         AS gf,
               SUM(p.goles_visitante)     AS gc,
               obtener_temporada_de_jornada(p.id_jornada) AS id_temporada
        FROM partido p
        WHERE p.goles_local > p.goles_visitante
        GROUP BY p.id_equipo_local, obtener_temporada_de_jornada(p.id_jornada)
    ) r ON c.id_equipo = r.id_equipo AND c.id_temporada = r.id_temporada
    SET c.victorias     = c.victorias + r.victorias,
        c.puntos        = c.puntos    + (r.victorias * 2),
        c.goles_favor   = c.goles_favor  + r.gf,
        c.goles_contra  = c.goles_contra + r.gc;

    -- Paso 3: Victorias del equipo VISITANTE
    UPDATE clasificacion c
    INNER JOIN (
        SELECT p.id_equipo_visitante      AS id_equipo,
               COUNT(*)                   AS victorias,
               SUM(p.goles_visitante)     AS gf,
               SUM(p.goles_local)         AS gc,
               obtener_temporada_de_jornada(p.id_jornada) AS id_temporada
        FROM partido p
        WHERE p.goles_visitante > p.goles_local
        GROUP BY p.id_equipo_visitante, obtener_temporada_de_jornada(p.id_jornada)
    ) r ON c.id_equipo = r.id_equipo AND c.id_temporada = r.id_temporada
    SET c.victorias     = c.victorias + r.victorias,
        c.puntos        = c.puntos    + (r.victorias * 2),
        c.goles_favor   = c.goles_favor  + r.gf,
        c.goles_contra  = c.goles_contra + r.gc;

    -- Paso 4: Empates LOCAL
    UPDATE clasificacion c
    INNER JOIN (
        SELECT p.id_equipo_local          AS id_equipo,
               COUNT(*)                   AS empates,
               SUM(p.goles_local)         AS gf,
               SUM(p.goles_visitante)     AS gc,
               obtener_temporada_de_jornada(p.id_jornada) AS id_temporada
        FROM partido p
        WHERE p.goles_local = p.goles_visitante
        GROUP BY p.id_equipo_local, obtener_temporada_de_jornada(p.id_jornada)
    ) r ON c.id_equipo = r.id_equipo AND c.id_temporada = r.id_temporada
    SET c.empates       = c.empates + r.empates,
        c.puntos        = c.puntos  + r.empates,
        c.goles_favor   = c.goles_favor  + r.gf,
        c.goles_contra  = c.goles_contra + r.gc;

    -- Paso 5: Empates VISITANTE
    UPDATE clasificacion c
    INNER JOIN (
        SELECT p.id_equipo_visitante      AS id_equipo,
               COUNT(*)                   AS empates,
               SUM(p.goles_visitante)     AS gf,
               SUM(p.goles_local)         AS gc,
               obtener_temporada_de_jornada(p.id_jornada) AS id_temporada
        FROM partido p
        WHERE p.goles_local = p.goles_visitante
        GROUP BY p.id_equipo_visitante, obtener_temporada_de_jornada(p.id_jornada)
    ) r ON c.id_equipo = r.id_equipo AND c.id_temporada = r.id_temporada
    SET c.empates       = c.empates + r.empates,
        c.puntos        = c.puntos  + r.empates,
        c.goles_favor   = c.goles_favor  + r.gf,
        c.goles_contra  = c.goles_contra + r.gc;

    -- Paso 6: Derrotas LOCAL
    UPDATE clasificacion c
    INNER JOIN (
        SELECT p.id_equipo_local          AS id_equipo,
               COUNT(*)                   AS derrotas,
               SUM(p.goles_local)         AS gf,
               SUM(p.goles_visitante)     AS gc,
               obtener_temporada_de_jornada(p.id_jornada) AS id_temporada
        FROM partido p
        WHERE p.goles_local < p.goles_visitante
        GROUP BY p.id_equipo_local, obtener_temporada_de_jornada(p.id_jornada)
    ) r ON c.id_equipo = r.id_equipo AND c.id_temporada = r.id_temporada
    SET c.derrotas      = c.derrotas + r.derrotas,
        c.goles_favor   = c.goles_favor  + r.gf,
        c.goles_contra  = c.goles_contra + r.gc;

    -- Paso 7: Derrotas VISITANTE
    UPDATE clasificacion c
    INNER JOIN (
        SELECT p.id_equipo_visitante      AS id_equipo,
               COUNT(*)                   AS derrotas,
               SUM(p.goles_visitante)     AS gf,
               SUM(p.goles_local)         AS gc,
               obtener_temporada_de_jornada(p.id_jornada) AS id_temporada
        FROM partido p
        WHERE p.goles_visitante < p.goles_local
        GROUP BY p.id_equipo_visitante, obtener_temporada_de_jornada(p.id_jornada)
    ) r ON c.id_equipo = r.id_equipo AND c.id_temporada = r.id_temporada
    SET c.derrotas      = c.derrotas + r.derrotas,
        c.goles_favor   = c.goles_favor  + r.gf,
        c.goles_contra  = c.goles_contra + r.gc;

    -- Paso 8: Diferencia de goles
    UPDATE clasificacion
    SET diferencia_goles = goles_favor - goles_contra
    WHERE id_temporada = v_id_temporada;

    -- Paso 9: Recalcular posiciones
    SET @pos = 0;
    UPDATE clasificacion c
    INNER JOIN (
        SELECT id_clasificacion,
               @pos := @pos + 1 AS nueva_pos
        FROM clasificacion
        WHERE id_temporada = v_id_temporada
        ORDER BY puntos DESC, diferencia_goles DESC, goles_favor DESC
    ) r ON c.id_clasificacion = r.id_clasificacion
    SET c.posicion = r.nueva_pos;

END$$


-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- TRIGGER: Sustituye el trigger antiguo del UPDATE
-- Borra el viejo y pone uno nuevo que llama al procedimiento.
-- Así cada vez que edites un resultado se recalcula todo solo.
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

DROP TRIGGER IF EXISTS actualizar_clasificacion_update$$
CREATE TRIGGER actualizar_clasificacion_update
AFTER UPDATE ON partido
FOR EACH ROW
BEGIN
    -- Solo recalcular si cambiaron los goles
    IF OLD.goles_local    <> NEW.goles_local
    OR OLD.goles_visitante <> NEW.goles_visitante THEN
        CALL sp_recalcular_clasificacion();
    END IF;
END$$


-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- TRIGGER EXTRA: También recalcula al ELIMINAR un partido
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•

DROP TRIGGER IF EXISTS recalcular_clasificacion_delete$$
CREATE TRIGGER recalcular_clasificacion_delete
AFTER DELETE ON partido
FOR EACH ROW
BEGIN
    CALL sp_recalcular_clasificacion();
END$$


DELIMITER ;

-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
-- Ejecutar el recálculo ahora mismo para sincronizar los datos
-- que ya tenías en la BD antes de crear este archivo.
-- â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•â•
CALL sp_recalcular_clasificacion();

SELECT 'Clasificación recalculada y triggers instalados correctamente' AS resultado;

SET FOREIGN_KEY_CHECKS = 1;
SELECT 'Instalacion completa ASOBAL finalizada correctamente' AS resultado;
