-- some functions
-- loops, branching (if), variables, cursors, exception
-- why need use functions, not views?




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
    







create function trigger_before_insert_update_participation() returns trigger as $trigger_before_insert_update_participation$
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
    
create trigger trigger_before_insert_update_participation before insert or update on participation for each row execute function trigger_before_insert_update_participation(); 


-- add person to set of events
create type p_e_ids as (person_id integer, event_id integer);
--drop function func_1;
create or replace function func_1(person_id integer, variadic event_ids integer[]) 
returns setof p_e_ids as $$
    declare 
        i integer;
    begin
	    if person_id not in (select id from persons p where p.id = person_id) then 
	        raise exception 'there is no person with id = %', person_id;
	    end if;
	    
	    foreach i in array event_ids loop
		    if i not in (select id from events e where e.id = i) then 
		        raise warning 'there is no event with id = %', i;
		    else
		        begin 
   		            insert into participation(person_id, event_id)
		                   values (person_id, i);
		            return next (person_id, i);
		            raise info 'add person % to event %', person_id, i;
		           
		        exception
		            when others then
		                raise warning 'exception while inserting (p_id = %, e_id = %)', person_id, i;
		        end;
		       
		    end if;
	    end loop;
    end
$$
language plpgsql;

select * from participation where person_id = 338757 and event_id = 220102;
select * from func_1(338757, 1, 220101, 3, 4, 220102);



-- calculate mean value of number of participants in events per person
create or replace function func_2() returns float8 as $$
    declare 
        rec record;
        summ integer;
        num integer;
        cur cursor for select id, my_events from persons ;
    begin 
	    
	    summ = 0;
	    num = 0;	   

        for rec in cur loop
        	summ = summ + cardinality(rec.my_events);
            num = num + 1;
        end loop;
        
        raise notice '% %', summ, num;
        return summ / num;
    end
    
$$
language plpgsql;

select func_2();