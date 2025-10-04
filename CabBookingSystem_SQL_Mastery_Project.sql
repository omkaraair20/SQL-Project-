
-- =============================================
-- CAB BOOKING SYSTEM - SQL MASTERY PROJECT
-- Chapters 1 to 6
-- =============================================

-- 1️⃣ SQL Launchpad
CREATE DATABASE CabBookingDB;
USE CabBookingDB;

-- 2️⃣ Crafting SQL Databases (DDL)
CREATE TABLE Customer (
    CustomerID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15),
    Email VARCHAR(100),
    Address VARCHAR(200)
);

CREATE TABLE Driver (
    DriverID INT PRIMARY KEY AUTO_INCREMENT,
    DriverName VARCHAR(100) NOT NULL,
    PhoneNumber VARCHAR(15),
    LicenseNumber VARCHAR(30),
    Rating DECIMAL(3,2)
);

CREATE TABLE Cab (
    CabID INT PRIMARY KEY AUTO_INCREMENT,
    CabNumber VARCHAR(20) UNIQUE NOT NULL,
    CabModel VARCHAR(50),
    CabType VARCHAR(50),
    Capacity INT,
    DriverID INT,
    FOREIGN KEY (DriverID) REFERENCES Driver(DriverID)
);

CREATE TABLE Booking (
    BookingID INT PRIMARY KEY AUTO_INCREMENT,
    CustomerID INT,
    CabID INT,
    PickupLocation VARCHAR(150),
    DropLocation VARCHAR(150),
    BookingDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    Fare DECIMAL(10,2),
    Status VARCHAR(50) DEFAULT 'Pending',
    FOREIGN KEY (CustomerID) REFERENCES Customer(CustomerID),
    FOREIGN KEY (CabID) REFERENCES Cab(CabID)
);

CREATE TABLE Payment (
    PaymentID INT PRIMARY KEY AUTO_INCREMENT,
    BookingID INT,
    PaymentDate DATETIME DEFAULT CURRENT_TIMESTAMP,
    PaymentMethod VARCHAR(50),
    Amount DECIMAL(10,2),
    Status VARCHAR(30) DEFAULT 'Paid',
    FOREIGN KEY (BookingID) REFERENCES Booking(BookingID)
);

-- 3️⃣ Mastering Data Control (DML)
INSERT INTO Customer (CustomerName, PhoneNumber, Email, Address) VALUES
('Aarav Patel', '9876543210', 'aarav@example.com', 'Mumbai'),
('Neha Sharma', '9123456789', 'neha@example.com', 'Pune'),
('Rohit Verma', '9988776655', 'rohit@example.com', 'Delhi');

INSERT INTO Driver (DriverName, PhoneNumber, LicenseNumber, Rating) VALUES
('Suresh Kumar', '9865321470', 'MH12DL1234', 4.5),
('Pooja Rane', '9812345678', 'MH14DL5678', 4.8),
('Imran Sheikh', '9876012345', 'MH04DL7890', 4.2);

INSERT INTO Cab (CabNumber, CabModel, CabType, Capacity, DriverID) VALUES
('MH12AB1234', 'Suzuki Dzire', 'Sedan', 4, 1),
('MH14CD5678', 'Toyota Innova', 'SUV', 6, 2),
('MH04EF7890', 'Tata Indica', 'Hatchback', 4, 3);

INSERT INTO Booking (CustomerID, CabID, PickupLocation, DropLocation, Fare, Status) VALUES
(1, 1, 'Andheri', 'Bandra', 250.00, 'Completed'),
(2, 2, 'Pune Station', 'Kothrud', 350.00, 'Completed'),
(3, 3, 'Connaught Place', 'Lajpat Nagar', 300.00, 'Pending');

INSERT INTO Payment (BookingID, PaymentMethod, Amount, Status) VALUES
(1, 'UPI', 250.00, 'Paid'),
(2, 'Cash', 350.00, 'Paid');

UPDATE Driver SET Rating = 4.9 WHERE DriverName = 'Pooja Rane';
DELETE FROM Booking WHERE Status = 'Pending';

-- 4️⃣ Querying Into Data (DQL)
SELECT * FROM Booking;

SELECT 
    C.CustomerName,
    B.BookingID,
    B.PickupLocation,
    B.DropLocation,
    B.Fare,
    B.Status
FROM Booking B
JOIN Customer C ON B.CustomerID = C.CustomerID;

SELECT 
    D.DriverName,
    Cb.CabModel,
    Cb.CabType,
    D.Rating
FROM Driver D
JOIN Cab Cb ON D.DriverID = Cb.DriverID;

SELECT SUM(Fare) AS Total_Revenue FROM Booking;
SELECT Status, COUNT(*) AS Total FROM Booking GROUP BY Status;

-- 5️⃣ Unlock The Built-Ins
SELECT AVG(Fare) AS AvgFare, MAX(Fare) AS MaxFare, MIN(Fare) AS MinFare FROM Booking;

SELECT UPPER(CustomerName) AS Customer_UpperCase FROM Customer;

SELECT BookingID, DATE(BookingDate) AS BookingDateOnly, DAYNAME(BookingDate) AS DayOfWeek FROM Booking;

SELECT BookingID, Fare,
CASE 
    WHEN Fare > 300 THEN 'High Fare'
    ELSE 'Low Fare'
END AS FareCategory
FROM Booking;

-- 6️⃣ Connecting Data For Insights
SELECT 
    C.CustomerName,
    B.BookingID,
    B.PickupLocation,
    B.DropLocation,
    P.PaymentMethod,
    P.Amount
FROM Booking B
JOIN Customer C ON B.CustomerID = C.CustomerID
JOIN Payment P ON B.BookingID = P.BookingID;

SELECT 
    C.CustomerName,
    B.BookingID,
    B.Status
FROM Customer C
LEFT JOIN Booking B ON C.CustomerID = B.CustomerID;

SELECT * FROM Booking WHERE Fare = (SELECT MAX(Fare) FROM Booking);

SELECT DriverName FROM Driver
WHERE DriverID IN (
    SELECT Cb.DriverID
    FROM Cab Cb
    JOIN Booking B ON Cb.CabID = B.CabID
    GROUP BY Cb.DriverID
    HAVING COUNT(B.BookingID) > 1
);
