delimiter $$

drop trigger if exists trg_gestionar_sanciones_insert$$
create trigger trg_gestionar_sanciones_insert
after insert on estadisticas
for each row
begin
    declare amarillas_acumuladas int;
    declare jornada_siguiente int;
    
    -- obtener siguiente jornada usando función
    set jornada_siguiente = obtener_jornada_siguiente(new.id_jornada);
    
    -- gestionar tarjetas amarillas
    if new.tarjetas_amarillas > 0 then
        -- contar amarillas acumuladas usando función
        set amarillas_acumuladas = contar_amarillas_temporada(new.id_jugador, new.id_temporada);
        
        -- si llega a 3, crear sanción
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
    if new.tarjetas_azul > 0 then
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

