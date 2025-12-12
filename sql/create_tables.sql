ALTER SESSION SET CONTAINER = FREEPDB1;


CREATE TABLESPACE f1_data 
DATAFILE './f1_data02.dbf' SIZE 1G AUTOEXTEND ON;

CREATE TABLESPACE f1_idx 
DATAFILE './f1_idx02.dbf' SIZE 500M AUTOEXTEND ON;

commit;


-- CREATE APPLICATION USER
CREATE USER formula1 IDENTIFIED BY "Lateral12$"
DEFAULT TABLESPACE f1_data
TEMPORARY TABLESPACE temp
QUOTA UNLIMITED ON f1_data  
QUOTA UNLIMITED ON f1_idx
ACCOUNT UNLOCK;

commit;


-- GRANT PERMISSIONS TO USER
GRANT CREATE SESSION TO formula1;
GRANT CREATE TABLE TO formula1;
GRANT CREATE VIEW TO formula1;
GRANT CREATE SEQUENCE TO formula1;
GRANT CREATE PROCEDURE TO formula1;
GRANT CREATE ANY INDEX TO formula1;

commit;

SHOW CON_NAME;




-- circuits table 
CREATE TABLE circuits (
    circuit_id    NUMBER PRIMARY KEY,
    circuit_ref   VARCHAR2(50) NOT NULL,
    name          VARCHAR2(100) NOT NULL,
    location      VARCHAR2(100),
    country       VARCHAR2(50),
    lat           NUMBER(10, 6),
    lng           NUMBER(10, 6),
    alt           NUMBER(6, 1),
    url           VARCHAR2(200),
    created_date  DATE DEFAULT sysdate,
    modified_date DATE DEFAULT sysdate
);


-- Create drivers table
CREATE TABLE drivers (
    driver_id     NUMBER PRIMARY KEY,
    driver_ref    VARCHAR2(50) NOT NULL,
    driver_number VARCHAR(2),
    driver_code   VARCHAR2(3),
    forename      VARCHAR2(50) NOT NULL,
    surname       VARCHAR2(50) NOT NULL,
    date_of_birth DATE,
    nationality   VARCHAR2(50),
    url           VARCHAR2(200),
    created_date  DATE DEFAULT sysdate,
    modified_date DATE DEFAULT sysdate,
    CONSTRAINT uk_driver_ref UNIQUE ( driver_ref )
);

CREATE TABLE constructors (
    constructor_id  NUMBER PRIMARY KEY,
    constructor_ref VARCHAR2(50)
        CONSTRAINT uk_constructor_ref UNIQUE
    NOT NULL,
    name            VARCHAR2(100) NOT NULL,
    nationality     VARCHAR2(50),
    url             VARCHAR2(200),
    created_date    DATE DEFAULT sysdate
);

-- STATUS TABLE
CREATE TABLE status (
    status_id NUMBER PRIMARY KEY,
    status    VARCHAR2(20) UNIQUE NOT NULL
);

-- RACES TABLE

CREATE TABLE races (
    race_id        NUMBER        PRIMARY KEY,
    year          NUMBER(4)     NOT NULL CHECK (year >= 1900),
    round         NUMBER(2)     NOT NULL CHECK (round >= 1),
    circuit_id     NUMBER        NOT NULL,
    name          VARCHAR2(100) NOT NULL,
    race_date          DATE          NOT NULL,
    race_time          VARCHAR2(10),
    url           VARCHAR2(200) NOT NULL UNIQUE,
    
    CONSTRAINT fk_races_circuit FOREIGN KEY (circuit_id) REFERENCES circuits(circuit_id)
);

CREATE TABLE driver_standings (
    driver_standings_id NUMBER NOT NULL PRIMARY KEY,
    race_id             NUMBER NOT NULL,
    driver_id           NUMBER NOT NULL,
    points              NUMBER(6,2) NOT NULL CHECK (points >= 0),
    position            NUMBER NOT NULL CHECK (position >= 1),
    position_text       VARCHAR2(10) NOT NULL,
    wins                NUMBER NOT NULL CHECK (wins >= 0),
    
    CONSTRAINT fk_driver_standings_race FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT fk_driver_standings_driver FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CONSTRAINT uk_driver_standings_race_driver UNIQUE (race_id, driver_id)
);

COMMIT;

CREATE TABLE constructor_results (
    constructor_results_id NUMBER NOT NULL PRIMARY KEY,
    race_id                NUMBER NOT NULL,
    constructor_id         NUMBER NOT NULL,
    points                 NUMBER(6,2) NOT NULL CHECK (points >= 0),
    
    CONSTRAINT fk_constructor_results_race FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT fk_constructor_results_constructor FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id),
    CONSTRAINT uk_constructor_results_race_constructor UNIQUE (race_id, constructor_id)
);

commit;


CREATE TABLE constructor_standings (
    constructor_standings_id NUMBER NOT NULL PRIMARY KEY,
    race_id                  NUMBER NOT NULL,
    constructor_id           NUMBER NOT NULL,
    points                   NUMBER(6,2) NOT NULL CHECK (points >= 0),
    position                 NUMBER NOT NULL CHECK (position >= 1),
    position_text            VARCHAR2(10) NOT NULL,
    wins                     NUMBER NOT NULL CHECK (wins >= 0),
    
    CONSTRAINT fk_constructor_standings_race FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT fk_constructor_standings_constructor FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id),
    CONSTRAINT uk_constructor_standings_race_constructor UNIQUE (race_id, constructor_id)
);

commit;

CREATE TABLE pit_stops (
    race_id         NUMBER NOT NULL,
    driver_id       NUMBER NOT NULL,
    stop            NUMBER NOT NULL CHECK (stop >= 1),
    lap             NUMBER NOT NULL CHECK (lap >= 1),
    time            VARCHAR2(10) NOT NULL,
    duration        VARCHAR2(20),
    milliseconds    NUMBER,
    
    CONSTRAINT pk_pit_stops PRIMARY KEY (race_id, driver_id, stop),
    CONSTRAINT fk_pit_stops_race FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT fk_pit_stops_driver FOREIGN KEY (driver_id) REFERENCES drivers(driver_id)
);
commit;


CREATE TABLE qualifying (
    qualify_id       NUMBER NOT NULL PRIMARY KEY,
    race_id          NUMBER NOT NULL,
    driver_id        NUMBER NOT NULL,
    constructor_id   NUMBER NOT NULL,
    number           NUMBER(2),
    position         NUMBER,
    q1               VARCHAR2(20),
    q2               VARCHAR2(20),
    q3               VARCHAR2(20),
    
    CONSTRAINT fk_qualifying_race FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT fk_qualifying_driver FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CONSTRAINT fk_qualifying_constructor FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id),
    CONSTRAINT uk_qualifying_race_driver UNIQUE (race_id, driver_id)
);
commit;


CREATE TABLE results (
    result_id           NUMBER NOT NULL PRIMARY KEY,
    race_id             NUMBER NOT NULL,
    driver_id           NUMBER NOT NULL,
    constructor_id      NUMBER NOT NULL,
    number_result              NUMBER(2),
    grid                NUMBER NOT NULL,
    position            NUMBER,
    position_text       VARCHAR2(10),
    position_order      NUMBER NOT NULL,
    points              NUMBER(6,2) NOT NULL,
    laps                NUMBER NOT NULL,
    time_result                VARCHAR2(20),
    milliseconds        NUMBER,
    fastest_lap         NUMBER,
    rank_result                NUMBER,
    fastest_lap_time    VARCHAR2(20),
    fastest_lap_speed   VARCHAR2(20),
    status_id           NUMBER NOT NULL,
    
    CONSTRAINT fk_results_race FOREIGN KEY (race_id) REFERENCES races(race_id),
    CONSTRAINT fk_results_driver FOREIGN KEY (driver_id) REFERENCES drivers(driver_id),
    CONSTRAINT fk_results_constructor FOREIGN KEY (constructor_id) REFERENCES constructors(constructor_id),
    CONSTRAINT fk_results_status FOREIGN KEY (status_id) REFERENCES status(status_id),
    CONSTRAINT uk_results_race_driver UNIQUE (race_id, driver_id),
    CONSTRAINT chk_results_points CHECK (points >= 0),
    CONSTRAINT chk_results_laps CHECK (laps >= 0)
);
