delimiter $$

-- trigger para insert
create trigger trg_validar_partido_insert
before insert on partido
for each row
begin
    declare existe_equipo_local int;
    declare existe_equipo_visitante int;
    declare existe_jornada int;
    declare existe_pabellon int;
    declare fecha_inicio_temp date;
    declare fecha_fin_temp date;
    declare partido_duplicado int;
    
    -- validar que los goles no sean negativos
    if new.goles_local < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo local no pueden ser negativos';
    end if;
    
    if new.goles_visitante < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo visitante no pueden ser negativos';
    end if;
    
    -- validar que los equipos local y visitante sean diferentes
    if new.id_equipo_local = new.id_equipo_visitante then
        signal sqlstate '45000'
        set message_text = 'El equipo local y visitante deben ser diferentes';
    end if;
    
    -- validar que el equipo local existe
    select count(*) into existe_equipo_local
    from equipo
    where id_equipo = new.id_equipo_local;
    
    if existe_equipo_local = 0 then
        signal sqlstate '45000'
        set message_text = 'El equipo local no existe en la base de datos';
    end if;
    
    -- validar que el equipo visitante existe
    select count(*) into existe_equipo_visitante
    from equipo
    where id_equipo = new.id_equipo_visitante;
    
    if existe_equipo_visitante = 0 then
        signal sqlstate '45000'
        set message_text = 'El equipo visitante no existe en la base de datos';
    end if;
    
    -- validar que la jornada existe
    select count(*) into existe_jornada
    from jornada
    where id_jornada = new.id_jornada;
    
    if existe_jornada = 0 then
        signal sqlstate '45000'
        set message_text = 'La jornada asignada no existe';
    end if;
    
    -- validar que el pabellón existe
    select count(*) into existe_pabellon
    from pabellon
    where id_pabellon = new.id_pabellon;
    
    if existe_pabellon = 0 then
        signal sqlstate '45000'
        set message_text = 'El pabellón asignado no existe';
    end if;
    
    -- validar que la fecha del partido está dentro del periodo de la temporada
    select t.fecha_inicio, t.fecha_fin
    into fecha_inicio_temp, fecha_fin_temp
    from temporada t
    inner join jornada j on t.id_temporada = j.id_temporada
    where j.id_jornada = new.id_jornada;
    
    if date(new.fecha) < fecha_inicio_temp or date(new.fecha) > fecha_fin_temp then
        signal sqlstate '45000'
        set message_text = 'La fecha del partido debe estar dentro del periodo de la temporada';
    end if;
    
    -- validar que no haya partidos duplicados entre los mismos equipos en la misma jornada
    select count(*) into partido_duplicado
    from partido
    where id_jornada = new.id_jornada
    and ((id_equipo_local = new.id_equipo_local and id_equipo_visitante = new.id_equipo_visitante)
    or (id_equipo_local = new.id_equipo_visitante and id_equipo_visitante = new.id_equipo_local));
    
    if partido_duplicado > 0 then
        signal sqlstate '45000'
        set message_text = 'Ya existe un partido entre estos equipos en esta jornada';
    end if;
    
end$$

-- trigger para update
create trigger trg_validar_partido_update
before update on partido
for each row
begin
    declare existe_equipo_local int;
    declare existe_equipo_visitante int;
    declare existe_jornada int;
    declare existe_pabellon int;
    declare fecha_inicio_temp date;
    declare fecha_fin_temp date;
    declare partido_duplicado int;
    
    -- validar que los goles no sean negativos
    if new.goles_local < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo local no pueden ser negativos';
    end if;
    
    if new.goles_visitante < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo visitante no pueden ser negativos';
    end if;
    
    -- validar que los equipos local y visitante sean diferentes
    if new.id_equipo_local = new.id_equipo_visitante then
        signal sqlstate '45000'
        set message_text = 'El equipo local y visitante deben ser diferentes';
    end if;
    
    -- validar que el equipo local existe
    select count(*) into existe_equipo_local
    from equipo
    where id_equipo = new.id_equipo_local;
    
    if existe_equipo_local = 0 then
        signal sqlstate '45000'
        set message_text = 'El equipo local no existe en la base de datos';
    end if;
    
    -- validar que el equipo visitante existe
    select count(*) into existe_equipo_visitante
    from equipo
    where id_equipo = new.id_equipo_visitante;
    
    if existe_equipo_visitante = 0 then
        signal sqlstate '45000'
        set message_text = 'El equipo visitante no existe en la base de datos';
    end if;
    
    -- validar que la jornada existe
    select count(*) into existe_jornada
    from jornada
    where id_jornada = new.id_jornada;
    
    if existe_jornada = 0 then
        signal sqlstate '45000'
        set message_text = 'La jornada asignada no existe';
    end if;
    
    -- validar que el pabellón existe
    select count(*) into existe_pabellon
    from pabellon
    where id_pabellon = new.id_pabellon;
    
    if existe_pabellon = 0 then
        signal sqlstate '45000'
        set message_text = 'El pabellón asignado no existe';
    end if;
    
    -- validar que la fecha del partido está dentro del periodo de la temporada
    select t.fecha_inicio, t.fecha_fin
    into fecha_inicio_temp, fecha_fin_temp
    from temporada t
    inner join jornada j on t.id_temporada = j.id_temporada
    where j.id_jornada = new.id_jornada;
    
    if date(new.fecha) < fecha_inicio_temp or date(new.fecha) > fecha_fin_temp then
        signal sqlstate '45000'
        set message_text = 'La fecha del partido debe estar dentro del periodo de la temporada';
    end if;
    
    -- validar que no haya partidos duplicados (excluyendo el partido actual)
    select count(*) into partido_duplicado
    from partido
    where id_jornada = new.id_jornada
    and id_partido != new.id_partido
    and ((id_equipo_local = new.id_equipo_local and id_equipo_visitante = new.id_equipo_visitante)
    or (id_equipo_local = new.id_equipo_visitante and id_equipo_visitante = new.id_equipo_local));
    
    if partido_duplicado > 0 then
        signal sqlstate '45000'
        set message_text = 'Ya existe un partido entre estos equipos en esta jornada';
    end if;
    
end$$

delimiter ;
