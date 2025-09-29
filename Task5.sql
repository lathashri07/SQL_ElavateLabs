USE studentdb;

CREATE TABLE Customers (
    CustomerID INT PRIMARY KEY,
    CustomerName VARCHAR(50),
    City VARCHAR(50)
);

CREATE TABLE Orders (
    OrderID INT PRIMARY KEY,
    OrderDate DATE,
    Amount INT,
    CustomerID INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

INSERT INTO Customers (CustomerID, CustomerName, City) VALUES
(1, 'Asha', 'Bangalore'),
(2, 'Ravi', 'Chennai'),
(3, 'Meena', 'Hyderabad'),
(4, 'Arun', 'Delhi');


INSERT INTO Orders (OrderID, OrderDate, Amount, CustomerID) VALUES
(101, '2025-09-01', 5000, 1),
(102, '2025-09-05', 3000, 2),
(103, '2025-09-10', 7000, 1),
(104, '2025-09-12', 2500, 3);

SELECT Customers.CustomerName, Orders.OrderID, Orders.Amount
FROM Customers
INNER JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

SELECT Customers.CustomerName, Orders.OrderID, Orders.Amount
FROM Customers
LEFT JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

SELECT Customers.CustomerName, Orders.OrderID, Orders.Amount
FROM Customers
RIGHT JOIN Orders ON Customers.CustomerID = Orders.CustomerID;

SELECT Customers.CustomerName, Orders.OrderID, Orders.Amount
FROM Customers
FULL JOIN Orders ON Customers.CustomerID = Orders.CustomerID;
