
-- FUNCIONES DE VALIDACIÃ“N COMPLEJA


delimiter $$

drop function if exists fecha_dentro_temporada$$
create function fecha_dentro_temporada(fecha_partido date, jornada_id int)
returns boolean
deterministic
begin
    declare fecha_ini date;
    declare fecha_fin date;
    
    select t.fecha_inicio, t.fecha_fin
    into fecha_ini, fecha_fin
    from temporada t
    inner join jornada j on t.id_temporada = j.id_temporada
    where j.id_jornada = jornada_id;
    
    return fecha_partido between fecha_ini and fecha_fin;
end$$

drop function if exists existe_partido_duplicado$$
create function existe_partido_duplicado(
    jornada_id int, 
    equipo_local int, 
    equipo_visitante int,
    excluir_partido int
)
returns boolean
deterministic
begin
    declare cantidad int;
    
    if excluir_partido is null then
        select count(*) into cantidad
        from partido
        where id_jornada = jornada_id
        and ((id_equipo_local = equipo_local and id_equipo_visitante = equipo_visitante)
        or (id_equipo_local = equipo_visitante and id_equipo_visitante = equipo_local));
    else
        select count(*) into cantidad
        from partido
        where id_jornada = jornada_id
        and id_partido != excluir_partido
        and ((id_equipo_local = equipo_local and id_equipo_visitante = equipo_visitante)
        or (id_equipo_local = equipo_visitante and id_equipo_visitante = equipo_local));
    end if;
    
    return cantidad > 0;
end$$

delimiter ;

