import psycopg as pg
import json

def add_item(id, name, stackibility, attack_speed, attack_damage, peaceful_obtainable, renewable):
    cursor = connection.cursor()            #cursor for db connection

    #change stackibility value if it is "Unstackable"
    if stackibility.lower() == 'unstackable':
        stackiblity = 1

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO items (item_id, item_name, stackibility, attack_speed, attack_damage, peaceful_obtainable, renewable)
        VALUES (%s, %s, %s, %s, %s, %s, %s);
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name, stackibility, attack_speed, attack_damage, peaceful_obtainable, renewable))

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

    #open file if exists
    with open('items.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)

            #set values of item to variables to use for add_item funct
            id = item['id']
            name = item['item']
            stackibility = item['stackibility']
            attack_speed = item['attack_speed']
            attack_damage = item['attack_damage']
            peaceful_obtainable = item['peaceful_obtainable']
            renewable = item['renewable']
            
            #use add_item to add item information to db
            add_item(id, name, stackibility, attack_speed, attack_damage, peaceful_obtainable, renewable)
finally:
    if connection:
        connection.close()