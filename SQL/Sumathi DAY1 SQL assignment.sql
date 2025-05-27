create Table categories(
categoryID serial PRIMARY KEY,
categoryName varchar(50) NOT NULL,
description  text
)

select * from  categories

create Table employees(
employeeID   serial PRIMARY KEY,
employeeName varchar(50),
title        varchar(50),
city         varchar(30),
country      varchar(20),
reportsTo    integer
)

select * from  employees

create Table  shippers(
shipperID  serial PRIMARY KEY,
companyName  varchar NOT NULL
)

select * from  shippers

create Table customers(
customerID   varchar(5) Primary key,
companyName  varchar(50) Not null,
contactName  varchar(50) not null,
contactTitle   text ,
city            varchar(50),
country         varchar(50)
)

Alter TABLE customers 
alter column customerID type char(5)

select * from  customers

create Table products(
productID serial PRIMARY KEY,
productName varchar NOT NULL,
quantityPerUnit varchar NOT NULL,
unitPrice  float NOT NULL,
discontinued Boolean,
categoryID INT REFERENCES categories(categoryID)
)

select * from  products

create SEQUENCE order_id_seq
START 10248
INCREMENT 1				

create Table orders(
orderID int DEFAULT nextval('order_id_seq') PRIMARY KEY,
customerID  char(5) REFERENCES customers(customerID),
employeeID int REFErENCES employees(employeeID),
orderDate DATE NOT NULL,
requiredDate DATE NOT NULL,
shippedDate DATE NOT NULL,
shipperID INT REFERENCES shippers(shipperID),
freight NUMERIC(10,2)
)

select * from  orders

create Table order_details(
orderID int REFERENCES orders(orderID),
productID int REFERENCES products(productID),
unitPrice  NUMERIC(10,2),
quantity   INT,
discount   NUMERIC(10,2),
PRIMARY KEY(orderID,productID)
)

select * from order_details;






