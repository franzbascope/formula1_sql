-- create indexes for frequent queried columns

-- index for for races by circuit_id
CREATE INDEX idx_races_circuit_id ON races(circuit_id) TABLESPACE f1_idx;
CREATE INDEX idx_circuit_ref ON circuits(circuit_ref) TABLESPACE f1_idx;



-- Get all races by circuit id
SELECT * FROM RACES
JOIN CIRCUITS USING (CIRCUIT_ID)
WHERE circuit_ref = 'bahrain';

-- indexes for driver_standings race_id,driver_id
CREATE INDEX idx_driver_standings_race_id ON driver_standings(race_id) TABLESPACE f1_idx;
CREATE INDEX idx_driver_standings_driver_id ON driver_standings(driver_id) TABLESPACE f1_idx;
CREATE INDEX idx_drivers_surname ON drivers(driver_code) TABLESPACE f1_idx;

-- indexes for frequently used columns on results table
CREATE INDEX idx_results_race_id ON results(race_id) TABLESPACE f1_idx;
CREATE INDEX idx_results_driver_id ON results(driver_id) TABLESPACE f1_idx;
CREATE INDEX idx_results_constructor_id ON results(constructor_id) TABLESPACE f1_idx;
CREATE INDEX idx_results_status_id ON results(status_id) TABLESPACE f1_idx;
CREATE INDEX idx_races_year_round ON races(year, round) TABLESPACE f1_idx;
CREATE INDEX idx_results_position ON results(position) TABLESPACE f1_idx;
CREATE INDEX idx_driver_standings_position ON driver_standings(position) TABLESPACE f1_idx;

-- Find races won by Verstappen
SELECT DRIVER_REF, RA.NAME, RACE_DATE
FROM DRIVER_STANDINGS 
JOIN DRIVERS USING (DRIVER_ID)
JOIN RACES RA USING (RACE_ID)
WHERE DRIVER_REF = 'max_verstappen'
AND POSITION = 1;





-- create partitioning for results

ALTER TABLE races MODIFY
PARTITION BY RANGE (year) (
    PARTITION races_before_2000 VALUES LESS THAN (2000),
    PARTITION races_2000_2005 VALUES LESS THAN (2006),
    PARTITION races_2005_2010 VALUES LESS THAN (2011),
     PARTITION races_2010_2015 VALUES LESS THAN (2016),
    PARTITION races_2015_2020 VALUES LESS THAN (2020),
    PARTITION races_2020_2023 VALUES LESS THAN (2023),
    PARTITION races_future VALUES LESS THAN (MAXVALUE)
);

ALTER TABLE results MODIFY
PARTITION BY REFERENCE (fk_results_race);

ALTER TABLE driver_standings MODIFY
PARTITION BY REFERENCE (fk_driver_standings_race);