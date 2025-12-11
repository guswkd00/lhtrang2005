-- 3.1. Feedback Sentiment Analysis
SELECT 
    Category,
    COUNT(*) as TotalFeedback,
    AVG(Rating) as AvgRating,
    MIN(Rating) as MinRating,
    MAX(Rating) as MaxRating,
    STDDEV(Rating) as RatingStdDev,
    SUM(CASE WHEN Rating >= 4 THEN 1 ELSE 0 END) as PositiveReviews,
    SUM(CASE WHEN Rating = 3 THEN 1 ELSE 0 END) as NeutralReviews,
    SUM(CASE WHEN Rating <= 2 THEN 1 ELSE 0 END) as NegativeReviews,
    ROUND((SUM(CASE WHEN Rating >= 4 THEN 1 ELSE 0 END) * 100.0 / COUNT(*)), 2) as PositivePercentage
FROM Feedback
GROUP BY Category
ORDER BY AvgRating DESC;

-- 3.2. Correlation between Rating and Other Factors
SELECT 
    t.TourName,
    COUNT(f.FeedbackID) as TotalFeedbacks,
    AVG(f.Rating) as AvgRating,
    AVG(b.TotalAmount) as AvgBookingValue,
    AVG(b.NumberOfPeople) as AvgGroupSize,
    CORR(f.Rating, b.TotalAmount) as Rating_Price_Correlation,
    CORR(f.Rating, b.NumberOfPeople) as Rating_GroupSize_Correlation
FROM Tour t
JOIN Booking b ON t.TourID = b.TourID
JOIN Feedback f ON b.BookingID = f.BookingID
GROUP BY t.TourID, t.TourName
HAVING COUNT(f.FeedbackID) >= 5
ORDER BY AvgRating DESC;

-- 3.3. Keyword Analysis in Feedback Comments
SELECT 
    'Excellent' as Keyword,
    COUNT(*) as Occurrences
FROM Feedback 
WHERE LOWER(Comment) LIKE '%excellent%' OR LOWER(Comment) LIKE '%amazing%' OR LOWER(Comment) LIKE '%perfect%'
UNION ALL
SELECT 
    'Good' as Keyword,
    COUNT(*) as Occurrences
FROM Feedback 
WHERE LOWER(Comment) LIKE '%good%' OR LOWER(Comment) LIKE '%nice%' OR LOWER(Comment) LIKE '%satisfied%'
UNION ALL
SELECT 
    'Poor' as Keyword,
    COUNT(*) as Occurrences
FROM Feedback 
WHERE LOWER(Comment) LIKE '%poor%' OR LOWER(Comment) LIKE '%bad%' OR LOWER(Comment) LIKE '%disappointed%'
UNION ALL
SELECT 
    'Service' as Keyword,
    COUNT(*) as Occurrences
FROM Feedback 
WHERE LOWER(Comment) LIKE '%service%'
UNION ALL
SELECT 
    'Guide' as Keyword,
    COUNT(*) as Occurrences
FROM Feedback 
WHERE LOWER(Comment) LIKE '%guide%';