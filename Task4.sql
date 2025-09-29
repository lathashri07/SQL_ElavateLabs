USE studentdb;
CREATE TABLE Employees (
    EmpID INT PRIMARY KEY,
    Name VARCHAR(50),
    Department VARCHAR(50),
    Salary INT,
    Age INT
);


INSERT INTO Employees (EmpID, Name, Department, Salary, Age) VALUES
(1, 'Asha', 'IT', 60000, 25),
(2, 'Ravi', 'IT', 55000, 28),
(3, 'Meena', 'HR', 40000, 30),
(4, 'Arun', 'HR', 42000, 26),
(5, 'Kiran', 'Sales', 50000, 29),
(6, 'Divya', 'Sales', 48000, 32);


SELECT 
    AVG(Salary) AS AvgSalary,
    SUM(Salary) AS TotalSalary,
    MAX(Salary) AS MaxSalary,
    MIN(Salary) AS MinSalary,
    COUNT(*) AS EmployeeCount
FROM Employees;


SELECT 
    Department,
    AVG(Salary) AS AvgSalary,
    SUM(Salary) AS TotalSalary,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Department;


SELECT 
    Department,
    AVG(Salary) AS AvgSalary,
    SUM(Salary) AS TotalSalary,
    COUNT(*) AS EmployeeCount
FROM Employees
GROUP BY Department
HAVING AVG(Salary) > 50000;
