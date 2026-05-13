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
