--Exercise 1: Use the order_binary metric from the previous exercise, count the number of users per treatment group for test_id = 7, 
--and count the number of users with orders (for test_id 7)
SELECT
  assignment,
  COUNT(user_id)    AS Total_Users,
  SUM(Order_Binary) AS Total_Orders
FROM
  (SELECT
    Test_Event.test_id                                                  AS test_id,
    Test_Event.assignment                                               AS assignment,
    Test_Event.user_id                                                  AS user_id,
    MAX(CASE WHEN dsv1069.orders.paid_at IS NOT NULL THEN 1 
        ELSE 0 END)                                                     AS Order_Binary
  FROM
    (SELECT 
      event_id, 
      event_time,
      user_id,
      MAX(CASE WHEN parameter_name = 'test_id' THEN CAST(parameter_value AS INT) 
          ELSE NULL END ) AS test_id,
      MAX(CASE WHEN parameter_name = 'test_assignment' THEN parameter_value
          ELSE NULL END ) AS assignment
    FROM
      dsv1069.events
    WHERE 
      event_name = 'test_assignment'
    GROUP BY
      event_id,
      event_time,
      user_id) AS Test_Event
  LEFT JOIN 
    dsv1069.orders
  ON
    Test_Event.user_id = dsv1069.orders.user_id
  AND 
    Test_Event.event_time < dsv1069.orders.paid_at
  GROUP BY 
    Test_Event.test_id,
    Test_Event.assignment,
    Test_Event.user_id) AS Users_Level
WHERE 
  test_id = 7
GROUP BY
  assignment
 
--Exercise 2: Create a new tem view binary metric. Count the number of users per treatment group, 
--and count the number of users with views (for test_id 7)

--Exercise 1: Use the order_binary metric from the previous exercise, count the number of users per treatment group for test_id = 7, 
--and count the number of users with orders (for test_id 7)
SELECT
  assignment,
  COUNT(user_id)    AS Total_Users,
  SUM(View_Binary)  AS Total_Views
FROM
  (SELECT
    Test_Event.test_id                                                  AS test_id,
    Test_Event.assignment                                               AS assignment,
    Test_Event.user_id                                                  AS user_id,
    MAX(CASE WHEN View_Event.event_time IS NOT NULL 
        THEN 1 ELSE 0 END)                                              AS View_Binary
  FROM
    (SELECT 
      event_id, 
      event_time,
      user_id,
      MAX(CASE WHEN parameter_name = 'test_id'
          THEN CAST(parameter_value AS INT) 
          ELSE NULL END ) AS test_id,
      MAX(CASE WHEN parameter_name = 'test_assignment'
          THEN parameter_value
          ELSE NULL END ) AS assignment
    FROM
      dsv1069.events
    WHERE 
      event_name = 'test_assignment'
    GROUP BY
      event_id,
      event_time,
      user_id) AS Test_Event
  LEFT JOIN 
    (SELECT 
      * 
    FROM
      dsv1069.events
    WHERE
      event_name = 'view_item') AS View_Event
  ON
    Test_Event.user_id = View_Event.user_id
  AND 
    Test_Event.event_time < View_Event.event_time
  GROUP BY 
    Test_Event.test_id,
    Test_Event.assignment,
    Test_Event.user_id) AS Users_Level
WHERE 
  test_id = 7
GROUP BY
  assignment
  
--Exercise 3: Alter the result from EX 2, to compute the users who viewed an item WITHIN 30 days of their treatment event

SELECT
  assignment,
  COUNT(user_id)            AS Total_Users,
  SUM(View_Binary)          AS Total_Views,
  SUM(View_Binary_30Days)   AS Total_Views_30Days
FROM
  (SELECT
    Test_Event.test_id                                                                          AS test_id,
    Test_Event.assignment                                                                       AS assignment,
    Test_Event.user_id                                                                          AS user_id,
    MAX(CASE WHEN view_event.event_time IS NOT NULL 
        THEN 1 ELSE 0 END)                                                                      AS View_Binary,
    MAX(CASE WHEN DATE_PART('day',View_Event.event_time -Test_Event.event_time) <= 30 THEN 1 
        ELSE 0 END )                                                                            AS View_Binary_30Days
  FROM
    (SELECT 
      event_id, 
      event_time,
      user_id,
      MAX(CASE WHEN parameter_name = 'test_id'
          THEN CAST(parameter_value AS INT) 
          ELSE NULL END ) AS test_id,
      MAX(CASE WHEN parameter_name = 'test_assignment'
          THEN parameter_value
          ELSE NULL END ) AS assignment
    FROM
      dsv1069.events
    WHERE 
      event_name = 'test_assignment'
    GROUP BY
      event_id,
      event_time,
      user_id) AS Test_Event
  LEFT JOIN 
    (SELECT 
      * 
    FROM
      dsv1069.events
    WHERE
      event_name = 'view_item') AS View_Event
  ON
    Test_Event.user_id = View_event.user_id
  AND 
    Test_Event.event_time < View_Event.event_time
 
  GROUP BY 
    Test_Event.test_id,
    Test_Event.assignment,
    Test_Event.user_id) AS Users_Level
WHERE 
  test_id = 7
GROUP BY
  assignment


--Exercise 4:Create the metric invoices (this is a mean metric, not a binary metric) and for test_id = 7
----The count of users per treatment group
----The average value of the metric per treatment group
----The standard deviation of the metric per treatment group

SELECT 
  test_id,
  assignment,
  COUNT(user_id),
  AVG(Orders_Count)      AS Average_Orders,
  STDDEV(Orders_Count)   AS Steddev_Orders
FROM 
  (SELECT
    Test_Event.test_id,
    Test_Event.assignment,
    Test_Event.user_id,
    COALESCE(COUNT(DISTINCT dsv1069.orders.invoice_id),0)     AS Orders_Count,
    COALESCE(COUNT(DISTINCT dsv1069.orders.item_id),0)        AS Items_Count,
    COALESCE(SUM(dsv1069.orders.price),0)                     AS Revenue
  FROM
    (SELECT 
      event_id, 
      event_time,
      user_id,
      MAX(CASE WHEN parameter_name = 'test_id'THEN CAST(parameter_value AS INT) 
          ELSE NULL END ) AS test_id,
      MAX(CASE WHEN parameter_name = 'test_assignment'THEN parameter_value
          ELSE NULL END ) AS assignment
    FROM
      dsv1069.events
    WHERE 
      event_name = 'test_assignment'
    GROUP BY
      event_id,
      event_time,
      user_id) AS Test_Event
  LEFT JOIN 
    dsv1069.orders
  ON
    Test_Event.user_id = dsv1069.orders.user_id
  AND 
    Test_Event.event_time < dsv1069.orders.paid_at
  GROUP BY 
    Test_Event.test_id,
    Test_Event.assignment,
    Test_Event.user_id) AS Metric_Level
GROUP BY 
  test_id,
  assignment
ORDER BY
  test_id
