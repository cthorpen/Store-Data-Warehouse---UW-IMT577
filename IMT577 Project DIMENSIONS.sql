USE WAREHOUSE IMT577_DW_COLE_THORPEN;
USE DATABASE IMT577_DB_COLE_THORPEN;



-- 1. CREATE DIM TABLE DIM_PRODUCT
CREATE OR REPLACE TABLE DIM_PRODUCT(
    DimProductID INT IDENTITY(1,1) CONSTRAINT PK_DimProductID PRIMARY KEY NOT NULL -- SURROGATE KEY
    ,ProductID INTEGER NOT NULL -- NATURAL KEY
    ,ProductTypeID INTEGER NOT NULL 
    ,ProductCategoryID INTEGER NOT NULL 
    ,ProductName VARCHAR(255) NOT NULL 
    ,ProductType VARCHAR(255) NOT NULL 
    ,ProductCategory VARCHAR(255) NOT NULL 
    ,ProductRetailPrice FLOAT NOT NULL 
    ,ProductWholesalePrice FLOAT NOT NULL 
    ,ProductCost FLOAT NOT NULL 
    ,ProductRetailProfit FLOAT NOT NULL 
    ,ProductWholesaleUnitProfit FLOAT NOT NULL 
    ,ProductProfitMarginUnitPercent FLOAT NOT NULL
);

-- LOAD UNKNOWN MEMBERS
INSERT INTO DIM_PRODUCT (
    DimProductID
    ,ProductID
    ,ProductTypeID
    ,ProductCategoryID
    ,ProductName
    ,ProductType
    ,ProductCategory
    ,ProductRetailPrice
    ,ProductWholesalePrice
    ,ProductCost
    ,ProductRetailProfit
    ,ProductWholesaleUnitProfit
    ,ProductProfitMarginUnitPercent
) VALUES (
    -1
    ,-1
    ,-1
    ,-1
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,-1.0
    ,-1.0
    ,-1.0
    ,-1.0
    ,-1.0
    ,-1.0
);

-- LOAD DATA
INSERT INTO DIM_PRODUCT (
    -- DimProductID
    ProductID
    ,ProductTypeID
    ,ProductCategoryID
    ,ProductName
    ,ProductType
    ,ProductCategory
    ,ProductRetailPrice
    ,ProductWholesalePrice
    ,ProductCost
    ,ProductRetailProfit
    ,ProductWholesaleUnitProfit
    ,ProductProfitMarginUnitPercent
)
    SELECT 
        -- VALUES HERE
        P.PRODUCTID AS ProductID
        ,PT.PRODUCTTYPEID AS ProductTypeID
        ,PC.PRODUCTCATEGORYID AS ProductCategoryID
        ,P.PRODUCT AS ProductName
        ,PT.PRODUCTTYPE AS ProductType
        ,PC.PRODUCTCATEGORY AS ProductCategory
        ,P.PRICE AS ProductRetailPrice
        ,P.WHOLESALEPRICE AS ProductWholesalePrice
        ,P.COST AS ProductCost
        ,(P.PRICE - P.COST) AS ProductRetailProfit
        ,(P.WHOLESALEPRICE - P.COST) AS ProductWholesaleUnitProfit
        ,((P.WHOLESALEPRICE - P.COST) / P.WHOLESALEPRICE) * 100 AS ProductProfitMarginUnitPercent
    FROM STAGE_PRODUCT P-- TABLES HERE
        INNER JOIN STAGE_PRODUCT_TYPE PT ON PT.PRODUCTTYPEID = P.PRODUCTTYPEID
        INNER JOIN STAGE_PRODUCT_CATEGORY PC ON PC.PRODUCTCATEGORYID = PT.PRODUCTCATEGORYID
    ;

-- SELECT (VALIDATE)
SELECT * FROM DIM_PRODUCT;



-- 2. CREATE DIM TABLE DIM_LOCATION 
CREATE OR REPLACE TABLE DIM_LOCATION(
    DimLocationID INT IDENTITY(1,1) CONSTRAINT PK_DimLocationID PRIMARY KEY NOT NULL -- SURROGATE KEY
    ,Address VARCHAR(255) NOT NULL 
    ,City VARCHAR(255) NOT NULL
    ,PostalCode VARCHAR(255) NOT NULL
    ,State_Province VARCHAR(255) NOT NULL
    ,Country VARCHAR(255) NOT NULL
);

-- LOAD UNKNOWN MEMBERS
INSERT INTO DIM_LOCATION (
    DimLocationID
    ,Address 
    ,City 
    ,PostalCode
    ,State_Province
    ,Country
) VALUES (
    -1
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
);

-- LOAD DATA
--  STORE LOCATION 
INSERT INTO DIM_LOCATION (
    -- DimLocationID
    Address
    ,City
    ,PostalCode
    ,State_Province
    ,Country
)
    SELECT 
        ADDRESS
        ,CITY
        ,POSTALCODE
        ,STATEPROVINCE
        ,COUNTRY
    FROM STAGE_STORE
    UNION 
    SELECT 
        ADDRESS
        ,CITY
        ,POSTALCODE
        ,STATEPROVINCE
        ,COUNTRY
    FROM STAGE_RESELLER
    UNION
    SELECT 
        ADDRESS
        ,CITY
        ,POSTALCODE
        ,STATEPROVINCE
        ,COUNTRY
    FROM STAGE_CUSTOMER;

-- SELECT (VALIDATE)
SELECT * FROM DIM_LOCATION;



-- 3. CREATE DIM TABLE DIM_CHANNEL
CREATE OR REPLACE TABLE DIM_CHANNEL(
    DimChannelID INT IDENTITY(1,1) CONSTRAINT PK_DimChannelID PRIMARY KEY NOT NULL -- SURROGATE KEY
    ,ChannelID INTEGER NOT NULL -- NATURAL KEY
    ,ChannelCategoryID INTEGER NOT NULL
    ,ChannelName VARCHAR(255) NOT NULL 
    ,ChannelCategory VARCHAR(255) NOT NULL
);

-- LOAD UNKNOWN MEMBERS
INSERT INTO DIM_CHANNEL (
    DimChannelID
    ,ChannelID
    ,ChannelCategoryID
    ,ChannelName
    ,ChannelCategory
) VALUES (
    -1
    ,-1
    ,-1
    ,'Unknown'
    ,'Unknown'
);

-- LOAD DATA
INSERT INTO DIM_CHANNEL (
    -- DimChannelID
    ChannelID
    ,ChannelCategoryID
    ,ChannelName
    ,ChannelCategory
) 
    SELECT
        C.CHANNELID AS ChannelID 
        ,CC.CHANNELCATEGORYID AS ChannelCategoryID
        ,C.CHANNEL AS ChannelName
        ,CC.CHANNELCATEGORY AS ChannelCategory 
    FROM STAGE_CHANNEL C
        INNER JOIN STAGE_CHANNEL_CATEGORY CC ON CC.CHANNELCATEGORYID = C.CHANNELCATEGORYID
    ;

-- SELECT (VALIDATE)
SELECT * FROM DIM_CHANNEL;



-- 4. CREATE DIM TABLE DIM_CUSTOMER
CREATE OR REPLACE TABLE DIM_CUSTOMER(
    DimCustomerID INT IDENTITY(1,1) CONSTRAINT PK_DimCustomerID PRIMARY KEY NOT NULL -- SURROGATE KEY
    ,DimLocationID INT FOREIGN KEY REFERENCES DIM_LOCATION(DimLocationID) NOT NULL -- FOREIGN KEY
    ,CustomerID VARCHAR(255) NOT NULL
    ,CustomerFullName VARCHAR(255) NOT NULL
    ,CustomerFirstName VARCHAR(255) NOT NULL
    ,CustomerLastName VARCHAR(255) NOT NULL
    ,CustomerGender VARCHAR(255) NOT NULL
);

-- LOAD UNKNOWN MEMBERS
INSERT INTO DIM_CUSTOMER(
    DimCustomerID
    ,DimLocationID
    ,CustomerID
    ,CustomerFullName
    ,CustomerFirstName
    ,CustomerLastName
    ,CustomerGender
) VALUES ( 
    -1
    ,-1
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
)

-- LOAD DATA
INSERT INTO DIM_CUSTOMER(
    -- DimCustomerID
    DimLocationID
    ,CustomerID
    ,CustomerFullName
    ,CustomerFirstName
    ,CustomerLastName
    ,CustomerGender
) 
    SELECT 
        L.DimLocationID AS DimLocationID
        ,C.CUSTOMERID AS CustomerID
        ,CONCAT(C.FIRSTNAME, ' ', C.LASTNAME) AS CustomerFullName
        ,C.FIRSTNAME AS CustomerFirstName
        ,C.LASTNAME AS CustomerLastName
        ,C.GENDER AS CustomerGender
    FROM STAGE_CUSTOMER C
        INNER JOIN DIM_LOCATION L ON L.ADDRESS = C.ADDRESS 
            AND L.CITY = C.CITY
            AND L.POSTALCODE = C.POSTALCODE
            AND L.STATE_PROVINCE = C.STATEPROVINCE
            AND L.COUNTRY = C.COUNTRY     
    ;

-- SELECT (VALIDATE)
SELECT * FROM DIM_CUSTOMER;

-- 5. CREATE DIM TABLE DIM_STORE
CREATE OR REPLACE TABLE DIM_STORE(
    DimStoreID INT IDENTITY(1,1) CONSTRAINT PK_DimStoreID PRIMARY KEY NOT NULL -- SURROGATE KEY
    ,DimLocationID INT FOREIGN KEY REFERENCES DIM_LOCATION(DimLocationID) NOT NULL -- FOREIGN KEY
    ,SourceStoreID INT NOT NULL 
    ,StoreName VARCHAR(255) NOT NULL
    ,StoreNumber INTEGER NOT NULL 
    ,StoreManager VARCHAR(255) NOT NULL
);

-- LOAD UNKNOWN MEMBERS
INSERT INTO DIM_STORE(
    DimStoreID
    ,DimLocationID
    ,SourceStoreID
    ,StoreName
    ,StoreNumber
    ,StoreManager
) VALUES (
    -1
    ,-1
    ,-1
    ,'Unknown'
    ,-1
    ,'Unknown'
);

-- LOAD DATA
INSERT INTO DIM_STORE(
    -- DimStoreID
    DimLocationID
    ,SourceStoreID
    ,StoreName
    ,StoreNumber
    ,StoreManager
)
    SELECT
        L.DimLocationID AS DimLocationID
        ,S.STOREID AS SourceStoreID
        ,CONCAT('Store Number', ' ', S.STORENUMBER) AS StoreName
        ,S.STORENUMBER AS StoreNumber 
        ,S.STOREMANAGER AS StoreManager 
    FROM STAGE_STORE S 
        INNER JOIN DIM_LOCATION L ON L.ADDRESS = S.ADDRESS 
            AND L.CITY = S.CITY
            AND L.POSTALCODE = S.POSTALCODE
            AND L.STATE_PROVINCE = S.STATEPROVINCE
            AND L.COUNTRY = S.COUNTRY     
    ;

-- SELECT (VALIDATE)
SELECT * FROM DIM_STORE;



-- 6. CREATE DIM TABLE DIM_RESELLER
CREATE OR REPLACE TABLE DIM_RESELLER(
    DimResellerID INT IDENTITY(1,1) CONSTRAINT PK_DimResellerID PRIMARY KEY NOT NULL -- SURROGATE KEY
    ,DimLocationID INT FOREIGN KEY REFERENCES DIM_LOCATION(DimLocationID) NOT NULL -- FOREIGN KEY
    ,ResellerID VARCHAR(255) NOT NULL
    ,ResellerName VARCHAR(255) NOT NULL
    ,ContactName VARCHAR(255) NOT NULL
    ,PhoneNumber VARCHAR(255) NOT NULL
    ,Email VARCHAR(255) NOT NULL
);

-- LOAD UNKNOWN MEMBERS
INSERT INTO DIM_RESELLER(
    DimResellerID
    ,DimLocationID
    ,ResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email 
) VALUES (
    -1
    ,-1
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
    ,'Unknown'
);

-- LOAD DATA
INSERT INTO DIM_RESELLER(
    DimLocationID
    ,ResellerID
    ,ResellerName
    ,ContactName
    ,PhoneNumber
    ,Email 
)
    SELECT
        L.DimLocationID AS DimLocationID
        ,R.RESELLERID AS ResellerID 
        ,R.RESELLERNAME AS ResellerName 
        ,R.CONTACT AS ContactName
        ,R.PHONENUMBER AS PhoneNumber 
        ,R.EMAILADDRESS AS Email 
    FROM STAGE_RESELLER R 
        INNER JOIN DIM_LOCATION L ON L.ADDRESS = R.ADDRESS 
            AND L.CITY = R.CITY
            AND L.POSTALCODE = R.POSTALCODE
            AND L.STATE_PROVINCE = R.STATEPROVINCE
            AND L.COUNTRY = R.COUNTRY  
    ;


-- SELECT (VALIDATE)
SELECT * FROM DIM_RESELLER;

