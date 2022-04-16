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
  

