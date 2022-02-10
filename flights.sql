--4.1 � ����� ������� ������ ������ ���������

select a.city, count(airport_code) as airports_number /* �������� �������� ������� � ���-�� ���������� � ���*/
from airports a /* �� ������� � ��� �� ���������� */
group by a.city /* ���������� �� ��������� ������� */
having count(airport_code) > 1 /* ������ ������ �� ���-�� ���������� � ������ ������ */

--4.2 � ����� ���������� ���� �����, ����������� ��������� � ������������ ���������� ��������?

select a.airport_name, a2.range, a2.model as aircraft_model/* �������� �������� ��������, ��������� ��������� � ��������, ������� �������� ������ �� ���� ���������� */
from airports a /* �� ������� � ����������� */
join flights f on f.departure_airport = a.airport_code /* � ������� ������� ������� � ���������� �� ��������� ������, ����� ��������� �� ������� � ���������� ������ */
join aircrafts a2 on a2.aircraft_code = f.aircraft_code /* ����� ������� ������� � ���������� ������, ����� ��� �� ��� ����� ���������� � ���������� ��������*/
where a2.range = (select max(range) from aircrafts a3)/* ��������� ������� �� ����� ������ ���� �������� �������� */ 
group by a.airport_name, a2.range, a2.model /*���������� ������� */
order by a.airport_name /* ��������� �� ��������� �� �������� ��� �������� */

--4.3 ������� 10 ������ � ������������ �������� �������� ������

select concat(departure_airport_name,' - ', arrival_airport_name) as flight, (actual_departure - scheduled_departure) as delay /* �������� �������� ���������� � 
��������� �� ��� ��������, ������� �������� ����� ����������� ������� � ��������������� */
from flights_v f /* �� �������-������������� � ���������� */
where actual_departure is not null /* ������� �� �����, �� ������� �������� ��� � �� �������� */
order by delay desc /* ��������� �� ������������ �������� ��� ����������� � �������� */
limit 10 /* �������� ������� 10 ��������*/

--4.4 ���� �� �����, �� ������� �� ���� �������� ���������� ������?

select t.book_ref, row_number() over() as id /* �������� ������ ������ � ����������� ���������� ����� ����� ��� �������*/
-- select count(t.book_ref) ����� ���� ������� ���, ���� ������ �������� ���-�� ������ ������
from tickets t /* �� ������� � �������� */
join ticket_flights tf on tf.ticket_no = t.ticket_no /* ������� ������� �� ������� ����� �������� � ������� */ 
full outer join boarding_passes bp on bp.ticket_no = tf.ticket_no /* ������� ������� � ��������� � ���������� �������. ����� full join ����� �� ���������� ������ �������� */
where boarding_no is null /* ������ ������� �� �� �������, ��� ����� �� ����� ����������� ������ */
order by id desc /* ��������� �� ����������� ������ � ���������, ����� ������ ���� ������ � ����� ����� ������ ������ */


--4.5 ������� ��������� ����� ��� ������� �����, �� % ��������� � ������ ���������� ���� � ��������.  
--�������� ������� � ������������� ������ -��������� ���������� ���������� ���������� ���������� �� ������� ��������� �� ������ ����. 
--�.�. � ���� ������� ������ ���������� ������������� ����� -������� ������� ��� �������� �� ������� ��������� �� ���� ��� ����� ������ ������ �� ����.

with max_seats as ( /* ��������� cte � ��� � ���� ���-�� ���� ��� ������� ���� �������� */
	select aircraft_code, count(seat_no) as max_seats_per_flight
	from seats s  
	group by aircraft_code
	),
	sold_seats as ( /* ��������� cte � ��� � ���-�� ��������� ������� �� ������ ����, ��� ����� ����� ���-�� ������� ���� � �������� */
	select flight_id, count(ticket_no) as sold_seats_no
	from ticket_flights tf
	group by flight_id
	)
select  /* ������ ������� �� ���� ����� */
	actual_departure_local, /* ���� ������ */
	f.flight_no, /* ����� ����� */ 
	departure_airport_name, /* �������� ��������� ������ */
	arrival_airport_name, /* �������� ��������� �������� */
	max_seats_per_flight, /* ����� ���-�� ���� � ��������� �� ��������� ���� */
	(max_seats_per_flight - sold_seats_no) as available_seats, /* �� ������ ���-�� ���� �������� ���-�� ���������, ������� ��������� */
	round(cast(max_seats_per_flight - sold_seats_no as decimal)/max_seats_per_flight*100, 2) as perc_seats_ratio, /* ������� ���������� ����������� �� ���� � ������ ���-�� ���� */
	sold_seats_no, /* ���-�� ������� ���� */
	sum(sold_seats_no) over(partition by departure_airport_name order by actual_departure_local) /* ������ ������� �� ����� ��������� ���� ��� ������� ��������� */
	from flights_v f /* �� ������� - ������������� � ���������� */
join max_seats as1 on as1.aircraft_code = f.aircraft_code /* ������� cte � ���� ���-��� ���� ��� ������� ����� �� ���� ��������*/
join sold_seats ss on ss.flight_id = f.flight_id /* ������� cte � ���-��� ��������� ���� */ 
where actual_departure_local is not null /* ������� �����, ������� ��� �� �������� */
order by departure_airport_name, actual_departure_local /* ��������� �� �������� ��������� � ���� ������ */


--4.6 ������� ���������� ����������� ��������� �� ����� ��������� �� ������ ����������

select 
	count(flight_id) as flight_by_type, /* ������� ����� ���������� ��������� */
	aircraft_code, /* �������� ���� �����  */
	round(cast(count(flight_id) as decimal) / (select count(flight_id) from flights)*100,2) as type_to_total_ratio /* ����� ����� ���-�� ��������� ������� �������� �� ����� ���-�� ��������� */
from flights /* ������� �� ������� � ���������� */
group by aircraft_code /* ����������� ������� �� ���� ��������, ����� �������� ������� ������� �� ������ ��� �������� */
order by type_to_total_ratio desc

--4.7 ���� �� ������, � ������� ����� ��������� ������ -������� �������, ��� ������-������� � ������ ��������? 

with business as ( /* ������� ��� cte. � ����� �������� ����� � ��������� ������� ������ ������, � ������ ���� ����� ������ ������*/
	select flight_id, amount
	from ticket_flights tf 
	where fare_conditions = 'Business'
	group by flight_id, amount 
),
economy as (
	select flight_id, amount
	from ticket_flights tf 
	where fare_conditions = 'Economy'
	group by flight_id, amount 
	)
select b.flight_id, b.amount as business_price, e.amount as economy_price /* �������� ����� ����� � ���� */
from business b /* �� ���� cte ������������ �� ������ ����� */
full outer join economy e on e.flight_id = b.flight_id 
where b.amount < e.amount /* ������ �������, ��� ���� �� ������ ����� ������ ���� ������, ��� �� ������ */

--4.8 ����� ������ �������� ��� ������ ������?

select a.city, b.city 
from airports a 
cross join airports b 
where a.city <> b.city
except
select departure_city, arrival_city
from routes

--4.9 ��������� ���������� ����� �����������, ���������� ������� �������, 
--�������� � ���������� ������������ ���������� ��������� ����������, ������������� ��� �����

with departure_airports as ( /* ������� cte �� ������� ���������� ������ � �� ������������ */
	select flight_no, departure_airport_name, latitude as lat1, longitude as long1, aircraft_code
	from routes r
	join airports a on a.airport_code = r.departure_airport 
	),
arrival_airports as ( 
	select flight_no, arrival_airport_name, latitude as lat2, longitude as long2
	from routes r
	join airports a on a.airport_code = r.arrival_airport 
	),
distance as (select 
	dc.flight_no,
	round(ATAN(SQRT(POW(COS(RADIANS(lat2)) * SIN(ABS(RADIANS(long2)-RADIANS(long1))),2) + 
	POW(COS(RADIANS(lat1)) * SIN(RADIANS(lat2)) - SIN(RADIANS(lat1)) * 
	COS(RADIANS(lat2))*COS(ABS(RADIANS(long2)-RADIANS(long1))),2))/(SIN(RADIANS(lat1))*SIN(RADIANS(lat2)) + 
	COS(RADIANS(lat1))*COS(RADIANS(lat2))*COS(ABS(RADIANS(long2)-RADIANS(long2)))))::numeric * 6373,2) as distance_btw_airports
	from departure_airports dc 
	join arrival_airports ac on ac.flight_no = dc.flight_no
	) /* ������ �������, ���� ����� � ���� ������ � �� ������������� �� ���� ��� */
select departure_airport_name, arrival_airport_name, 
	a.model as aircraft_model,
	a.range as max_range,
	distance_btw_airports,
	a.range - distance_btw_airports as distance_dif,
	case when (distance_btw_airports/a.range*100) > 70 then 'no' else 'yes' end	/* �������� �������, ��� ������� ����� ��� � 70% �������� ����������� 
	�������������� ������������� �������� �� ����� ����������� */							
	from departure_airports dc 
join arrival_airports ac on ac.flight_no = dc.flight_no 
join aircrafts a on a.aircraft_code = dc.aircraft_code
join distance d on d.flight_no = dc.flight_no
