-- 10 upcoming flights from airport UFA
-- select bookings.now(); -- 2017-08-15 18:00:00+03

select flight_no as N, 
       to_char(scheduled_departure, 'DD.MM.YY HH:MM') as when,
	   arrival_airport dest
from flights f
where departure_airport = 'UFA' and status in ('On Time', 'Scheduled')
order by scheduled_departure
limit 10
;

-- simple query
-- select *
-- from flights
-- where departure_airport = 'UFA'
-- order by scheduled_departure
-- ;
