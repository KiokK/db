--1. Вывести к каждому самолету класс обслуживания и количество мест этого класса
SELECT a.model, s.fare_conditions, count(s.seat_no)
FROM aircrafts a
         JOIN seats s ON a.aircraft_code = s.aircraft_code
GROUP BY a.model, s.fare_conditions
ORDER BY a.model, s.fare_conditions;

--2. Найти 3 самых вместительных самолета (модель + кол-во мест)
SELECT a.model, count(s.seat_no)
FROM aircrafts a
         JOIN seats s ON a.aircraft_code = s.aircraft_code
GROUP BY a.model
ORDER BY count(s.seat_no) desc
LIMIT 3;

--3. Найти все рейсы, которые задерживались более 2 часов
SELECT *
FROM flights
WHERE actual_departure - scheduled_departure > interval '2 hours';

--4. Найти последние 10 билетов, купленные в бизнес-классе (fare_conditions = 'Business'), с указанием
-- имени пассажира и контактных данных
SELECT tf.ticket_no, passenger_name, contact_data
FROM tickets t
         JOIN bookings ON t.book_ref = bookings.book_ref
         JOIN ticket_flights tf ON t.ticket_no = tf.ticket_no
WHERE tf.fare_conditions = 'Business'
ORDER BY book_date DESC
LIMIT 10;

--5. Найти все рейсы, у которых нет забронированных мест в бизнес-классе (fare_conditions = 'Business')
SELECT flight_id, flight_no
FROM flights
WHERE flight_id NOT IN (SELECT tf.flight_id
                        FROM ticket_flights tf
                        WHERE fare_conditions = 'Business');

--6. Получить список аэропортов (airport_name) и городов (city), в которых есть рейсы с задержкой
SELECT DISTINCT a.airport_name, a.city
FROM airports a
         JOIN flights f ON a.airport_code = f.departure_airport OR
                           a.airport_code = f.arrival_airport
WHERE f.status = 'Delayed';

--7. Получить список аэропортов (airport_name) и количество рейсов, вылетающих из каждого аэропорта, отсортированный по
-- убыванию количества рейсов
SELECT a.airport_name, COUNT(f.flight_id) AS flight_count
FROM airports a
         JOIN flights f ON a.airport_code = f.departure_airport
GROUP BY a.airport_name
ORDER BY flight_count DESC;

--8. Найти все рейсы, у которых запланированное время прибытия (scheduled_arrival) было изменено и новое время прибытия
-- (actual_arrival) не совпадает с запланированным
SELECT *
FROM flights
WHERE scheduled_arrival != actual_arrival
  AND actual_arrival IS NOT NULL;

--9. Вывести код,модель самолета и места не эконом класса для самолета 'Аэробус A321-200' с сортировкой по местам
SELECT a.aircraft_code, a.model, s.seat_no
FROM aircrafts a
         JOIN seats s ON a.aircraft_code = s.aircraft_code
    AND a.model = 'Аэробус A321-200'
    AND s.fare_conditions != 'Economy'
GROUP BY a.aircraft_code, a.model, s.seat_no
ORDER BY s.seat_no;

--10. Вывести города в которых больше 1 аэропорта ( код аэропорта, аэропорт, город)
SELECT airport_code, airport_name, city
FROM airports
WHERE city IN (SELECT city
               FROM airports
               GROUP BY city
               HAVING count(city) > 1);

--11. Найти пассажиров, у которых суммарная стоимость бронирований превышает среднюю сумму всех бронирований
SELECT t.passenger_id, t.passenger_name, sum(b.total_amount)
FROM tickets t
         JOIN bookings b ON b.book_ref = t.book_ref
GROUP BY t.passenger_id, t.passenger_name
HAVING SUM(b.total_amount) > (SELECT AVG(total_amount)
                              FROM bookings);

--12. Найти ближайший вылетающий рейс из Екатеринбурга в Москву, на который еще не завершилась регистрация
SELECT departure_airport, arrival_airport, departure.city, arrival.city, scheduled_departure
FROM flights f
         JOIN airports as departure ON
            departure.airport_code = departure_airport AND departure.city = 'Екатеринбург'
         JOIN airports as arrival ON
            arrival.airport_code = arrival_airport AND arrival.city = 'Москва'
WHERE f.status = 'On Time'
ORDER BY f.scheduled_departure
LIMIT 1;

--13. Вывести самый дешевый и дорогой билет и стоимость ( в одном результирующем ответе)
(SELECT *
 FROM ticket_flights
 ORDER BY amount DESC
 LIMIT 1)
UNION
(SELECT *
 FROM ticket_flights
 ORDER BY amount
 LIMIT 1);

--14. Написать DDL таблицы Customers , должны быть поля id , firstName, LastName, email , phone. Добавить ограничения на поля ( constraints) .
CREATE DOMAIN emailType AS TEXT CHECK (VALUE ~* '^[A-Za-z0-9._%-]+@[A-Za-z0-9.-]+[.][A-Za-z]+$');
CREATE DOMAIN phoneType AS TEXT CHECK (VALUE ~* '^\+?375(17|29|33|44|25)[0-9]{7}');

CREATE TABLE customers_data
(
    customer_id bigserial PRIMARY KEY NOT NULL,
    firstName   varchar(30)           NOT NULL CHECK (firstName ~* '^[A-Z]*$'),
    lastName    varchar(30)           NOT NULL CHECK (lastName ~* '^[A-Z]*$'),
    email       emailType,
    phone       phoneType
);

--15. Написать DDL таблицы Orders , должен быть id, customerId, quantity.
CREATE TABLE orders_data
(
    order_id    bigserial PRIMARY KEY NOT NULL,
    customer_id integer               NOT NULL,
    quantity    int default 0,
    CONSTRAINT orders_quantity_check CHECK (quantity >= 0)
);

-- Должен быть внешний ключ на таблицу customers + ограничения
ALTER TABLE ONLY orders_data
    ADD CONSTRAINT customers_orders_code_fkey FOREIGN KEY (customer_id) REFERENCES customers_data (customer_id);

--16. Написать 5 insert в эти таблицы
INSERT INTO customers_data (customer_id, firstName, LastName, phone, email)
VALUES (1, 'Ivan', 'Ivanov', '+375250009876', 'ivanovw3@gmail.com'),
       (2, 'Ivan', 'Abramov', '+375250009876', 'ivanAbramov@gmail.com'),
       (3, 'Oleg', 'Ivan', '375250009876', 'OleleGo23fifa@gmail.com'),
       (4, 'Kity', 'Kleno', '+375250009876', 'Keityty@gmail.com'),
       (5, 'Arthur', 'Kirilenko', '375250009876', 'Arth13tr@gmail.com');

INSERT INTO orders_data (order_id, customer_id, quantity)
VALUES (1, 1, 20),
       (2, 5, 3),
       (3, 2, 19),
       (4, 4, 3),
       (5, 2, 1);

-- 17. удалить таблицы
DROP TABLE IF EXISTS orders_data;
DROP TABLE IF EXISTS customers_data;
DROP DOMAIN emailType;
DROP DOMAIN phoneType;
