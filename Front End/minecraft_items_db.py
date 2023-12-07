# import psycopg as pg
from psycopg import connect, sql

# select a view from the database
def select_view(view: str, search_attr: str, search_str: str, order_type: str, attributes):
    # first double check order_type to prevent injection
    if order_type != "ASC" and order_type != "DESC":
        raise Exception("ERROR INCORRECT ORDER TYPE! SQL INJECTION ATTEMPT DETECTED!")
    
    cursor = connection.cursor()  # cursor for db connection

    # string variable for the select statement
    cmd = sql.SQL("""SELECT * FROM {}
                     WHERE {} LIKE {}
                     ORDER BY {}""" + order_type + ";")\
        .format(sql.Identifier(view),
                sql.Identifier(search_attr),
                sql.Placeholder(),
                sql.Identifier("item_id"))

    # execute the select statement
    cursor.execute(cmd, (search_str, ))

    # take the output
    output = cursor.fetchall()

    # check is there are no rows and return if so
    if len(output) == 0:
        print("The resulting query had 0 results.")
        return

    # pass to paginate function
    paginate_output(output, attributes)

    # close the cursor
    cursor.close()

# insert information for a new item in items table
def add_item(id:str, name:str, stack:int, a_speed, a_damage, p_obtain:bool, renew:bool):
    cursor = connection.cursor()  # cursor for db connection

    # use try finally to make sure cursor closes
    try:
        # string variable for insert statement
        cmd = sql.SQL("""INSERT INTO  {}
                        VALUES ({}, {}, {}, {}, {}, {}, {});""")\
            .format(sql.Identifier("items"),
                    sql.Placeholder(),
                    sql.Placeholder(),
                    sql.Placeholder(),
                    sql.Placeholder(),
                    sql.Placeholder(),
                    sql.Placeholder(),
                    sql.Placeholder(),)
        
        # execute the insert statement
        cursor.execute(cmd, (id, name, stack, a_speed, a_damage, p_obtain, renew))

        # commit new information
        connection.commit()

        # output success message
        print("Item successfully added to items table.")
    
    # make sure cursor closes
    finally:
        if cursor:
            cursor.close()

# insert information for a new item in survival_obtainable table
def add_survive(id:str, survive:bool):
    cursor = connection.cursor()  # cursor for db connection

    try:
        # string variable for insert statement
        cmd = sql.SQL("""INSERT INTO  {}
                        VALUES ({}, {});""")\
            .format(sql.Identifier("survival_obtainable"),
                    sql.Placeholder(),
                    sql.Placeholder())
        
        # execute the insert statement
        cursor.execute(cmd, (id, survive))

        # commit new information
        connection.commit()

        # output success message
        print("Item successfully added to survival_obtainable table.")
    
    # make sure cursor closes
    finally:
        if cursor:
            cursor.close()

# insert information for a new item in breaking_speeds
def add_b_speed(id:str, b_type_id:int, b_speed):
    cursor = connection.cursor()  # cursor for db connection

    try:
        # string variable for insert statement
        cmd = sql.SQL("""INSERT INTO  {}
                        VALUES ({}, {}, {});""")\
            .format(sql.Identifier("breaking_speeds"),
                    sql.Placeholder(),
                    sql.Placeholder(),
                    sql.Placeholder())
        
        # execute the insert statement
        cursor.execute(cmd, (id, b_type_id, b_speed))

        # commit new information
        connection.commit()

        # output success message
        print("Item successfully added to breaking speeds")
    
    # make sure cursor closes
    finally:
        if cursor:
            cursor.close()

# function that paginates the output from the query
def paginate_output(output, attributes):
    row_amount = len(output)            # amount of rows in current output

    # create variable early for set data type
    header = str("|")

    # create header to print
    for attribute in attributes:
        header += (f" {attribute} | ")
    
    # print header
    print(header)

    # use amount of rows to make for loop for pagination
    for i in range(row_amount):
        # create variable early for set data type
        row = str("|")
        
        # format current row
        for column in output[i]:
            row += (f" {column} |")
        
        # print row
        print(row)

        # if at a row count of 10 prompt user to continue
        if (i + 1) % 10 == 0 and i != (row_amount - 1):
            
            # user input to continue or not
            cont = input("Press ENTER to continue (input anything else to stop)...")

            # stop loop if user no longer wants to continue
            if cont != "":
                break

# VARIABLES FOR GLOBAL USE OF THE PROGRAM
# variable for help message in program to give command instructions
HELP_MESSAGE = """This is a database that consists of all items in Minecraft (Java Edition) 1.19"""

# dictionary of the different views partnered with their command counterpart
VIEW_DICT = {
    "default": "default",
    "breaking speeds": "breaking_speeds_view",
    "food effects": "food_effects_view",
    "smelting obtainable": "smelting_obtainable_view",
    "smeltable items": "smeltable_items_view",
    "fuel duration": "fuel_duration_view",
    "food items": "food_items_view",
    "cooldown": "cooldown_view"
}

# dictionary of the attributes of every view
VIEW_ATTRIBUTES_DICT = {
    "default": ["ID", "Name", "Stackability", "Attack Speed", "Attack Damage", "Damage Per Second", "Peaceful Obtainable", "Renewable", "Survival Obtainable"],
    "breaking speeds": ["ID", "Name", "Breaking Type", "Breaking Speed"],
    "food effects": ["ID", "Name", "Effect", "Effect Degree", "Time", "Chance"],
    "smelting obtainable": ["ID", "Name", "Smelting Method (Obtained)"],
    "smeltable items": ["ID", "Name", "XP From Smelting", "Smelting Method"],
    "fuel duration": ["ID", "Name", "Fuel Duration"],
    "food items": ["ID", "Name", "Hunger", "Saturation"],
    "cooldown": ["ID", "Name", "Cooldown"]
}

# Make user login for connection
while (True):
    # ask the user to login in order to connect to the database
    username = input("Please enter you username and password\nUsername: ")
    password = input("Password: ")

    # make sure username and password are right return error otherwise
    if username == "postgres" and password == "Ilikepie13$":
        print("Logging in user 'postgres'...")
        break
    elif username == "standard_user" and password == "password123":
        print("Logging in user 'standard_user'...")
        break
    else:
        print("ERROR IMPROPER LOGIN INFORMATION! PLEASE TRY AGAIN!")


try:
    # connection to minecraft_items database
    connection = connect(f'dbname=minecraft_items user={username} password={password} port=5432')

    # display help message
    print(HELP_MESSAGE)

    # start while loop to prompt user until the quit
    while True:
        # prompt for input
        query_type = input("Select either 'view' or 'add' to start querying: ").lower()

        # decision logic for query type and onward
        # decision logic for views queries
        if query_type == "view":
            # prompt user again for what view
            view_type = input("Select what view you want to see (default, breaking speeds, food effects, smelting obtainable, smeltable items, fuel duration, food items, cooldown): ").lower()

            # check for view
            try:
                # translate view command to actual view value
                view = VIEW_DICT[view_type]

                # translate view command to table header
                attributes = VIEW_ATTRIBUTES_DICT[view_type]
                
            except BaseException:
                # send error message
                print("ERROR INVALID VIEW NAME! TRY AGAIN!")
                continue
            
            # prompt for search and order terms
            search = input("Enter your search terms and order type (ex. 'id stone ASC') or nothing to continue: ")

            if search == "":
                # enter default values for search and order
                select_view(view, "item_id", "%", "ASC", attributes)
            else:
                # split input up
                search_terms = search.split(" ", 2)
                
                # check for enough inputs
                try:
                    # setup variables from search_terms
                    search_attr = search_terms[0].lower()
                    search_str = "%" + search_terms[1] + "%"
                    order_type = search_terms[2].upper()
                    
                except BaseException:
                    print("ERROR INVALID AMOUNT OF INPUTS! MAKE SURE IT LOOKS LIKE 'id stone ASC'!")
                    continue
                
                # test and reassign search_attr
                if search_attr == "id":
                    search_attr = "item_id"
                elif search_attr == "name":
                    search_attr = "item_name"
                else:
                    print("ERROR INVALID SEARCH ATTRIBUTE! ONLY USE 'id' OR 'name'!")
                    continue
                    
                # test order_type
                if order_type != "ASC" and order_type != "DESC":
                    print("ERROR INVALID ORDER TYPE! ONLY USE 'ASC' OR 'DESC'!")
                    continue

                # run select_view with search parameters
                select_view(view, search_attr, search_str, order_type, attributes)
        
        # decision logic for adding items
        elif query_type == "add":
            # go table by table inserting and adding values to the different tables if necessary
            # start by asking for main inputs for the items table
            items = input("Start by providing the ID, Name, Stackability, Attack Speed, Attack Damage, Peaceful Obtainable, and Renewable values.\nEx. example_item, Example Item, 64, 4, 1, True, False\nInput HERE: ")
            
            # split it with split function
            items_values = items.split(", ")

            # check amount of inputs
            if (len(items_values) != 7):
                print("ERROR INVALID AMOUNT OF INPUTS!")
                continue

            # set values to variables for legibility
            id = items_values[0]
            name = items_values[1]
            stack = items_values[2]
            a_damage = items_values[3]
            a_speed = items_values[4]
            p_obtain = items_values[5]
            renew = items_values[6]

            # run insert for items table with input but in try catch
            try:
                add_item(id, name, stack, a_damage, a_speed, p_obtain, renew)
            except Exception as e:
                print(e)
                break
            
            # move on to survival obtainable input
            survival_obtainable = input("Enter 'true' or 'false' if this item can be obtained in survival: ")
            
            # enter information in try catch
            try:
                add_survive(id, survival_obtainable)
            except Exception as e:
                print(e)
                break
            
            # enter information for breaking speeds
            while(True):
                # prompt for input
                b_speed = input("Enter the breaking speed type ID and the breaking speed:\nEx. 1, 1\nEnter HERE: ")

                # split the input
                b_speed_values = b_speed.split(", ")

                # check amount of inputs and send error if wrong
                if len(b_speed_values) != 2:
                    print("ERROR INVALID AMOUNT OF INPUTS!")
                    break

                # setup variable for legibility
                b_type_id = b_speed_values[0]
                b_speed_num = b_speed_values[1]

                # enter information in try catch
                try:
                    add_b_speed(id, b_type_id, b_speed_num)
                except Exception as e:
                    print(e)
                    break

                # ask user if they want to add an additional speed
                cont = input("Press ENTER to continue (input anything else to stop)...")

                # stop loop if user no longer wants to add breaking speeds
                if (cont != ""):
                    break

        # break out of loop with proper command
        elif query_type == "exit" or query_type == "quit":
            break

        # give error message for anything else
        else:
            print("ERROR UNREGISTERED COMMAND! TRY AGAIN")

# use finally to close connection
finally:
    if connection:
        connection.close()