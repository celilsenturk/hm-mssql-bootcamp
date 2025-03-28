-- 1. Tanım Sorusu:
-- Northwind veritabanında toplam kaç tablo vardır? Bu tabloların isimlerini listeleyiniz.

SELECT COUNT(*) AS TableCount
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

SELECT TABLE_NAME
FROM INFORMATION_SCHEMA.TABLES
WHERE TABLE_TYPE = 'BASE TABLE';

-- 2. JOIN Sorusu:
-- Her sipariş (Orders) için, Şirket adı (CompanyName), çalışan adı (Employee Full Name), sipariş tarihi ve
-- gönderici şirketin adı (Shipper) ile birlikte bir liste çıkarın.

select * from Orders;
select * from Customers;
select * from Employees;

SELECT
    ord.OrderID AS 'Şipariş ID',
    cus.CompanyName AS ŞirketAdı,
    emp.FirstName AS 'Çalışan Adı', emp.LastName AS 'Çalışan Soyadı',
    ord.OrderDate,
    shp.CompanyName AS 'Gönderici Şirketin Adı'
FROM Orders ord
JOIN Customers cus ON ord.CustomerID = cus.CustomerID
JOIN Employees emp ON ord.EmployeeID = emp.EmployeeID
JOIN Shippers shp ON ord.ShipVia = shp.ShipperID;

-- 3. Aggregate Fonksiyon:
-- Tüm siparişlerin toplam tutarını bulun. (Order Details tablosundaki Quantity UnitPrice üzerinden hesaplayınız)

select * from [Order Details];

SELECT SUM(Quantity * UnitPrice) AS 'Tüm Siparişlerin Toplam Tutarı'
FROM "Order Details";

-- 4. Gruplama:
-- Hangi ülkeden kaç müşteri vardır?

select * from Customers;

SELECT Country, COUNT(CustomerID) AS 'Kaç Müşteri Var'
FROM Customers
GROUP BY Country;

-- 5. Subquery Kullanımı:
-- En pahalı ürünün adını ve fiyatını listeleyiniz.
select * from Products;

SELECT ProductName, UnitPrice AS 'En Pahalı Ürün'
FROM Products
WHERE UnitPrice = (
SELECT MAX(UnitPrice)
FROM Products);

-- 6. JOIN ve Aggregate:
-- Çalışan başına düşen sipariş sayısını gösteren bir liste çıkarınız.
select * from Employees;
select * from Orders;

SELECT emp.EmployeeID, emp.LastName, emp.FirstName,
    COUNT(ord.OrderID) AS 'Çalışan Bşına Düşen Sipariş Sayısı'
FROM Employees emp
LEFT JOIN Orders ord ON emp.EmployeeID = ord.EmployeeID
GROUP BY emp.EmployeeID, emp.LastName, emp.FirstName
ORDER BY [Çalışan Bşına Düşen Sipariş Sayısı] DESC;

-- 7. Tarih Filtreleme:
-- 1997 yılında verilen siparişleri listeleyin.
SELECT * FROM Orders;

SELECT * FROM Orders
WHERE OrderDate >= '1997-01-01' AND OrderDate < '1998-01-01';

-- 8. CASE Kullanımı:
-- Ürünleri fiyat aralıklarına göre kategorilere ayırarak listeleyin: 020 → Ucuz, 20-50 → Orta, 50+ → Pahalı.
SELECT * FROM Products;

SELECT ProductName, UnitPrice,
    CASE
        WHEN UnitPrice <= 20 THEN 'Ucuz'
        WHEN UnitPrice <= 50 THEN 'Orta'
        WHEN UnitPrice >= 51 THEN 'Pahalı'
    END AS PriceCategory
FROM Products;

-- 9. Nested Subquery:
-- En çok sipariş verilen ürünün adını ve sipariş adedini (adet bazında) bulun.
SELECT * FROM Products;
SELECT * FROM Orders Details;

SELECT pro.ProductName, SUM(od.Quantity) AS 'Sipariş Adedi'
FROM Products pro
JOIN "Order Details" od ON pro.ProductID = od.ProductID
GROUP BY pro.ProductID, pro.ProductName
HAVING SUM(od.Quantity) = (
    SELECT TOP 1 SUM(Quantity)
    FROM "Order Details"
    GROUP BY ProductID
    ORDER BY SUM(Quantity) DESC
    );

-- 10. View Oluşturma:
-- Ürünler ve kategoriler bilgilerini birleştiren bir görünüm (view) oluşturun.
SELECT * FROM Products;
SELECT * FROM Categories;

-- 11. Trigger:
-- Ürün silindiğinde log tablosuna kayıt yapan bir trigger yazınız.


-- 12. Stored Procedure:
-- Belirli bir ülkeye ait müşterileri listeleyen bir stored procedure yazınız.


-- 13. Left Join Kullanımı:
-- Tüm ürünlerin tedarikçileriyle (suppliers) birlikte listesini yapın. Tedarikçisi olmayan ürünler de listelensin.
SELECT * FROM Products;
SELECT * FROM Suppliers;

SELECT pro.ProductID, pro.ProductName, pro.UnitPrice,
    sup.SupplierID, sup.CompanyName, sup.ContactName
FROM Products pro
LEFT JOIN Suppliers sup ON pro.SupplierID = sup.SupplierID;

-- 14. Fiyat Ortalamasının Üzerindeki Ürünler:
-- Fiyatı ortalama fiyatın üzerinde olan ürünleri listeleyin.
SELECT * FROM Products;

SELECT ProductID, ProductName, UnitPrice
FROM Products
WHERE UnitPrice > (
    SELECT AVG(UnitPrice)
    FROM Products
    );

-- 15. En Çok Ürün Satan Çalışan:
-- Sipariş detaylarına göre en çok ürün satan çalışan kimdir? FULL
SELECT * FROM [Order Details];
SELECT * FROM Employees;

SELECT TOP 1
    emp.EmployeeID,
    emp.FirstName,
    emp.LastName,
    SUM(od.Quantity) AS TotalProductsSold
FROM Employees emp
LEFT JOIN Orders ord ON emp.EmployeeID = ord.EmployeeID
LEFT JOIN "Order Details" od ON ord.OrderID = od.OrderID
GROUP BY emp.EmployeeID, emp.FirstName, emp.LastName
ORDER BY SUM(od.Quantity) DESC;

-- 16. Ürün Stoğu Kontrolü:
-- Stok miktarı 10’un altında olan ürünleri listeleyiniz.
SELECT * FROM Products;

SELECT ProductID, ProductName, UnitsInStock, UnitPrice
FROM Products
WHERE UnitsInStock < 10;

-- 17. Şirketlere Göre Sipariş Sayısı:
-- Her müşteri şirketinin yaptığı sipariş sayısını ve toplam harcamasını bulun.
SELECT * FROM Orders;
SELECT * FROM Customers;

SELECT
    cus.CompanyName,
    COUNT(ord.OrderID) AS 'Sipariş Sayısı',
    SUM(od.Quantity * od.UnitPrice) AS 'Toplam Harcama'
FROM Customers cus
LEFT JOIN Orders ord ON cus.CustomerID = ord.CustomerID
LEFT JOIN "Order Details" od ON ord.OrderID = od.OrderID
GROUP BY cus.CompanyName;

-- 18. En Fazla Müşterisi Olan Ülke:
-- Hangi ülkede en fazla müşteri var?
SELECT * FROM Customers;

SELECT TOP 1
    Country,
    COUNT(CustomerID) AS 'Müşteri Sayısı'
FROM Customers
GROUP BY Country
ORDER BY COUNT(CustomerID) DESC;

-- 19. Her Siparişteki Ürün Sayısı:
-- Siparişlerde kaç farklı ürün olduğu bilgisini listeleyin.
SELECT * FROM [Order Details];

SELECT
    OrderID,
    COUNT(DISTINCT ProductID) AS 'Benzersiz Ürün Sayısı'
FROM "Order Details"
GROUP BY OrderID;

-- 20. Ürün Kategorilerine Göre Ortalama Fiyat:
-- Her kategoriye göre ortalama ürün fiyatını bulun.
SELECT * FROM Products;
SELECT * FROM Categories;

SELECT
    cat.CategoryName,
    AVG(pro.UnitPrice) AS 'Ortalama Fiyat'
FROM Categories cat
LEFT JOIN Products pro ON cat.CategoryID = pro.CategoryID
GROUP BY cat.CategoryName;

-- 21. Aylık Sipariş Sayısı:
-- Siparişleri ay ay gruplayarak kaç sipariş olduğunu listeleyin.
SELECT * FROM Orders;

SELECT
    YEAR(OrderDate) AS OrderYear,
    MONTH(OrderDate) AS OrderMonth,
    COUNT(OrderID) AS OrderCount
FROM Orders
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY OrderYear, OrderMonth;

-- 22. Çalışanların Müşteri Sayısı:
-- Her çalışanın ilgilendiği müşteri sayısını listeleyin.
SELECT * FROM Orders;
SELECT * FROM Employees;

SELECT emp.EmployeeID, emp.FirstName, emp.LastName,
    COUNT(DISTINCT ord.CustomerID) AS 'Müşteri Sayısı'
FROM Employees emp
LEFT JOIN Orders ord ON emp.EmployeeID = ord.EmployeeID
GROUP BY emp.EmployeeID, emp.FirstName, emp.LastName;

-- 23. Hiç siparişi olmayan müşterileri listeleyin.
SELECT * FROM Orders;
SELECT * FROM Customers;

SELECT cus.CustomerID, cus.CompanyName
FROM Customers cus
LEFT JOIN Orders ord ON cus.CustomerID = ord.CustomerID
WHERE ord.OrderID IS NULL;

-- 24. Siparişlerin Nakliye (Freight) Maliyeti Analizi:
-- Nakliye maliyetine göre en pahalı 5 siparişi listeleyin.
SELECT * FROM Orders;

SELECT TOP 5 OrderID, Freight, CustomerID, OrderDate
FROM Orders
ORDER BY Freight DESC;