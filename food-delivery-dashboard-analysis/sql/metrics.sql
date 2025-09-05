/*
-- ============================================================================
-- Author:      [Iamgm]
-- Create date: [19.02.2025]
-- Description: Расчет ключевых бизнес-метрик для сервиса доставки еды
--              в г. Саранск за май-июнь 2021 года.
-- ============================================================================
*/


-------------------------------------------------------------------------------
-- 1. Расчёт DAU 
-------------------------------------------------------------------------------

SELECT 
    log_date,
    COUNT(DISTINCT user_id) AS  DAU
FROM analytics_events AS ae
JOIN cities AS c USING("city_id")
WHERE event='order' 
    AND city_name='Саранск'
    AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
GROUP BY log_date
ORDER BY log_date ASC;
-- LIMIT 10;


-------------------------------------------------------------------------------
-- 2. Расчёт Conversion Rate 
-------------------------------------------------------------------------------
SELECT 
    log_date,
    ROUND(1. * COUNT(DISTINCT user_id)
        FILTER (WHERE event='order') / 
        COUNT(DISTINCT user_id) , 2) AS CR
FROM analytics_events AS ae
JOIN cities AS c USING("city_id")
WHERE city_name='Саранск'
    AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
GROUP BY log_date
ORDER BY log_date ASC;
-- LIMIT 10;

-------------------------------------------------------------------------------
-- 3. Расчёт среднего чека 
-------------------------------------------------------------------------------
-- Рассчитываем величину комиссии с каждого заказа, отбираем заказы по дате и городу
WITH orders AS
    (SELECT *,
            revenue * commission AS commission_revenue
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE revenue IS NOT NULL
         AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск')

SELECT 
    DATE_TRUNC('month', log_date)::date AS "Месяц",
    COUNT(DISTINCT order_id) AS "Количество заказов",
    SUM(commission_revenue) AS "Сумма комиссии",
    ROUND(SUM(commission_revenue)::numeric / COUNT(DISTINCT order_id),2) "Средний чек"
FROM orders
GROUP BY 1;

-------------------------------------------------------------------------------
-- 4. Расчёт LTV ресторанов 
-------------------------------------------------------------------------------

-- Рассчитываем величину комиссии с каждого заказа, отбираем заказы по дате и городу
WITH orders_commission AS
    (SELECT analytics_events.rest_id,
            analytics_events.city_id,
            revenue * commission AS commission_revenue
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE revenue IS NOT NULL
         AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск')

SELECT
    p.rest_id,
    p.chain AS "Название сети",
    p.type AS "Тип кухни",
    ROUND(SUM(oc.commission_revenue)::numeric, 2) AS LTV
FROM
    orders_commission AS oc
JOIN
    partners AS p USING("city_id", "rest_id")
GROUP BY  p.rest_id,  p.type, p.chain
ORDER BY LTV DESC;
-- LIMIT 3;

-------------------------------------------------------------------------------
-- 5. Расчёт LTV ресторанов — самые популярные блюда 
-------------------------------------------------------------------------------

-- Рассчитываем величину комиссии с каждого заказа, отбираем заказы по дате и городу
WITH orders_commission AS
    (SELECT analytics_events.rest_id AS rest_id,
            analytics_events.city_id,
            analytics_events.object_id,
            revenue * commission AS commission_revenue
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE revenue IS NOT NULL
         AND log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск'), 

-- Рассчитываем два ресторана с наибольшим LTV 
top_ltv_restaurants AS
    (SELECT orders_commission.rest_id AS rest_id,
            chain,
            type,
            ROUND(SUM(commission_revenue)::numeric, 2) AS LTV
     FROM orders_commission
     JOIN partners ON orders_commission.rest_id = partners.rest_id AND orders_commission.city_id = partners.city_id
     GROUP BY 1, 2, 3
     ORDER BY LTV DESC
     LIMIT 2)

SELECT
    tlr.chain AS "Название сети",
    d.name AS "Название блюда",
    d.spicy,
    d.fish,
    d.meat,
    ROUND(SUM(oc.commission_revenue)::numeric, 2) AS LTV
FROM
    top_ltv_restaurants AS tlr
JOIN 
    orders_commission AS oc USING("rest_id")
LEFT JOIN
    dishes AS d USING("object_id")
WHERE tlr.chain IN ('Гурманское Наслаждение','Гастрономический Шторм')
GROUP BY tlr.chain, d.name,d.spicy,d.fish,d.meat
ORDER BY LTV DESC
LIMIT 5;

-------------------------------------------------------------------------------
-- 6. Расчёт Retention Rate 
-------------------------------------------------------------------------------

-- Рассчитываем новых пользователей по дате первого посещения продукта
WITH new_users AS
    (SELECT DISTINCT first_date,
                     user_id
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE first_date BETWEEN '2021-05-01' AND '2021-06-24'
         AND city_name = 'Саранск'),

-- Рассчитываем активных пользователей по дате события
active_users AS
    (SELECT DISTINCT log_date,
                     user_id
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск'),
         
total_new_users AS (
    SELECT COUNT(DISTINCT user_id) AS total
    FROM new_users
)

SELECT
    au.log_date - nu.first_date  AS day_since_install,
    COUNT(DISTINCT au.user_id) FILTER (WHERE (au.log_date - nu.first_date) <=7) AS retained_users,
    ROUND(COUNT(DISTINCT au.user_id)::numeric / 
          total.total, 2) AS retention_rate
FROM
    active_users AS au 
JOIN
    new_users AS nu USING(user_id)
CROSS JOIN
    total_new_users AS total  
WHERE 
    (au.log_date - nu.first_date) BETWEEN 0 AND 7
GROUP BY
    day_since_install, total.total
ORDER BY
    day_since_install;

-------------------------------------------------------------------------------
-- 7. Сравнение Retention Rate по месяцам 
-------------------------------------------------------------------------------

-- Рассчитываем новых пользователей по дате первого посещения продукта
WITH new_users AS
    (SELECT DISTINCT first_date,
                     user_id
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE first_date BETWEEN '2021-05-01' AND '2021-06-24'
         AND city_name = 'Саранск'),

-- Рассчитываем активных пользователей по дате события
active_users AS
    (SELECT DISTINCT log_date,
                     user_id
     FROM analytics_events
     JOIN cities ON analytics_events.city_id = cities.city_id
     WHERE log_date BETWEEN '2021-05-01' AND '2021-06-30'
         AND city_name = 'Саранск'),

-- Соединяем таблицы с новыми и активными пользователями
daily_retention AS
    (SELECT new_users.user_id,
            first_date,
            log_date::date - first_date::date AS day_since_install
     FROM new_users
     JOIN active_users ON new_users.user_id = active_users.user_id
     AND log_date >= first_date)

SELECT
    DATE_TRUNC('month', first_date)::date "Месяц",
    day_since_install,
    COUNT(DISTINCT user_id) AS retained_users,
    ROUND(1.0 * COUNT(DISTINCT user_id) / MAX(COUNT(DISTINCT user_id)) OVER
         (PARTITION BY DATE_TRUNC('month', first_date)::date ),2) AS retention_rate
FROM
    daily_retention AS dr
WHERE
    day_since_install <=7 
GROUP BY "Месяц", day_since_install
ORDER BY "Месяц", day_since_install

-------------------------------------------------------------------------------