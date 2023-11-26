import psycopg as pg
import json
import csv

def add_survival_obtainable(id, survival_obtainable):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO survival_obtainable (item_id, survival_obtainable)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, survival_obtainable))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_fuel_duration(id, fuel_duration):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO fuel_duration (item_id, fuel_duration)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, fuel_duration))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_cooldown(id, cooldown):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO cooldown (item_id, cooldown)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, cooldown))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_food_item(id, hunger, saturation):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO food_items (item_id, hunger, saturation)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, hunger, saturation))

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

    #open file if exists to add most of items to survial_obtainable table
    with open('other_files/survival_obtainable.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use for add_item funct
            id = item['id']
            survival_obtainable = item['survival_obtainable']
            
            #use add_item to add item information to db
            add_survival_obtainable(id, survival_obtainable)
    
    #open file if exists to add potion items to survival_obtainable
    with open('other_files/potion_id_list.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for potion in file:
            if potion[0]:
                id = potion[0]
                #assign survival_obtainable based off of the type of potion
                if ("uncraftable" in id) or ("luck" in id):
                    survival_obtainable = False
                else:
                    survival_obtainable = True
                #call function to add the potions to the survival_obtainable table
                add_survival_obtainable(id, survival_obtainable)

    #open files if exists to add tipped_arrow items to survival_obtainable
    with open('items_files/tipped_arrows.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for arrow in file:
            if arrow[0]:
                id = arrow[0]
                survival_obtainable = arrow[2]
                #call function to add the potions to the survial_obtainable table
                add_survival_obtainable(id, survival_obtainable)
    
    #open file if exists to add items to fuel duration table
    with open('other_files/fuel_duration.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use
            id = item['id']
            fuel_duration = item['fuel_duration']
            
            #call function to add info to fuel_duration table
            add_fuel_duration(id, fuel_duration)
    
    #open file if exists to add items to cooldown table
    with open('other_files/cooldown.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use
            id = item['id']
            cooldown = item['cooldown']
            
            #call function to add info to cooldown table
            add_cooldown(id, cooldown)
    
    #open file if exists to add items to cooldown table
    with open('other_files/food_items.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use
            id = item['id']
            hunger = item['hunger']
            saturation = item['saturation']
            
            #call function to add info to cooldown table
            add_food_item(id, hunger, saturation)
    
finally:
    if connection:
        connection.close()