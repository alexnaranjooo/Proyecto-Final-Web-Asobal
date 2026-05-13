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
