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

