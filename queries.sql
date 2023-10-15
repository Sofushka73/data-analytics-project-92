--1
--с помощью агрегации count подсчитываем значения customer_id из таблицы customers
select 
count(customer_id) as customers_count
from customers 
;
--2
--создаём вспомогательные таблицы с подсчётом выручки
with agr as(
select
s.product_id as id,
s.quantity * p.price as amount
from sales s
join products p
on p.product_id = s.product_id
order by id
), 
--с объединением имени и фамилии сотрудника
names as(
select
employee_id as id,
concat(first_name,' ',last_name) as name
from employees 
order by id
),
--с подсчётом кол-ва сделок
counts as(
select
sales_person_id as id,
count(sales_id) as counts
from sales 
group by id
)
--соединяем вспомогательные таблицы с таблицей sales
select 
distinct(n.name) as name, --вытаскиваем уникальные имена
sum(c.counts) as operations, --суммируем все сделки
sum(agr.amount) as income --сумируем выручку
from sales s
join agr
on agr.id = s.product_id 
join names n
on n.id = s.sales_person_id 
join counts c
on c.id = s.sales_person_id 
group by 1 --группируем по name
order by income desc --сортируем по income в порядке убывания
limit 10 --ограничиваем запрос 10-ю строками
;--получаем таблицу топ 10 продавцов по выручке
