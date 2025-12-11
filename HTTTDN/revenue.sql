-- 1.1. Revenue ordering by month and growth rate
SELECT 
    YEAR(BookingDate) as Year,
    MONTH(BookingDate) as Month,
    COUNT(*) as TotalBookings,
    SUM(TotalAmount) as MonthlyRevenue,
    SUM(TotalAmount) / SUM(SUM(TotalAmount)) OVER (PARTITION BY YEAR(BookingDate)) * 100 as MonthlyPercent,
    LAG(SUM(TotalAmount)) OVER (ORDER BY YEAR(BookingDate), MONTH(BookingDate)) as PreviousMonthRevenue,
    ROUND(((SUM(TotalAmount) - LAG(SUM(TotalAmount)) OVER (ORDER BY YEAR(BookingDate), MONTH(BookingDate))) / 
           LAG(SUM(TotalAmount)) OVER (ORDER BY YEAR(BookingDate), MONTH(BookingDate))) * 100, 2) as GrowthRate
FROM Booking
WHERE BookingStatus = 'Confirmed'
GROUP BY YEAR(BookingDate), MONTH(BookingDate)
ORDER BY Year DESC, Month DESC;

-- 1.2. Revenue ordering by customer
WITH CustomerRevenue AS (
    SELECT 
        c.CustomerType,
        COUNT(DISTINCT b.BookingID) as TotalBookings,
        SUM(b.TotalAmount) as TotalRevenue,
        AVG(b.TotalAmount) as AvgBookingValue,
        SUM(b.NumberOfPeople) as TotalTravelers
    FROM Booking b
    JOIN Customer c ON b.CustomerID = c.CustomerID
    WHERE b.BookingStatus = 'Confirmed'
    GROUP BY c.CustomerType
)
SELECT *,
    TotalRevenue / SUM(TotalRevenue) OVER() * 100 as RevenuePercentage,
    RANK() OVER (ORDER BY TotalRevenue DESC) as RevenueRank
FROM CustomerRevenue;

-- 1.3. Top 10 tour have the highest revenue
SELECT 
    t.TourName,
    t.Destination,
    COUNT(b.BookingID) as TotalBookings,
    SUM(b.TotalAmount) as TotalRevenue,
    SUM(b.NumberOfPeople) as TotalTravelers,
    AVG(b.TotalAmount) as AvgBookingValue,
    ROUND(AVG(f.Rating), 2) as AvgRating
FROM Tour t
LEFT JOIN Booking b ON t.TourID = b.TourID AND b.BookingStatus = 'Confirmed'
LEFT JOIN Feedback f ON b.BookingID = f.BookingID
GROUP BY t.TourID, t.TourName, t.Destination
ORDER BY TotalRevenue DESC
LIMIT 10;

-- 1.4. Seasonality Analysis
SELECT 
    CASE 
        WHEN MONTH(TravelDate) IN (12,1,2) THEN 'Winter'
        WHEN MONTH(TravelDate) IN (3,4,5) THEN 'Spring'
        WHEN MONTH(TravelDate) IN (6,7,8) THEN 'Summer'
        WHEN MONTH(TravelDate) IN (9,10,11) THEN 'Autumn'
    END as Season,
    COUNT(*) as TotalBookings,
    SUM(TotalAmount) as TotalRevenue,
    AVG(TotalAmount) as AvgRevenue,
    SUM(NumberOfPeople) as TotalTravelers,
    AVG(NumberOfPeople) as AvgGroupSize
FROM Booking
WHERE BookingStatus = 'Confirmed'
GROUP BY Season
ORDER BY TotalRevenue DESC;