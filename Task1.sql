CREATE DATABASE StudentDB;
USE StudentDB;

CREATE TABLE Student (
Std_ID INT PRIMARY KEY,
Std_Name VARCHAR(100) NOT NULL,
Email VARCHAR(50) UNIQUE,
DOB DATE
);

CREATE TABLE Course (
Course_ID INT PRIMARY KEY,
Course_Name VARCHAR(50) NOT NULL,
Credits INT
);

CREATE TABLE Enrollment (
Enrollment_ID INT PRIMARY KEY,
Std_ID INT,
Course_ID INT,
Enrollment_Date DATE,
FOREIGN KEY(Std_ID) REFERENCES Student(Std_ID),
FOREIGN KEY(Course_ID) REFERENCES Course(Course_ID)
);

INSERT INTO Student (Std_ID, Std_Name, Email, DOB) VALUES
(70, 'Alice Johnson', 'alice.johnson@example.com', '2003-05-12'),
(71, 'Bob Smith', 'bob.smith@example.com', '2002-08-23'),
(72, 'Charlie Brown', 'charlie.brown@example.com', '2003-11-30'),
(73, 'Steve', 'steve.brown@example.com', '2004-07-16'),
(74, 'Nancy Wheler', 'nancy.brown@example.com', '2005-04-27');

INSERT INTO Course (Course_ID, Course_Name, Credits) VALUES
(101, 'Cloud Computing', 4),
(106, 'DBMS', 3),
(103, 'Machine Learning', 5),
(108, 'SQL', 3),
(102, 'Java', 4),
(109, 'Python', 4),
(104, 'Data Structure', 10);

INSERT INTO Enrollment (Enrollment_ID, Std_ID, Course_ID, Enrollment_Date) VALUES
(1, 70, 106, '2025-09-01'),
(2, 70, 103, '2025-09-02'),
(3, 71, 109, '2025-09-01'),
(4, 71, 104, '2025-09-05'),
(5, 72, 101, '2025-09-03'),
(6, 73, 102, '2025-09-03'),
(7, 73, 109, '2025-09-03'),
(8, 73, 103, '2025-09-11'),
(9, 74, 106, '2025-09-23');

SELECT * FROM Enrollment;
SELECT * FROM Student;
SELECT * FROM Course;