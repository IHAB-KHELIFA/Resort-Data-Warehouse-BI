-- ------------------------------------------------------------------------------
-- PHASE 1: POPULATE DIMENSIONS
-- ------------------------------------------------------------------------------

-- 1. DIM_DATE 
INSERT INTO DIM_DATE (DateKey, FullDate, Day, Month, Quarter, Year) VALUES 
(20240110, '2024-01-10', 10, 1, 1, 2024),
(20240214, '2024-02-14', 14, 2, 1, 2024),
(20240322, '2024-03-22', 22, 3, 1, 2024),
(20240505, '2024-05-05', 5, 5, 2, 2024),
(20240615, '2024-06-15', 15, 6, 2, 2024), -- Summer Peak
(20240720, '2024-07-20', 20, 7, 3, 2024), -- Summer Peak
(20240812, '2024-08-12', 12, 8, 3, 2024), -- Summer Peak
(20241010, '2024-10-10', 10, 10, 4, 2024),
(20241225, '2024-12-25', 25, 12, 4, 2024),
(20250105, '2025-01-05', 5, 1, 1, 2025),
(20250220, '2025-02-20', 20, 2, 1, 2025),
(20250412, '2025-04-12', 12, 4, 2, 2025),
(20250618, '2025-06-18', 18, 6, 2, 2025), -- Summer Peak
(20250722, '2025-07-22', 22, 7, 3, 2025), -- Summer Peak
(20250815, '2025-08-15', 15, 8, 3, 2025), -- Summer Peak
(20250905, '2025-09-05', 5, 9, 3, 2025),
(20251118, '2025-11-18', 18, 11, 4, 2025),
(20251231, '2025-12-31', 31, 12, 4, 2025),
(20260115, '2026-01-15', 15, 1, 1, 2026),
(20260228, '2026-02-28', 28, 2, 1, 2026),
(20260310, '2026-03-10', 10, 3, 1, 2026),
(20260420, '2026-04-20', 20, 4, 2, 2026),
(20260501, '2026-05-01', 1, 5, 2, 2026);

-- 2. DIM_PERSON 
INSERT INTO DIM_PERSON (PersonKey, Age, Gender, SocialMediaType) VALUES 
(1, 22, 'Female', 'Instagram'),  (2, 25, 'Male', 'TikTok'),       (3, 29, 'Female', 'Instagram'),
(4, 31, 'Male', 'Facebook'),     (5, 38, 'Female', 'Twitter'),    (6, 42, 'Male', 'None'),
(7, 48, 'Female', 'Facebook'),   (8, 55, 'Male', 'Twitter'),     (9, 61, 'Female', 'None'),
(10, 67, 'Male', 'None'),         (11, 19, 'Female', 'TikTok'),    (12, 27, 'Male', 'Instagram'),
(13, 34, 'Female', 'TikTok'),     (14, 40, 'Male', 'Facebook'),    (15, 45, 'Female', 'None'),
(16, 52, 'Male', 'Twitter'),     (17, 58, 'Female', 'Facebook'),  (18, 63, 'Male', 'None'),
(19, 71, 'Female', 'None'),       (20, 26, 'Male', 'Instagram');

-- 3. DIM_RESORT
INSERT INTO DIM_RESORT (ResortKey, ResortName) VALUES 
(10, 'Palermo Grand Resort'),
(20, 'Alpine Ski Lodge');

-- 4. DIM_SPECIAL_OFFER
INSERT INTO DIM_SPECIAL_OFFER (SpecialOfferKey, DiscountPercentage, FreeAccess, SocialMediaType) VALUES 
(0, 0.00, FALSE, 'None'),          
(1, 10.00, FALSE, 'Facebook'),    
(2, 15.00, FALSE, 'Instagram'),   
(3, 20.00, FALSE, 'Twitter'),
(4, 25.00, FALSE, 'TikTok'),
(5, 0.00, TRUE, 'Instagram');     -- Free Pool Access Promo

-- 5. DIM_ROOM 
INSERT INTO DIM_ROOM (RoomKey, RoomType, HotelName, ResortName) VALUES 
(101, 'Standard Single', 'Coastal Tower', 'Palermo Grand Resort'),
(102, 'Ocean View Suite', 'Coastal Tower', 'Palermo Grand Resort'),
(103, 'Deluxe Double', 'Marina Wing', 'Palermo Grand Resort'),
(104, 'Presidential Penthouse', 'Marina Wing', 'Palermo Grand Resort'),
(201, 'Standard Single', 'Peak Lodge', 'Alpine Ski Lodge'),
(202, 'Mountain Chalet', 'Peak Lodge', 'Alpine Ski Lodge'),
(203, 'Luxury Cabin', 'Forest Ridge', 'Alpine Ski Lodge'),
(204, 'Family Duplex', 'Forest Ridge', 'Alpine Ski Lodge');

-- 6. DIM_SWIMMING_POOL
INSERT INTO DIM_SWIMMING_POOL (PoolKey, PoolName, ResortName) VALUES 
(1, 'Infinity Sunset Pool', 'Palermo Grand Resort'),
(2, 'Indoor Heated Pool', 'Alpine Ski Lodge');

-- 7. DIM_SPECIFIC_SERVICE
INSERT INTO DIM_SPECIFIC_SERVICE (ServiceKey, ServiceType, CenterName, ResortName) VALUES 
(1, 'Deep Tissue Massage', 'Oasis Wellness Center', 'Palermo Grand Resort'),
(2, 'Finnish Sauna Session', 'Oasis Wellness Center', 'Palermo Grand Resort'),
(3, 'Hydrotherapy Bath', 'Oasis Wellness Center', 'Palermo Grand Resort'),
(4, 'Guided Ski Lesson', 'Alpine Sports Center', 'Alpine Ski Lodge'),
(5, 'Snowboard Rental Equipment', 'Alpine Sports Center', 'Alpine Ski Lodge');

-- 8. DIM_STOCK_MARKET_TITLE
INSERT INTO DIM_STOCK_MARKET_TITLE (StockKey, StockType) VALUES 
(1, 'Technology ETF'),
(2, 'Real Estate Trust'),
(3, 'Sustainable Energy Fund');


-- ------------------------------------------------------------------------------
-- PHASE 2: POPULATE FACTS 
-- ------------------------------------------------------------------------------

-- 1. FACT_ROOM_RENTAL (20 rows - lots of peak season summer months 6, 7, 8)
INSERT INTO FACT_ROOM_RENTAL VALUES 
(20240110, 4, 201, 0, 4, 1), (20240214, 12, 202, 2, 3, 1), (20240322, 15, 203, 0, 5, 1),
(20240505, 1, 101, 0, 2, 1), (20240615, 2, 102, 4, 7, 1), (20240720, 3, 103, 2, 10, 1),
(20240812, 7, 104, 1, 14, 1), (20241010, 16, 204, 3, 3, 1), (20241225, 18, 202, 0, 6, 1),
(20250105, 5, 203, 0, 4, 1), (20250220, 11, 201, 4, 2, 1), (20250412, 13, 101, 4, 3, 1),
(20250618, 14, 102, 1, 7, 1), (20250722, 20, 104, 2, 5, 1), (20250815, 6, 103, 0, 8, 1),
(20250905, 8, 101, 3, 4, 1), (20251118, 17, 204, 1, 3, 1), (20251231, 10, 202, 0, 5, 1),
(20260115, 19, 203, 0, 7, 1), (20260310, 9, 102, 0, 3, 1);

-- 2. FACT_PAYMENT (22 rows - creates a beautiful historical trajectory line)
INSERT INTO FACT_PAYMENT VALUES 
(20240110, 4, 20, 600.00),   (20240214, 12, 20, 1200.00), (20240322, 15, 20, 1750.00),
(20240505, 1, 10, 400.00),   (20240615, 2, 10, 2450.00),  (20240720, 3, 10, 3500.00),
(20240812, 7, 10, 7000.00),  (20241010, 16, 20, 1050.00), (20241225, 18, 20, 2100.00),
(20250105, 5, 20, 1600.00),  (20250220, 11, 20, 500.00),  (20250412, 13, 10, 750.00),
(20250618, 14, 10, 2200.00), (20250722, 20, 10, 4800.00), (20250815, 6, 10, 2400.00),
(20250905, 8, 10, 900.00),   (20251118, 17, 20, 1100.00), (20251231, 10, 20, 1800.00),
(20260115, 19, 20, 2800.00), (20260228, 2, 20, 350.00),   (20260310, 9, 10, 1050.00),
(20260420, 1, 10, 150.00);

-- 3. FACT_POOL_RENTAL 
INSERT INTO FACT_POOL_RENTAL VALUES 
(20240110, 4, 2, 0, 45, 1),  (20240505, 1, 1, 0, 60, 1),   (20240615, 2, 1, 5, 180, 1),
(20240720, 3, 1, 5, 120, 1), (20240812, 7, 1, 0, 90, 1),   (20241225, 18, 2, 0, 60, 1),
(20250105, 5, 2, 0, 45, 1),  (20250220, 11, 2, 4, 30, 1),  (20250412, 13, 1, 0, 75, 1), -- FIXED: Changed Pool 10 to Pool 1
(20250618, 14, 1, 1, 90, 1), (20250722, 20, 1, 5, 240, 1), (20250815, 6, 1, 0, 110, 1),
(20260115, 19, 2, 0, 40, 1), (20260228, 2, 2, 0, 55, 1),   (20260310, 9, 1, 0, 80, 1),
(20260420, 1, 1, 2, 100, 1), (20240615, 12, 1, 5, 150, 1), (20250722, 4, 1, 5, 200, 1),
(20250815, 11, 1, 5, 135, 1),(20260501, 13, 1, 0, 70, 1);

-- 4. FACT_SERVICE_RENTAL 
INSERT INTO FACT_SERVICE_RENTAL VALUES 
(20240110, 4, 4, 1),  (20240214, 12, 4, 2), (20240322, 15, 5, 1), (20240505, 1, 1, 1),
(20240615, 2, 2, 1),  (20240720, 3, 3, 1),  (20240812, 7, 1, 2),  (20241010, 16, 5, 1),
(20241225, 18, 4, 2), (20250105, 5, 4, 1),  (20250220, 11, 5, 1), (20250412, 13, 2, 1),
(20250618, 14, 1, 1), (20250722, 20, 3, 1), (20250815, 6, 2, 2),  (20250905, 8, 1, 1),
(20260115, 19, 5, 2), (20260228, 2, 4, 1),  (20260310, 9, 2, 1),  (20260420, 1, 3, 1);

-- 5. FACT_INVESTMENT 
INSERT INTO FACT_INVESTMENT VALUES 
(20240110, 20, 1, 50000.00, 180), (20240214, 20, 2, 75000.00, 365), (20240322, 20, 3, 60000.00, 365),
(20240505, 10, 1, 120000.00, 90),  (20240615, 10, 2, 90000.00, 180), (20240720, 10, 3, 110000.00, 365),
(20240812, 10, 1, 130000.00, 730), (20241010, 20, 2, 45000.00, 180), (20241225, 20, 3, 85000.00, 365),
(20250105, 20, 1, 55000.00, 180),  (20250220, 20, 2, 65000.00, 365), (20250412, 10, 3, 100000.00, 180),
(20250618, 10, 1, 140000.00, 365), (20250722, 10, 2, 95000.00, 365), (20250815, 10, 3, 105000.00, 730),
(20251118, 20, 1, 40000.00, 90),   (20251231, 20, 2, 70000.00, 180), (20260115, 20, 3, 95000.00, 365),
(20260310, 10, 1, 150000.00, 365), (20260420, 10, 2, 80000.00, 180);

-- 6. FACT_STOCK_PRICE_HISTORY 
INSERT INTO FACT_STOCK_PRICE_HISTORY VALUES 
(20240110, 1, TRUE, 300.50), (20240214, 1, TRUE, 305.20), (20240322, 1, TRUE, 312.00), (20240505, 1, TRUE, 308.50),
(20240615, 2, TRUE, 150.00), (20240720, 2, TRUE, 153.75), (20240812, 2, TRUE, 152.10), (20241010, 2, TRUE, 156.40),
(20241225, 3, TRUE, 98.25),  (20250105, 3, TRUE, 101.10), (20250220, 3, TRUE, 104.50), (20250412, 3, TRUE, 103.20),
(20250618, 1, TRUE, 325.40), (20250722, 1, TRUE, 331.10), (20250815, 1, TRUE, 335.00), (20251118, 2, TRUE, 161.20),
(20251231, 2, TRUE, 159.50), (20260115, 3, TRUE, 108.90), (20260310, 3, TRUE, 112.30), (20260420, 1, TRUE, 342.75);