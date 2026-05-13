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
