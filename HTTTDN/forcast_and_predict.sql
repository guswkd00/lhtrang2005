-- 5.1. Revenue Forecasting using Moving Average
WITH MonthlyRevenue AS (
    SELECT 
        YEAR(BookingDate) as Year,
        MONTH(BookingDate) as Month,
        SUM(TotalAmount) as Revenue
    FROM Booking
    WHERE BookingStatus = 'Confirmed'
    GROUP BY YEAR(BookingDate), MONTH(BookingDate)
)
SELECT 
    Year,
    Month,
    Revenue,
    AVG(Revenue) OVER (ORDER BY Year, Month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) as MovingAvg3Months,
    AVG(Revenue) OVER (ORDER BY Year, Month ROWS BETWEEN 5 PRECEDING AND CURRENT ROW) as MovingAvg6Months,
    SUM(Revenue) OVER (ORDER BY Year, Month) as CumulativeRevenue
FROM MonthlyRevenue
ORDER BY Year, Month;

-- 5.2. Booking Trend Analysis
SELECT 
    YEAR(BookingDate) as Year,
    QUARTER(BookingDate) as Quarter,
    COUNT(*) as Bookings,
    SUM(TotalAmount) as Revenue,
    ROUND(AVG(TotalAmount), 2) as AvgBookingValue,
    ROUND((SUM(TotalAmount) - LAG(SUM(TotalAmount)) OVER (ORDER BY YEAR(BookingDate), QUARTER(BookingDate))) / 
          LAG(SUM(TotalAmount)) OVER (ORDER BY YEAR(BookingDate), QUARTER(BookingDate)) * 100, 2) as QoQ_Growth
FROM Booking
WHERE BookingStatus = 'Confirmed'
GROUP BY YEAR(BookingDate), QUARTER(BookingDate)
ORDER BY Year DESC, Quarter DESC;

-- 5.3. Customer Churn Rate Analysis
WITH CustomerActivity AS (
    SELECT 
        CustomerID,
        MAX(BookingDate) as LastBookingDate,
        CASE 
            WHEN DATEDIFF(CURDATE(), MAX(BookingDate)) > 180 THEN 'Churned'
            WHEN DATEDIFF(CURDATE(), MAX(BookingDate)) > 90 THEN 'At Risk'
            ELSE 'Active'
        END as Status
    FROM Booking
    WHERE BookingStatus = 'Confirmed'
    GROUP BY CustomerID
)
SELECT 
    Status,
    COUNT(*) as CustomerCount,
    COUNT(*) * 100.0 / SUM(COUNT(*)) OVER() as Percentage,
    AVG(DATEDIFF(CURDATE(), LastBookingDate)) as AvgDaysSinceLastBooking
FROM CustomerActivity
GROUP BY Status;