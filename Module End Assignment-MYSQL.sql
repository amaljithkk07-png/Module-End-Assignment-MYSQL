CREATE DATABASE ecomm;
USE ecomm;
SELECT * FROM customer_churn;
USE ecomm;

SELECT COUNT(*) AS Total_Rows
FROM customer_churn;

SET SQL_SAFE_UPDATES = 0;
SET @avg_warehouse = (SELECT ROUND(AVG(WarehouseToHome)) FROM customer_churn);

UPDATE customer_churn
SET WarehouseToHome = @avg_warehouse
WHERE WarehouseToHome IS NULL;

SET @avg_app = (SELECT ROUND(AVG(HourSpendOnApp)) FROM customer_churn);

UPDATE customer_churn
SET HourSpendOnApp = @avg_app
WHERE HourSpendOnApp IS NULL;

SET @avg_hike = (SELECT ROUND(AVG(OrderAmountHikeFromlastYear)) FROM customer_churn);

UPDATE customer_churn
SET OrderAmountHikeFromlastYear = @avg_hike
WHERE OrderAmountHikeFromlastYear IS NULL;

SET @avg_order = (SELECT ROUND(AVG(DaySinceLastOrder)) FROM customer_churn);

UPDATE customer_churn
SET DaySinceLastOrder = @avg_order
WHERE DaySinceLastOrder IS NULL;

SET SQL_SAFE_UPDATES = 0;
SET @mode_tenure = (
    SELECT Tenure
    FROM customer_churn
    WHERE Tenure IS NOT NULL
    GROUP BY Tenure
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

UPDATE customer_churn
SET Tenure = @mode_tenure
WHERE Tenure IS NULL;

SET @mode_coupon = (
    SELECT CouponUsed
    FROM customer_churn
    WHERE CouponUsed IS NOT NULL
    GROUP BY CouponUsed
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

UPDATE customer_churn
SET CouponUsed = @mode_coupon
WHERE CouponUsed IS NULL;

SET @mode_order = (
    SELECT OrderCount
    FROM customer_churn
    WHERE OrderCount IS NOT NULL
    GROUP BY OrderCount
    ORDER BY COUNT(*) DESC
    LIMIT 1
);

UPDATE customer_churn
SET OrderCount = @mode_order
WHERE OrderCount IS NULL;

DELETE FROM customer_churn
WHERE WarehouseToHome > 100;

UPDATE customer_churn
SET PreferredLoginDevice = 'Mobile Phone'
WHERE PreferredLoginDevice = 'Phone';

UPDATE customer_churn
SET PreferedOrderCat = 'Mobile Phone'
WHERE PreferedOrderCat = 'Mobile';

SHOW COLUMNS FROM customer_churn;

UPDATE customer_churn
SET PreferredPaymentMode = 'Cash on Delivery'
WHERE PreferredPaymentMode = 'COD';

UPDATE customer_churn
SET PreferredPaymentMode = 'Credit Card'
WHERE PreferredPaymentMode = 'CC';

ALTER TABLE customer_churn
RENAME COLUMN PreferedOrderCat TO PreferredOrderCat;
ALTER TABLE customer_churn
RENAME COLUMN HourSpendOnApp TO HoursSpentOnApp;
SHOW COLUMNS FROM customer_churn;

ALTER TABLE customer_churn
ADD COLUMN ComplaintReceived VARCHAR(3);

UPDATE customer_churn
SET ComplaintReceived = CASE
    WHEN Complain = 1 THEN 'Yes'
    ELSE 'No'
END;

ALTER TABLE customer_churn
ADD COLUMN ChurnStatus VARCHAR(10);
UPDATE customer_churn
SET ChurnStatus = CASE
    WHEN Churn = 1 THEN 'Churned'
    ELSE 'Active'
END;

ALTER TABLE customer_churn
DROP COLUMN Churn,
DROP COLUMN Complain;

SELECT ChurnStatus, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY ChurnStatus;
SELECT
    AVG(Tenure) AS AverageTenure,
    SUM(CashbackAmount) AS TotalCashbackAmount
FROM customer_churn
WHERE ChurnStatus = 'Churned';
SELECT
	ROUND(
        SUM(CASE WHEN ComplaintReceived = 'Yes' THEN 1 ELSE 0 END) * 100.0
        / COUNT(*),
        2
    ) AS ComplaintPercentage
FROM customer_churn
WHERE ChurnStatus = 'Churned';
SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE ChurnStatus = 'Churned'
  AND PreferredOrderCat = 'Laptop & Accessory'
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;
SELECT PreferredPaymentMode, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE ChurnStatus = 'Active'
GROUP BY PreferredPaymentMode
ORDER BY CustomerCount DESC
LIMIT 1;
SELECT SUM(OrderAmountHikeFromlastYear) AS TotalOrderAmountHike
FROM customer_churn
WHERE MaritalStatus = 'Single'
  AND PreferredOrderCat = 'Mobile Phone';
SELECT AVG(NumberOfDeviceRegistered) AS AverageDevicesRegistered
FROM customer_churn
WHERE PreferredPaymentMode = 'UPI';
SELECT CityTier, COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY CityTier
ORDER BY CustomerCount DESC
LIMIT 1;
SELECT Gender, SUM(CouponUsed) AS TotalCoupons
FROM customer_churn
GROUP BY Gender
ORDER BY TotalCoupons DESC
LIMIT 1;
SELECT PreferredOrderCat,
       COUNT(*) AS CustomerCount,
       MAX(HoursSpentOnApp) AS MaxHoursSpent
FROM customer_churn
GROUP BY PreferredOrderCat;
SELECT SUM(OrderCount) AS TotalOrderCount
FROM customer_churn
WHERE PreferredPaymentMode = 'Credit Card'
AND SatisfactionScore = (SELECT MAX(SatisfactionScore) FROM customer_churn);
SELECT AVG(SatisfactionScore) AS AverageSatisfactionScore
FROM customer_churn
WHERE ComplaintReceived = 'Yes';
SELECT PreferredOrderCat, COUNT(*) AS CustomerCount
FROM customer_churn
WHERE CouponUsed > 5
GROUP BY PreferredOrderCat
ORDER BY CustomerCount DESC;
SELECT PreferredOrderCat,
       AVG(CashbackAmount) AS AverageCashback
FROM customer_churn
GROUP BY PreferredOrderCat
ORDER BY AverageCashback DESC
LIMIT 3;

SELECT PreferredPaymentMode,
       AVG(Tenure) AS AverageTenure
FROM customer_churn
WHERE OrderCount > 500
GROUP BY PreferredPaymentMode
HAVING AVG(Tenure) = 10;
SELECT
    CASE
        WHEN WarehouseToHome <= 5 THEN 'Very Close Distance'
        WHEN WarehouseToHome <= 10 THEN 'Close Distance'
        WHEN WarehouseToHome <= 15 THEN 'Moderate Distance'
        ELSE 'Far Distance'
    END AS DistanceCategory,
    ChurnStatus,
    COUNT(*) AS CustomerCount
FROM customer_churn
GROUP BY DistanceCategory, ChurnStatus
ORDER BY DistanceCategory, ChurnStatus;
SELECT *
FROM customer_churn
WHERE MaritalStatus = 'Married'
  AND CityTier = 1
  AND OrderCount > (SELECT AVG(OrderCount)
                    FROM customer_churn);
                    
CREATE TABLE customer_returns (
    ReturnID INT,
    CustomerID INT,
    ReturnDate DATE,
    RefundAmount DECIMAL(10,2)
);
INSERT INTO customer_returns
(ReturnID, CustomerID, ReturnDate, RefundAmount)
VALUES
(1001, 50022, '2023-01-01', 2130),
(1002, 50316, '2023-01-23', 2000),
(1003, 51099, '2023-02-14', 2290),
(1004, 52321, '2023-03-08', 2510),
(1005, 52928, '2023-03-20', 3000),
(1006, 53749, '2023-04-17', 1740),
(1007, 54206, '2023-04-21', 3250),
(1008, 54838, '2023-04-30', 1990);
SELECT
    r.ReturnID,
    r.CustomerID,
    r.ReturnDate,
    r.RefundAmount,
    c.*
FROM customer_returns r
JOIN customer_churn c
    ON r.CustomerID = c.CustomerID
WHERE c.ChurnStatus = 'Churned'
  AND c.ComplaintReceived = 'Yes';
