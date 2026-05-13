delimiter $$

create trigger actualizar_clasificacion_update
after update on partido
for each row
begin
    declare equipo_ganador_old int;
    declare equipo_perdedor_old int;
    declare equipo_ganador_new int;
    declare equipo_perdedor_new int;
    
    -- primero revertir los datos del resultado anterior
    if old.goles_local > old.goles_visitante then
        -- revertir victoria del equipo local
        update clasificacion
        set puntos = puntos - 2,
            victorias = victorias - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = (goles_favor - old.goles_local) - (goles_contra - old.goles_visitante)
        where id_equipo = old.id_equipo_local 
        and id_temporada = (select id_temporada from jornada where id_jornada = old.id_jornada);
        
        -- revertir derrota del equipo visitante
        update clasificacion
        set derrotas = derrotas - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = (goles_favor - old.goles_visitante) - (goles_contra - old.goles_local)
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = (select id_temporada from jornada where id_jornada = old.id_jornada);
        
    elseif old.goles_visitante > old.goles_local then
        -- revertir victoria del equipo visitante
        update clasificacion
        set puntos = puntos - 2,
            victorias = victorias - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = (goles_favor - old.goles_visitante) - (goles_contra - old.goles_local)
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = (select id_temporada from jornada where id_jornada = old.id_jornada);
        
        -- revertir derrota del equipo local
        update clasificacion
        set derrotas = derrotas - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = (goles_favor - old.goles_local) - (goles_contra - old.goles_visitante)
        where id_equipo = old.id_equipo_local 
        and id_temporada = (select id_temporada from jornada where id_jornada = old.id_jornada);
        
    else
        -- revertir empate
        update clasificacion
        set puntos = puntos - 1,
            empates = empates - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = (goles_favor - old.goles_local) - (goles_contra - old.goles_visitante)
        where id_equipo = old.id_equipo_local 
        and id_temporada = (select id_temporada from jornada where id_jornada = old.id_jornada);
        
        update clasificacion
        set puntos = puntos - 1,
            empates = empates - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = (goles_favor - old.goles_visitante) - (goles_contra - old.goles_local)
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = (select id_temporada from jornada where id_jornada = old.id_jornada);
    end if;
    
    -- ahora aplicar los nuevos datos
    if new.goles_local > new.goles_visitante then
        set equipo_ganador_new = new.id_equipo_local;
        set equipo_perdedor_new = new.id_equipo_visitante;
        
        update clasificacion
        set puntos = puntos + 2,
            victorias = victorias + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = (goles_favor + new.goles_local) - (goles_contra + new.goles_visitante)
        where id_equipo = equipo_ganador_new 
        and id_temporada = (select id_temporada from jornada where id_jornada = new.id_jornada);
        
        update clasificacion
        set derrotas = derrotas + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = (goles_favor + new.goles_visitante) - (goles_contra + new.goles_local)
        where id_equipo = equipo_perdedor_new 
        and id_temporada = (select id_temporada from jornada where id_jornada = new.id_jornada);
        
    elseif new.goles_visitante > new.goles_local then
        set equipo_ganador_new = new.id_equipo_visitante;
        set equipo_perdedor_new = new.id_equipo_local;
        
        update clasificacion
        set puntos = puntos + 2,
            victorias = victorias + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = (goles_favor + new.goles_visitante) - (goles_contra + new.goles_local)
        where id_equipo = equipo_ganador_new 
        and id_temporada = (select id_temporada from jornada where id_jornada = new.id_jornada);
        
        update clasificacion
        set derrotas = derrotas + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = (goles_favor + new.goles_local) - (goles_contra + new.goles_visitante)
        where id_equipo = equipo_perdedor_new 
        and id_temporada = (select id_temporada from jornada where id_jornada = new.id_jornada);
        
    else
        update clasificacion
        set puntos = puntos + 1,
            empates = empates + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = (goles_favor + new.goles_local) - (goles_contra + new.goles_visitante)
        where id_equipo = new.id_equipo_local 
        and id_temporada = (select id_temporada from jornada where id_jornada = new.id_jornada);
        
        update clasificacion
        set puntos = puntos + 1,
            empates = empates + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = (goles_favor + new.goles_visitante) - (goles_contra + new.goles_local)
        where id_equipo = new.id_equipo_visitante 
        and id_temporada = (select id_temporada from jornada where id_jornada = new.id_jornada);
    end if;
    
    -- reordenar posiciones
    set @posicion = 0;
    update clasificacion c
    join (
        select id_clasificacion,
               @posicion := @posicion + 1 as nueva_posicion
        from clasificacion
        where id_temporada = (select id_temporada from jornada where id_jornada = new.id_jornada)
        order by puntos desc, diferencia_goles desc, goles_favor desc
    ) as ranking on c.id_clasificacion = ranking.id_clasificacion
    set c.posicion = ranking.nueva_posicion;
    
end$$

delimiter ;
