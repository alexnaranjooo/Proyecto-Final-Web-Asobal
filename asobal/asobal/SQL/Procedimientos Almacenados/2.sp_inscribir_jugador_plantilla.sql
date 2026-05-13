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
