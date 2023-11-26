import psycopg as pg
import json
import csv

def add_item(id, name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO items (item_id, item_name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable)
        VALUES (%s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_potion(id, name, peaceful_obtainable):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO items (item_id, item_name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable)
        VALUES (%s, %s, 1, 4, 1, %s, true)
        ON CONFLICT DO NOTHING;
          """
    
    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name, peaceful_obtainable))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_splash_potion(id, name, peaceful_obtainable):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO items (item_id, item_name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable)
        VALUES (%s, %s, 1, 4, 1, %s, true)
        ON CONFLICT DO NOTHING;
          """
    
    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name, peaceful_obtainable))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_lingering_potion(id, name):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO items (item_id, item_name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable)
        VALUES (%s, %s, 1, 4, 1, false, true)
        ON CONFLICT DO NOTHING;
          """
    
    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_tipped_arrow(id, name):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO items (item_id, item_name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable)
        VALUES (%s, %s, 64, 4, 1, false, true)
        ON CONFLICT DO NOTHING;
          """
    
    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name))

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

    #open file if exists to add most of items to items table
    with open('items_files/items.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use for add_item funct
            id = item['id']
            name = item['item']
            attack_speed = item['attack_speed']
            attack_damage = item['attack_damage']
            peaceful_obtainable = item['peaceful_obtainable']
            renewable = item['renewable']

            #decision logic to prevent issue with stackability
            if item['stackability'] == "Unstackable":
                stackability = 1
            else:
                stackability = item['stackability']
            
            #use add_item to add item information to db
            add_item(id, name, stackability, attack_speed, attack_damage, peaceful_obtainable, renewable)

    #open files if exists to add potion items to items table
    with open('items_files/potions.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for potion in file:
            if potion[0]:
                id = potion[0]
                name = potion[1]
                #assign peaceful_obtainable based off of the type of potion
                if ("Healing" in potion[1]) or ("Fire Resistance" in potion[1]) or ("Weakness" in potion[1]) or ("Invisibility" in potion[1]) or ("Water" in potion[1] and "Water Breathing" not in potion[1]):
                    peaceful_obtainable = True
                else:
                    peaceful_obtainable = False
                #call function to add the potions to the items table
                add_potion(id, name, peaceful_obtainable)
    
    #open files if exists to add splash potion items to items table
    with open('items_files/splash_potions.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for potion in file:
            if potion[0]:
                id = potion[0]
                name = potion[1]
                #assign peaceful_obtainable based off of the type of potion
                if ("Fire Resistance" in potion[1]) or ("Water" in potion[1] and "Water Breathing" not in potion[1]):
                    peaceful_obtainable = True
                else:
                    peaceful_obtainable = False
                #call function to add the potions to the items table
                add_splash_potion(id, name, peaceful_obtainable)
    
    #open files if exists to add lingering potion items to items table
    with open('items_files/lingering_potions.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for potion in file:
            if potion[0]:
                id = potion[0]
                name = potion[1]
                #call function to add the potions to the items table
                add_lingering_potion(id, name)
    
    #open files if exists to add tipped arrow items to items table
    with open('items_files/tipped_arrows.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for arrow in file:
            if arrow[0]:
                id = arrow[0]
                name = arrow[1]
                #call function to add the potions to the items table
                add_tipped_arrow(id, name)

finally:
    if connection:
        connection.close()