-- =====================================
-- SECTION : Inspect restaurants table
-- =====================================

SELECT *
FROM restaurants
LIMIT 10;



-- =====================================
-- SECTION : Inspect rschema table
-- =====================================
SELECT name
FROM sqlite_master
WHERE type = 'table';
PRAGMA table_info(locations);
PRAGMA table_info(restaurants);
PRAGMA table_info(locations_to_restaurants);
PRAGMA table_info(menuItems);
PRAGMA table_info(categories);
PRAGMA table_info(categories_restaurants);


SELECT
    m.name AS table_name,
    p.name AS column_name,
    p.type AS data_type
FROM sqlite_master m
JOIN pragma_table_info(m.name) p
WHERE m.type = 'table'
ORDER BY m.name, p.cid;



-- =====================================
-- 1. What is the price distribution of menu items?
-- =====================================

-- exploration query

SELECT
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM menuItems;

-- my codses for this exercise 

SELECT
    CASE
        WHEN price >= 0  AND price < 5   THEN '0-5'
        WHEN price >= 5  AND price < 10  THEN '5-10'
        WHEN price >= 10 AND price < 20  THEN '10-20'
        WHEN price >= 20 AND price < 40  THEN '20-40'
        WHEN price >= 40 AND price < 80  THEN '40-80'
        ELSE '80-150'
    END AS price_range,
    COUNT(*) AS item_count
FROM menuItems
WHERE price IS NOT NULL
GROUP BY price_range
ORDER BY
    CASE price_range
        WHEN '0-5'    THEN 1
        WHEN '5-10'   THEN 2
        WHEN '10-20'  THEN 3
        WHEN '20-40'  THEN 4
        WHEN '40-80'  THEN 5
        WHEN '80-150' THEN 6
    END;




SELECT
    CASE
        WHEN price < 5 THEN '0-5'
        WHEN price >= 5 AND price < 10 THEN '5-10'
        WHEN price >= 10 AND price < 15 THEN '10-15'
        ELSE '15+'
    END AS price_range,
    COUNT(*) AS item_count
FROM menuitems
WHERE price IS NOT NULL
GROUP BY price_range
ORDER BY item_count DESC;

-- ===========this can be visualized as a bar chart=============


-- =====================================
-- 2. What is the distribution of restaurants per location?
-- =====================================

SELECT
    locations.city,
    COUNT(DISTINCT restaurants.restaurant_id) AS restaurant_count
FROM locations
JOIN locations_to_restaurants
    ON locations.ID = locations_to_restaurants.location_id
JOIN restaurants
    ON locations_to_restaurants.restaurant_id = restaurants.primarySlug
GROUP BY locations.city
ORDER BY restaurant_count DESC;

-- ===========are the cities correct? Ghent and Zwijnaarde, same?=============




-- =====================================
3. Which are the top 10 pizza restaurants by rating?
-- =====================================

-- exploration query
SELECT
    COUNT(*) AS total_rows,
    COUNT(ratings) AS non_null_ratings,
    COUNT(*) - COUNT(ratings) AS null_ratings
FROM restaurants;

PRAGMA table_info(restaurants);
PRAGMA table_info(categories);

SELECT *
FROM menuItems
WHERE LOWER(menuItems.name) LIKE '%pizza%'
LIMIT 100;

SELECT *
FROM lo
WHERE LOWER(menuItems.name) LIKE '%pizza%'
LIMIT 100;

-- code to get top 10 pizza restaurants by rating

SELECT DISTINCT
    restaurants.name AS restaurant_name,
    restaurants.city,
    restaurants.ratings
FROM restaurants
JOIN categories
    ON restaurants.primarySlug = categories.restaurant_id
JOIN menuItems
    ON categories.item_id = menuItems.id
WHERE
    restaurants.ratings IS NOT NULL
    AND LOWER(menuItems.name) LIKE '%pizza%'
ORDER BY restaurants.ratings DESC
LIMIT 10;


-- ===========these restaurants are not necessarily pizza restaurants=============


-- =====================================
4. Map locations offering kapsalons (or your favorite dish) and their average price.
-- =====================================

-- To explore the connections and make sure that restaurant_id in different tables= primarySlug in restaurants table

SELECT name, price
FROM menuItems

SELECT DISTINCT
    categories_restaurants.restaurant_id
FROM categories_restaurants
LEFT JOIN restaurants
    ON categories_restaurants.restaurant_id = restaurants.primarySlug
WHERE restaurants.primarySlug IS NULL
LIMIT 20;



SELECT DISTINCT
    categories.restaurant_id
FROM categories
LEFT JOIN restaurants
    ON categories.restaurant_id = restaurants.primarySlug
WHERE restaurants.primarySlug IS NULL
LIMIT 20;


SELECT DISTINCT restaurant_id
FROM categories;


-- my codes for 4. (one with lattitude and longitude, one without)
SELECT
    locations.city,
    locations.latitude,
    locations.longitude,
    AVG(menuItems.price) AS average_burger_price,
    COUNT(DISTINCT restaurants.primarySlug) AS number_of_burger_restaurants
FROM restaurants
JOIN categories
    ON restaurants.primarySlug = categories.restaurant_id
JOIN menuItems
    ON categories.item_id = menuItems.id
JOIN locations_to_restaurants
    ON restaurants.primarySlug = locations_to_restaurants.restaurant_id
JOIN locations
    ON locations_to_restaurants.location_id = locations.ID
WHERE
    LOWER(categories.name) LIKE '%burger%'
    AND menuItems.price IS NOT NULL
GROUP BY
    locations.city,
    locations.latitude,
    locations.longitude
ORDER BY
    average_burger_price DESC;



    SELECT
    locations.city,
    AVG(menuItems.price) AS average_burger_price,
    COUNT(DISTINCT restaurants.primarySlug) AS number_of_burger_restaurants
FROM restaurants
JOIN categories
    ON restaurants.primarySlug = categories.restaurant_id
JOIN menuItems
    ON categories.item_id = menuItems.id
JOIN locations_to_restaurants
    ON restaurants.primarySlug = locations_to_restaurants.restaurant_id
JOIN locations
    ON locations_to_restaurants.location_id = locations.ID
WHERE
    LOWER(categories.name) LIKE '%burger%'
    AND menuItems.price IS NOT NULL
GROUP BY
    locations.city
ORDER BY
    average_burger_price DESC;


SELECT *
FROM menuItems
LIMIT 10;



-- =====================================
open-ended Question: 1. Which restaurants have the best price-to-rating ratio?
-- =====================================

-------------- my code without limitting ratingsNumber to 25 and more
SELECT
    restaurants.name AS restaurant_name,
    restaurants.city,
    restaurants.ratings,
    AVG(menuItems.price) AS average_menu_price,
    AVG(menuItems.price) / restaurants.ratings AS price_to_rating_ratio
FROM restaurants
JOIN categories
    ON restaurants.primarySlug = categories.restaurant_id
JOIN menuItems
    ON categories.item_id = menuItems.id
WHERE
    restaurants.ratings IS NOT NULL
    AND restaurants.ratings > 0
    AND menuItems.price IS NOT NULL
GROUP BY
    restaurants.name,
    restaurants.city,
    restaurants.ratings
ORDER BY price_to_rating_ratio ASC
LIMIT 10;



----(selected code)---- my code with limitting ratingsNumber to 25 and more
-----This code includes both drinks and all food types

----- 
-- Purpose:
-- Calculate a value-for-money metric for restaurants based on
-- average menu price relative to customer rating.

-- Method:
-- 1. Join restaurants to menu items via the categories table.
-- 2. Aggregate menu item prices at restaurant level.
-- 3. Compute price_to_rating_ratio = AVG(menuItems.price) / restaurants.ratings.

-- Assumptions:
-- - Average menu item price represents restaurant price level.
-- - Ratings are reliable only when supported by sufficient reviews.
-- - Zero or NULL prices do not represent real consumer costs.

-- Filters applied:
-- - Exclude restaurants without ratings or with zero ratings.
-- - Include only restaurants with at least 25 reviews.
-- - Exclude menu items with NULL prices.
-- - Exclude restaurants with zero average menu price.

-- Result:
-- Returns the top 10 restaurants with the lowest price-to-rating ratio,
-- indicating best value for money.
---------

SELECT
    restaurants.name AS restaurant_name,
    restaurants.city,
    restaurants.ratings,
    restaurants.ratingsNumber,
    AVG(menuItems.price) AS average_menu_price,
    AVG(menuItems.price) / restaurants.ratings AS price_to_rating_ratio
FROM restaurants
JOIN categories
    ON restaurants.primarySlug = categories.restaurant_id
JOIN menuItems
    ON categories.item_id = menuItems.id
WHERE
    restaurants.ratings IS NOT NULL
    AND restaurants.ratings > 0
    AND restaurants.ratingsNumber >= 25
    AND menuItems.price IS NOT NULL
GROUP BY
    restaurants.name,
    restaurants.city,
    restaurants.ratings,
    restaurants.ratingsNumber
HAVING
    AVG(menuItems.price) > 0
ORDER BY price_to_rating_ratio ASC
LIMIT 10;



-------------- my code with addiing postal code ( here then 
-- it gives repeated names for same restaurant in different locations- so not very useful)
--but at least we can see different locations)


SELECT
    restaurants.name AS restaurant_name,
    restaurants.city,
    locations.postalCode,
    restaurants.ratings,
    restaurants.ratingsNumber,
    AVG(menuItems.price) AS average_menu_price,
    AVG(menuItems.price) / restaurants.ratings AS price_to_rating_ratio
FROM restaurants
JOIN categories
    ON restaurants.primarySlug = categories.restaurant_id
JOIN menuItems
    ON categories.item_id = menuItems.id
JOIN locations_to_restaurants
    ON restaurants.primarySlug = locations_to_restaurants.restaurant_id
JOIN locations
    ON locations_to_restaurants.location_id = locations.ID
WHERE
    restaurants.ratings IS NOT NULL
    AND restaurants.ratings > 0
    AND restaurants.ratingsNumber >= 25
    AND menuItems.price IS NOT NULL
GROUP BY
    restaurants.name,
    restaurants.city,
    locations.postalCode,
    restaurants.ratings,
    restaurants.ratingsNumber
HAVING
    AVG(menuItems.price) > 0
ORDER BY price_to_rating_ratio ASC
LIMIT 10;



-------------- the selected code with addiing restuarant category 
--------------- but strange category names-so not very useful 
SELECT
    restaurants.name AS restaurant_name,
    restaurants.city,
    categories.name AS category_name,
    restaurants.ratings,
    restaurants.ratingsNumber,
    AVG(menuItems.price) AS average_menu_price,
    AVG(menuItems.price) / restaurants.ratings AS price_to_rating_ratio
FROM restaurants
JOIN categories
    ON restaurants.primarySlug = categories.restaurant_id
JOIN menuItems
    ON categories.item_id = menuItems.id
WHERE
    restaurants.ratings IS NOT NULL
    AND restaurants.ratings > 0
    AND restaurants.ratingsNumber >= 25
    AND menuItems.price IS NOT NULL
GROUP BY
    restaurants.name,
    restaurants.city,
    categories.name,
    restaurants.ratings,
    restaurants.ratingsNumber
ORDER BY price_to_rating_ratio ASC
LIMIT 10;




-- =====================================
--oe 2. Where are the delivery 'dead zones'—areas with minimal restaurant coverage?
-- =====================================

---------------exploration queries--------------
SELECT
    l.city,
    l.postalCode,
    COUNT(DISTINCT r.primarySlug) AS restaurant_count
FROM locations l
JOIN locations_to_restaurants lr
    ON l.ID = lr.location_id
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city,
    l.postalCode
ORDER BY
    restaurant_count ASC,
    l.city,
    l.postalCode;


SELECT
    l.city,
    l.postalCode,
    COUNT(DISTINCT r.primarySlug) AS restaurant_count
FROM locations l
LEFT JOIN locations_to_restaurants lr
    ON l.ID = lr.location_id
LEFT JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city,
    l.postalCode
ORDER BY
    restaurant_count ASC,  -- shows areas with fewest restaurants first
    l.city,
    l.postalCode;



---- counting the number of postcodes per city to infere which city is big or samll
    SELECT
    l.city,
    COUNT(DISTINCT l.postalCode) AS num_postal_codes,
    COUNT(DISTINCT r.primarySlug) AS total_restaurants
FROM locations l
JOIN locations_to_restaurants lr
    ON l.ID = lr.location_id
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city
ORDER BY
    total_restaurants DESC;


---orderd vesion
SELECT
    l.city,
    COUNT(DISTINCT l.postalCode) AS num_postal_codes,
    COUNT(DISTINCT r.primarySlug) AS total_restaurants
FROM locations l
JOIN locations_to_restaurants lr
    ON l.ID = lr.location_id
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city
ORDER BY
    num_postal_codes DESC,
    total_restaurants DESC;  -- optional secondary sort


------ added the number of restaurants per postcode
SELECT
    l.city,
    COUNT(DISTINCT l.postalCode) AS num_postal_codes,
    COUNT(DISTINCT r.primarySlug) AS total_restaurants,
    GROUP_CONCAT(postcode_restaurants.num_restaurants) AS restaurants_per_postcode
FROM locations l
JOIN locations_to_restaurants lr
    ON l.ID = lr.location_id
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
JOIN (
    SELECT
        l2.postalCode,
        COUNT(DISTINCT lr2.restaurant_id) AS num_restaurants
    FROM locations l2
    JOIN locations_to_restaurants lr2
        ON l2.ID = lr2.location_id
    GROUP BY l2.postalCode
) AS postcode_restaurants
    ON l.postalCode = postcode_restaurants.postalCode
GROUP BY
    l.city
ORDER BY
    num_postal_codes DESC,
    total_restaurants DESC;

    
    
    
    ---------------- final code 
-- Purpose:
-- Identify postal codes with minimal restaurant coverage (delivery dead zones).

-- Method:
-- 1. Start from locations and LEFT JOIN locations_to_restaurants and restaurants.
-- 2. Count distinct restaurants per city and postal code.

-- Filters:
-- - Exclude invalid postal codes (NULL or 0).
-- - Include only postal codes with ≤ 1 restaurant.

-- Result:
-- Returns postal codes with the fewest restaurants, highlighting areas with poor coverage.


--- Find delivery dead zones: postal codes with minimal restaurant coverage

SELECT
    l.city,
    l.postalCode,
    COUNT(DISTINCT r.primarySlug) AS restaurant_count
FROM locations l
LEFT JOIN locations_to_restaurants lr
    ON l.ID = lr.location_id
LEFT JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
WHERE l.postalCode IS NOT NULL
  AND l.postalCode != 0  -- exclude invalid postal codes
GROUP BY
    l.city,
    l.postalCode
HAVING
    restaurant_count <= 1  -- postal codes with minimal coverage
ORDER BY
    restaurant_count ASC,
    l.city,
    l.postalCode;

    ---to answer this question we nned to consider also size of every postcode and poulation 
    ---- in that speciifc postcode to anser this question more realisticlay and anwser the 
    ---- question where we might open restaurants or have delivery services.




-- =====================================
--oe 3. How does the availability of vegetarian and vegan dishes vary by area?
-- =====================================

-------------- exploration queries--------------

-- to see which relevant names are used for vegerarian and vegan-------
SELECT DISTINCT
    name
FROM categories
WHERE name LIKE '%vegan%'
   OR name LIKE '%vegetarian%'
ORDER BY name ASC;
 ---results: identificataion 
 -- vegetarian/ USED NAMES LIKE 'vegetarian', vegetarisch, veggies, vegetariana, veggi, veggie
 --vegan only vegan
 --have non vegan

 ----------- code to answer the question----------
 SELECT
    l.city,
    l.postalCode,
    COUNT(DISTINCT CASE 
        WHEN LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%' THEN r.primarySlug
    END) AS vegan_restaurants,
    COUNT(DISTINCT CASE 
        WHEN (LOWER(c.name) LIKE '%vegetarian%' 
              OR LOWER(c.name) LIKE '%vegetarisch%' 
              OR LOWER(c.name) LIKE '%veggies%' 
              OR LOWER(c.name) LIKE '%vegetariana%' 
              OR LOWER(c.name) LIKE '%veggi%' 
              OR LOWER(c.name) LIKE '%veggie%') 
         AND LOWER(c.name) NOT LIKE '%non vegan%' THEN r.primarySlug
    END) AS vegetarian_restaurants,
    COUNT(DISTINCT CASE 
        WHEN LOWER(c.name) LIKE '%veg/%' THEN r.primarySlug
    END) AS veg_and_vegan_restaurants
FROM categories c
JOIN locations_to_restaurants lr
    ON c.restaurant_id = lr.restaurant_id
JOIN locations l
    ON lr.location_id = l.ID
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city,
    l.postalCode
ORDER BY
    l.city,
    l.postalCode;



    --------selected code-----2nd code: change o name of the columns,
    ---omitting the last column andadding one calculating bothe columns
    --ordering 
    SELECT
    l.city,
    l.postalCode,
    COUNT(DISTINCT CASE 
        WHEN LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%' 
        THEN r.primarySlug
    END) AS restaurants_offering_vegan,
    COUNT(DISTINCT CASE 
        WHEN (LOWER(c.name) LIKE '%vegetarian%' 
              OR LOWER(c.name) LIKE '%vegetarisch%' 
              OR LOWER(c.name) LIKE '%veggies%' 
              OR LOWER(c.name) LIKE '%vegetariana%' 
              OR LOWER(c.name) LIKE '%veggi%' 
              OR LOWER(c.name) LIKE '%veggie%') 
         AND LOWER(c.name) NOT LIKE '%non vegan%' 
        THEN r.primarySlug
    END) AS restaurants_offering_vegetarian,
    COUNT(DISTINCT CASE 
        WHEN (LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%')
          OR (LOWER(c.name) LIKE '%vegetarian%' 
              OR LOWER(c.name) LIKE '%vegetarisch%' 
              OR LOWER(c.name) LIKE '%veggies%' 
              OR LOWER(c.name) LIKE '%vegetariana%' 
              OR LOWER(c.name) LIKE '%veggi%' 
              OR LOWER(c.name) LIKE '%veggie%') 
        THEN r.primarySlug
    END) AS restaurants_offering_vegan_or_vegetarian
FROM categories c
JOIN locations_to_restaurants lr
    ON c.restaurant_id = lr.restaurant_id
JOIN locations l
    ON lr.location_id = l.ID
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city,
    l.postalCode
ORDER BY
    restaurants_offering_vegan_or_vegetarian DESC,
    l.city,
    l.postalCode;


-------- we can also searchwhich postcodes have less and
offer those restaurants to add vegan or veggie to their menuItems 
SELECT
    l.city,
    l.postalCode,
    COUNT(DISTINCT CASE 
        WHEN (LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%')
          OR (LOWER(c.name) LIKE '%vegetarian%' 
              OR LOWER(c.name) LIKE '%vegetarisch%' 
              OR LOWER(c.name) LIKE '%veggies%' 
              OR LOWER(c.name) LIKE '%vegetariana%' 
              OR LOWER(c.name) LIKE '%veggi%' 
              OR LOWER(c.name) LIKE '%veggie%') 
        THEN r.primarySlug
    END) AS restaurants_offering_vegan_or_vegetarian
FROM categories c
JOIN locations_to_restaurants lr
    ON c.restaurant_id = lr.restaurant_id
JOIN locations l
    ON lr.location_id = l.ID
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city,
    l.postalCode
HAVING
    restaurants_offering_vegan_or_vegetarian = 0
ORDER BY
    l.city,
    l.postalCode;


    --------- again one more step: how many reatarnats are there in the 
    --postcodes that they dont offer veggie

    ----- good code: shows how many restaurant are there but dont offer vieggie or vegan and vegan
    -- s we can offer them to have 
    SELECT
    l.city,
    l.postalCode,
    COUNT(DISTINCT r.primarySlug) AS total_restaurants,
    COUNT(DISTINCT CASE 
        WHEN (LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%')
          OR (LOWER(c.name) LIKE '%vegetarian%' 
              OR LOWER(c.name) LIKE '%vegetarisch%' 
              OR LOWER(c.name) LIKE '%veggies%' 
              OR LOWER(c.name) LIKE '%vegetariana%' 
              OR LOWER(c.name) LIKE '%veggi%' 
              OR LOWER(c.name) LIKE '%veggie%') 
        THEN r.primarySlug
    END) AS restaurants_offering_vegan_or_vegetarian
FROM categories c
JOIN locations_to_restaurants lr
    ON c.restaurant_id = lr.restaurant_id
JOIN locations l
    ON lr.location_id = l.ID
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city,
    l.postalCode
HAVING
    restaurants_offering_vegan_or_vegetarian = 0
ORDER BY
    total_restaurants DESC,
    l.city,
    l.postalCode;

----- This query shows, for each city, the total number of restaurants, how many offer vegan or vegetarian options, 
----and the percentage of restaurants that provide these plant-based options.

----ordered by percentage 
SELECT
    l.city,
    COUNT(DISTINCT r.primarySlug) AS total_restaurants,
    COUNT(DISTINCT CASE 
        WHEN (LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%')
          OR (LOWER(c.name) LIKE '%vegetarian%' 
              OR LOWER(c.name) LIKE '%vegetarisch%' 
              OR LOWER(c.name) LIKE '%veggies%' 
              OR LOWER(c.name) LIKE '%vegetariana%' 
              OR LOWER(c.name) LIKE '%veggi%' 
              OR LOWER(c.name) LIKE '%veggie%') 
        THEN r.primarySlug
    END) AS restaurants_offering_vegan_or_vegetarian,
    ROUND(
        100.0 * COUNT(DISTINCT CASE 
            WHEN (LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%')
              OR (LOWER(c.name) LIKE '%vegetarian%' 
                  OR LOWER(c.name) LIKE '%vegetarisch%' 
                  OR LOWER(c.name) LIKE '%veggies%' 
                  OR LOWER(c.name) LIKE '%vegetariana%' 
                  OR LOWER(c.name) LIKE '%veggi%' 
                  OR LOWER(c.name) LIKE '%veggie%') 
            THEN r.primarySlug
        END) / COUNT(DISTINCT r.primarySlug), 2
    ) AS percent_restaurants_vegan_or_vegetarian
FROM categories c
JOIN locations_to_restaurants lr
    ON c.restaurant_id = lr.restaurant_id
JOIN locations l
    ON lr.location_id = l.ID
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city
ORDER BY
    percent_restaurants_vegan_or_vegetarian DESC,
    total_restaurants DESC;



----above code ordered by total restaurants

    SELECT
    l.city,
    COUNT(DISTINCT r.primarySlug) AS total_restaurants,
    COUNT(DISTINCT CASE 
        WHEN (LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%')
          OR (LOWER(c.name) LIKE '%vegetarian%' 
              OR LOWER(c.name) LIKE '%vegetarisch%' 
              OR LOWER(c.name) LIKE '%veggies%' 
              OR LOWER(c.name) LIKE '%vegetariana%' 
              OR LOWER(c.name) LIKE '%veggi%' 
              OR LOWER(c.name) LIKE '%veggie%') 
        THEN r.primarySlug
    END) AS restaurants_offering_vegan_or_vegetarian,
    ROUND(
        100.0 * COUNT(DISTINCT CASE 
            WHEN (LOWER(c.name) LIKE '%vegan%' AND LOWER(c.name) NOT LIKE '%non vegan%')
              OR (LOWER(c.name) LIKE '%vegetarian%' 
                  OR LOWER(c.name) LIKE '%vegetarisch%' 
                  OR LOWER(c.name) LIKE '%veggies%' 
                  OR LOWER(c.name) LIKE '%vegetariana%' 
                  OR LOWER(c.name) LIKE '%veggi%' 
                  OR LOWER(c.name) LIKE '%veggie%') 
            THEN r.primarySlug
        END) / COUNT(DISTINCT r.primarySlug), 2
    ) AS percent_restaurants_vegan_or_vegetarian
FROM categories c
JOIN locations_to_restaurants lr
    ON c.restaurant_id = lr.restaurant_id
JOIN locations l
    ON lr.location_id = l.ID
JOIN restaurants r
    ON lr.restaurant_id = r.primarySlug
GROUP BY
    l.city
ORDER BY
    total_restaurants DESC;




- =====================================
--oe 4. Identify the **World Hummus Order (WHO)**; top 3 hummus serving restaurants.
-- =====================================
--in other words, find the top 3 restaurants serving hummus dishes based on the number of hummus menu items they offer.
SELECT
    r.name AS restaurant_name,
    r.city,
    COUNT(m.id) AS hummus_item_count
FROM restaurants r
JOIN menuItems m
    ON r.primarySlug = m.primarySlug
WHERE LOWER(m.name) LIKE '%hummus%' 
   OR LOWER(m.description) LIKE '%hummus%'
GROUP BY
    r.name,
    r.city
ORDER BY
    hummus_item_count DESC
LIMIT 10;
-----------------
-- ******* selected for this question- lets add the average price of hummus items as well
-----------------
SELECT
    r.name AS restaurant_name,
    r.city,
    COUNT(m.id) AS hummus_item_count,
    ROUND(AVG(m.price), 2) AS average_hummus_price
FROM restaurants r
JOIN menuItems m
    ON r.primarySlug = m.primarySlug
WHERE LOWER(m.name) LIKE '%hummus%' 
   OR LOWER(m.description) LIKE '%hummus%'
GROUP BY
    r.name,
    r.city
ORDER BY
    hummus_item_count DESC
LIMIT 10;

--the hummus items and their price added as well
SELECT
    r.name AS restaurant_name,
    r.city,
    COUNT(m.id) AS hummus_item_count,
    GROUP_CONCAT(m.name || ' ($' || ROUND(m.price, 2) || ')', ', ') AS hummus_items,
    ROUND(AVG(m.price), 2) AS average_hummus_price
FROM restaurants r
JOIN menuItems m
    ON r.primarySlug = m.primarySlug
WHERE LOWER(m.name) LIKE '%hummus%' 
   OR LOWER(m.description) LIKE '%hummus%'
GROUP BY
    r.name,
    r.city
ORDER BY
    hummus_item_count DESC
LIMIT 10;



Top 5 most expensive hummus items:
SELECT
    r.name AS restaurant_name,
    r.city,
    m.name AS hummus_item_name,
    m.price AS hummus_price
FROM restaurants r
JOIN menuItems m
    ON r.primarySlug = m.primarySlug
WHERE LOWER(m.name) LIKE '%hummus%'
   OR LOWER(m.description) LIKE '%hummus%'
ORDER BY m.price DESC
LIMIT 20
;




Top 5 least expensive hummus items:
SELECT
    r.name AS restaurant_name,
    r.city,
    m.name AS hummus_item_name,
    m.price AS hummus_price
FROM restaurants r
JOIN menuItems m
    ON r.primarySlug = m.primarySlug
WHERE LOWER(m.name) LIKE '%hummus%'
   OR LOWER(m.description) LIKE '%hummus%'
ORDER BY m.price ASC
LIMIT 20;



 
 
 ----This query lists the top 10 hummus-serving restaurants, excluding menu items that mention
 -- “person,” and shows the count and average price of their hummus dishes.

-- to be compared
SELECT
    r.name AS restaurant_name,
    r.city,
    COUNT(m.id) AS hummus_item_count,
    ROUND(AVG(m.price), 2) AS average_hummus_price
FROM restaurants r
JOIN menuItems m
    ON r.primarySlug = m.primarySlug
WHERE (LOWER(m.name) LIKE '%hummus%' 
       OR LOWER(m.description) LIKE '%hummus%')
  AND LOWER(m.name) NOT LIKE '%person%'
GROUP BY
    r.name,
    r.city
ORDER BY
    hummus_item_count DESC
LIMIT 10;



-----------------------------------------------------------------------------------------------------------------------
--some notes for me
-----------------------------------------------------------------------------------------------------------------------
| Tables                               | Relationship           |
| ------------------------------------ | ---------------------- |
| restaurants ↔ locations              | Many-to-many           |
| restaurants ↔ menuItems              | One-to-many (indirect) |
| restaurants ↔ categories             | One-to-many            |
| categories ↔ menuItems               | One-to-many            |
| restaurants ↔ categories_restaurants | One-to-many            |
| primarySlug ↔ primarySlug            | ❌ No relation          |



SQL ▼
	
1
 / 1		  1 - 40 of 40

table_name	column_name	data_type
categories	id	
categories	restaurant_id	
categories	name	
categories	item_id	
categories_restaurants	category_id	
categories_restaurants	restaurant_id	
locations	ID	INTEGER
locations	postalCode	INTEGER
locations	latitude	NUMBER
locations	longitude	NUMBER
locations	city	
locations	name	
locations_to_restaurants	restaurant_id	
locations_to_restaurants	location_id	INTEGER
menuItems	primarySlug	
menuItems	id	
menuItems	name	TEXT
menuItems	description	TEXT
menuItems	price	
menuItems	alcoholContent	
menuItems	caffeineContent	
restaurants	primarySlug	TEXT
restaurants	restaurant_id	
restaurants	name	TEXT
restaurants	address	TEXT
restaurants	city	TEXT
restaurants	supportsDelivery	TEXT
restaurants	supportsPickup	
restaurants	paymentMethods	TEXT
restaurants	ratings	NUMBER
restaurants	ratingsNumber	INTEGER
restaurants	deliveryScoober	TEXT
restaurants	durationRangeMin	INTEGER
restaurants	durationRangeMax	INTEGER
restaurants	deliveryFee	
restaurants	minOrder	INTEGER
restaurants	longitude	NUMBER
restaurants	latitude	NUMBER
sqlite_sequence	name	
sqlite_sequence	seq

-- =====================================
-- SECTION : Inspect rschema table
-- =====================================
SELECT name
FROM sqlite_master
WHERE type = 'table';
PRAGMA table_info(locations);
PRAGMA table_info(restaurants);
PRAGMA table_info(locations_to_restaurants);
PRAGMA table_info(menuItems);
PRAGMA table_info(categories);
PRAGMA table_info(categories_restaurants);


SELECT
    m.name AS table_name,
    p.name AS column_name,
    p.type AS data_type
FROM sqlite_master m
JOIN pragma_table_info(m.name) p
WHERE m.type = 'table'
ORDER BY m.name, p.cid;



Vanessa Rivera Quinones — 10:41 AMTuesday, December 30, 2025 10:41 AM
@Arai 8 if your queries are getting long and ugly there are formatting tools https://sqlformat.org/
sqlformat: Online SQL Formatter
Format SQL statements online. Format and check your SQL statements, made a bit more easy.
https://sqlformat.org/


installing odbc
https://www.ch-werner.de/sqliteodbc/?utm_source=chatgpt.com

### cleaning other colleagues did


Vanessa Rivera Quinones — 4:39 PMTuesday, December 30, 2025 4:39 PM
"Basic" cleaning:
Merging categories,
Missing values,
Keeping single language,
 
Kristin — 4:39 PMTuesday, December 30, 2025 4:39 PM
city blank or number


---- inconsistency in data
A single menuitems ID exists up to 57 times in this table. It refers to a glutenfree pizza margherita from Dominos, but there are many Dominos pizza places and the names and descriptions in different languages. So that's considered a primary key then? Next up seems Pizza Hut... The categories ID field has a similar issue, with 940 records with the same value, all related to Pizza Hut

----- sample codes from colleagues

Wiktor Porczyński — 9:12 AMWednesday, December 31, 2025 9:12 AM
query = """
        SELECT
            r.name,
            r.ratings,
            r.ratingsNumber
        FROM
            restaurants r
        WHERE
            r.primarySlug IN (
                SELECT DISTINCT mi.primarySlug
                FROM menuItems mi
                WHERE mi.name LIKE '%pizza%' OR mi.description LIKE '%pizza%'
            )
        ORDER BY
            r.ratings DESC,
            r.ratingsNumber DESC
        LIMIT ?;
    """


    Esra — 9:13 AMWednesday, December 31, 2025 9:13 AM
query = """
SELECT DISTINCT r.primarySlug,
       r.name, c.name AS category,
       r.city,
       r.ratings,
       r.deliveryFee,
       r.durationRangeMin,
       r.durationRangeMax
FROM restaurants r
JOIN categories c
    ON r.primarySlug = c.restaurant_id
WHERE c.name LIKE '%Pizza%'
  AND r.ratings >= 4
ORDER BY r.ratings DESC
LIMIT 10;
"""

------------------ suggestions
clean the columns you need to work on?

