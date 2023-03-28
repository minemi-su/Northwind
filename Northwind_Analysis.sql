1- "Calculate total sales according to the Northwind Database for each year 2016 through 2018. Did sales rise or fall?"

SELECT  SUBSTRING(o.OrderDate,1,4) AS order_year,  SUM(od.Quantity) AS amount_of_sales, ROUND(SUM(od.Quantity*od.UnitPrice),2) as total_sales
FROM Orders o
LEFT JOIN "Order Details" od ON od.OrderID = o.OrderID 
GROUP BY order_year
ORDER BY order_year ASC
;

2- "Calculate top 5 selling products by number."
SELECT od.productid , SUM(od.quantity) as total , p.ProductName
FROM 'order details' od 
JOIN products p  
ON p.productid = od.ProductID 
GROUP BY od.productid
ORDER BY total desc 
LIMIT 5 ;


3- "Generate a report for the number of territories3 each employee is responsible for. Are the territories evenly distributed among the employees?"
SELECT  ET.employeeid , E.FirstName , E.LastName , COUNT(ET.TerritoryID ) as number_territories , 
CASE WHEN COUNT(ET.TerritoryID ) < 5 THEN 'bad' when count(ET.TerritoryID ) < 8 THEN  'okay'
ELSE 'good' END AS distribution_status 
FROM EmployeeTerritories AS ET
INNER JOIN Employees AS E on ET.EmployeeID = e.EmployeeID 
GROUP BY ET.EmployeeID 
ORDER BY number_territories DESC 
;

4- "Generate a report for each employee’s performance based on sales quantity in descending order.  Examine if the employee has more territories he/she performs better or worse."
SELECT et.employeeid , e.FirstName , e.LastName, SUM(od.Quantity) as total_sales, COUNT(DISTINCT(et.TerritoryID)) 
FROM "Order Details" od 
JOIN Orders o ON o.OrderID = od.OrderID 
JOIN Employees e ON e.EmployeeID = o.EmployeeID 
JOIN EmployeeTerritories et ON et.EmployeeID =e.EmployeeID 
GROUP BY et.EmployeeID
ORDER BY total_sales DESC 
;


5- 	"Find the countries (top 5) that have the fewest number of ordered items (table Orders and table Order Details)."
SELECT SUM(od.quantity) AS Subtotal, o.shipcountry
FROM 'order details' od
JOIN orders o
ON o.orderID = od.orderID
GROUP BY o.shipcountry
ORDER BY subtotal ASC 
LIMIT 5
;

6- 	"Which are the categories most prevalent in those countries? (table categories)"
SELECT COUNT(c.CategoryID) AS MOSTprevalent,c.CategoryName,p.UnitPrice, SUM(od.quantity) AS subtotal, o.shipcountry
FROM 'order details' AS od
JOIN orders AS o
ON o.orderID = od.orderID
JOIN Products AS p
ON p.UnitPrice = od.UnitPrice
JOIN Categories AS c
ON c.CategoryID = p.CategoryID
GROUP BY shipcountry
ORDER BY subtotal ASC
LIMIT 5
;

7- 	"Find top 10-15 products for every country and find how many of them have a discount. Now show in a table every country and how many of the products ordered from there are discounted. Order them DESC. Analyze the information. Are the top 5 lowest sales countries from the previous question also order products without discounts? Or the opposite?"
# "first query"
CREATE TABLE order_quantities AS
SELECT p.ProductID , p.productName, o.shipcountry , SUM(od.quantity) AS total_quantity, SUM(od.discount/100) as is_discounted, ROW_NUMBER() over (PARTITION BY o.Shipcountry ORDER BY SUM(od.quantity) DESC) AS product_rank
FROM 'order details' od
JOIN orders o ON o.orderID = od.orderID
JOIN Products p ON p.ProductID =od.ProductID
GROUP BY ShipCountry, ProductName
ORDER BY od.quantity
;

# "second query"
SELECT ShipCountry, SUM(CEIL(is_discounted)) AS discounted_item_count, MAX(Product_rank) AS sample_size, ROUND(SUM(CEIL(is_discounted))/MAX(Product_rank)*100) AS discounted_percentage
FROM order_quantities
WHERE product_rank <16
GROUP BY ShipCountry
ORDER BY discounted_item_count DESC
;


8- "Find estimated populations of the territories and normalise performance of employees on a per-capita basis."

Territories assigned to each of the employees
SELECT  et.employeeid , e.FirstName , e.LastName , T.TerritoryDescription ,T.TerritoryID
FROM EmployeeTerritories et
JOIN Employees e  ON et.EmployeeID = e.EmployeeID 
JOIN Territories t ON T.TerritoryID = ET.TerritoryID
;

# "Total sales of the employees calculated in question 4, link of the Query"


9- "For the top 10 selling products, how many have a reorder level.  Calculate which had the highest reorder index based on purchases for the three years."

SELECT od.productid , SUM(od.quantity) AS total , p.ProductName , p.ReorderLevel , ROUND(SUM(od.quantity)/ReorderLevel,1)
FROM 'order details' od 
JOIN products p
ON p.productid = od.ProductID 
GROUP BY od.productid
ORDER BY total DESC
LIMIT 10
;

