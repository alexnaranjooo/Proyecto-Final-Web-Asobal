-- trigger para gestionar sanciones automáticas
delimiter $$

create trigger trg_gestionar_sanciones_insert
after insert on estadisticas
for each row
begin
    declare amarillas_acumuladas int;
    declare numero_jornada_actual int;
    declare jornada_siguiente int;
    
    -- obtener el número de jornada actual
    select numero into numero_jornada_actual
    from jornada
    where id_jornada = new.id_jornada;
    
    -- buscar la siguiente jornada
    select id_jornada into jornada_siguiente
    from jornada
    where id_temporada = new.id_temporada
    and numero = numero_jornada_actual + 1
    limit 1;
    
    -- si no hay siguiente jornada, usar la actual
    if jornada_siguiente is null then
        set jornada_siguiente = new.id_jornada;
    end if;
    
    -- gestionar tarjetas amarillas
    if new.tarjetas_amarillas > 0 then
        -- contar amarillas acumuladas en la temporada
        select count(*) into amarillas_acumuladas
        from estadisticas
        where id_jugador = new.id_jugador
        and id_temporada = new.id_temporada
        and tarjetas_amarillas > 0;
        
        -- si llega a 3 amarillas, crear suspensión de 1 partido
        if amarillas_acumuladas >= 3 then
            insert into sanciones (
                id_jugador,
                id_temporada,
                tipo_tarjeta,
                motivo,
                partidos_suspension,
                jornada_inicio,
                estado
            ) values (
                new.id_jugador,
                new.id_temporada,
                'Amarilla',
                'Acumulación de 3 tarjetas amarillas',
                1,
                jornada_siguiente,
                'Activa'
            );
        end if;
    end if;
    
    -- gestionar tarjetas rojas
    if new.tarjetas_rojas > 0 then
        -- roja directa: 2 partidos de suspensión
        insert into sanciones (
            id_jugador,
            id_temporada,
            tipo_tarjeta,
            motivo,
            partidos_suspension,
            jornada_inicio,
            estado
        ) values (
            new.id_jugador,
            new.id_temporada,
            'Roja',
            'Tarjeta roja directa',
            2,
            jornada_siguiente,
            'Activa'
        );
    end if;
    
    -- gestionar tarjetas azules
    if new.tarjetas_azul > 0 thens
        insert into sanciones (
            id_jugador,
            id_temporada,
            tipo_tarjeta,
            motivo,
            partidos_suspension,
            jornada_inicio,
            estado
        ) values (
            new.id_jugador,
            new.id_temporada,
            'Azul',
            'Conducta grave - Pendiente resolución comité disciplinario',
            999,
            jornada_siguiente,
            'Pendiente'
        );
    end if;
end$$
delimiter ;
