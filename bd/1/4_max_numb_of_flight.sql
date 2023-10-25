-- find number of passengers with max count of flights
with flight_count as (
    select ticket_no,
           count(*) count
    from ticket_flights
    group by ticket_no
    order by count(*) desc
)
select distinct 
       t.passenger_name name,
       t.contact_data->'phone' phone,
	   c.count
from tickets t join flight_count c
     on (t.ticket_no = c.ticket_no)
where c.count = (
	select max(count)
	from flight_count
)
order by t.passenger_name

;