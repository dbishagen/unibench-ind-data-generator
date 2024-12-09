
DROP DATABASE IF EXISTS unibench;
CREATE DATABASE unibench;
USE unibench;




CREATE TABLE Customer (
   customer_id          bigint            not null,
   first_name           text              not null,
   last_name            text              not null,    
   mail                 text              not null,    

   CONSTRAINT pk_customer PRIMARY KEY (customer_id)
);

LOAD DATA INFILE '/import/customer.csv'
INTO TABLE Customer
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
(customer_id, first_name, last_name, mail);




CREATE TABLE Vendor (
   vendor_id            int             not null,
   vendor               varchar(32)     not null,
   country              text            not null, 

   CONSTRAINT pk_vendor PRIMARY KEY (vendor_id)
);

LOAD DATA INFILE '/import/vendor.csv'
INTO TABLE Vendor
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(vendor_id, vendor, country);




CREATE TABLE Invoice (
   order_id             bigint            not null,
   customer_id          bigint            not null,
   total_price          float             not null,
   number_of_items      int               not null,

   CONSTRAINT pk_invoice PRIMARY KEY (order_id)
);

LOAD DATA INFILE '/import/invoice.csv'
INTO TABLE Invoice
FIELDS TERMINATED BY ',' 
LINES TERMINATED BY '\r\n'
IGNORE 1 ROWS
(order_id, customer_id, total_price, number_of_items);
