USE studentdb;
CREATE TABLE employee (
e_ID INT PRIMARY KEY AUTO_INCREMENT,
e_Name VARCHAR(50) NOT NULL,
ph_no VARCHAR(10) UNIQUE,
Salary DECIMAL(5, 2) DEFAULT 00.00
);

INSERT INTO employee VALUES
("Raju", "9945876152", 15.000),
("Vara", "9740598741", 10.000),
("Srinivas", "9587462158", 25.000),
("Umesh", "9856247136", 35.000),
("Krishna", "9214568730", 55.000),
("Sakshi", "9123658740");

DELETE FROM employee
WHERE e_ID = 2;

UPDATE employee
SET e_Name =  "Darshan", Salary =  70.897
WHERE e_ID = 1;

SELECT * FROM employee;