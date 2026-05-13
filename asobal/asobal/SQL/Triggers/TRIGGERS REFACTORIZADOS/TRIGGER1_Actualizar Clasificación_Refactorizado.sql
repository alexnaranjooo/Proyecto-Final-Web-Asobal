delimiter $$

drop trigger if exists actualizar_clasificacion_update$$
create trigger actualizar_clasificacion_update
after update on partido
for each row
begin
    declare temporada int;
    
    -- obtener temporada una sola vez (usando función)
    set temporada = obtener_temporada_de_jornada(new.id_jornada);
    
    -- revertir resultado anterior
    if old.goles_local > old.goles_visitante then
        -- revertir victoria local
        update clasificacion
        set puntos = puntos - 2,
            victorias = victorias - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_local 
        and id_temporada = temporada;
        
        -- revertir derrota visitante
        update clasificacion
        set derrotas = derrotas - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = temporada;
        
    elseif old.goles_visitante > old.goles_local then
        -- revertir victoria visitante
        update clasificacion
        set puntos = puntos - 2,
            victorias = victorias - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = temporada;
        
        -- revertir derrota local
        update clasificacion
        set derrotas = derrotas - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_local 
        and id_temporada = temporada;
        
    else
        -- revertir empate
        update clasificacion
        set puntos = puntos - 1,
            empates = empates - 1,
            goles_favor = goles_favor - old.goles_local,
            goles_contra = goles_contra - old.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_local 
        and id_temporada = temporada;
        
        update clasificacion
        set puntos = puntos - 1,
            empates = empates - 1,
            goles_favor = goles_favor - old.goles_visitante,
            goles_contra = goles_contra - old.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = old.id_equipo_visitante 
        and id_temporada = temporada;
    end if;
    
    -- aplicar nuevo resultado
    if new.goles_local > new.goles_visitante then
        -- victoria local
        update clasificacion
        set puntos = puntos + 2,
            victorias = victorias + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_local 
        and id_temporada = temporada;
        
        -- derrota visitante
        update clasificacion
        set derrotas = derrotas + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_visitante 
        and id_temporada = temporada;
        
    elseif new.goles_visitante > new.goles_local then
        -- victoria visitante
        update clasificacion
        set puntos = puntos + 2,
            victorias = victorias + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_visitante 
        and id_temporada = temporada;
        
        -- derrota local
        update clasificacion
        set derrotas = derrotas + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_local 
        and id_temporada = temporada;
        
    else
        -- empate
        update clasificacion
        set puntos = puntos + 1,
            empates = empates + 1,
            goles_favor = goles_favor + new.goles_local,
            goles_contra = goles_contra + new.goles_visitante,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_local 
        and id_temporada = temporada;
        
        update clasificacion
        set puntos = puntos + 1,
            empates = empates + 1,
            goles_favor = goles_favor + new.goles_visitante,
            goles_contra = goles_contra + new.goles_local,
            diferencia_goles = goles_favor - goles_contra
        where id_equipo = new.id_equipo_visitante 
        and id_temporada = temporada;
    end if;
    
    -- reordenar posiciones
    set @posicion = 0;
    update clasificacion c
    join (
        select id_clasificacion,
               @posicion := @posicion + 1 as nueva_posicion
        from clasificacion
        where id_temporada = temporada
        order by puntos desc, diferencia_goles desc, goles_favor desc
    ) as ranking on c.id_clasificacion = ranking.id_clasificacion
    set c.posicion = ranking.nueva_posicion;
end$$

delimiter ;

