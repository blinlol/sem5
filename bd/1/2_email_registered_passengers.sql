-- get emails of registered passengers to the given flight
with bp(book_ref, 
		flight_id, 
		seat_no, 
		pass_name, 
		contact_data) as
(
    select book_ref, flight_id, seat_no, passenger_name, contact_data 
	from boarding_passes bp join tickets t on bp.ticket_no = t.ticket_no
)
select contact_data->>'email' as email, 
       'Dear ' || initcap(pass_name) ||
	   ', your place on the flight №' || f.flight_no || 
	   ' is ' || seat_no as message
from bp join flights f on bp.flight_id = f.flight_id
where contact_data->'email' is not null
order by book_ref
;



-- simple query
-- with bp(book_ref, 
-- 		flight_id, 
-- 		seat_no, 
-- 		pass_name, 
-- 		contact_data) as
-- (
--     select book_ref, flight_id, seat_no, passenger_name, contact_data 
-- 	from boarding_passes bp join tickets t on bp.ticket_no = t.ticket_no
-- )
-- select *
-- from bp
-- -- where contact_data->'email' is not null
-- order by book_ref