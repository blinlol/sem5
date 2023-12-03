select current_role;

drop role test;

create user test password 'test'; 
alter role test inherit;

grant select 
on persons,
   events,
   event_participants,
   event_description,
   event_themes,
   participation,
   themes,
   roles
to test;

revoke select 
on event_description
from test;

grant select, insert, update
on person_themes
to test;

grant select, update (mark)
on participation
to test;

grant select, update (personal_data, date_added)
on persons
to test;


create view persons_fname_lname_email(id, first_name, last_name, email) as (
select id, 
       personal_data->'first_name' first_name, 
       personal_data->'last_name' last_name,
       personal_data->'email' email
from persons
);


create view event_start_end_duration(id, start_date, end_date, duration) as (
select id,
       start_date, 
       end_date,
       end_date - start_date duration
from events
);



grant select 
on event_start_end_duration
to test;


create role test_role ;

revoke select on event_start_end_duration from test_role;
grant select 
on event_start_end_duration
to test_role;

grant update (start_date, end_date) 
on event_start_end_duration
to test_role;

grant test_role to test;


select * 
from events e join (select event_id, name 
                    from event_themes et join themes t on )


drop view event_themes_name;  
                    
create view event_themes_name as (
select id, name, start_date, themes_arr
from events e join (
  select event_id, array_agg(name) themes_arr
  from event_themes et join themes t on et.theme_id = t.id
  group by et.event_id
) et
on e.id = et.event_id
)
;


select * from event_themes_name;

create view person_last_event as (
  select p.id, last_event.event_id, registration_date 
  from persons p join (
    select distinct on (person_id) person_id, event_id, registration_date
    from participation p 
    order by person_id, registration_date desc 
  ) last_event
  on p.id = last_event.person_id
)
;

select * from person_last_event;	





















