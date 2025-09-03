/*
-- =============================================
-- Author:      [iamgm]
-- Create date: [2025-08-11]
-- Description: Скрипт для выгрузки данных по активности пользователей
--              маркетплейса за 2024 год.
--              Содержит 4 независимых запроса для создания 4 датасетов.
-- =============================================
*/


-------------------------------------------------------------------------------
-- 1. Выгрузка данных о пользователях (users.csv)
-------------------------------------------------------------------------------
SELECT
	user_id,
	registration_date,
	user_params ->> 'age' AS age,
	user_params ->> 'gender' AS gender,
	user_params ->> 'country' AS country,
	user_params ->> 'region' AS region,
	user_params ->> 'buyer_segment' AS buyer_segment,
	user_params ->> 'user_segment' AS user_segment,
	user_params ->> 'device' AS device,
	user_params ->> 'browser' AS browser,
	user_params ->> 'os' AS os,
	user_params ->> 'acq_channel' AS acq_channel,
	user_params ->> 'campaign_id' AS campaign_id,
	DATE_TRUNC('week', registration_date)::date AS cohort_week,
	DATE_TRUNC('month', registration_date)::date AS cohort_month
FROM 
	pa_graduate.users u
WHERE
	EXTRACT('year' FROM registration_date) = 2024
ORDER BY 
    registration_date ASC;
-- LIMIT 100;

-------------------------------------------------------------------------------
-- 2. Выгрузка данных о событиях (events.csv)
-------------------------------------------------------------------------------
SELECT
	e.event_id, 
	e.session_id, 
	e.user_id , 
	e.timestamp AS "event_date",
	e.event_type,  
	e.event_params ->> 'os' AS os, 
	e.event_params ->> 'device' AS device, 
	-- e.event_params ->> 'browser' AS browser, 
	e.event_params ->> 'event_index' AS event_index, 
	e.event_params ->> 'user_segment' AS user_segment, 
	pi.product_name AS product_name,
	DATE_TRUNC('week', e.timestamp)::date AS event_week, 
	DATE_TRUNC('month', e.timestamp)::date AS event_month 
FROM 
	pa_graduate.events e
LEFT JOIN
	pa_graduate.product_id AS pi
USING
	(product_id)
WHERE
	EXTRACT('year' FROM e.timestamp) = 2024
ORDER BY 
    e.timestamp ASC;
-- LIMIT 100;

-------------------------------------------------------------------------------
-- 3. Выгрузка данных о заказах (orders.csv)
-------------------------------------------------------------------------------
SELECT
	o.order_id,
	o.user_id,
	o.order_date,
	pd.product_name,
	o.quantity,
	o.unit_price,
	o.total_price,
	pd.category_name,
	DATE_TRUNC('week', order_date)::date AS order_week,
	DATE_TRUNC('month', order_date)::date AS order_month
FROM
	pa_graduate.orders AS o
LEFT JOIN
	pa_graduate.product_dict AS pd
USING
	(product_id)
WHERE
	EXTRACT('year' FROM o.order_date) = 2024
ORDER BY 
    o.order_date ASC;
-- LIMIT 100;


-------------------------------------------------------------------------------
-- 4. Выгрузка данных о сессиях (sessions.csv)
-------------------------------------------------------------------------------
SELECT
	s.session_id,
	s.user_id,
	s.session_start,
	session_params ->> 'device' AS device,
	session_params ->> 'browser' AS browser,
	session_params ->> 'os' AS os,
	session_params ->> 'user_segment' AS user_segment,
	session_params ->> 'entry_path' AS entry_path,
	session_params ->> 'path_start' AS path_start,
	session_params ->> 'country' AS country,
	session_params ->> 'region' AS region,
	session_params ->> 'screen_size' AS screen_size,
	session_params ->> 'scroll_depth' AS scroll_depth,
	session_params ->> 'utm_source' AS utm_source,
	session_params ->> 'utm_campaign_id' AS utm_campaign_id,
	DATE_TRUNC('week', s.session_start)::date AS session_week,
	DATE_TRUNC('month', s.session_start)::date AS session_month
FROM
	pa_graduate.sessions AS s
WHERE
	EXTRACT('year' FROM s.session_start) = 2024
ORDER BY 
    s.session_start ASC;
-- LIMIT 100;

