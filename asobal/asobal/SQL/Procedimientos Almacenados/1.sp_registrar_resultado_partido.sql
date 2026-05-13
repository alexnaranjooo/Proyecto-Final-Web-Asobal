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

