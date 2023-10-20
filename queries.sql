--1
--с помощью агрегации count подсчитываем значения customer_id из таблицы customers
select 
count(customer_id) as customers_count
from customers 
;
--2
select 
name,
operations,
floor(income) as income --округляем в меньшую сторону
from ( select                          --делаем подзапрос
concat(e.first_name,' ',e.last_name) as name, --соединяем имя и фамилию сотрудника
sum(s.quantity* p.price) as income, --высчитываем выручку
count(s.sales_id) as operations --подсчитываем кол-во сделок
from sales s 
join products p 
on p.product_id = s.product_id --соединяем по id
join employees e 
on e.employee_id = s.sales_person_id --соединяем по id
group by e.first_name , e.last_name --группируем 
) as tab
order by income desc --сортируем по выручке в порядке убывания
limit 10 --ограничиваем таблицу 10-ю строками
;-- получаем топ10 сотрудников

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

--5
select 
case --с помощью case разделяем покупателей на группы по возрасту
when age between 16 and 25 then '16-25'
when age between 26 and 40 then '26-40'
else '40+'
end as age_category ,
count(age) as count --подсчитываем кол-во покупателей по возрасту
from customers
group by age_category--группируем по возрастным категориям
order by age_category--сортируем по возростным категориям
;--получаем таблицу с колличеством покупателей в каждой возрастной категории

--6
select 
to_char(sale_date,'yyyy-mm') as date, --выделяем из даты только год и месяц
count(distinct(s.customer_id)) as total_customers, --подсчитываем число уникальных покупателей
floor(sum(p.price*s.quantity)) as income --вычисляем выручку и округляем
from sales s 
join customers c 
on c.customer_id = s.customer_id --присоединяем customers по id 
join products p
on p.product_id = s.product_id --присоединяем products по id 
group by date --группируем
order by date-- сортируем по возрастанию
; --получаем таблицу с числом уникальных покупателей и выручкой за каждый месяц

--7
select
t.customer,
t.sale_date,
min(concat(e.first_name,' ',e.last_name))  as seller --соединяем имя и фамилию сотрудника, выделяем самого первого
from (select                                   --подзапрос№2
id,
customer, 
min(date) as sale_date   --вытаскиваем самую раннюю дату
from (select                                    --подзапрос№1
p.price as price,
concat(c.first_name,' ',c.last_name) as customer, --скрещиваем имя и фамилию покупателя
c.customer_id as id,
s.sale_date as date
from sales s 
join products p 
on p.product_id = s.product_id --соединяем таблицы по id
join customers c 
on c.customer_id = s.customer_id --соединяем таблицы по id
) as fool
where price = 0 --выделяем только строки со значением цены 0
group by 1,2 --группируем по id и customer
) as t
join sales s
on s.customer_id = t.id --соединяем таблицы по id
join employees e 
on s.sales_person_id = e.employee_id --соединяем по id
group by 1,2,t.id --группируем по customer, sale_date и id
order by t.id --сортируем по id в порядке возрастания
; -- получаем таблицу с клиентами что совершили свою первую покупку по акции
