
-- --------------------------------------- // ZOMATO SALES ANALYTICS PROJECT // -----------------------------------------------
-- ---------------------------------------------------------------------------------------------------------------------------- 


USE PROJECTS ;

SELECT * FROM GOLD_USERS_SIGNUP ;
SELECT * FROM PRODUCT ; 
SELECT * FROM SALES ;
SELECT * FROM USERS ;

# adding primary & foreign keys to the tables for ER diagram 
alter table users add primary key(userid) ; -- primary key 
alter table product add primary key(product_id) ; -- primary key 
alter table sales add constraint fk_sales_users foreign key(userid) references users(userid) ; -- foreign key 
alter table sales add constraint fk_sales_product foreign key(product_id) references product(product_id) ; -- foreign key 
alter table gold_users_signup add constraint fk_goldusers_users foreign key(userid) references users(userid) ; -- foreign key  

SHOW CREATE TABLE users;
SHOW CREATE TABLE sales;
SHOW CREATE TABLE product;
SHOW CREATE TABLE gold_users_signup;

-- --------------------------------------------- / Objectives / ----------------------------------------------------------------- 


# Obj. 1- WHAT IS THE TOTAL AMOUNT EACH CUSTOMER SPENT ON ZOMATO ?

select distinct USERID FROM SALES ; 


# I method - explicitly counting the no of products
SELECT 
    S.USERID, SUM(P.PRICE * S.PRODUCT_ID_COUNT) AS AMNT_SPENT
FROM
    (SELECT 
        USERID, PRODUCT_ID, COUNT(PRODUCT_ID) AS PRODUCT_ID_COUNT
    FROM
        SALES
    GROUP BY USERID , PRODUCT_ID
    ORDER BY USERID , PRODUCT_ID) S
        JOIN
    PRODUCT AS P ON P.PRODUCT_ID = S.PRODUCT_ID
GROUP BY S.USERID
ORDER BY S.USERID;
-- -----------------------------------------------

# II method  
SELECT S.USERID, SUM(P.PRICE)AS TOTAL_AMT_SPENT 
FROM SALES AS S 
JOIN 
PRODUCT AS P
ON 
S.PRODUCT_ID= P.PRODUCT_ID 
group by S.USERID;

-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------


# Obj. 2- HOW MANY DAYS HAS EACH CUSTOMER VISITED ZOMATO ? 

SELECT * FROM SALES ;

# finding distinct date for each of the visit made by the customer 
SELECT USERID, count(CREATED_DATE) AS NUM_DAYS_VISITED 
FROM SALES 
group by USERID 
order by USERID ;

-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

# Obj. 3- WHAT WAS THE FIRST PRODUCT PURCHASED BY EACH CUSTOMER ?

# finding the corresponding date for the first product purchased by the customer 
SELECT S.USERID, S.CREATED_DATE AS PURCHASE_DATE, P.PRODUCT_NAME AS FIRST_PROD_PURCHASED
FROM 
	(
	SELECT *,
	row_number() OVER(partition by USERID order by CREATED_DATE) AS RN
	FROM SALES
	)S
JOIN
PRODUCT AS P
ON S.PRODUCT_ID= P.PRODUCT_ID 
WHERE S.RN=1 ; 


-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------


# Obj. 4

# (4-a) WHAT WAS THE MOST PURCHASED PRODUCT BY INDIVIDUAL CUSTOMER ? 


SELECT * FROM SALES ;

# most purchased product by individual customer 
SELECT A.*
FROM 
(
SELECT USERID, PRODUCT_ID, count(PRODUCT_ID)AS PRODUCT_COUNT,
-- CASE WHEN PRODUCT_COUNT=3 THEN RANK() over(partition by USERID)
RANK() OVER(partition by USERID order by count(PRODUCT_ID) DESC) RNK 
FROM 
SALES 
group by USERID, PRODUCT_ID
order by USERID, PRODUCT_ID
)A
WHERE A.RNK=1;


# (4-b) WHAT IS THE MOST PURCHASED ITEM ON THE MENU & HOW MANY TIMES WAS IT PURCHASED BY ALL CUSTOMERS ?
SELECT PRODUCT_ID, count(PRODUCT_ID)AS PRODUCT_COUNT
FROM 
SALES 
group by PRODUCT_ID
order by PRODUCT_COUNT DESC ; 

-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

# Obj. 5- WHICH PRODUCT WAS MOST POPULAR FOR EACH CUSTOMER ?
 
SELECT * FROM SALES ;

SELECT A.*
FROM 
	(
	SELECT USERID, PRODUCT_ID, count(PRODUCT_ID)AS PRODUCT_COUNT,
	-- CASE WHEN PRODUCT_COUNT=3 THEN RANK() over(partition by USERID)
	RANK() OVER(partition by USERID order by count(PRODUCT_ID) DESC) RNK 
	FROM 
	SALES 
	group by USERID, PRODUCT_ID
	order by USERID, PRODUCT_ID
	)A
WHERE A.RNK=1;


-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------


# Obj. 6- WHICH PRODUCT WAS PURCHASED FIRST BY THE CUSTOMER AFTER THEY BECAME A GOLD MEMBER ?

# sub-querying above query & ranking the date 
# retrieving the records for earliest date on the basis of highest rank
SELECT 
A.USERID, A.GOLD_SIGNUP_DATE, A.CREATED_DATE, A.PRODUCT_ID
FROM
	(
	SELECT X.*, RANK() over(partition by USERID order by CREATED_DATE ) AS RNK
	FROM 
		(
		SELECT GU.USERID, GU.GOLD_SIGNUP_DATE, S.CREATED_DATE, S.PRODUCT_ID 
		FROM 
		GOLD_USERS_SIGNUP AS GU 
		JOIN 
		SALES AS S 
		ON 
		GU.USERID=S.USERID
		AND 
		S.CREATED_DATE>=GU.GOLD_SIGNUP_DATE
		order by USERID 
		)X 
	)A
WHERE A.RNK=1 ;

-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

# Obj. 7-  WHICH PRODUCT WAS PURCHASED FIRST BY THE CUSTOMER BEFORE THEY BECAME A GOLD MEMBER ?

SELECT 
A.USERID, A.GOLD_SIGNUP_DATE, A.CREATED_DATE, A.PRODUCT_ID -- to retrieve records of highest rank
FROM
	(
	SELECT X.*, RANK() over(partition by USERID order by CREATED_DATE DESC) AS RNK 
	FROM 
		(
		SELECT GU.USERID, GU.GOLD_SIGNUP_DATE, S.CREATED_DATE, S.PRODUCT_ID 
		FROM 
		GOLD_USERS_SIGNUP AS GU 
		JOIN 
		SALES AS S 
		ON 
		GU.USERID=S.USERID
		AND 
		S.CREATED_DATE<=GU.GOLD_SIGNUP_DATE 
		order by USERID 
		)X 
	)A
WHERE A.RNK=1 ;

-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

# Obj. 8- WHAT IS THE TOTAL ORDERS & AMOUNT SPENT ON EACH CUSTOMER BEFORE THEY BECAME A MEMBER ? 

SELECT A.USERID, SUM(A.PRODUCT_ID) AS TOTAL_ORDERS, sum(A.PRICE) AS TOTAL_AMOUNT_SPENT
FROM 
	(
		SELECT S.USERID, S.PRODUCT_ID, P.PRICE, S.CREATED_DATE, GU.GOLD_SIGNUP_DATE 
		FROM SALES AS S
		JOIN GOLD_USERS_SIGNUP AS GU 
		ON S.USERID= GU.USERID 
		JOIN 
		PRODUCT AS P 
		ON S.PRODUCT_ID=P.PRODUCT_ID 
		WHERE S.CREATED_DATE<= GU.GOLD_SIGNUP_DATE
	)A
group by A.USERID
order by A.USERID ; 


-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------


# Obj. 9 - 
/* IF BUYING EACH PRODUCT GENERATES POINTS FOR EX- 5rs=2 zomato points 
& EACH PRODUCT HAS DIFFERENT PURCHASING POINTS FOR EX- 
FOR P1, 5rs=1 zomato point,
FOR P2, 10rs=5 zomato points & 
FOR P3, 5rs=1 zomato point , 
CALCULATE POINTS COLLECTED BY EACH CUSTOMER & FOR WHICH PRODUCT MOST POINTS HAVE BEEN GIVEN TILL NOW */  

# I part - for points collected by each customer
SELECT A.USERID,
sum(A.POINTS_EARNED)AS POINTS_EARNED_TILL_DATE
FROM
		(
			SELECT S.USERID, S.PRODUCT_ID, SUM(P.PRICE)AS TOTAL_PRICE,
			CASE WHEN S.PRODUCT_ID=1 THEN ROUND((SUM(P.PRICE)/5),0) 
				 WHEN S.PRODUCT_ID=2 THEN ROUND((SUM(P.PRICE)/2),0)
				 WHEN S.PRODUCT_ID=3 THEN ROUND((SUM(P.PRICE)/5),0)
				 END AS POINTS_EARNED	
			FROM SALES AS S
			JOIN PRODUCT AS P
			ON S.PRODUCT_ID= P.PRODUCT_ID
			group by S.USERID, S.PRODUCT_ID
		)A
group by A.USERID
order by A.USERID ; 

-- --------------------------------------------------

# II part - for product which has received highest reward points 

SELECT P.*
FROM
	(
		SELECT X.*,
		rank() over(partition by USERID order by X.POINTS_EARNED_TILL_DATE DESC)AS RNK
		FROM
			(
				SELECT A.USERID, A.PRODUCT_ID,
				sum(A.POINTS_EARNED)AS POINTS_EARNED_TILL_DATE
				-- rank() over(partition by USERID order by POINTS_EARNED_TILL_DATE DESC)AS RNK
				FROM
						(
							SELECT S.USERID, S.PRODUCT_ID, SUM(P.PRICE)AS TOTAL_PRICE,
							CASE WHEN S.PRODUCT_ID=1 THEN ROUND((SUM(P.PRICE)/5),0) 
								 WHEN S.PRODUCT_ID=2 THEN ROUND((SUM(P.PRICE)/2),0)
								 WHEN S.PRODUCT_ID=3 THEN ROUND((SUM(P.PRICE)/5),0)
								 END AS POINTS_EARNED	
							FROM SALES AS S
							JOIN PRODUCT AS P
							ON S.PRODUCT_ID= P.PRODUCT_ID
							group by S.USERID, S.PRODUCT_ID
						)A
				group by A.USERID, A.PRODUCT_ID
				order by A.USERID, A.PRODUCT_ID
			)X 
	 )P
WHERE P.RNK=1 ;


-- --------------------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------------------

# Obj. 10- 
/*IN THE FIRST YEAR AFTER A CUSTOMER JOINS THE GOLD PROGRAM(INCLUDING THE JOIN DATE) 
IRRESPECTIVE OF WHAT THE CUSTOMER HAS PURCHASED, THEY EARN 5 ZOMATO POINTS FOR 
EVERY 10 RS SPENT. 

WHO EARNED MORE 1 OR 3 & WHAT WAS THEIR EARNINGS IN THEIR FIRST YEAR ? */ 

# to find the total points earned 
# normalizing the cash points to unity 
SELECT X.*, ROUND(((X.PRICE)*0.5),0)AS TOTAL_POINTS_EARNED
FROM 
	(
		SELECT S.USERID, S.PRODUCT_ID, P.PRICE, S.CREATED_DATE, GU.GOLD_SIGNUP_DATE 
			FROM SALES AS S
			JOIN GOLD_USERS_SIGNUP AS GU 
			ON S.USERID= GU.USERID 
		JOIN 
			PRODUCT AS P
			ON S.PRODUCT_ID=P.PRODUCT_ID 
			WHERE CREATED_DATE>=GOLD_SIGNUP_DATE 
			AND CREATED_DATE<=date_add(GOLD_SIGNUP_DATE, INTERVAL 1 YEAR) 
			order by USERID, PRODUCT_ID 
	)X ; 

-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------

# Obj. 11 - RANK ALL THE TRANSACTIONS OF THE CUSTOMERS 

SELECT S.USERID,  S.PRODUCT_ID, P.PRICE, S.CREATED_DATE AS TRANSACTION_DATE,
rank() OVER(partition by USERID order by CREATED_DATE) AS TRANSACTION_RANK 
FROM SALES AS S 
JOIN 
PRODUCT AS P
ON S.PRODUCT_ID=P.PRODUCT_ID;  

-- --------------------------------------------------------------------------------------------------------------
-- --------------------------------------------------------------------------------------------------------------


# Obj. 12- 
/*RANK ALL THE TRANSACTIONS FOR EACH MEMBER WHEREVER THERE IS A GOLD MEMBER. 
AND FOR THE TRANSACTION OF EVERY NON-GOLD MEMBER, MARK AS 'NA' */


SELECT A.*, 
CASE WHEN A.GOLD_SIGNUP_DATE IS null THEN 'NA' ELSE rank() over(partition by A.USERID order by A.CREATED_DATE DESC) END AS MEMBERSHIP_STATUS
FROM 
	(
		SELECT S.USERID, S.PRODUCT_ID, S.CREATED_DATE, GU.GOLD_SIGNUP_DATE
		FROM SALES AS S
		LEFT JOIN 
		GOLD_USERS_SIGNUP AS GU 
		ON 
		S.USERID= GU.USERID
		AND CREATED_DATE>=GOLD_SIGNUP_DATE
	)A
 order by USERID ;