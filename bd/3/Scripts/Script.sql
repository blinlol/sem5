select current_role;

select * from persons;
select * from events;
select * from event_description ed ;
select * from event_start_end_duration esed ;
select * from persons_fname_lname_email pfle ;

select * from persons where id = 460826;
update persons 
set personal_data = jsonb_set(personal_data, '{email}', '"OLOLOLO"', false)
where id = 460826
;

update persons 
set my_events = '{1}'::integer[] || my_events
where id = 460826
;


select * from event_start_end_duration esed where id = 220101;
update event_start_end_duration 
set start_date = start_date + '-1h'::interval
where id = 220101;
