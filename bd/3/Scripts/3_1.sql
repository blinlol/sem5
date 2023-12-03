--create table countries (
--    id serial primary key,
--    name text not null unique
--);



create table themes (
    id serial primary key,
    name text not null unique
);

create table roles (
    id serial primary key,
    name text not null unique    
);


create table persons (
    id serial primary key,
    personal_data jsonb default '{}'::jsonb,
    my_events integer array default array[]::integer[], 
    date_added timestamp default current_timestamp   
);

--drop table person_themes ;
create table person_themes (
    person_id integer references persons(id),
    theme_id integer references themes(id),
    constraint person_themes_unique_row unique (person_id, theme_id)
);


create table events (
    id serial primary key,
    name text not null,
    start_date timestamp,
    end_date timestamp,
    date_added timestamp default current_timestamp
);

--drop table event_themes ;
create table event_themes (
    event_id integer references events(id),
    theme_id integer references themes(id),
    constraint event_themes_unique_row unique (event_id, theme_id)
);

create table event_description (
    event_id integer references events(id),
    description text default ''
);

create table event_participants (
    event_id integer unique references events(id),
    participants_id integer[] default array[]::integer[]
);



create table participation (
    person_id integer references persons(id),
    event_id integer references events(id),
    roles integer[] default array[]::integer[],
    registration_date timestamp default current_timestamp,
    constraint participation_unique unique (person_id, event_id)
);





create function trigger_after_insert_event() returns trigger as $trigger_after_insert_event$
    begin
    	insert into event_participants(event_id) values (new.id);
        return new;
    end;
$trigger_after_insert_event$ language plpgsql
    
create trigger trigger_after_insert_event after insert on events for each row execute function trigger_after_insert_event();







--drop function trigger_after_insert_participation() cascade;
create function trigger_after_insert_participation() returns trigger as $trigger_insert_participation$
    begin
    	update persons p set my_events = my_events || new.event_id where p.id = new.person_id;
        update event_participants ep set participants_id = participants_id || new.person_id where ep.event_id = new.event_id;
        return new;
    end;
$trigger_insert_participation$ language plpgsql

create trigger trigger_after_insert_participation after insert on participation for each row execute function trigger_after_insert_participation();
    

--insert into events(name) values ('dkdk'); 
--select id, name from events;
--
--insert into participation(event_id, person_id) values (11, 2);
--select * from participation p ;
--select * from event_participants ep ;
--select * from persons p where p.id = 2;
--
--select 10 not in (select id from events);



--drop table countries ;





create function trigger_before_insert__update_participation() returns trigger as $trigger_before_insert_update_participation$
    declare 
        r int;
    begin
    	foreach r in array new.roles loop
    		if r not in (select id from roles where id = r) then
    		    raise '% not in roles.id', r; 
    		end if;
    	end loop;
        return new;
    end;
$trigger_before_insert_update_participation$ language plpgsql
    
create trigger trigger_before_insert__update_participation before insert or update on participation for each row execute function trigger_before_insert__update_participation(); 


--insert into participation(event_id, person_id, roles ) values (2, 4, array[3]);
--select * from participation p ;
--update participation set roles = roles || 3 where event_id = 2 and person_id = 3 


--truncate persons, events cascade;
--select * from themes;
--
--drop table participation  ;




--insert into events(name, start_date, end_date) values ('sddc', '20-10-2023'::timestamp, '30-10-2023'::timestamp);
--insert into persons(personal_data, date_added) values ('{"name": "AAA"}'::jsonb, '19-10-2023'::timestamp);
--
--select * from persons;
--select * from event_participants ep ;



alter table participation 
add column mark integer 
constraint participation_mark_from_1_to_10 check (1 <= mark and mark <= 10);

truncate persons, events cascade;




































