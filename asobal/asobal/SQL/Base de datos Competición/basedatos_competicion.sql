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




