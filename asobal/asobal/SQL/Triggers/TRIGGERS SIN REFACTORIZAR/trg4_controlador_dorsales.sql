delimiter $$

-- trigger para insert
create trigger trg_controlar_dorsales_insert
before insert on jugador
for each row
begin
    declare dorsal_duplicado int;
    declare nombre_jugador_existente varchar(100);
    declare mensaje_error varchar(255);
    
    -- validar que el dorsal esté en el rango de 1 a 99
    if new.dorsal < 1 or new.dorsal > 99 then
        signal sqlstate '45000'
        set message_text = 'El dorsal debe estar entre 1 y 99';
    end if;
    
    -- buscar si ya existe otro jugador con ese dorsal en el mismo equipo
    select count(*), max(nombre)
    into dorsal_duplicado, nombre_jugador_existente
    from jugador
    where id_equipo = new.id_equipo
    and dorsal = new.dorsal
    and id_equipo is not null;
    
    -- si encuentra un duplicado, rechazar la operación
    if dorsal_duplicado > 0 then
        set mensaje_error = concat('El dorsal ', new.dorsal, ' ya está asignado al jugador ', nombre_jugador_existente);
        signal sqlstate '45000'
        set message_text = mensaje_error;
    end if;
    
end$$

-- trigger para update
create trigger trg_controlar_dorsales_update
before update on jugador
for each row
begin
    declare dorsal_duplicado int;
    declare nombre_jugador_existente varchar(100);
    declare mensaje_error varchar(255);
    
    -- validar que el dorsal esté en el rango de 1 a 99
    if new.dorsal < 1 or new.dorsal > 99 then
        signal sqlstate '45000'
        set message_text = 'El dorsal debe estar entre 1 y 99';
    end if;
    
    -- buscar si ya existe otro jugador con ese dorsal en el mismo equipo (excluyendo el jugador actual)
    select count(*), max(nombre)
    into dorsal_duplicado, nombre_jugador_existente
    from jugador
    where id_equipo = new.id_equipo
    and dorsal = new.dorsal
    and id_jugador != new.id_jugador
    and id_equipo is not null;
    
    -- si encuentra un duplicado, rechazar la operación
    if dorsal_duplicado > 0 then
        set mensaje_error = concat('El dorsal ', new.dorsal, ' ya está asignado al jugador ', nombre_jugador_existente);
        signal sqlstate '45000'
        set message_text = mensaje_error;
    end if;
    
end$$

delimiter;
