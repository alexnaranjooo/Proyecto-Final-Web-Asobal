-- ======================================
-- PROCEDIMIENTOS ALMACENADOS - ASOBAL
-- Proyecto: Liga de Balonmano
-- ======================================

USE Asobal;

-- Tabla de administradores
CREATE TABLE IF NOT EXISTS usuarios_admin (
    id_admin INT PRIMARY KEY AUTO_INCREMENT,
    usuario VARCHAR(50) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    creado_en DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- Insertamos usuario de prueba (si no existe)
-- Usuario: admin | Contraseña: Admin123!
INSERT INTO usuarios_admin (usuario, password_hash)
VALUES ('admin', '$2y$10$92IXUNpkjO0rOQ5byMi.Ye4oKoEa3Ro9llC/.og/at2.uheWG/igi')
ON DUPLICATE KEY UPDATE password_hash = VALUES(password_hash);

-- ======================================
-- PROCEDIMIENTOS
-- ======================================

DELIMITER $$

-- Procedimiento 1: Listar clasificación
DROP PROCEDURE IF EXISTS sp_listar_clasificacion$$
CREATE PROCEDURE sp_listar_clasificacion()
READS SQL DATA
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
        c.diferencia_goles,
        c.id_temporada
    FROM clasificacion c
    INNER JOIN equipo e ON e.id_equipo = c.id_equipo
    INNER JOIN temporada t ON t.id_temporada = c.id_temporada
    WHERE t.estado_temporada = 'En juego'
    ORDER BY c.posicion ASC, c.puntos DESC, c.diferencia_goles DESC, c.goles_favor DESC;
END$$

-- Procedimiento 2: Listar partidos (con filtro por tipo)
DROP PROCEDURE IF EXISTS sp_listar_partidos$$
CREATE PROCEDURE sp_listar_partidos(IN p_tipo VARCHAR(20))
READS SQL DATA
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

-- Procedimiento 3: Listar equipos
DROP PROCEDURE IF EXISTS sp_listar_equipos$$
CREATE PROCEDURE sp_listar_equipos()
READS SQL DATA
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

-- Procedimiento 4: Listar jugadores de un equipo
DROP PROCEDURE IF EXISTS sp_listar_jugadores_equipo$$
CREATE PROCEDURE sp_listar_jugadores_equipo(IN p_id_equipo INT)
READS SQL DATA
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

-- Procedimiento 5: Obtener partido por ID
DROP PROCEDURE IF EXISTS sp_obtener_partido$$
CREATE PROCEDURE sp_obtener_partido(IN p_id_partido INT)
READS SQL DATA
BEGIN
    SELECT
        p.id_partido,
        p.fecha,
        p.goles_local,
        p.goles_visitante,
        j.numero AS jornada,
        pa.nombre AS pabellon,
        el.nombre_club AS equipo_local,
        el.id_equipo AS id_equipo_local,
        ev.nombre_club AS equipo_visitante,
        ev.id_equipo AS id_equipo_visitante
    FROM partido p
    INNER JOIN jornada j ON j.id_jornada = p.id_jornada
    INNER JOIN pabellon pa ON pa.id_pabellon = p.id_pabellon
    INNER JOIN equipo el ON el.id_equipo = p.id_equipo_local
    INNER JOIN equipo ev ON ev.id_equipo = p.id_equipo_visitante
    WHERE p.id_partido = p_id_partido;
END$$

-- Procedimiento 6: Insertar partido
DROP PROCEDURE IF EXISTS sp_insertar_partido$$
CREATE PROCEDURE sp_insertar_partido(
    IN p_fecha DATETIME,
    IN p_id_jornada INT,
    IN p_id_pabellon INT,
    IN p_id_equipo_local INT,
    IN p_id_equipo_visitante INT
)
MODIFIES SQL DATA
BEGIN
    DECLARE exit handler FOR sqlexception
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    
    START TRANSACTION;
    
    IF p_id_equipo_local = p_id_equipo_visitante THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El equipo local y visitante deben ser diferentes';
    END IF;

    IF p_id_equipo_local IS NULL OR p_id_equipo_visitante IS NULL OR 
       p_id_jornada IS NULL OR p_id_pabellon IS NULL OR p_fecha IS NULL THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Todos los parámetros son obligatorios';
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
    
    COMMIT;
END$$

-- Procedimiento 7: Actualizar resultado
DROP PROCEDURE IF EXISTS sp_actualizar_resultado$$
CREATE PROCEDURE sp_actualizar_resultado(
    IN p_id_partido INT,
    IN p_goles_local TINYINT,
    IN p_goles_visitante TINYINT
)
MODIFIES SQL DATA
BEGIN
    DECLARE v_afectadas INT DEFAULT 0;
    
    IF p_goles_local < 0 OR p_goles_local > 100 OR p_goles_visitante < 0 OR p_goles_visitante > 100 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'Los goles deben estar entre 0 y 100';
    END IF;

    UPDATE partido
    SET goles_local = p_goles_local,
        goles_visitante = p_goles_visitante
    WHERE id_partido = p_id_partido;

    SET v_afectadas = ROW_COUNT();
    
    IF v_afectadas = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No existe el partido indicado';
    END IF;
END$$

-- Procedimiento 8: Eliminar partido
DROP PROCEDURE IF EXISTS sp_eliminar_partido$$
CREATE PROCEDURE sp_eliminar_partido(IN p_id_partido INT)
MODIFIES SQL DATA
BEGIN
    DECLARE v_afectadas INT DEFAULT 0;
    
    DELETE FROM partido
    WHERE id_partido = p_id_partido;

    SET v_afectadas = ROW_COUNT();
    
    IF v_afectadas = 0 THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'No existe el partido indicado';
    END IF;
END$$

-- Procedimiento 9: Insertar equipo
DROP PROCEDURE IF EXISTS sp_insertar_equipo$$
CREATE PROCEDURE sp_insertar_equipo(
    IN p_nombre_club VARCHAR(100),
    IN p_ciudad VARCHAR(80),
    IN p_presupuesto DECIMAL(12,2),
    IN p_anio_fundacion YEAR,
    IN p_presidente VARCHAR(100),
    IN p_titulos TINYINT
)
MODIFIES SQL DATA
BEGIN
    DECLARE v_id_equipo INT;
    DECLARE v_id_temporada INT;
    DECLARE v_siguiente_posicion INT;

    IF p_nombre_club IS NULL OR TRIM(p_nombre_club) = '' THEN
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = 'El nombre del club es obligatorio';
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

-- Procedimiento 10: Obtener admin por usuario
DROP PROCEDURE IF EXISTS sp_obtener_admin_por_usuario$$
CREATE PROCEDURE sp_obtener_admin_por_usuario(IN p_usuario VARCHAR(50))
READS SQL DATA
BEGIN
    SELECT id_admin, usuario, password_hash
    FROM usuarios_admin
    WHERE usuario = p_usuario
    LIMIT 1;
END$$

-- Procedimiento 11: Listar máximos goleadores
DROP PROCEDURE IF EXISTS sp_listar_maximos_goleadores$$
CREATE PROCEDURE sp_listar_maximos_goleadores(IN p_limite INT)
READS SQL DATA
BEGIN
    SELECT
        j.nombre,
        e.nombre_club,
        COALESCE(et.goles_totales, 0) AS goles_totales,
        COALESCE(et.partidos_jugados, 0) AS partidos_jugados,
        COALESCE(et.promedio_goles, 0) AS promedio_goles
    FROM jugador j
    LEFT JOIN estadisticas_temporada et ON j.id_jugador = et.id_jugador
    INNER JOIN equipo e ON e.id_equipo = j.id_equipo
    LEFT JOIN temporada t ON t.id_temporada = et.id_temporada AND t.estado_temporada = 'En juego'
    GROUP BY j.id_jugador, e.nombre_club
    ORDER BY COALESCE(et.goles_totales, 0) DESC
    LIMIT COALESCE(p_limite, 10);
END$$

-- Procedimiento 12: Listar sanciones activas
DROP PROCEDURE IF EXISTS sp_listar_sanciones_activas$$
CREATE PROCEDURE sp_listar_sanciones_activas()
READS SQL DATA
BEGIN
    SELECT
        s.id_sancion,
        j.nombre AS jugador,
        e.nombre_club AS equipo,
        s.tipo_tarjeta,
        s.partidos_suspension,
        s.estado,
        s.fecha_registro
    FROM sanciones s
    INNER JOIN jugador j ON j.id_jugador = s.id_jugador
    INNER JOIN equipo e ON e.id_equipo = j.id_equipo
    WHERE s.estado IN ('Activa', 'Pendiente')
    ORDER BY s.fecha_registro DESC;
END$$

DELIMITER ;

-- Verificación final
SELECT 'Procedimientos creados exitosamente' AS estado;


