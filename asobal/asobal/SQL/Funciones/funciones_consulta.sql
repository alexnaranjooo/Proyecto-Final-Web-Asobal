
-- FUNCIONES DE OBTENCIÃ“N DE DATOS

delimiter $$

drop function if exists obtener_temporada_de_jornada$$
create function obtener_temporada_de_jornada(jornada_id int)
returns int
deterministic
begin
    declare temp_id int;
    
    select id_temporada into temp_id
    from jornada
    where id_jornada = jornada_id;
    
    return temp_id;
end$$

drop function if exists obtener_jornada_siguiente$$
create function obtener_jornada_siguiente(jornada_actual int)
returns int
deterministic
begin
    declare numero_actual int;
    declare jornada_sig int;
    declare temporada_id int;
    
    select numero, id_temporada 
    into numero_actual, temporada_id
    from jornada
    where id_jornada = jornada_actual;
    
    select id_jornada into jornada_sig
    from jornada
    where id_temporada = temporada_id
    and numero = numero_actual + 1
    limit 1;
    
    if jornada_sig is null then
        return jornada_actual;
    end if;
    
    return jornada_sig;
end$$

drop function if exists obtener_jugador_con_dorsal$$
create function obtener_jugador_con_dorsal(
    equipo_id int, 
    dorsal_num int,
    excluir_jugador int
)
returns varchar(100)
deterministic
begin
    declare nombre_jugador varchar(100);
    
    if excluir_jugador is null then
        select nombre into nombre_jugador
        from jugador
        where id_equipo = equipo_id
        and dorsal = dorsal_num
        and id_equipo is not null
        limit 1;
    else
        select nombre into nombre_jugador
        from jugador
        where id_equipo = equipo_id
        and dorsal = dorsal_num
        and id_jugador != excluir_jugador
        and id_equipo is not null
        limit 1;
    end if;
    
    return nombre_jugador;
end$$

drop function if exists contar_amarillas_temporada$$
create function contar_amarillas_temporada(jugador_id int, temporada_id int)
returns int
deterministic
begin
    declare total int;
    
    select count(*) into total
    from estadisticas
    where id_jugador = jugador_id
    and id_temporada = temporada_id
    and tarjetas_amarillas > 0;
    
    return total;
end$$

delimiter ;

