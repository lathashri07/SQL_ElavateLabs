-- --------------------------------------------------------
-- MySQL Script: CREATE PROCEDURE & CREATE FUNCTION 
-- Demonstrating parameters and conditional logic
-- --------------------------------------------------------

-- Step 1: Drop database (if exists) and create new one
DROP DATABASE IF EXISTS company_db;
CREATE DATABASE company_db;
USE company_db;

-- Step 2: Create a sample Employee table
CREATE TABLE employees (
    emp_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_name VARCHAR(100),
    department VARCHAR(50),
    salary DECIMAL(10,2),
    join_date DATE
);

-- Step 3: Insert sample data
INSERT INTO employees (emp_name, department, salary, join_date) VALUES
('Ananya', 'HR', 40000, '2022-05-01'),
('Vikram', 'IT', 60000, '2023-03-10'),
('Priya', 'Finance', 55000, '2023-07-15'),
('Ravi', 'IT', 75000, '2021-11-25');

-- --------------------------------------------------------
-- CREATE FUNCTION: Calculate Bonus Based on Salary
-- --------------------------------------------------------
DELIMITER $$

CREATE FUNCTION calculate_bonus(emp_salary DECIMAL(10,2))
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE bonus DECIMAL(10,2);
    
    -- Conditional logic based on salary
    IF emp_salary >= 70000 THEN
        SET bonus = emp_salary * 0.15; -- 15% bonus for top earners
    ELSEIF emp_salary >= 50000 THEN
        SET bonus = emp_salary * 0.10; -- 10% bonus for mid-level
    ELSE
        SET bonus = emp_salary * 0.05; -- 5% bonus for others
    END IF;
    
    RETURN bonus;
END$$

DELIMITER ;

-- --------------------------------------------------------
-- CREATE PROCEDURE: Update Salary with Bonus
-- --------------------------------------------------------
DELIMITER $$

CREATE PROCEDURE update_salary_with_bonus(IN empName VARCHAR(100))
BEGIN
    DECLARE baseSalary DECIMAL(10,2);
    DECLARE bonusAmount DECIMAL(10,2);
    
    -- Get current salary
    SELECT salary INTO baseSalary FROM employees WHERE emp_name = empName;
    
    IF baseSalary IS NULL THEN
        SELECT CONCAT('Employee ', empName, ' not found!') AS Message;
    ELSE
        -- Calculate bonus using function
        SET bonusAmount = calculate_bonus(baseSalary);
        
        -- Update salary by adding bonus
        UPDATE employees
        SET salary = salary + bonusAmount
        WHERE emp_name = empName;
        
        SELECT CONCAT(empName, ' received a bonus of ₹', bonusAmount, 
                      ' and new salary is ₹', salary) AS Message
        FROM employees WHERE emp_name = empName;
    END IF;
END$$

DELIMITER ;

-- --------------------------------------------------------
-- Step 4: Test the Procedure and Function
-- --------------------------------------------------------

-- View all employees before update
SELECT * FROM employees;

-- Call the procedure for one employee
CALL update_salary_with_bonus('Vikram');

-- Check results
SELECT * FROM employees;

-- Test function directly (optional)
SELECT emp_name, salary, calculate_bonus(salary) AS next_bonus
FROM employees;
