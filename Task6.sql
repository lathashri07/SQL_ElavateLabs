CREATE TABLE Departments (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50)
);

CREATE TABLE Employees (
    emp_id INT PRIMARY KEY,
    name VARCHAR(50),
    dept_id INT,
    salary DECIMAL(10,2),
    FOREIGN KEY (dept_id) REFERENCES Departments(dept_id)
);


INSERT INTO Departments (dept_id, dept_name) VALUES
(1, 'HR'),
(2, 'Finance'),
(3, 'IT'),
(4, 'Marketing');


INSERT INTO Employees (emp_id, name, dept_id, salary) VALUES
(101, 'Alice', 1, 50000),
(102, 'Bob', 2, 60000),
(103, 'Charlie', 2, 55000),
(104, 'David', 3, 70000),
(105, 'Eva', 3, 80000),
(106, 'Frank', 4, 45000),
(107, 'Grace', 1, 52000);

SELECT name, salary
FROM Employees
WHERE salary > (SELECT AVG(salary) FROM Employees);

SELECT e.name, e.salary, e.dept_id
FROM Employees e
WHERE e.salary > (
    SELECT AVG(salary)
    FROM Employees sub
    WHERE sub.dept_id = e.dept_id
);

SELECT name, dept_id
FROM Employees
WHERE dept_id IN (
    SELECT dept_id
    FROM Departments
    WHERE dept_name IN ('HR', 'Finance')
);

SELECT d.dept_id, d.dept_name
FROM Departments d
WHERE EXISTS (
    SELECT 1
    FROM Employees e
    WHERE e.dept_id = d.dept_id
);

SELECT dept_name
FROM Departments
WHERE dept_id = (
    SELECT dept_id
    FROM Employees
    WHERE emp_id = 101
);
