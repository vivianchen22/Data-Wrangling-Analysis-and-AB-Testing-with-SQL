-- Create Table Structure & Insert Into Data
CREATE TABLE IF NOT EXISTS 'view_item_events'(
  event_id    VARCHAR(32) NOT NULL PRIMARY KEY,
  event_time  VARCHAR(26),
  user_id     INT(10),
  platform    VARCHAR(10),
  item_id     INT(10),
  referrer    VARCHAR(17)
);

INSERT INTO 
'view_item_events'

SELECT 
  event_id, 
  event_time,
  user_id,
  platform,
  MAX(CASE WHEN parameter_name = 'item_id'
      THEN CAST(parameter_value AS INT) 
      ELSE NULL END ) AS item_id,
  MAX(CASE WHEN parameter_name = 'referrer'
      THEN parameter_value
      ELSE NULL END ) AS referrer
FROM
  dsv1069.events
WHERE 
  event_name = 'view_item'
GROUP BY
  event_id,
  event_time,
  user_id,
  platform
ORDER BY 
  event_id
  

