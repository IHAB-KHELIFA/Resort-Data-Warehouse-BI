-- ==============================================================================
-- RESET BLOCK: Drop existing tables to prevent "Already Exists" errors
-- (Always drop Facts first, then Dimensions)
-- ==============================================================================

-- 1. Drop Facts (The Centers)
DROP TABLE IF EXISTS FACT_ROOM_RENTAL CASCADE;
DROP TABLE IF EXISTS FACT_PAYMENT CASCADE;
DROP TABLE IF EXISTS FACT_POOL_RENTAL CASCADE;
DROP TABLE IF EXISTS FACT_SERVICE_RENTAL CASCADE;
DROP TABLE IF EXISTS FACT_INVESTMENT CASCADE;
DROP TABLE IF EXISTS FACT_STOCK_PRICE_HISTORY CASCADE;

-- 2. Drop Dimensions (The Points)
DROP TABLE IF EXISTS DIM_DATE CASCADE;
DROP TABLE IF EXISTS DIM_PERSON CASCADE;
DROP TABLE IF EXISTS DIM_RESORT CASCADE;
DROP TABLE IF EXISTS DIM_SPECIAL_OFFER CASCADE;
DROP TABLE IF EXISTS DIM_ROOM CASCADE;
DROP TABLE IF EXISTS DIM_SWIMMING_POOL CASCADE;
DROP TABLE IF EXISTS DIM_SPECIFIC_SERVICE CASCADE;
DROP TABLE IF EXISTS DIM_STOCK_MARKET_TITLE CASCADE;

-- ------------------------------------------------------------------------------
-- PART 1: CREATE CONFORMED DIMENSIONS (Shared across multiple facts)
-- ------------------------------------------------------------------------------

-- 1. TIME DIMENSION (Used by all Facts)
CREATE TABLE DIM_DATE (
    DateKey INT PRIMARY KEY,
    FullDate DATE,
    Day INT,
    Month INT,
    Quarter INT,
    Year INT
);

-- 2. PERSON DIMENSION (Denormalized with Social Media for Payment tracking)
CREATE TABLE DIM_PERSON (
    PersonKey INT PRIMARY KEY,
    Age INT,
    Gender VARCHAR(20),
    SocialMediaType VARCHAR(50) -- Grafted from Social Media
);

-- 3. RESORT DIMENSION (Used directly by Payment and Investment)
CREATE TABLE DIM_RESORT (
    ResortKey INT PRIMARY KEY,
    ResortName VARCHAR(100)
);

-- 4. SPECIAL OFFER DIMENSION (Denormalized hierarchy with Social Media)
CREATE TABLE DIM_SPECIAL_OFFER (
    SpecialOfferKey INT PRIMARY KEY,
    DiscountPercentage DECIMAL(5,2),
    FreeAccess BOOLEAN,
    SocialMediaType VARCHAR(50)
);

-- ------------------------------------------------------------------------------
-- PART 2: CREATE SPECIFIC DIMENSIONS (With internal Snowflake hierarchies)
-- ------------------------------------------------------------------------------

-- 5. ROOM DIMENSION (Hierarchy: Room -> Hotel -> Resort)
CREATE TABLE DIM_ROOM (
    RoomKey INT PRIMARY KEY,
    RoomType VARCHAR(50),
    HotelName VARCHAR(100),
    ResortName VARCHAR(100)
);

-- 6. SWIMMING POOL DIMENSION (Hierarchy: Pool -> Resort)
CREATE TABLE DIM_SWIMMING_POOL (
    PoolKey INT PRIMARY KEY,
    PoolName VARCHAR(100),
    ResortName VARCHAR(100)
);

-- 7. SPECIFIC SERVICE DIMENSION (Hierarchy: Service -> Center -> Resort)
CREATE TABLE DIM_SPECIFIC_SERVICE (
    ServiceKey INT PRIMARY KEY,
    ServiceType VARCHAR(100),
    CenterName VARCHAR(100),
    ResortName VARCHAR(100)
);

-- 8. STOCK MARKET TITLE DIMENSION
CREATE TABLE DIM_STOCK_MARKET_TITLE (
    StockKey INT PRIMARY KEY,
    StockType VARCHAR(100)
);

-- ------------------------------------------------------------------------------
-- PART 3: CREATE FACT TABLES (The Centers of the Stars/Snowflakes)
-- ------------------------------------------------------------------------------

-- FACT 1: ROOM_RENTAL (Snowflake Schema)
CREATE TABLE FACT_ROOM_RENTAL (
    DateKey INT,
    PersonKey INT,
    RoomKey INT,
    SpecialOfferKey INT,
    
    -- Measures
    Period INT,
    RentalCount INT DEFAULT 1, 
    
    -- Constraints
    PRIMARY KEY (DateKey, PersonKey, RoomKey, SpecialOfferKey),
    FOREIGN KEY (DateKey) REFERENCES DIM_DATE(DateKey),
    FOREIGN KEY (PersonKey) REFERENCES DIM_PERSON(PersonKey),
    FOREIGN KEY (RoomKey) REFERENCES DIM_ROOM(RoomKey),
    FOREIGN KEY (SpecialOfferKey) REFERENCES DIM_SPECIAL_OFFER(SpecialOfferKey)
);

-- FACT 2: PAYMENT (Star Schema)
CREATE TABLE FACT_PAYMENT (
    DateKey INT,
    PersonKey INT,
    ResortKey INT,
    
    -- Measures
    Amount DECIMAL(15,2),
    
    -- Constraints
    PRIMARY KEY (DateKey, PersonKey, ResortKey),
    FOREIGN KEY (DateKey) REFERENCES DIM_DATE(DateKey),
    FOREIGN KEY (PersonKey) REFERENCES DIM_PERSON(PersonKey),
    FOREIGN KEY (ResortKey) REFERENCES DIM_RESORT(ResortKey)
);

-- FACT 3: POOL_RENTAL (Snowflake Schema)
CREATE TABLE FACT_POOL_RENTAL (
    DateKey INT,
    PersonKey INT,
    PoolKey INT,
    SpecialOfferKey INT,
    
    -- Measures
    Duration INT,
    RentalCount INT DEFAULT 1,
    
    -- Constraints
    PRIMARY KEY (DateKey, PersonKey, PoolKey, SpecialOfferKey),
    FOREIGN KEY (DateKey) REFERENCES DIM_DATE(DateKey),
    FOREIGN KEY (PersonKey) REFERENCES DIM_PERSON(PersonKey),
    FOREIGN KEY (PoolKey) REFERENCES DIM_SWIMMING_POOL(PoolKey),
    FOREIGN KEY (SpecialOfferKey) REFERENCES DIM_SPECIAL_OFFER(SpecialOfferKey)
);

-- FACT 4: SERVICE_RENTAL (Snowflake Schema)
CREATE TABLE FACT_SERVICE_RENTAL (
    DateKey INT,
    PersonKey INT,
    ServiceKey INT,
    
    -- Measures
    RentalCount INT DEFAULT 1,
    
    -- Constraints
    PRIMARY KEY (DateKey, PersonKey, ServiceKey),
    FOREIGN KEY (DateKey) REFERENCES DIM_DATE(DateKey),
    FOREIGN KEY (PersonKey) REFERENCES DIM_PERSON(PersonKey),
    FOREIGN KEY (ServiceKey) REFERENCES DIM_SPECIFIC_SERVICE(ServiceKey)
);

-- FACT 5: INVESTMENT (Star Schema)
CREATE TABLE FACT_INVESTMENT (
    DateKey INT,
    ResortKey INT,
    StockKey INT,
    
    -- Measures
    Amount DECIMAL(15,2),
    Duration INT,
    
    -- Constraints
    PRIMARY KEY (DateKey, ResortKey, StockKey),
    FOREIGN KEY (DateKey) REFERENCES DIM_DATE(DateKey),
    FOREIGN KEY (ResortKey) REFERENCES DIM_RESORT(ResortKey),
    FOREIGN KEY (StockKey) REFERENCES DIM_STOCK_MARKET_TITLE(StockKey)
);

-- FACT 6: STOCK_PRICE_HISTORY (Star Schema)
CREATE TABLE FACT_STOCK_PRICE_HISTORY (
    DateKey INT,
    StockKey INT,
    
    -- Degenerate Dimension / Attributes
    IsChanged BOOLEAN,
    
    -- Measures
    Amount DECIMAL(15,2),
    
    -- Constraints
    PRIMARY KEY (DateKey, StockKey),
    FOREIGN KEY (DateKey) REFERENCES DIM_DATE(DateKey),
    FOREIGN KEY (StockKey) REFERENCES DIM_STOCK_MARKET_TITLE(StockKey)
);