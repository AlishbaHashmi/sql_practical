create database practical;
use practical;

 --Orders table

 create table Orders(
 OrderID int not null unique,
 CustomerID int primary key,
 OrderDate date,
 TotalAmount decimal(10,2)
 );



 
 insert into Orders (OrderID,CustomerID,OrderDate,TotalAmount) values
 (1,201,'2024-01-20',2400.00),
 (2,202,'2023-12-09',4000.00),
 (3,203,'2024-02-03',3500.00),
 (4,204,'2023-10-10',9000.00),
 (5,205,'2023-09-20',1500.00),
 (6,206,'2024-01-13',2800.00),
 (7,207,'2023-11-24',6758.00),
 (8,208,'2024-01-16',5000.00),
 (9,209,'2024-01-18',4555.00),
 (10,210,'2023-12-23',3400.00);

 select * from Orders;

--Customers table

 create table Customers (
 CustomerID int primary key ,
 FirstName varchar(255),
 LastName varchar(255),
 Email varchar(255),
 PhoneNumber varchar(255)
 foreign key (CustomerID) references Orders (CustomerID)
 );


 insert into Customers ( CustomerID,FirstName,LastName,Email,PhoneNumber) values
 (201,'John','Smith','john@gmail.com','03-532-62939'),
 (202,'Fizza','Bashir','fizza@gmail.com','03-987-76326'),
 (203,'William','Worth','william@gmail.com','03-872-56867'),
 (204,'Taylor','Swift','taylor@gmail.com','03-787-24566'),
 (205,'James','John','james@gmail.com','03-650-67898'),
 (206,'olivia','Rodrigo','john@gmail.com','03-316-73462'),
 (207,'Bellie','Eillish','john@gmail.com','03-265-87644'),
 (208,'Diana','James','john@gmail.com','03-345-34646'),
 (209,'Alishba','Hashmi','alishba@gmail.com','03-377-27635'),
 (210,'Rabia','Kanwal','rabia@gmail.com','03-234-87654');
 

 select * from Customers;
 
 --Products table

 create table Products(
 ProductID int primary key,
 ProductName varchar(255),
 UnitPrice decimal (10,2),
 InStockQuantity int
 );

 insert into Products(ProductID,ProductName,UnitPrice,InStockQuantity) values
 (101,'T-Shirt',2000.00,34),
 (102,'Jeans',1800.00,41),
 (103,'Watch',1000.00,23),
 (104,'Coat',6900.00,12),
 (105,'Shoes',3500.00,9);

 select * from Products;

 --order detail table  

 create table OrderDetails(
 OrderDetailID int not null unique,
 OrderID int not null ,
 ProductID int not null,
 Quantity int,
 UnitPrice decimal(10,2),
 foreign key (ProductID) references Products (ProductID),
 foreign key (OrderID) references Orders (OrderID)
 );


  select * from  OrderDetails;

--1) Create a new user named Order_Clerk with permission to insert new orders and update order details in the Orders and OrderDetails tables.

create login Order_Clerk with password ='orders123';

create user Order_Clerk for login Order_Clerk
go
grant insert,update on Orders to Order_Clerk;
grant insert,update on OrderDetails to Order_Clerk;

insert into  OrderDetails ( OrderDetailID,OrderID, ProductID,Quantity , UnitPrice) values(301,1,101,3,5500.00),
(302,2,102,2,4300.00),
(303,3,105,3,6600.00),
(304,4,103,6,8800.00),
(305,5,104,2,2500.00),
(306,6,101,7,7600.00),
(307,7,104,8,8000.00),
(308,8,102,4,7800.00),
(309,9,101,5,7800.00),
(310,10,105,8,4567.00);

select * from OrderDetails;

--2) Create a trigger named Update_Stock_Audit that logs any updates made to the InStockQuantity column of the Products table into a Stock_Update_Audit table.

create table Stock_Update_Audit(
AuditID int,
AuditInfo varchar(255)
);

create trigger Update_Stock_Audit on Products
after update 
as 
begin
declare @id int, @name varchar(50), @stock int

select @id = ProductID, @name = ProductName, @stock= InStockQuantity from inserted

insert into Stock_Update_Audit  values ('product with id  ' + '  ' + CAST(@id as varchar(50)) + '  ' +'  with name '+ '  ' + @name  + '  ' + '  with Stock quantity '+ '  ' + @stock + '  ' +  '  is inserted in the table')
end

update Products set InStockQuantity =100 where ProductID =105;

select * from Stock_Update_Audit;


--3) Write a SQL query that retrieves the FirstName, LastName, OrderDate, and TotalAmount of orders along with the customer details by joining the Customers and Orders tables.

select Customers.FirstName ,Customers.LastName , Orders.OrderDate ,Orders.TotalAmount from Customers join
Orders on Customers.CustomerID = Orders.CustomerID;

--4) Write a SQL query that retrieves the ProductName, Quantity, and TotalPrice of products ordered in orders with a total amount greater than the average total amount of all orders.

select ProductID , Quantity from OrderDetails where OrderID in (select OrderID from Orders where TotalAmount >(select avg(TotalAmount) as AvgTotalAmount from Orders));

--5) Create a stored procedure named GetOrdersByCustomer that takes a CustomerID as input and returns all orders placed by that customer along with their details.
create procedure GetOrdersByCustomer
@CustomerID int 
as
begin
select Orders.OrderID ,Orders.CustomerID, Orders.OrderDate,Orders.TotalAmount, OrderDetails.OrderDetailID,OrderDetails.ProductID, OrderDetails.Quantity, OrderDetails.UnitPrice 
from Orders join OrderDetails on Orders.OrderID =OrderDetails.OrderID where Orders.CustomerID= @CustomerID
end;

exec GetOrdersByCustomer @CustomerID = 201;

--6) Write a SQL query to create a view named OrderSummary that displays the OrderID, OrderDate, CustomerID, and TotalAmount from the Orders table.

 create view OrderSummary as select OrderID, CustomerID,OrderDate , TotalAmount from Orders;
 select * from OrderSummary;

--7) Create a view named ProductInventory that shows the ProductName and InStockQuantity from the Products table.

create view ProductInventory as select ProductName, InStockQuantity from Products;
select * from ProductInventory;

--8) Write a SQL query that joins the OrderSummary view with the Customers table to retrieve the customer's first name and last name along with their order details.

select OrderSummary.OrderID, OrderSummary.OrderDate, Customers.FirstName , Customers.LastName from OrderSummary join
Customers on OrderSummary.CustomerID = Customers.CustomerID;