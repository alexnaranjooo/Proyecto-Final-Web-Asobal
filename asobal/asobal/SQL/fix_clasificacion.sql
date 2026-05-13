USE Asobal;

DELIMITER $$

-- PROCEDIMIENTO: sp_recalcular_clasificacion
-- Recalcula toda la clasificación desde cero mirando los partidos.
-- Uso: CALL sp_recalcular_clasificacion();

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


-- TRIGGER: Sustituye el trigger antiguo del UPDATE
-- Borra el viejo y pone uno nuevo que llama al procedimiento.
-- Así cada vez que edites un resultado se recalcula todo solo.

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


-- TRIGGER EXTRA: También recalcula al ELIMINAR un partido

DROP TRIGGER IF EXISTS recalcular_clasificacion_delete$$
CREATE TRIGGER recalcular_clasificacion_delete
AFTER DELETE ON partido
FOR EACH ROW
BEGIN
    CALL sp_recalcular_clasificacion();
END$$


DELIMITER ;

-- Ejecutar el recálculo ahora mismo para sincronizar los datos que ya tenías en la BD antes de crear este archivo.
CALL sp_recalcular_clasificacion();

SELECT 'Clasificación recalculada y triggers instalados correctamente' AS resultado;
