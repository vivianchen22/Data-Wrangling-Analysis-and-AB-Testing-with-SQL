--Exercise 1: Using any methods you like determine if you can you trust this events table dsv1069.events_201701.
--HINT: There are some entire days missing
SELECT 
  DATE(event_time) AS DATE,
  COUNT(event_id)
FROM 
  dsv1069.events_201701
GROUP BY
  DATE
ORDER BY 
  DATE
 
--Exercise 2:
--Using any methods you like, determine if you can you trust this events table dsv1069.events_ex2. 
--(HINT: When did we start recording events on mobile)

SELECT 
  DATE(event_time) as Date,
  platform,
  COUNT(event_id)
FROM 
  dsv1069.events_ex2
GROUP BY
  Date,
  platform
ORDER BY
  Date

--Exercise 3: Imagine that you need to count item views by category. You found this table item_views_by_category_temp 
-- should you use it to answer your questiuon?
--Answer: NO the numbers of event was not matched

--SELECT
--  SUM (view_events)
--FROM 
--  dsv1069.item_views_by_category_temp

SELECT 
  COUNT(DISTINCT event_id)
FROM
  dsv1069.events
WHERE
  event_name = 'view_item'


--Exercise 4: Using any methods you like, decide if this table is ready to be used as a source of truth.
--Anwser: couldn't find the dsv1069.raw_events table in the database
SELECT 
  *
FROM
  dsv1069.raw_events
  
--Exercise 5: Is this the right way to join orders to users? Is this the right way this join.
--SELECT 
--  * 
--FROM 
--  dsv1069.orders
--JOIN 
--  dsv1069.users
--ON 
--  orders.user_id = users.parent_user_id

SELECT 
  COUNT(*)
FROM
  dsv1069.orders
JOIN
  dsv1069.users
ON
  orders.user_id = COALESCE(users.parent_user_id,users.id)
  



