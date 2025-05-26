-- שימוש בדאטה ביס קיים 
USE  customer_personality_analysis; 
-- הצגת הטבלאות 
show  TABLES;
-- מחיקת טבלאות 
DROP table campaigns;
DROP table customer_value;
DROP table purchase_channels;
DROP table spending;
DROP table stg_marketing;
DROP table fact_customers;
-- הצגת טבלת mrr_marketing;
select * from mrr_marketing limit 10 ;
-- ספירה ובדיקת שורות 
select COUNT(*) from mrr_marketing;
-- מחקתי כי ראיתי שיש  שורות חסרות 
DROP table mrr_marketing;
-- הקמת טבלה מחדש
CREATE TABLE mrr_marketing(
    ID INT PRIMARY KEY,
  Year_Birth YEAR,
Education VARCHAR(50),
 Marital_Status VARCHAR(50),
    Income DECIMAL(10,2),
    Kidhome TINYINT,
Teenhome TINYINT,
Dt_Customer DATE,
 Recency INT,
 MntWines INT,
MntFruits INT,
MntMeatProducts INT,
MntFishProducts INT,
    MntSweetProducts INT,
 MntGoldProds INT,
NumDealsPurchases INT,
    NumWebPurchases INT,
NumCatalogPurchases INT,
NumStorePurchases INT,
NumWebVisitsMonth INT,
AcceptedCmp3 TINYINT,
 AcceptedCmp4 TINYINT,
    AcceptedCmp5 TINYINT,
    AcceptedCmp1 TINYINT,
    AcceptedCmp2 TINYINT,
 Complain TINYINT,
    Z_CostContact INT,
Z_Revenue INT,
 Response TINYINT
);
show tables;
SELECT * FROM mrr_marketing;
SHOW VARIABLES LIKE 'secure_file_priv';
-- עשיתי שינויים כי ראיתי שהטבלה שלי חסרה ויש בה 2216 במקום 2240
Alter table mrr_marketing
change column Dt_Customer  Dt_Customer varchar (50);
alter table mrr_marketing
change column Income Income varchar(50);
Alter table mrr_marketing
change column Year_Birth  Year_Birth INT;
-- לכן מחקתי את הקודמת ועשיתי ייבוא מחדש 
-- יבוא מחדש לדאטה 
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/Markiting data.csv'
INTO TABLE mrr_marketing
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS;
-- הצגת הטבלה 
SELECT * FROM mrr_marketing;
-- בדיקת מספר שורות 
SELECT COUNT(*) FROM mrr_marketing;
-- הקמת STG TABLE
-- מושכת כל הדאטה לטבלת ה STG
Create TABLE stg_marketing
select * from mrr_marketing;
show tables;
SElect * from stg_marketing limit 10;
-- ניקוי דאטה ושינוי שמות העמודות לשמות אינפורמטיביות 
Alter table stg_marketing
change column ID Customer_id int;
 -- יש לי 3 לקוחות עם תאריכים חריגים 
SELECT *
FROM stg_marketing
WHERE Year_Birth <= 1900
   OR Year_Birth > YEAR(CURDATE())
   OR Year_Birth IS NULL;

Alter table stg_marketing
change column Income Income int;
-- אני בודקת עמודתת INCOME
-- בדקתי ערכים חסרים ויצא לי 24 ערכים 
select 
count(*) as total_rows,
Sum(case when Income is null Then 1 Else 0 End) As null_count,
sum(case when Income = '' THEN 1 ELSE 0 END ) AS empty_string_count
from stg_marketing;

-- בודקת ממוצע של הערכים המלאים והתקנים
select avg(cast(Income as decimal (10,2))) into @AVG_Income
from stg_marketing
Where Income is not null
and Income <>'';

-- בדיקת הממוצע לסך הכל עמודת ההכנסות 
select @AVG_INCOME AS CALCULATED_AVERAGE;
-- מלוי לערכים החסרים ב ממצוע השכר שמצאתי 
update stg_marketing
set Income = @avg_income 
where Income is null
or Income = '';
-- ביטול מצב עידכון בטוח
SET SQL_SAFE_UPDATES = 0;
-- החזרת מצב עכון בטוח 
SET SQL_SAFE_UPDATES = 1;
select Income from stg_marketing limit 20;
-- ראיתי שהשורות שהתעדכנו ה 24 שורות 
-- בדיקת סה"כ שורות ב עמודת INCOME
 select count(Income) from stg_marketing;
-- קיבלתי שיש לי 2240 שורות 
show columns from stg_marketing;
-- שינוי סוג העמודה של ה INCOME
alter table stg_marketing
change column Income Income decimal(10,2);
-- בודקת WARNING
show warnings limit 10;

-- שינוי עוד שמות לעמודות 
ALTER TABLE stg_marketing
change column MntWines Amount_wines int;

Alter table stg_marketing
change column MntFruits Amount_fruits int;

Alter table stg_marketing
change column MntMeatProducts Amount_meat_products INT;

Alter table stg_marketing
change MntFishProducts Amount_fish_products int;

Alter table stg_marketing
change column MntSweetProducts Amount_sweet_products int;

Alter table stg_marketing
change column MntGoldProds Amount_premium_products Int;


ALTER table stg_marketing
change column Dt_Customer Customer_joining_date varchar(50);
SET SQL_SAFE_UPDATES = 0;
--  שיוני סוג העמודה 
UPDATE stg_marketing
SET customer_joining_date = DATE_FORMAT(STR_TO_DATE(customer_joining_date, '%d/%m/%Y'), '%Y-%m-%d')
WHERE Customer_joining_date LIKE '__/__/____';
UPDATE stg_marketing
SET customer_joining_date = DATE_FORMAT(STR_TO_DATE(customer_joining_date, '%d-%m-%Y'), '%Y-%m-%d')
WHERE Customer_joining_date LIKE '__-__-____';

describe stg_marketing;
-- שינוי סוג העמודה לתאריך 
ALTER TABLE stg_marketing
MODIFY COLUMN customer_joining_date DATE;
-- בדיקת כפוליות 
SELECT Customer_id,Year_Birth,Education,Marital_Status,Income,Kidhome,Teenhome,customer_joining_date,Recency,
 COUNT(*) as count
from stg_marketing 
group by Customer_id,Year_Birth,Education,Marital_Status,Income,Kidhome,Teenhome,customer_joining_date,Recency
HAVING COUNT(*) >1;
-- בדיקת ערכים חסרים 
SELECT 
  SUM(CASE WHEN Customer_id IS NULL THEN 1 ELSE 0 END) AS missing_Customer_id,
  SUM(CASE WHEN Year_Birth IS NULL THEN 1 ELSE 0 END) AS missing_Year_Birth,
  SUM(CASE WHEN Education IS NULL THEN 1 ELSE 0 END) AS missing_Education,
  SUM(CASE WHEN Marital_Status IS NULL THEN 1 ELSE 0 END) AS missing_Marital_Status,
  SUM(CASE WHEN Income IS NULL THEN 1 ELSE 0 END) AS missing_Income,
  SUM(CASE WHEN Kidhome IS NULL THEN 1 ELSE 0 END) AS missing_Kidhome,
  SUM(CASE WHEN Teenhome IS NULL THEN 1 ELSE 0 END) AS missing_Teenhome,
  SUM(CASE WHEN Customer_joining_date IS NULL THEN 1 ELSE 0 END) AS missing_Customer_joining_date,
  SUM(CASE WHEN Recency IS NULL THEN 1 ELSE 0 END) AS missing_Recency
FROM stg_marketing;
-- בדיקת ערכים שליליים 
SELECT *
FROM stg_marketing
WHERE Customer_id < 0
OR Year_Birth < 0
OR Income < 0
OR Kidhome < 0
OR Teenhome < 0
OR Recency < 0
OR Amount_wines <0
OR Amount_fruits <0
OR Amount_fish_products <0
OR Amount_sweet_products <0
OR Amount_premium_products < 0
OR NumDealsPurchases < 0
OR NumWebPurchases < 0
OR NumCatalogPurchases < 0
OR NumStorePurchases < 0
OR NumWebVisitsMonth < 0
OR AcceptedCmp1 < 0
OR AcceptedCmp2 < 0
OR AcceptedCmp3 < 0
OR AcceptedCmp4 < 0
OR AcceptedCmp5 < 0
OR Complain < 0
OR Z_CostContact < 0
OR Z_Revenue < 0
OR Response < 0;
 -- מחיקת עומודות 
 Alter  table stg_marketing
 DROP COLUMN Z_Revenue,
 DROP COLUMN Z_CostContact;
  -- הקמת טבלאות ממד 
  Create TABLE fact_Customers As 
Select
   Customer_id,
   Year_Birth ,
   Education ,
   Marital_status,
   Income ,
   Kidhome ,fact_customers
   Teenhome ,
   customer_joining_date,
   Recency
from stg_marketing;

Create Table dim_spending AS 
SELECT 
Customer_id,
Amount_wines,
Amount_fruits,
Amount_meat_products,
Amount_fish_products,
Amount_sweet_products,
Amount_premium_products
From stg_marketing;

Create Table dim_purchase_channels AS
Select
customer_id,
NumWebPurchases,
NumCatalogPurchases,
NumStorePurchases,
NumWebVisitsMonth
From stg_marketing;

Create Table Customer_value AS 
select
Customer_id,
Z_CostContact,
Z_Revenue
From stg_marketing;

RENAME TABLE customer_value
TO dim_customer_value;

Create Table dim_Campaigns AS
Select 
Customer_id,
NumDealsPurchases,
AcceptedCmp1,
AcceptedCmp2,
AcceptedCmp3,
AcceptedCmp4,
AcceptedCmp5,
Response
From stg_marketing;

show tables;
DROP TABLE dim_customer_value;
-- הוספת PK & FK לטבלאות הממד
ALTER TABLE fact_customers ADD primary key(customer_id);

ALTER TABLE dim_campaigns
ADD CONSTRAINT fk_customer_campaign
FOREIGN KEY (customer_id)
REFERENCES fact_customers(customer_id);

ALTER TABLE dim_spending
ADD CONSTRAINT fk_customer_spending
foreign key (customer_id)
references fact_customers(customer_id);

ALTER TABLE dim_customer_value
ADD CONSTRAINT fk_customer_customer_value
foreign key (customer_id)
references fact_customers(customer_id);


ALTER TABLE dim_purchase_channels
ADD CONSTRAINT fk_customer_purchase_channels
foreign key (customer_id)
references fact_customers(customer_id);

-- שמירת הדאטה לקובץ CSV
SELECT *
FROM stg_marketing
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/stg_marketing_export.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n';

