
DROP DATABASE IF EXISTS unibench;
CREATE DATABASE unibench;
\c unibench;




CREATE TABLE Customer (
   customer_id          bigint            not null,
   first_name           text              not null,
   last_name            text              not null,    
   mail                 text              not null,    

   CONSTRAINT pk_customer PRIMARY KEY (customer_id)
);

COPY Customer(customer_id, first_name, last_name, mail)
FROM '/import/customer.csv'
DELIMITER ','
CSV;



-- Index
create unique index idx_customer_customer_id_pk on Customer (customer_id);




CREATE TABLE Vendor (
   vendor_id            int             not null,
   vendor               varchar(32)     not null,
   country              text            not null, 

   CONSTRAINT pk_vendor PRIMARY KEY (vendor_id)
);


COPY Vendor(vendor_id, vendor, country)
FROM '/import/vendor.csv'
DELIMITER ','
CSV HEADER;


-- Index
create unique index idx_vendor_vendor_id_pk on Vendor (vendor_id);




CREATE TABLE Invoice (
   order_id             bigint            not null,
   customer_id          bigint            not null,
   total_price          float             not null,
   number_of_items      int               not null,

   CONSTRAINT pk_invoice PRIMARY KEY (order_id)
);

COPY Invoice(order_id, customer_id, total_price, number_of_items)
FROM '/import/invoice.csv'
DELIMITER ','
CSV HEADER;

-- Index
create unique index idx_invoice_order_id_pk on Invoice (order_id);

