import psycopg as pg
import json
import csv

def add_breaking_type(id, name):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO breaking_types (breaking_type_id, breaking_type_name)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_breaking_speed(id, type_id, breaking_speed):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO breaking_speeds (item_id, breaking_type_id, breaking_speed)
        VALUES (%s, %s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, type_id, breaking_speed))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_effect(id, name):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO effects (effect_id, effect_name)
        VALUES (%s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

def add_food_effect(id, effect_id, degree, time, chance):
    cursor = connection.cursor()            #cursor for db connection

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO food_effects (item_id, effect_id, effect_degree, time, chance)
        VALUES (%s, %s, %s, %s, %s)
        ON CONFLICT DO NOTHING;
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, effect_id, degree, time, chance))

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
    add_breaking_type(1, 'Default')
    add_breaking_type(2, 'Cobwebs')
    add_breaking_type(3, 'Wool')
    add_breaking_type(4, 'Leaves')

    with open('association_files/breaking_speeds.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use for add_item funct
            id = item['id']
            breaking_speed = item['breaking_speed']
            
            add_breaking_speed(id, 1, breaking_speed)

            #decision logic for outliers of information
            if "sword" in id:
                add_breaking_speed(id, 2, 15)
            elif id == "shears":
                add_breaking_speed(id, 3, 5)
                add_breaking_speed(id, 2, 15)
                add_breaking_speed(id, 4, 15)
    
    with open('association_files/other_items.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for potion in file:
            if potion[0]:
                id = potion[0]
                add_breaking_speed(id, 1, 1)

    #add effects to effect table
    with open('association_files/effects.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        iteration = 0           #variable for keeping track of for loop iteration

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for effect in file:
            iteration+=1

            if effect[0]:
                name = effect[0]
                add_effect(iteration, name)
    
    with open('association_files/food_effects.csv', 'r') as f:
        file = csv.reader(f)

        next(file)

        #for loop that goes through each row of the csv and 
        #pushes values as parameters to function that adds them to the db
        for item in file:
            if item[0]:
                id = item[0]
                effect_id = item[1]
                degree = item[2]
                time = item[3]
                chance = item[4]
                add_food_effect(id, effect_id, degree, time, chance)
finally:
    if connection:
        connection.close()