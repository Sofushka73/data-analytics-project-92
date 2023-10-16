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
on p.product_id = s.product_id --присоединяем таблицу products по id
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
on agr.id = s.product_id --присоединяем таблицу agr по id 
join names n
on n.id = s.sales_person_id --присоединяем таблицу names по id
join counts c
on c.id = s.sales_person_id --присоединяем таблицу counts по id
group by 1 --группируем по name
order by income desc --сортируем по income в порядке убывания
limit 10 --ограничиваем запрос 10-ю строками
;--получаем таблицу топ 10 продавцов по выручке

--3
--создаём вспомогательную таблицу 
with tab as(
select 
concat(e.first_name,' ',e.last_name) as name, --соединяем имя и фамилию сотрудника
avg(s.quantity * p.price) as avgprice --вычисляем среднюю выручку
from sales s
join products p
on p.product_id = s.product_id --присоединяем таблицу products по id
join employees e 
on s.sales_person_id  = e.employee_id --присоединяем таблицу employees по id
group by e.first_name ,e.last_name --группируем по имени и фамилии
order by name --сортируем по name по возрастанию
)
select
name,
round(avgprice) as average_income --округляем значение средней выручки
from tab
where avgprice < (select 
         avg(s.quantity * p.price)
         from sales s
         join products p
         on p.product_id = s.product_id) --создаём подзапрос позволяющий подсчитать среднюю выручку по всем продавцам 
order by average_income --сортируем по average_income в порядке возрастания
;--получаем таблицу с сотрудниками чья выручка меньше средней

--4
--создаём вспомогательную таблицу
with tab as(
select 
concat(e.first_name,' ',e.last_name) as name, --соединяем имя и фамилию сотрудников
to_char(s.sale_date, 'day') as day,--получаем название дня недели
to_char(s.sale_date, 'id') as numberday,--получаем порядковый номер дня недели
p.price * s.quantity as amount --подсчитываем выручку 
from sales s 
join employees e 
on e.employee_id = s.sales_person_id --присоединяем таблицу emloyees по id
join products p 
on p.product_id = s.product_id --присоединяем таблицу products по id 
)
select 
name,
day as weekday,
round(sum(amount)) as income--суммируем и округляем выручку
from tab
group by name, weekday, numberday --группируем таблицу по 3 столбцам
order by numberday, name --сортируем по 2 столбцам в порядке возрастания
;--получаем таблицу с выручкой продавцов за каждый день недели
