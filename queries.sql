--с помощью агрегации count подсчитываем значения customer_id из таблицы customers
select 
count(customer_id) as customers_count
from customers 