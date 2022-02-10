1. ������� 10 ��������� �������� �� ������ �������;

select payment_date, amount
from payment 
order by payment_date 
limit 10

2. �������� ��������, ������� ������ 300 �����������;

select store_id
from customer c 
group by store_id 
having count (customer_id) >= 300

3. �������� � ������� ���������� ����� � ������� �� �����

select concat (first_name, ' ', last_name) as customer_name, city
from customer c
join address a on a.address_id = c.address_id 
join city c2 on c2.city_id = a.city_id 

select name, city 
from customer_list cl 

4. �������� ��� ����������� � ������ ���������, ������� ������ 300 �����������;

select concat (first_name, ' ', last_name) as staff_name, city
from staff s 
join store s2 on s2.store_id = s.store_id 
join address a on a.address_id = s2.address_id 
join city c2 on c2.city_id = a.city_id 
where s.store_id = (
select store_id
from customer c 
group by store_id 
having count (customer_id) >= 300)

5. �������� ���������� �������, ����������� � �������, ������� ������� � ������ �� 2,99;

select count(distinct actor_id)
from film f 
join film_actor fa on fa.film_id = f.film_id 
where rental_rate = 2.99

7. �������� ������ � ������� rental. �������� ������� � ���������� ������� ������� ������ (����������� �� rental_date) ��� ������� �����;

select rental_id, rental_date, customer_id,
row_number() over (partition by customer_id order by rental_date) as id
from rental 


8. ��� ������� ������������ ���������� ������� �� ���� � ������������� �� ����������� ��������� Behind the Scenes;

select count(f.film_id) as films_num, concat(c.first_name, ' ', c.last_name) as customer_name
from film f
join inventory i on i.film_id = f.film_id 
join rental r on r.inventory_id = i.inventory_id 
join customer c on c.customer_id = r.customer_id 
where 'Behind the Scenes' = any(special_features)
group by customer_name
order by films_num desc








