import psycopg as pg
import json

def add_item(id, name, stackibility, attack_speed, attack_damage, peaceful_obtainable):
    cursor = connection.cursor()            #cursor for db connection

    #change stackibility value if it is "Unstackable"
    if stackibility.lower() == 'unstackable':
        stackiblity = 1

    #string variable for the actual insert sql statement
    sql = """
        INSERT INTO items (item_id, item_name, stackibility, attack_speed, attack_damage, peaceful_obtainable)
        VALUES (%s, %s, %s, %s, %s, %s);
          """

    #execute sql statment with passed parameters
    cursor.execute(sql, (id, name, stackibility, attack_speed, attack_damage, peaceful_obtainable))

    #commit changes and close cursor
    connection.commit()
    cursor.close()

#open file if exists
with open('itemlist.json', 'r') as f:
    file = json.load(f)         #python list = to json file
    
    #use for loop to iterate through each json object in the json file
    for i in file:
        #convert each json object to a python dictionary
        item = dict(i)
        #iterate through the key value pairs of each object
        for key, value in item.items():
            print (value)
        
try:
    connection = pg.connect('dbname=minecraft_items user=postgres password=Ilikepie13$ port=5432')      #connection to minecraft_items database

    #open file if exists
    with open('itemlist.json', 'r') as f:
        file = json.load(f)         #python list = to json file
        
        #use for loop to iterate through each json object in the json file
        for i in file:
            #convert each json object to a python dictionary
            item = dict(i)
            #iterate through the key value pairs of each object
            for key, value in item.items():
                #CHANGE THIS PART
                print (value)
finally:
    if connection:
        connection.close()