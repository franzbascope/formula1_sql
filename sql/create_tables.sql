-- circuits table 
CREATE TABLE circuits (
    circuit_id      NUMBER          PRIMARY KEY,
    circuit_ref     VARCHAR2(50)    NOT NULL,
    name            VARCHAR2(100)   NOT NULL,
    location        VARCHAR2(100),
    country         VARCHAR2(50),
    lat             NUMBER(10, 6),   
    lng             NUMBER(10, 6),  
    alt             NUMBER(6, 1),   
    url             VARCHAR2(200),
    created_date    DATE            DEFAULT SYSDATE,
    modified_date   DATE            DEFAULT SYSDATE
);
