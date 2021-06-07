/*
Lab 1 report Nicolas Taba (nicta839), Tim Yuki Washio (timwa902)
*/

/* All non code should be within SQL-comments like this */ 


/*
Drop all user created tables that have been created when solving the lab
*/

DROP TABLE IF EXISTS custom_table CASCADE;


/* Have the source scripts in the file so it is easy to recreate!*/

SOURCE company_schema.sql;
SOURCE company_data.sql;

/*
Question 1: 

List all employees, i.e. all tuples in the jbemployee relation.
*/

SELECT * AS jbemployee;

/* Output
+------+--------------------+--------+---------+-----------+-----------+
| id   | name               | salary | manager | birthyear | startyear |
+------+--------------------+--------+---------+-----------+-----------+
|   10 | Ross, Stanley      |  15908 |     199 |      1927 |      1945 |
|   11 | Ross, Stuart       |  12067 |    NULL |      1931 |      1932 |
|   13 | Edwards, Peter     |   9000 |     199 |      1928 |      1958 |
|   26 | Thompson, Bob      |  13000 |     199 |      1930 |      1970 |
|   32 | Smythe, Carol      |   9050 |     199 |      1929 |      1967 |
|   33 | Hayes, Evelyn      |  10100 |     199 |      1931 |      1963 |
|   35 | Evans, Michael     |   5000 |      32 |      1952 |      1974 |
|   37 | Raveen, Lemont     |  11985 |      26 |      1950 |      1974 |
|   55 | James, Mary        |  12000 |     199 |      1920 |      1969 |
|   98 | Williams, Judy     |   9000 |     199 |      1935 |      1969 |
|  129 | Thomas, Tom        |  10000 |     199 |      1941 |      1962 |
|  157 | Jones, Tim         |  12000 |     199 |      1940 |      1960 |
|  199 | Bullock, J.D.      |  27000 |    NULL |      1920 |      1920 |
|  215 | Collins, Joanne    |   7000 |      10 |      1950 |      1971 |
|  430 | Brunet, Paul C.    |  17674 |     129 |      1938 |      1959 |
|  843 | Schmidt, Herman    |  11204 |      26 |      1936 |      1956 |
|  994 | Iwano, Masahiro    |  15641 |     129 |      1944 |      1970 |
| 1110 | Smith, Paul        |   6000 |      33 |      1952 |      1973 |
| 1330 | Onstad, Richard    |   8779 |      13 |      1952 |      1971 |
| 1523 | Zugnoni, Arthur A. |  19868 |     129 |      1928 |      1949 |
| 1639 | Choy, Wanda        |  11160 |      55 |      1947 |      1970 |
| 2398 | Wallace, Maggie J. |   7880 |      26 |      1940 |      1959 |
| 4901 | Bailey, Chas M.    |   8377 |      32 |      1956 |      1975 |
| 5119 | Bono, Sonny        |  13621 |      55 |      1939 |      1963 |
| 5219 | Schwarz, Jason B.  |  13374 |      33 |      1944 |      1959 |
+------+--------------------+--------+---------+-----------+-----------+
25 rows in set (0.02 sec)
*/ 

/*
Question 2: 

List the name of all departments in alphabetical order. 
Note: by “name” we mean the name attribute for all tuples in the jbdept relation.
*/

SELECT DISTINCT name FROM jbdept ORDER BY name;

/* Output
+------------------+
| name             |
+------------------+
| Bargain          |
| Book             |
| Candy            |
| Children's       |
| Furniture        |
| Giftwrap         |
| Jewelry          |
| Junior Miss      |
| Junior's         |
| Linens           |
| Major Appliances |
| Men's            |
| Sportswear       |
| Stationary       |
| Toys             |
| Women's          |
+------------------+
16 rows in set (0.01 sec)
*/


/*
Question 3: 

What parts are not in store, i.e. qoh = 0? (qoh = Quantity On Hand)
*/

SELECT id, name, qoh FROM jbparts WHERE qoh = 0;

/* Output
+----+-------------------+------+
| id | name              | qoh  |
+----+-------------------+------+
| 11 | card reader       |    0 |
| 12 | card punch        |    0 |
| 13 | paper tape reader |    0 |
| 14 | paper tape punch  |    0 |
+----+-------------------+------+
4 rows in set (0.01 sec)
*/


/*
Question 4: 

Which employees have a salary between 9000 (included) and 10000 (included)?
*/

SELECT id, name, salary FROM jbemployee WHERE salary BETWEEN 9000 AND 10000;

/* Output
+-----+----------------+--------+
| id  | name           | salary |
+-----+----------------+--------+
|  13 | Edwards, Peter |   9000 |
|  32 | Smythe, Carol  |   9050 |
|  98 | Williams, Judy |   9000 |
| 129 | Thomas, Tom    |  10000 |
+-----+----------------+--------+
4 rows in set (0.01 sec)
*/


/*
Question 5: 

What was the age of each employee when they started working (startyear)?
*/

SELECT id, name, startyear-birthyear as startage FROM jbemployee;

/* Output
+------+--------------------+----------+
| id   | name               | startage |
+------+--------------------+----------+
|   10 | Ross, Stanley      |       18 |
|   11 | Ross, Stuart       |        1 |
|   13 | Edwards, Peter     |       30 |
|   26 | Thompson, Bob      |       40 |
|   32 | Smythe, Carol      |       38 |
|   33 | Hayes, Evelyn      |       32 |
|   35 | Evans, Michael     |       22 |
|   37 | Raveen, Lemont     |       24 |
|   55 | James, Mary        |       49 |
|   98 | Williams, Judy     |       34 |
|  129 | Thomas, Tom        |       21 |
|  157 | Jones, Tim         |       20 |
|  199 | Bullock, J.D.      |        0 |
|  215 | Collins, Joanne    |       21 |
|  430 | Brunet, Paul C.    |       21 |
|  843 | Schmidt, Herman    |       20 |
|  994 | Iwano, Masahiro    |       26 |
| 1110 | Smith, Paul        |       21 |
| 1330 | Onstad, Richard    |       19 |
| 1523 | Zugnoni, Arthur A. |       21 |
| 1639 | Choy, Wanda        |       23 |
| 2398 | Wallace, Maggie J. |       19 |
| 4901 | Bailey, Chas M.    |       19 |
| 5119 | Bono, Sonny        |       24 |
| 5219 | Schwarz, Jason B.  |       15 |
+------+--------------------+----------+
25 rows in set (0.01 sec)
*/


/*
Question 6:

Which employees have a last name ending with “son”?
*/

SELECT id, name FROM jbemployee WHERE name LIKE "%son,%";

/* Output
+----+---------------+
| id | name          |
+----+---------------+
| 26 | Thompson, Bob |
+----+---------------+
1 row in set (0.02 sec)
*/


/*
Question 7:

Which items (note items, not parts) have been delivered by a supplier called Fisher-Price? 
Formulate this query using a subquery in the where-clause.
*/

SELECT id, name, supplier FROM jbitem WHERE supplier = (SELECT id FROM jbsupplier WHERE name = "Fisher-Price");

/* Output 

+-----+-----------------+----------+
| id  | name            | supplier |
+-----+-----------------+----------+
|  43 | Maze            |       89 |
| 107 | The 'Feel' Book |       89 |
| 119 | Squeeze Ball    |       89 |
+-----+-----------------+----------+
3 rows in set (0.13 sec)
*/


/*
Question 8:

Formulate the same query as above, but without a subquery.
*/

SELECT A.id, A.name, A.supplier FROM jbitem A JOIN jbsupplier B ON A.supplier = B.id WHERE B.name = "Fisher-Price";
/* Output
+-----+-----------------+----------+
| id  | name            | supplier |
+-----+-----------------+----------+
|  43 | Maze            |       89 |
| 107 | The 'Feel' Book |       89 |
| 119 | Squeeze Ball    |       89 |
+-----+-----------------+----------+
3 rows in set (0.02 sec)
*/


/* 
Question 9:

Show all cities that have suppliers located in them. Formulate this query using a subquery in the where-clause.
*/

SELECT id, name FROM jbcity WHERE id IN (SELECT DISTINCT city FROM jbsupplier);

/* Output
+-----+----------------+
| id  | name           |
+-----+----------------+
|  10 | Amherst        |
|  21 | Boston         |
| 100 | New York       |
| 106 | White Plains   |
| 118 | Hickville      |
| 303 | Atlanta        |
| 537 | Madison        |
| 609 | Paxton         |
| 752 | Dallas         |
| 802 | Denver         |
| 841 | Salt Lake City |
| 900 | Los Angeles    |
| 921 | San Diego      |
| 941 | San Francisco  |
| 981 | Seattle        |
+-----+----------------+
15 rows in set (0.12 sec)
*/


/* 
Question 10:

What is the name and color of the parts that are heavier than a card reader? 
Formulate this query using a subquery in the where-clause. (The SQL query must not contain the weight as a constant.)
*/

SELECT name, color FROM jbparts WHERE weight > ALL (SELECT weight FROM jbparts WHERE name = "card reader");

/* Output
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.51 sec)
*/


/* 
Question 11:

Formulate the same query as above, but without a subquery. (The query must not contain the weight as a constant.)
*/

SELECT A.name, A.color FROM jbparts A JOIN jbparts B ON A.weight > B.weight AND B.name = "card reader";

/* Output
+--------------+--------+
| name         | color  |
+--------------+--------+
| disk drive   | black  |
| tape drive   | black  |
| line printer | yellow |
| card punch   | gray   |
+--------------+--------+
4 rows in set (0.01 sec)
*/


/* 
Question 12:

What is the average weight of black parts?
*/

SELECT AVG(weight) FROM jbparts WHERE color = "black";

/* Output
+-------------+
| AVG(weight) |
+-------------+
|    347.2500 |
+-------------+
1 row in set (0.01 sec)
*/


/* 
Question 13:

What is the total weight of all parts that each supplier in Massachusetts (“Mass”) has delivered?
Retrieve the name and the total weight for each of these suppliers. Do not forget to take the quantity of delivered parts into account.
Note that one row should be returned for each supplier.
*/

SELECT A.name, SUM(C.weight*B.quan) as totalweight FROM jbsupplier A JOIN jbsupply B ON A.id = B.supplier JOIN jbparts C ON B.part = C.id JOIN jbcity D ON A.city = D.id WHERE D.state = "Mass" GROUP BY A.id;

/* Output
+--------------+-------------+
| name         | totalweight |
+--------------+-------------+
| Fisher-Price |     1135000 |
| DEC          |        3120 |
+--------------+-------------+
2 rows in set (0.01 sec)
*/


/*
Question 14:

Create a new relation (a table), with the same attributes as the table items using the CREATE TABLE syntax 
where you define every attribute explicitly (i.e. not as a copy of another table). 
Then fill the table with all items that cost less than the average price for items. 
Remember to define primary and foreign keys in your table!
*/

CREATE TABLE jbitemsbelowavg (
    id integer NOT NULL, 
    name varchar(255), 
    dept integer, 
    rice integer, 
    qoh integer, 
    supplier integer, 
    PRIMARY KEY (id),
    FOREIGN KEY (supplier) references jbsupplier(id)
)

/* Output
Query OK, 0 rows affected (0.04 sec)
*/

INSERT INTO jbitemsbelowavg SELECT * FROM jbitem WHERE price < (SELECT AVG(price) FROM jbitem);

/* Output
Query OK, 14 rows affected (0.02 sec)
Records: 14  Duplicates: 0  Warnings: 0
*/

SELECT * FROM jbitemsbelowavg;

/* Output
+-----+-----------------+------+-------+------+----------+
| id  | name            | dept | price | qoh  | supplier |
+-----+-----------------+------+-------+------+----------+
|  11 | Wash Cloth      |    1 |    75 |  575 |      213 |
|  19 | Bellbottoms     |   43 |   450 |  600 |       33 |
|  21 | ABC Blocks      |    1 |   198 |  405 |      125 |
|  23 | 1 lb Box        |   10 |   215 |  100 |       42 |
|  25 | 2 lb Box, Mix   |   10 |   450 |   75 |       42 |
|  26 | Earrings        |   14 |  1000 |   20 |      199 |
|  43 | Maze            |   49 |   325 |  200 |       89 |
| 106 | Clock Book      |   49 |   198 |  150 |      125 |
| 107 | The 'Feel' Book |   35 |   225 |  225 |       89 |
| 118 | Towels, Bath    |   26 |   250 | 1000 |      213 |
| 119 | Squeeze Ball    |   49 |   250 |  400 |       89 |
| 120 | Twin Sheet      |   26 |   800 |  750 |      213 |
| 165 | Jean            |   65 |   825 |  500 |       33 |
| 258 | Shirt           |   58 |   650 | 1200 |       33 |
+-----+-----------------+------+-------+------+----------+
14 rows in set (0.01 sec)
*/