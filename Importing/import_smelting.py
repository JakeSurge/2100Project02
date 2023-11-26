import psycopg as pg
import json
import csv

def add_smelting_method(id, name):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO smelting_methods (smelting_method_id, smelting_method_name)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_smeltable_item(id, smelting_xp, smelting_method_id):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO smeltable_items (item_id, smelting_xp, smelting_method_id)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, smelting_xp, smelting_method_id))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_smelting_obtainable(id, smelting_method_id):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO smelting_obtainable (item_id, smelting_method_id)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, smelting_method_id))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

# OPENING FILE EXAMPLE
# #open file if exists
# with open('test.json', 'r') as f:
#     file = json.load(f)         #python list = to json file
    
#     #use for loop to iterate through each json object in the json file
#     for i in file:
#         #convert each json object to a python dictionary
#         item = dict(i)
#         #iterate through the key value pairs of each object
#         for key, value in item.items():
#             print (value)
        
try:
    connection = pg.connect('dbname=minecraft_items user=postgres password=Ilikepie13$ port=5432')      #connection to minecraft_items database

    #pass values for the smelting_methods table
    add_smelting_method(1, 'With Furnace Only')
    add_smelting_method(2, 'With Blast Furnace')
    add_smelting_method(3, 'With Smoker')

    with open('smelting_files/smeltable_items.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use for add_item funct
            id = item['id']
            smelting_xp = item['xp_from_smelting']
            #decision logic for id assignment
            if item['smeltable'] == "With Furnace Only":
                smelting_method_id = 1
            elif item['smeltable'] == "With Blast Furnace":
                smelting_method_id = 2
            elif item['smeltable'] == "With Smoker":
                smelting_method_id = 3
            
            add_smeltable_item(id, smelting_xp, smelting_method_id)
    
    with open('smelting_files/smelting_obtainable.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use for add_item funct
            id = item['id']
            #decision logic for id assignment
            if item['obtainable_by_smelting'] == "With Furnace Only":
                smelting_method_id = 1
            elif item['obtainable_by_smelting'] == "With Blast Furnace":
                smelting_method_id = 2
            elif item['obtainable_by_smelting'] == "With Smoker":
                smelting_method_id = 3
            
            add_smelting_obtainable(id, smelting_method_id)
    
finally:
    if connection:
        connection.close()