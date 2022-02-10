--4.1 В каких городах больше одного аэропорта

select a.city, count(airport_code) as airports_number /* выбираем названия городов и кол-во аэропортов в них*/
from airports a /* из таблицы с инф по аэропортам */
group by a.city /* группируем по названиям городов */
having count(airport_code) > 1 /* задаем фильтр по кол-ву аэропортов в каждом городе */

--4.2 В каких аэропортах есть рейсы, выполняемые самолетом с максимальной дальностью перелета?

select a.airport_name, a2.range, a2.model as aircraft_model/* выбираем названия аэпортов, дальности перелетов и самолеты, которые способны летать на макс расстояние */
from airports a /* из таблицы с аэропортами */
join flights f on f.departure_airport = a.airport_code /* к которой цепляем таблицу с перелетами по аэропорту вылета, чтобы добраться до таблицы с воздушными судами */
join aircrafts a2 on a2.aircraft_code = f.aircraft_code /* далее цепляем таблицу с воздушными судами, чтобы уже из нее взять информацию о дальностях перелета*/
where a2.range = (select max(range) from aircrafts a3)/* добавляем условие на поиск самого макс значения перелета */ 
group by a.airport_name, a2.range, a2.model /*группируем выборку */
order by a.airport_name /* сортируем по аэропорты по алфавиту для удобства */

--4.3 Вывести 10 рейсов с максимальным временем задержки вылета

select concat(departure_airport_name,' - ', arrival_airport_name) as flight, (actual_departure - scheduled_departure) as delay /* выбираем названия аэропортов и 
соединяем их для удобства, считаем разность между фактическим вылетом и запланированным */
from flights_v f /* из таблицы-представления с перелетами */
where actual_departure is not null /* убираем те рейсы, по которым самолеты так и не вылетели */
order by delay desc /* сортируем по длительности задержки для наглядности и удобства */
limit 10 /* отсекаем верхние 10 значений*/

--4.4 Были ли брони, по которым не были получены посадочные талоны?

select t.book_ref, row_number() over() as id /* выбираем номера броней и проставляем порядковый номер через всю выборку*/
-- select count(t.book_ref) можно было сделать так, чтоб просто получить кол-во пустых броней
from tickets t /* из таблицы с билетами */
join ticket_flights tf on tf.ticket_no = t.ticket_no /* цепляем таблицу со связями между билетами и рейсами */ 
full outer join boarding_passes bp on bp.ticket_no = tf.ticket_no /* цепляем таблицу с привязкой к посадочным талонам. Берем full join чтобы не пропустить пустые значения */
where boarding_no is null /* задаем условие по по выборке, где бронь не имеет посадочного талона */
order by id desc /* сортируем по порядковому номеру с убыванием, чтобы видеть весь список и общее число пустых броней */


--4.5 Найдите свободные места для каждого рейса, их % отношение к общему количеству мест в самолете.  
--Добавьте столбец с накопительным итогом -суммарное накопление количества вывезенных пассажиров из каждого аэропорта на каждый день. 
--Т.е. в этом столбце должна отражаться накопительная сумма -сколько человек уже вылетело из данного аэропорта на этом или более ранних рейсах за день.

with max_seats as ( /* формируем cte с инф о макс кол-во мест для каждого типа самолета */
	select aircraft_code, count(seat_no) as max_seats_per_flight
	from seats s  
	group by aircraft_code
	),
	sold_seats as ( /* формируем cte с инф о кол-во проданных билетов на каждый рейс, что будет равно кол-ву занятых мест в самолете */
	select flight_id, count(ticket_no) as sold_seats_no
	from ticket_flights tf
	group by flight_id
	)
select  /* делаем выборку со след инфой */
	actual_departure_local, /* дата вылета */
	f.flight_no, /* номер рейса */ 
	departure_airport_name, /* название аэропорта вылета */
	arrival_airport_name, /* название аэропорта прибытия */
	max_seats_per_flight, /* общее кол-во мест в самоелете на выбранный рейс */
	(max_seats_per_flight - sold_seats_no) as available_seats, /* из общего кол-ва мест отнимаем кол-во проданных, получем свободные */
	round(cast(max_seats_per_flight - sold_seats_no as decimal)/max_seats_per_flight*100, 2) as perc_seats_ratio, /* считаем процентное соотношение св мест к общему кол-ву мест */
	sold_seats_no, /* кол-во занятых мест */
	sum(sold_seats_no) over(partition by departure_airport_name order by actual_departure_local) /* задаем каунтер по числу проданных мест для каждого аэропорта */
	from flights_v f /* из таблицы - представления с перелетами */
join max_seats as1 on as1.aircraft_code = f.aircraft_code /* цепляем cte с макс кол-вом мест для каждого рейса по коду самолета*/
join sold_seats ss on ss.flight_id = f.flight_id /* цепляем cte с кол-вом проданных мест */ 
where actual_departure_local is not null /* убираем рейсы, которые еще не вылетели */
order by departure_airport_name, actual_departure_local /* сортируем по названию аэропорта и дате вылета */


--4.6 Найдите процентное соотношение перелетов по типам самолетов от общего количества

select 
	count(flight_id) as flight_by_type, /* считаем общее количество перелетов */
	aircraft_code, /* выбираем коды судов  */
	round(cast(count(flight_id) as decimal) / (select count(flight_id) from flights)*100,2) as type_to_total_ratio /* делим общее кол-во перелетов каждого самолета на общее кол-во перелетов */
from flights /* выборка из таблицы с перелетами */
group by aircraft_code /* группировка выборки по типу самолета, чтобы получать подсчет вылетов на каждый тип самолета */
order by type_to_total_ratio desc

--4.7 Были ли города, в которые можно добраться бизнес -классом дешевле, чем эконом-классом в рамках перелета? 

with business as ( /* создаем два cte. В одном выбираем рейсы и стоимости билетов тарифа Эконом, в другом тоже самое только Бизнес*/
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
select b.flight_id, b.amount as business_price, e.amount as economy_price /* выбираем номер рейса и цены */
from business b /* из двух cte объединенных по номеру рейса */
full outer join economy e on e.flight_id = b.flight_id 
where b.amount < e.amount /* задаем условие, что цена за бизнес класс должна быть меньше, чем за эконом */

--4.8 Между какими городами нет прямых рейсов?

select a.city, b.city 
from airports a 
cross join airports b 
where a.city <> b.city
except
select departure_city, arrival_city
from routes

--4.9 Вычислите расстояние между аэропортами, связанными прямыми рейсами, 
--сравните с допустимой максимальной дальностью перелетов всамолетах, обслуживающих эти рейсы

with departure_airports as ( /* создаем cte со списком аэропортов вылета и их координатами */
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
	) /* расчет вынесен, чтоб иметь к нему доступ и не пересчитывать по неск раз */
select departure_airport_name, arrival_airport_name, 
	a.model as aircraft_model,
	a.range as max_range,
	distance_btw_airports,
	a.range - distance_btw_airports as distance_dif,
	case when (distance_btw_airports/a.range*100) > 70 then 'no' else 'yes' end	/* допустим считаем, что разница более чем в 70% является показателем 
	неэффективного использования самолета на таких расстояниях */							
	from departure_airports dc 
join arrival_airports ac on ac.flight_no = dc.flight_no 
join aircrafts a on a.aircraft_code = dc.aircraft_code
join distance d on d.flight_no = dc.flight_no
