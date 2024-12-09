#!/usr/bin/env python
# -*- coding: utf-8 -*-


from faker import Faker
from functools import reduce
import random
import json
import csv
import sys
import csv
import sys
import os


fake = Faker()

# Entity types
customers = []
vendors = []
products = []
orders = []
invoices = []
feedbacks = []
tags = []
posts = []
# Relationships
has_interest = []
wrote = []
has_tag = []
has_created = []


person_has_interest_random_range = 16
post_has_tag_random_range = 8
tag_vendor_random_range = 4


# customer_id_start_value = 1000000000000
# order_id_start_value = 2000000000000
# post_id_start_value = 3000000000000
# tag_id_start_value = 4000000000000

feedback_id_counter = 5000000000000


# Scale 1
num_unibench = {
    "tag": 9097,
    "person": 9949,
    "post": 1231991,
    #"feedback" : 150000,
    "order": 142256
}


def scale_num_data( scale ):
    for k, v in num_unibench.items():
        num_unibench[k] = int(v * scale)
        if num_unibench[k] <=1:
            print(f"Error: {k} is too small")
            sys.exit(1)
    
    


## DEPENDS
#  - tag
def gen_customer():
    """
    Generate customer data
    """
    global person_has_interest_random_range
    for idx in range(num_unibench['person']):
        obj = {} 
        obj['customer_id'] = idx + 1000000000000
        obj['first_name'] = fake.first_name()
        obj['last_name'] = fake.last_name()
        obj['mail'] = fake.ascii_email()

        obj['has_interest'] = []
        if len(tags) < person_has_interest_random_range:
            person_has_interest_random_range = len(tags)
        tags_sample = random.sample(range(0, len(tags)), random.randrange(0,person_has_interest_random_range))
        for i in tags_sample:
            obj['has_interest'].append( tags[i]['tag_id'] )

        customers.append(obj)

        if idx % 100 == 0:
            s = f"Customers: {round(idx/num_unibench['person']*100,2)}%"
            print(s, end='\r', flush=True) 
    print("Customers done                ")
    # add person knows person relationship
    #_gen_person_knows_person_relationship()




def _gen_person_knows_person_relationship():
    # add person knows person relationship
    customers_sample = random.sample(range(0, len(customers)), random.randrange((int(num_unibench['person']/100*75)),len(customers)+1))
    for idx in customers_sample:
        knows = random.sample(range(0, len(customers)), random.randrange(1,16))
        if idx in knows: knows.remove(idx)
        customers[idx]['knows'] = list(map(lambda i: { "$numberLong": f"{i}" }, knows))

        if idx % 100 == 0:
            s = f"Customers knows Customers: {round(idx/len(customers_sample)*100,2)}%"
            print(s, end='\r', flush=True)       
    print("Customers knows Customers done                ")




def gen_vendors(f):
    print("Generating vendors...", end='\r', flush=True)
    with open(f, 'r') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        # id,name,country,cdf,industry
        header = next(reader, None)
        for row in reader:
            vendor = {}
            # add id
            vendor['vendor_id'] = int(row[0])
            # add name
            vendor['vendor'] = row[1]
            # add country
            vendor['country'] = row[2]
            vendors.append(vendor)
    print("Vendors done                ")




## DEPENDS:
#  - vendor
def gen_products(f):
    print("Generating products...", end='\r', flush=True)
    with open(f, 'r') as csvfile:
        reader = csv.reader(csvfile, delimiter=',')
        # asin,title,price,imgUrl,productId,brand
        header = next(reader, None)
        for row in reader:
            product = {}
            # add id
            product['product_id'] = int(row[4])
            # add asin
            product['asin'] = row[0]
            # add title
            product['title'] = row[1]
            # add price
            product['price'] = { "$numberDouble": f"{row[2]}" }
            # add brand_id
            product['brand_id'] = int(row[5])
            # add brand
            product['brand'] = None
            for vendor in vendors:
                if vendor['vendor_id'] == int(row[5]):
                    product['brand'] = vendor['vendor']
                    break
            if product['brand'] == None:
                print('ERROR: brand not found')
                sys.exit(1)
            products.append(product)
    print("Products done                ")




## DEPENDS:
#  - customer
#  - product
def gen_orders_and_invoices():
    for idx in range(num_unibench['order']):
        order_obj = {}
        invoice_obj = {}

        invoice_obj['order_id'] = idx + 2000000000000
        order_obj['order_id'] = { "$numberLong": f"{idx + 2000000000000}" } 

        # add customer_id
        customer_obj = customers[random.randrange(0,len(customers))]
        order_obj['customer_id'] = { "$numberLong": f"{customer_obj['customer_id']}" }  
        invoice_obj['customer_id'] = customer_obj['customer_id']
        
        #order_obj['order_date'] = { "$date" : { "$numberLong": f"{fake.date_object().strftime('%s')}" } }
        order_obj['order_line'] = []
        total_price = 0
        for i in range(random.randint(1, 4)):
            order_line_obj = {}
            product_obj = products[random.randrange(0,len(products))]
            #order_line_obj['asin'] = product_obj['asin']
            order_line_obj['product_id'] = product_obj['product_id']
            order_line_obj['asin'] = product_obj['asin']
            order_line_obj['title'] = product_obj['title']
            order_line_obj['price'] = product_obj['price']

            #order_line_obj['brand'] = product_obj['brand']
            order_line_obj['vendor'] = {
                "brand_id": product_obj['brand_id'],
                "brand": product_obj['brand']
            }

            order_obj['order_line'].append(order_line_obj)
            total_price += float(product_obj['price']['$numberDouble'])

        order_obj['total_price'] = { "$numberDouble": f"{round(total_price,2)}" }
        invoice_obj['total_price'] = round(total_price,2)
        #order_obj['number_of_items'] = len(order_obj['order_line'])
        invoice_obj['number_of_items'] = len(order_obj['order_line'])

        orders.append(order_obj)
        invoices.append(invoice_obj)

        _gen_order_feedback(order_obj)

        if idx % 100 == 0:
            s = f"Orders: {round(idx/num_unibench['order']*100,2)}%"
            print(s, end='\r', flush=True) 
    print("Orders done                ")




def _gen_order_feedback(order_obj):
    order_len = len(order_obj['order_line'])
    order_feedbacks = random.randint(1, order_len)
    for i in range(order_feedbacks):
        order_line_obj = order_obj['order_line'][i]
        feedback_obj = {}
        global feedback_id_counter
        feedback_obj['feedback_id'] = feedback_id_counter
        feedback_id_counter += 1
        feedback_obj['person_id'] = int(order_obj['customer_id']['$numberLong'])
        feedback_obj['product_id'] = order_line_obj['product_id']
        feedback_obj['asin'] = order_line_obj['asin']
        feedback_obj['brand_id'] = order_line_obj['vendor']['brand_id']
        feedback_obj['brand'] = order_line_obj['vendor']['brand']
        feedback_obj['feedback'] = fake.paragraph(nb_sentences=random.randint(4, 16))
        feedbacks.append(feedback_obj)




# DEPENDS: 
#   - customers
#   - tags
def gen_posts():
    global post_has_tag_random_range
    for idx in range(num_unibench['post']):
        post_obj = {}
        post_obj['post_id'] = idx + 3000000000000

        customer_obj = customers[random.randrange(0,len(customers))]
        post_obj['person_id'] = customer_obj['customer_id']

        #post_obj['date'] = { "$date" : { "$numberLong": f"{fake.date_object().strftime('%s')}" } }
        #post_obj['title'] = fake.sentence()
        post_obj['content'] = fake.paragraph(nb_sentences=random.randint(4, 16))
        post_obj['length'] = len(post_obj['content'])

        post_obj['has_tags'] = []
        if len(tags) < post_has_tag_random_range:
            post_has_tag_random_range = len(tags)
        tags_sample = random.sample(range(0, len(tags)), random.randrange(1,post_has_tag_random_range))
        for i in tags_sample:
            post_obj['has_tags'].append( tags[i]['tag_id'] )

        posts.append(post_obj)

        if idx % 100 == 0:
            s = f"Posts: {round(idx/num_unibench['post']*100,2)}%"
            print(s, end='\r', flush=True) 
    print("Posts done                ")





# DEPENDS:
# - vendors
def gen_tags():
    global tag_vendor_random_range
    for idx in range(num_unibench['tag']):
        tag_obj = {}
        tag_obj['tag_id'] = idx + 4000000000000

        tag_obj['name'] = fake.word()
        if len(vendors) < tag_vendor_random_range:
            tag_vendor_random_range = len(vendors)
        vendor_sample = random.sample(range(0, len(vendors)), random.randrange(1,tag_vendor_random_range))
        vendor_list = []
        for idx in vendor_sample:
            vendor_list.append(vendors[idx]['vendor'])
        
        # NOTE: Convert list to string for csv export and import into neo4j
        vendor_list_str = ';'.join(vendor_list)
        tag_obj['vendors'] = vendor_list_str
        
        tags.append(tag_obj)

        if idx % 100 == 0:
            s = f"Tags: {round(idx/num_unibench['tag']*100,2)}%"
            print(s, end='\r', flush=True) 
    print("Tags done                ")




def gen_has_interest():
    print("Generating has_interest...", end='\r', flush=True)
    for customer in customers:
        for tag_id in customer['has_interest']:
            interest_obj = {}
            interest_obj['customer_id'] = customer['customer_id']
            interest_obj['tag_id'] = tag_id
            has_interest.append(interest_obj)
        # delete has_interest from customer
        del customer['has_interest']
    print("has_interest done                ")




def gen_wrote_and_has_tag():
    print("Generating wrote,has_tag...", end='\r', flush=True)
    for post in posts:
        wrote_obj = {}
        wrote_obj['person_id'] = post['person_id']
        wrote_obj['post_id'] = post['post_id']
        wrote.append(wrote_obj)

        for tag_id in post['has_tags']:
            has_tag_obj = {}
            has_tag_obj['post_id'] = post['post_id']
            has_tag_obj['tag_id'] = tag_id
            has_tag.append(has_tag_obj)

        # delete has_tags from post
        del post['has_tags']    
        # delete person_id from post
        del post['person_id']
    print("wrote,has_tag done                ")




def gen_has_created():
    print("Generating has_created...", end='\r', flush=True)
    for feedback in feedbacks:
        has_created_obj = {}
        has_created_obj['person_id'] = feedback['person_id']
        has_created_obj['feedback_id'] = feedback['feedback_id']
        has_created.append(has_created_obj)
        # delete person_id from feedback
        del feedback['person_id']
        
    print("has_created done                ")




def write_json_file(l,f):
    with open(f, 'w') as f:
       f.write('[')
       f.write(',\n'.join(map(json.dumps, l)))
       f.write(']')


def write_csv_file(l,f,no_header=False):
    with open(f, 'w') as f:
        header_written = False
        for d in l:
            w = csv.DictWriter(f, d.keys())
            if no_header == False:
                if not header_written:
                    w.writeheader()
                    header_written = True
            w.writerow(d)
    



def main(argv):
    # check arguments
    if len(argv) > 1 or len(argv) == 0:
        print("ERROR - with arguments")
        print("python gen-data.py <scale value>")
        sys.exit()
    scale = float(argv[0])
    
    # scale data
    if scale == 0.0:
        num_unibench['person'] = 4
        num_unibench['order'] = 8
        num_unibench['post'] = 8
        #num_unibench['feedback'] = 8
        num_unibench['tag'] = 8
    else:
        scale_num_data(scale)

    # set folder name and path
    folder_name = "data_sf_" + str(scale).replace('.','_')
    data_folder = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'data')
    output_folder = os.path.join(data_folder, folder_name)

    print(f"## Generating data with scale {scale} ##")
    print(num_unibench)
    vendor_csv_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'vendor.csv')
    product_csv_file = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'product.csv')
    gen_vendors(vendor_csv_file)
    gen_tags()
    gen_customer()
    gen_posts()
    gen_products(product_csv_file)
    gen_orders_and_invoices()
  
    gen_has_interest()
    gen_wrote_and_has_tag()
    gen_has_created()

    # remove vendor_id from vendors
    #for v in vendors:
    #    del v['vendor_id']

    print("Writing data to csv and json files...")
    write_csv_file(customers,os.path.join(output_folder,'customer.csv'),no_header=True)
    write_csv_file(vendors,os.path.join(output_folder,'vendor.csv'))
    write_json_file(orders,os.path.join(output_folder,'order.json'))
    write_csv_file(invoices,os.path.join(output_folder,'invoice.csv'))
    write_csv_file(posts,os.path.join(output_folder,'post.csv'),no_header=True)
    write_csv_file(tags,os.path.join(output_folder,'tag.csv'),no_header=True)
    write_csv_file(feedbacks,os.path.join(output_folder,'feedback.csv'),no_header=True)
    write_csv_file(has_interest,os.path.join(output_folder,'HAS_INTEREST.csv'),no_header=True)
    write_csv_file(wrote,os.path.join(output_folder,'WROTE.csv'),no_header=True)
    write_csv_file(has_tag,os.path.join(output_folder,'HAS_TAG.csv'),no_header=True)
    write_csv_file(has_created,os.path.join(output_folder,'HAS_CREATED.csv'),no_header=True)
    #write_json_file(products,os.path.join(output_folder,'product.json'))
    print("Data generation completed.")

    


if __name__ == '__main__':
    main(sys.argv[1:]) 
