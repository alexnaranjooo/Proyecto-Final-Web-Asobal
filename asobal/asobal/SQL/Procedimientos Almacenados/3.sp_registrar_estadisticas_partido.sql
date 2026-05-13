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
