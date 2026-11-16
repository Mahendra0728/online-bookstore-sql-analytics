-- ONLINE BOOKSTORE SQL ANALYTICS PROJECT

-- DATABASE SETUP
CREATE DATABASE OnlineBookstore;

-- TABLE CREATION
DROP TABLE IF EXISTS Books;
CREATE TABLE Books (
    Book_ID SERIAL PRIMARY KEY,
    Title VARCHAR(100),
    Author VARCHAR(100),
    Genre VARCHAR(50),
    Published_Year INT,
    Price NUMERIC(10, 2),
    Stock INT
);
DROP TABLE IF EXISTS customers;
CREATE TABLE Customers (
    Customer_ID SERIAL PRIMARY KEY,
    Name VARCHAR(100),
    Email VARCHAR(100),
    Phone VARCHAR(15),
    City VARCHAR(50),
    Country VARCHAR(150)
);
DROP TABLE IF EXISTS orders;
CREATE TABLE Orders (
    Order_ID SERIAL PRIMARY KEY,
    Customer_ID INT REFERENCES Customers(Customer_ID),
    Book_ID INT REFERENCES Books(Book_ID),
    Order_Date DATE,
    Quantity INT,
    Total_Amount NUMERIC(10, 2)
);


-- BASIC QUERY ANALYSIS

-- Analyze Fiction Genre Books
SELECT * FROM Books 
WHERE Genre='Fiction';

-- Identify Books Published After 1950
SELECT * FROM Books 
WHERE Published_year>1950;

-- Analyze Customers from Canada
SELECT * FROM Customers 
WHERE country='Canada';

-- Analyze Orders Placed in November 2023
SELECT * FROM Orders 
WHERE order_date BETWEEN '2023-11-01' AND '2023-11-30';

-- Calculate Total Available Book Stock
SELECT SUM(stock) AS Total_Stock
From Books;

-- Identify Most Expensive Book
SELECT * FROM Books 
ORDER BY Price DESC 
LIMIT 1;

-- Identify Bulk Book Orders
SELECT * FROM Orders 
WHERE quantity>1;

-- Analyze High-Value Orders Above $20
SELECT * FROM Orders 
WHERE total_amount>20;

-- Analyze Available Book Genres
SELECT DISTINCT genre FROM Books;

-- Identify Lowest Stock Book
SELECT * FROM Books 
ORDER BY stock 
LIMIT 1;

-- Calculate Total Revenue Generated
SELECT SUM(total_amount) As Revenue 
FROM Orders;

-- ADVANCED BUSINESS ANALYSIS

-- Calculate Average Price of Fantasy Books
SELECT AVG(price) AS Average_Price
FROM Books
WHERE Genre = 'Fantasy';

-- Identify Customers with Multiple Orders
SELECT o.customer_id, c.name, COUNT(o.Order_id) AS ORDER_COUNT
FROM orders o
JOIN customers c ON o.customer_id=c.customer_id
GROUP BY o.customer_id, c.name
HAVING COUNT(Order_id) >=2;

-- Identify Most Frequently Ordered Book
SELECT o.Book_id, b.title, COUNT(o.order_id) AS ORDER_COUNT
FROM orders o
JOIN books b ON o.book_id=b.book_id
GROUP BY o.book_id, b.title
ORDER BY ORDER_COUNT DESC LIMIT 1;

-- Analyze Top 3 Most Expensive Fantasy Books
SELECT * FROM books
WHERE genre ='Fantasy'
ORDER BY price DESC LIMIT 3;

-- Analyze Author-wise Book Sales
SELECT b.author, SUM(o.quantity) AS Total_Books_Sold
FROM orders o
JOIN books b ON o.book_id=b.book_id
GROUP BY b.Author;

-- Identify Cities with Highest Revenue
SELECT c.city, SUM(o.total_amount) AS total_revenue,
COUNT(o.order_id) AS total_orders
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.city
ORDER BY total_revenue DESC;

-- Analyze Remaining Book Inventor
SELECT b.book_id, b.title, b.stock, COALESCE(SUM(o.quantity),0) AS Order_quantity,  
b.stock- COALESCE(SUM(o.quantity),0) AS Remaining_Quantity
FROM books b
LEFT JOIN orders o ON b.book_id=o.book_id
GROUP BY b.book_id ORDER BY b.book_id;

-- Identify Top 5 Customers by Total Spending
WITH Customer_Spending AS (SELECT c.customer_id, c.name,SUM(o.total_amount) AS total_spent
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id, c.name)
SELECT *FROM Customer_Spending
ORDER BY total_spent DESC
LIMIT 5;

-- Analyze Genre-wise Revenue
WITH Genre_Revenue AS (SELECT b.genre, SUM(o.total_amount) AS total_revenue 
FROM Books b
JOIN Orders o
ON b.book_id = o.book_id
GROUP BY b.genre)
SELECT * FROM Genre_Revenue
ORDER BY total_revenue DESC;

-- Rank Books Based on Sales Within Each Genre
SELECT b.genre, b.title, SUM(o.quantity) AS total_books_sold,
DENSE_RANK() OVER (PARTITION BY b.genre ORDER BY SUM(o.quantity) DESC) AS sales_rank
FROM Books b
JOIN Orders o ON b.book_id = o.book_id
GROUP BY b.genre, b.book_id, b.title
ORDER BY b.genre, sales_rank;

-- Analyze Customer Order Sequence
SELECT customer_id, order_id, order_date, total_amount,
ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY order_date) AS order_sequence
FROM Orders
ORDER BY customer_id, order_sequence;

-- Identify Customers with Orders Above Average Order Amount
SELECT DISTINCT c.customer_id,c.name,c.city
FROM Customers c
JOIN Orders o ON c.customer_id = o.customer_id
WHERE o.total_amount > (SELECT AVG(total_amount) FROM Orders)
ORDER BY c.customer_id;

-- Identify Books That Have Never Been Ordered
SELECT b.book_id, b.title, b.genre, b.price
FROM Books b
WHERE NOT EXISTS (SELECT 1
FROM Orders o
WHERE o.book_id = b.book_id);

-- END OF SQL ANALYTICS PROJECT








