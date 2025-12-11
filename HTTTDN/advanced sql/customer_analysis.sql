-- 2.1. Customer Lifetime Value (CLV)
WITH CustomerMetrics AS (
    SELECT 
        c.CustomerID,
        c.CustomerName,
        c.CustomerType,
        c.Country,
        COUNT(DISTINCT b.BookingID) as TotalBookings,
        SUM(b.TotalAmount) as LifetimeValue,
        MIN(b.BookingDate) as FirstBookingDate,
        MAX(b.BookingDate) as LastBookingDate,
        DATEDIFF(MAX(b.BookingDate), MIN(b.BookingDate)) as CustomerLifetimeDays,
        AVG(b.TotalAmount) as AvgBookingValue
    FROM Customer c
    JOIN Booking b ON c.CustomerID = b.CustomerID
    WHERE b.BookingStatus = 'Confirmed'
    GROUP BY c.CustomerID, c.CustomerName, c.CustomerType, c.Country
    HAVING COUNT(DISTINCT b.BookingID) > 0
)
SELECT *,
    RANK() OVER (ORDER BY LifetimeValue DESC) as ValueRank,
    NTILE(4) OVER (ORDER BY LifetimeValue) as ValueSegment,
    CASE 
        WHEN TotalBookings >= 5 THEN 'Diamond'
        WHEN TotalBookings >= 3 THEN 'Gold'
        WHEN TotalBookings >= 2 THEN 'Silver'
        ELSE 'Bronze'
    END as LoyaltyTier
FROM CustomerMetrics
ORDER BY LifetimeValue DESC;

-- 2.2. RFM Analysis (Recency, Frequency, Monetary)
WITH RFM_Base AS (
    SELECT 
        c.CustomerID,
        c.CustomerName,
        c.CustomerType,
        MAX(b.BookingDate) as LastBookingDate,
        COUNT(b.BookingID) as Frequency,
        SUM(b.TotalAmount) as Monetary,
        DATEDIFF(CURDATE(), MAX(b.BookingDate)) as RecencyDays
    FROM Customer c
    JOIN Booking b ON c.CustomerID = b.CustomerID
    WHERE b.BookingStatus = 'Confirmed'
    GROUP BY c.CustomerID, c.CustomerName, c.CustomerType
),
RFM_Scores AS (
    SELECT *,
        NTILE(5) OVER (ORDER BY RecencyDays DESC) as R_Score,
        NTILE(5) OVER (ORDER BY Frequency) as F_Score,
        NTILE(5) OVER (ORDER BY Monetary) as M_Score
    FROM RFM_Base
)
SELECT *,
    CONCAT(R_Score, F_Score, M_Score) as RFM_Cell,
    CASE 
        WHEN R_Score >= 4 AND F_Score >= 4 AND M_Score >= 4 THEN 'Champions'
        WHEN R_Score >= 4 AND F_Score >= 3 THEN 'Loyal Customers'
        WHEN R_Score >= 3 AND M_Score >= 4 THEN 'Big Spenders'
        WHEN R_Score >= 3 THEN 'Potential Loyalists'
        WHEN R_Score >= 2 THEN 'Recent Customers'
        WHEN F_Score >= 4 THEN 'At Risk'
        ELSE 'Hibernating'
    END as CustomerSegment
FROM RFM_Scores
ORDER BY Monetary DESC;

-- 2.3. Customer Analysis by Country
SELECT 
    c.Country,
    COUNT(DISTINCT c.CustomerID) as TotalCustomers,
    COUNT(DISTINCT b.BookingID) as TotalBookings,
    SUM(b.TotalAmount) as TotalRevenue,
    AVG(b.TotalAmount) as AvgBookingValue,
    AVG(b.NumberOfPeople) as AvgGroupSize,
    ROUND(AVG(f.Rating), 2) as AvgRating
FROM Customer c
LEFT JOIN Booking b ON c.CustomerID = b.CustomerID AND b.BookingStatus = 'Confirmed'
LEFT JOIN Feedback f ON b.BookingID = f.BookingID
GROUP BY c.Country
HAVING TotalBookings > 0
ORDER BY TotalRevenue DESC;