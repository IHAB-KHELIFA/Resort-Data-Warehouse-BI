-- =========
-- QUERY 1: 
-- =========

SELECT 
    d_resort.ResortName,
    d_person.Gender,
    CASE 
        WHEN d_person.Age BETWEEN 18 AND 30 THEN '18-30'
        WHEN d_person.Age BETWEEN 31 AND 50 THEN '31-50'
        ELSE '51+' 
    END AS Age_Bracket,
    SUM(f_pay.Amount) AS Total_Revenue
FROM 
    FACT_PAYMENT f_pay
JOIN DIM_RESORT d_resort ON f_pay.ResortKey = d_resort.ResortKey
JOIN DIM_PERSON d_person ON f_pay.PersonKey = d_person.PersonKey
JOIN DIM_DATE d_date ON f_pay.DateKey = d_date.DateKey
WHERE 
    d_date.Year >= 2021 -- Adjust to last 3 years
GROUP BY 
    d_resort.ResortName,
    d_person.Gender,
    Age_Bracket
ORDER BY Total_Revenue DESC;

-- =========
-- QUERY 2: 
-- =========

SELECT 
    d_date.Year,
    CASE 
        WHEN d_person.SocialMediaType = 'None' THEN 'No Social Media'
        ELSE 'Follows on Social Media' 
    END AS Social_Media_Status,
    AVG(f_pay.Amount) AS Average_Expenditure
FROM 
    FACT_PAYMENT f_pay
JOIN DIM_PERSON d_person ON f_pay.PersonKey = d_person.PersonKey
JOIN DIM_DATE d_date ON f_pay.DateKey = d_date.DateKey
GROUP BY 
    d_date.Year,
    Social_Media_Status
ORDER BY d_date.Year;

-- =========
-- QUERY 3: 
-- =========

SELECT 
    d_room.RoomType,
    d_room.HotelName,
    d_date.Month,
    SUM(f_room.RentalCount) AS Total_Rentals
FROM 
    FACT_ROOM_RENTAL f_room
JOIN DIM_ROOM d_room ON f_room.RoomKey = d_room.RoomKey
JOIN DIM_DATE d_date ON f_room.DateKey = d_date.DateKey
WHERE 
    d_date.Month IN (6, 7, 8) -- Peak Season
GROUP BY 
    d_room.RoomType,
    d_room.HotelName,
    d_date.Month
ORDER BY Total_Rentals DESC;

-- =========
-- QUERY 4: 
-- =========

SELECT 
    d_service.ServiceType,
    d_person.Age,
    SUM(f_service.RentalCount) AS Volume_Of_Rentals
FROM 
    FACT_SERVICE_RENTAL f_service
JOIN DIM_SPECIFIC_SERVICE d_service ON f_service.ServiceKey = d_service.ServiceKey
JOIN DIM_PERSON d_person ON f_service.PersonKey = d_person.PersonKey
GROUP BY 
    d_service.ServiceType,
    d_person.Age
ORDER BY Volume_Of_Rentals DESC;

-- =========
-- QUERY 5: 
-- =========

SELECT 
    CASE 
        WHEN d_promo.FreeAccess = TRUE THEN 'Free Access'
        ELSE 'Paid Standard' 
    END AS Access_Type,
    AVG(f_pool.Duration) AS Average_Pool_Minutes
FROM 
    FACT_POOL_RENTAL f_pool
JOIN DIM_SPECIAL_OFFER d_promo ON f_pool.SpecialOfferKey = d_promo.SpecialOfferKey
GROUP BY 
    d_promo.FreeAccess;

-- =========
-- QUERY 6: 
-- =========

WITH Room_Renters AS (
    SELECT DISTINCT PersonKey FROM FACT_ROOM_RENTAL
),
Service_Renters AS (
    SELECT DISTINCT PersonKey FROM FACT_SERVICE_RENTAL
)
SELECT 
    (SELECT COUNT(*) FROM Room_Renters JOIN Service_Renters USING (PersonKey)) * 100.0 / 
    (SELECT COUNT(*) FROM Room_Renters) AS Cross_Sell_Percentage;

-- =========
-- QUERY 7: 
-- =========

SELECT 
    d_promo.SocialMediaType,
    SUM(f_room.RentalCount) AS Total_Discounted_Rentals
FROM 
    FACT_ROOM_RENTAL f_room
JOIN DIM_SPECIAL_OFFER d_promo ON f_room.SpecialOfferKey = d_promo.SpecialOfferKey
WHERE 
    d_promo.DiscountPercentage > 0
GROUP BY 
    d_promo.SocialMediaType
ORDER BY Total_Discounted_Rentals DESC;

-- =========
-- QUERY 8: 
-- =========

SELECT 
    d_date.Quarter,
    d_promo.DiscountPercentage,
    SUM(f_service.RentalCount) AS Total_Service_Volume
FROM 
    FACT_SERVICE_RENTAL f_service
JOIN DIM_DATE d_date ON f_service.DateKey = d_date.DateKey
-- Note: Assuming SpecialOfferKey was added to Service Fact if exact revenue tracking was required
CROSS JOIN DIM_SPECIAL_OFFER d_promo -- Placeholder for cross-analysis
GROUP BY 
    d_date.Quarter,
    d_promo.DiscountPercentage
ORDER BY 
    d_date.Quarter, 
    Total_Service_Volume DESC;

-- =========
-- QUERY 9: 
-- =========

SELECT 
    d_resort.ResortName,
    d_stock.StockType,
    d_date.Year,
    SUM(f_inv.Amount) AS Total_Invested
FROM 
    FACT_INVESTMENT f_inv
JOIN DIM_RESORT d_resort ON f_inv.ResortKey = d_resort.ResortKey
JOIN DIM_STOCK_MARKET_TITLE d_stock ON f_inv.StockKey = d_stock.StockKey
JOIN DIM_DATE d_date ON f_inv.DateKey = d_date.DateKey
GROUP BY 
    d_resort.ResortName,
    d_stock.StockType,
    d_date.Year
ORDER BY Total_Invested DESC;

-- =========
-- QUERY 10: 
-- =========

SELECT 
    d_stock.StockType,
    d_date.Month,
    d_date.Year,
    AVG(f_price.Amount) AS Average_Monthly_Value,
    COUNT(f_price.IsChanged) AS Times_Fluctuated
FROM 
    FACT_STOCK_PRICE_HISTORY f_price
JOIN DIM_STOCK_MARKET_TITLE d_stock ON f_price.StockKey = d_stock.StockKey
JOIN DIM_DATE d_date ON f_price.DateKey = d_date.DateKey
GROUP BY 
    d_stock.StockType,
    d_date.Month,
    d_date.Year
ORDER BY 
    d_date.Year, 
    d_date.Month;


