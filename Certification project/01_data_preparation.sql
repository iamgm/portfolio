
-------------------------------------------------------------------------------
-- Первичный анализ и сбор данных
-------------------------------------------------------------------------------

-- На этом этапе вы изучите структуру данных и приведёте их в удобный для анализа вид.

-- Особенности:

-- - Данные хранятся в шести таблицах: пользователи, события, заказы, сессии, кампании и справочник товаров.
-- - Некоторые поля имеют формат JSON — их нужно будет преобразовать в подходящий для анализа формат.
-- - Связи между таблицами не всегда прямые, их нужно правильно выстроить.

-- Ваша цель — собрать основу для дальнейшего анализа, аккуратно объединив данные по пользователям, действиям, заказам и маркетингу.


-------------------------------------------------------------------------------
-- Задание 1. Сбор данных о пользователях
-------------------------------------------------------------------------------
	
	-- -- Отберите данные о клиентах маркетплейса, которые зарегистрировались в 2024 году.
	-- -- Выведите все столбцы таблицы users. JSON-значения представьте в виде отдельных столбцов для каждого из параметров. 
	-- -- Дополнительно определите неделю привлечения (cohort_week) и месяц привлечения (cohort_month).
	-- -- Отсортируйте полученные данные по дате регистрации в порядке возрастания и выведите на экран 100 строк.


	-- SELECT
	-- 	user_id,
	-- 	registration_date,
	-- 	user_params ->> 'age' AS age,
	-- 	user_params ->> 'gender' AS gender,
	-- 	user_params ->> 'country' AS country,
	-- 	user_params ->> 'region' AS region,
	-- 	user_params ->> 'buyer_segment' AS buyer_segment,
	-- 	user_params ->> 'user_segment' AS user_segment,
	-- 	user_params ->> 'device' AS device,
	-- 	user_params ->> 'browser' AS browser,
	-- 	user_params ->> 'os' AS os,
	-- 	user_params ->> 'acq_channel' AS acq_channel,
	-- 	user_params ->> 'campaign_id' AS campaign_id,
	-- 	DATE_TRUNC('week', registration_date)::date AS cohort_week,
	-- 	DATE_TRUNC('month', registration_date)::date AS cohort_month
	-- FROM 
	-- 	pa_graduate.users u
	-- WHERE
	-- 	EXTRACT('year' FROM registration_date) = 2024
	-- ORDER BY 
	--     registration_date ASC
	-- LIMIT 100;

-------------------------------------------------------------------------------
-- Задание 2. Сбор данных о событиях
-------------------------------------------------------------------------------
	-- -- Соберите набор данных о событиях, которые произошли в 2024 году. В таблицу должны войти такие столбцы:



	-- -- - id события,
	-- -- - id сессии,
	-- -- - id пользователя,
	-- -- - дата события (назовите столбец `event_date`),
	-- -- - операционная система,
	-- -- - тип устройства,
	-- -- - браузер,
	-- -- - порядковый номер события,
	-- -- - сегмент пользователя,
	-- -- - наименование товара,
	-- -- - неделя события (`event_week`),
	-- -- - месяц события (`event_month`).	

	-- -- Отсортируйте полученные данные по дате события и выведите на экран 100 строк.





	-- SELECT
	-- 	e.event_id, 
	-- 	e.session_id, 
	-- 	e.user_id , 
	-- 	e.timestamp AS "event_date",
	-- 	e.event_type,  
	-- 	e.event_params ->> 'os' AS os, 
	-- 	e.event_params ->> 'device' AS device, 
	-- 	-- e.event_params ->> 'browser' AS browser, 
	-- 	e.event_params ->> 'event_index' AS event_index, 
	-- 	e.event_params ->> 'user_segment' AS user_segment, 
	-- 	pi.product_name AS product_name,
	-- 	DATE_TRUNC('week', e.timestamp)::date AS event_week, 
	-- 	DATE_TRUNC('month', e.timestamp)::date AS event_month 
	-- FROM 
	-- 	pa_graduate.events e
	-- LEFT JOIN
	-- 	pa_graduate.product_id AS pi
	-- USING
	-- 	(product_id)
	-- WHERE
	-- 	EXTRACT('year' FROM e.timestamp) = 2024
	-- ORDER BY 
	--     e.timestamp ASC
	-- LIMIT 100;

-------------------------------------------------------------------------------
-- Задание 3. Сбор данных о заказах  
-------------------------------------------------------------------------------

	-- -- Соберите набор данных о заказах, которые были сделаны в 2024 году. В таблицу должны войти такие столбцы:

	-- -- - id заказа,
	-- -- - id пользователя,
	-- -- - дата заказа,
	-- -- - наименование товара,
	-- -- - количество единиц товара,
	-- -- - цена за одну единицу товара,
	-- -- - итоговая сумма,
	-- -- - наименование категории товара,
	-- -- - неделя заказа (`order_week`),
	-- -- - месяц заказа (`order_month`).

	-- -- Отсортируйте полученные данные по дате заказа и выведите на экран 100 строк.

	-- SELECT
	-- 	o.order_id,
	-- 	o.user_id,
	-- 	o.order_date,
	-- 	pd.product_name,
	-- 	o.quantity,
	-- 	o.unit_price,
	-- 	o.total_price,
	-- 	pd.category_name,
	-- 	DATE_TRUNC('week', order_date)::date AS order_week,
	-- 	DATE_TRUNC('month', order_date)::date AS order_month
	-- FROM
	-- 	pa_graduate.orders AS o
	-- LEFT JOIN
	-- 	pa_graduate.product_dict AS pd
	-- USING
	-- 	(product_id)
	-- WHERE
	-- 	EXTRACT('year' FROM o.order_date) = 2024
	-- ORDER BY 
	--     o.order_date ASC
	-- LIMIT 100;


-------------------------------------------------------------------------------
-- Задание 4. Сбор данных о сессиях
-------------------------------------------------------------------------------
	-- -- Соберите данные о сессиях пользователей в 2024 году. В итоговый датафрейм должны войти все данные из таблицы с сессиями (после преобразования столбца в формате JSON). Добавьте неделю и месяц сессии.

	-- -- Отсортируйте полученные данные по дате начала сессии и выведите на экран 100 строк.


	-- SELECT
	-- 	s.session_id,
	-- 	s.user_id,
	-- 	s.session_start,
	-- 	session_params ->> 'device' AS device,
	-- 	session_params ->> 'browser' AS browser,
	-- 	session_params ->> 'os' AS os,
	-- 	session_params ->> 'user_segment' AS user_segment,
	-- 	session_params ->> 'entry_path' AS entry_path,
	-- 	session_params ->> 'path_start' AS path_start,
	-- 	session_params ->> 'country' AS country,
	-- 	session_params ->> 'region' AS region,
	-- 	session_params ->> 'screen_size' AS screen_size,
	-- 	session_params ->> 'scroll_depth' AS scroll_depth,
	-- 	session_params ->> 'utm_source' AS utm_source,
	-- 	session_params ->> 'utm_campaign_id' AS utm_campaign_id,
	-- 	DATE_TRUNC('week', s.session_start)::date AS order_week,
	-- 	DATE_TRUNC('month', s.session_start)::date AS order_month
	-- FROM
	-- 	pa_graduate.sessions AS s
	-- WHERE
	-- 	EXTRACT('year' FROM s.session_start) = 2024
	-- ORDER BY 
	--     s.session_start ASC
	-- LIMIT 100;

