delimiter $$

drop trigger if exists trg_validar_partido_insert$$
create trigger trg_validar_partido_insert
before insert on partido
for each row
begin
    -- validar goles no negativos
    if new.goles_local < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo local no pueden ser negativos';
    end if;
    
    if new.goles_visitante < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo visitante no pueden ser negativos';
    end if;
    
    -- validar equipos diferentes
    if new.id_equipo_local = new.id_equipo_visitante then
        signal sqlstate '45000'
        set message_text = 'El equipo local y visitante deben ser diferentes';
    end if;
    
    -- validar existencias usando funciones
    if not existe_equipo(new.id_equipo_local) then
        signal sqlstate '45000'
        set message_text = 'El equipo local no existe en la base de datos';
    end if;
    
    if not existe_equipo(new.id_equipo_visitante) then
        signal sqlstate '45000'
        set message_text = 'El equipo visitante no existe en la base de datos';
    end if;
    
    if not existe_jornada(new.id_jornada) then
        signal sqlstate '45000'
        set message_text = 'La jornada asignada no existe';
    end if;
    
    if not existe_pabellon(new.id_pabellon) then
        signal sqlstate '45000'
        set message_text = 'El pabellón asignado no existe';
    end if;
    
    -- validar fecha usando función
    if not fecha_dentro_temporada(date(new.fecha), new.id_jornada) then
        signal sqlstate '45000'
        set message_text = 'La fecha del partido debe estar dentro del periodo de la temporada';
    end if;
    
    -- validar partido no duplicado usando función
    if existe_partido_duplicado(new.id_jornada, new.id_equipo_local, new.id_equipo_visitante, null) then
        signal sqlstate '45000'
        set message_text = 'Ya existe un partido entre estos equipos en esta jornada';
    end if;
end$$

delimiter ;

delimiter $$

drop trigger if exists trg_validar_partido_update$$
create trigger trg_validar_partido_update
before update on partido
for each row
begin
    -- validar goles no negativos
    if new.goles_local < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo local no pueden ser negativos';
    end if;
    
    if new.goles_visitante < 0 then
        signal sqlstate '45000'
        set message_text = 'Los goles del equipo visitante no pueden ser negativos';
    end if;
    
    -- validar equipos diferentes
    if new.id_equipo_local = new.id_equipo_visitante then
        signal sqlstate '45000'
        set message_text = 'El equipo local y visitante deben ser diferentes';
    end if;
    
    -- validar existencias usando funciones
    if not existe_equipo(new.id_equipo_local) then
        signal sqlstate '45000'
        set message_text = 'El equipo local no existe en la base de datos';
    end if;
    
    if not existe_equipo(new.id_equipo_visitante) then
        signal sqlstate '45000'
        set message_text = 'El equipo visitante no existe en la base de datos';
    end if;
    
    if not existe_jornada(new.id_jornada) then
        signal sqlstate '45000'
        set message_text = 'La jornada asignada no existe';
    end if;
    
    if not existe_pabellon(new.id_pabellon) then
        signal sqlstate '45000'
        set message_text = 'El pabellón asignado no existe';
    end if;
    
    -- validar fecha usando función
    if not fecha_dentro_temporada(date(new.fecha), new.id_jornada) then
        signal sqlstate '45000'
        set message_text = 'La fecha del partido debe estar dentro del periodo de la temporada';
    end if;
    
    -- validar partido no duplicado usando función (excluyendo el actual)
    if existe_partido_duplicado(new.id_jornada, new.id_equipo_local, new.id_equipo_visitante, new.id_partido) then
        signal sqlstate '45000'
        set message_text = 'Ya existe un partido entre estos equipos en esta jornada';
    end if;
end$$

delimiter ;

