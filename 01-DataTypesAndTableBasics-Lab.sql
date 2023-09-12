-- 01. Create Tables

CREATE TABLE employees
(
    id             serial primary key not null,
    first_name     varchar(30),
    last_name      varchar(50),
    hiring_date    date default '2023-01-01',
    salary         numeric(10, 2),
    devices_number int
);

CREATE TABLE departments
(
    id          serial primary key not null,
    name        varchar(50),
    code        char(3),
    description text
);

CREATE TABLE issues
(
    id          serial primary key unique,
    description varchar(150),
    date        DATE,
    start       timestamp without time zone
);

-- 2.  Insert Data in Tables
INSERT INTO employees (first_name, last_name, hiring_date, salary, devices_number)
VALUES
    ('Ivan', 'Petrov', '2023-12-22', 2000.00, 1),
    ('Ivan', 'Ivanov', '2023-12-23', 2001.00, 2),
    ('Ivan', 'Petkov', '2023-12-24', 2002.00, 3);

-- 03. Alter Tables
ALTER TABLE employees
ADD COLUMN middle_name varchar(50);

-- 04. Add Constraints
ALTER TABLE employees
ALTER COLUMN salary SET default 0,
ALTER COLUMN salary SET not null,
ALTER COLUMN hiring_date SET not null;

-- 05. Modify Columns
ALTER TABLE employees
ALTER COLUMN middle_name TYPE varchar(100);

-- 06. Truncate Tables
TRUNCATE issues;

-- 07. Drop Tables
DROP TABLE departments;


