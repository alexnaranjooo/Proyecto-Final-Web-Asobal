
-- FUNCIONES DE VALIDACIÃ“N 
delimiter $$

drop function if exists existe_equipo$$
create function existe_equipo(equipo_id int)
returns boolean
deterministic
begin
    return exists(select 1 from equipo where id_equipo = equipo_id);
end$$

drop function if exists existe_jugador$$
create function existe_jugador(jugador_id int)
returns boolean
deterministic
begin
    return exists(select 1 from jugador where id_jugador = jugador_id);
end$$

drop function if exists existe_jornada$$
create function existe_jornada(jornada_id int)
returns boolean
deterministic
begin
    return exists(select 1 from jornada where id_jornada = jornada_id);
end$$

drop function if exists existe_pabellon$$
create function existe_pabellon(pabellon_id int)
returns boolean
deterministic
begin
    return exists(select 1 from pabellon where id_pabellon = pabellon_id);
end$$

drop function if exists existe_temporada$$
create function existe_temporada(temporada_id int)
returns boolean
deterministic
begin
    return exists(select 1 from temporada where id_temporada = temporada_id);
end$$

drop function if exists existe_partido$$
create function existe_partido(partido_id int)
returns boolean
deterministic
begin
    return exists(select 1 from partido where id_partido = partido_id);
end$$

delimiter ;

