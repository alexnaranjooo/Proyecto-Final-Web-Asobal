delimiter $$

drop trigger if exists trg_controlar_dorsales_insert$$
create trigger trg_controlar_dorsales_insert
before insert on jugador
for each row
begin
    declare nombre_existente varchar(100);
    declare mensaje_error varchar(255);
    
    -- validar rango del dorsal
    if new.dorsal < 1 or new.dorsal > 99 then
        signal sqlstate '45000'
        set message_text = 'El dorsal debe estar entre 1 y 99';
    end if;
    
    -- buscar jugador con ese dorsal usando función
    set nombre_existente = obtener_jugador_con_dorsal(new.id_equipo, new.dorsal, null);
    
    -- si existe, lanzar error
    if nombre_existente is not null then
        set mensaje_error = concat('El dorsal ', new.dorsal, ' ya está asignado al jugador ', nombre_existente);
        signal sqlstate '45000'
        set message_text = mensaje_error;
    end if;
end$$

delimiter ;

