USE studentdb;
CREATE TABLE students (
std_ID INT,
std_Name VARCHAR(50),
std_Branch VARCHAR(10),
std_gender VARCHAR(10)
);

INSERT INTO students VALUES
(70, 'LATHASHRI', 'CSE', 'FEMALE'),
(71, 'DARSHAN', 'MBA', 'MALE'),
(72, 'MONOJ', 'CSE', 'MALE'),
(73, 'HEMAVATI', 'BSC', 'FEMALE'),
(74, 'RISHAL', 'CSE', 'FEMALE');

SELECT * 
FROM students
ORDER BY std_Name DESC;

SELECT * 
FROM students
WHERE std_Name LIKE 'l%';

SELECT * 
FROM students
WHERE std_Name="LATHASHRI" AND std_Branch = "CSE";

SELECT * 
FROM students
WHERE std_gender="FEMALE" OR std_Branch = "CSE";

SELECT * 
FROM students
LIMIT 3;