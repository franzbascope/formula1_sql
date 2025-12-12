-- Find what position driver Max Verstappen finished on Abu Dhabi Grand Prix 2021

SELECT * FROM 
DRIVER_STANDINGS
JOIN RACES USING(RACE_ID)
JOIN DRIVERS DR USING(DRIVER_ID)
WHERE NAME='Abu Dhabi Grand Prix' 
AND DRIVER_CODE = 'VER'
AND YEAR = 2021

