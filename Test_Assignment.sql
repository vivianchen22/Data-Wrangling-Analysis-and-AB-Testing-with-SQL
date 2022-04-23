--Exercise 1: Figure out how many tests we have running right now

SELECT 
  COUNT(DISTINCT parameter_value) AS Tests_Count
FROM 
  dsv1069.events
WHERE
  event_name ='test_assignment'
AND
  parameter_name ='test_id'
  
  
--Exercise 2: Check for potential problems with test assignments. 
--For example Make sure there is no data obviously missing (This is an open ended question)

SELECT 
  parameter_value   AS Test_id,
  DATE(event_time)  AS Event_Day,
  COUNT(*)          AS Events_Count 
FROM 
  dsv1069.events
WHERE
  event_name ='test_assignment'
AND
  parameter_name ='test_id'
GROUP BY 
  Test_id,
  Event_Day
  
--Exercise 3: Write a query that returns a table of assignment events.
--Please include all of the relevant parameters as columns (Hint: A previous exercise as a template)
SELECT 
  event_id, 
  event_time,
  user_id,
  platform,
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
  user_id,
  platform
  
--Exercise 4: Check for potential assignment problems with test_id 5. 
--Specifically, make sure users are assigned only one treatment group
SELECT
  user_id,
  COUNT(DISTINCT assignment) AS Assignment_Count
FROM
  (SELECT 
    event_id, 
    event_time,
    user_id,
    platform,
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
    user_id,
    platform) AS Test_Event
WHERE 
  test_id = 5
GROUP BY
  user_id
ORDER BY 
   Assignment_Count DESC
