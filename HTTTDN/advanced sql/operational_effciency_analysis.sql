-- 4.1. Lead Time Analysis - Time from Booking to Travel
SELECT 
    DATEDIFF(TravelDate, BookingDate) as LeadTimeDays,
    COUNT(*) as TotalBookings,
    AVG(TotalAmount) as AvgRevenue,
    AVG(NumberOfPeople) as AvgGroupSize,
    ROUND(AVG(f.Rating), 2) as AvgRating,
    SUM(CASE WHEN BookingStatus = 'Cancelled' THEN 1 ELSE 0 END) as Cancellations
FROM Booking b
LEFT JOIN Feedback f ON b.BookingID = f.BookingID
GROUP BY DATEDIFF(TravelDate, BookingDate)
HAVING TotalBookings >= 5
ORDER BY LeadTimeDays;

-- 4.2. Staff Performance Analysis (based on activity rating)
SELECT 
    a.CustomerID,
    c.CustomerName,
    COUNT(a.ActivityID) as TotalActivities,
    AVG(a.Rating) as AvgActivityRating,
    COUNT(DISTINCT a.RelatedBookingID) as BookingsHandled,
    SUM(b.TotalAmount) as GeneratedRevenue,
    MIN(a.ActivityDate) as FirstActivityDate,
    MAX(a.ActivityDate) as LastActivityDate
FROM Activity a
JOIN Customer c ON a.CustomerID = c.CustomerID
LEFT JOIN Booking b ON a.RelatedBookingID = b.BookingID
GROUP BY a.CustomerID, c.CustomerName
HAVING TotalActivities >= 3
ORDER BY AvgActivityRating DESC;

-- 4.3. Booking Funnel Analysis
WITH BookingFunnel AS (
    SELECT 
        'Inquiry' as Stage,
        COUNT(DISTINCT CustomerID) as Count
    FROM Activity 
    WHERE ActivityType LIKE '%Inquiry%'
    UNION ALL
    SELECT 
        'Booking Made' as Stage,
        COUNT(DISTINCT CustomerID) as Count
    FROM Booking 
    WHERE BookingStatus IN ('Confirmed', 'Pending')
    UNION ALL
    SELECT 
        'Confirmed' as Stage,
        COUNT(DISTINCT CustomerID) as Count
    FROM Booking 
    WHERE BookingStatus = 'Confirmed'
    UNION ALL
    SELECT 
        'Feedback Provided' as Stage,
        COUNT(DISTINCT CustomerID) as Count
    FROM Feedback
)
SELECT 
    Stage,
    Count,
    ROUND((LAG(Count) OVER (ORDER BY 
        CASE Stage 
            WHEN 'Inquiry' THEN 1
            WHEN 'Booking Made' THEN 2
            WHEN 'Confirmed' THEN 3
            WHEN 'Feedback Provided' THEN 4
        END) - Count) * 100.0 / LAG(Count) OVER (ORDER BY 
        CASE Stage 
            WHEN 'Inquiry' THEN 1
            WHEN 'Booking Made' THEN 2
            WHEN 'Confirmed' THEN 3
            WHEN 'Feedback Provided' THEN 4
        END), 2) as DropoffPercentage
FROM BookingFunnel;