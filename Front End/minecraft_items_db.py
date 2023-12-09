# import psycopg as pg
from psycopg import connect, sql
# import inspect for easy tutorial output
import inspect

# select a view from the database
def select_view(view: str, search_attr: str, search_str: str, order_type: str, attributes):
    # first double check order_type to prevent injection
    if order_type != "ASC" and order_type != "DESC":
        raise Exception("\033[91mERROR INCORRECT ORDER TYPE! SQL INJECTION ATTEMPT DETECTED!\033[0m")
    
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
        print("\033[91mThe resulting query had 0 results.\033[0m")
        return

    # pass to paginate function
    paginate_output(output, attributes)

    # close the cursor
    cursor.close()

# function that paginates the output from the query
def paginate_output(output, attributes):
    row_amount = len(output)            # amount of rows in current output

    # create variable early for set data type
    header = str("|")

    # create header to print
    for attribute in attributes:
        header += ( "\033[92m\033[1m " + attribute + "\033[0m |")
    
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

# VARIABLES FOR GLOBAL USE OF THE PROGRAM
# variable for help message in program to give command instructions
TUTORIAL_MESSAGE = """\033[1mThis is a database that consists of all items in Minecraft (Java Edition) 1.19. There are
                  two main actions that can be performed to interact with the data: 'view' and 'add'.\033[0;0m
                  
                        \033[1m\033[92m'view'\033[0;0m: Command that allows you to view data in the database all users can access 
                        this command. After choosing this command you will be given options of what view to
                        select. Every view will have the item ID and name as two of the columns available.
                        
                        \033[1mView Options:\033[0;0m
                        1. \033[1m\033[92mdefault\033[0;0m - Main view of all items with all common attributes excluding breaking speeds
                        since that includes repeats of items for different breaking types.
                        2. \033[1m\033[92mbreaking speeds\033[0;0m - Table of all breaking speeds of all items. Includes multiple types
                        of breaking (different surfaces) and the associated speeds for all items.
                        3. \033[1m\033[92mfood effects\033[0;0m - Table of food items that have effects. Food items can have multiple 
                        effects so items can repeat with different effects of different degrees etc.
                        4. \033[1m\033[92msmelting obtainable\033[0;0m - Table of all items that can be obtained from smelting as well as
                        how an item can be smelted to obtain them
                        5. \033[1m\033[92msmeltable items\033[0;0m - Table of all items that can be smelted, the XP given by that, and how
                        they can be smelted
                        6. \033[1m\033[92mfuel duration\033[0;0m - Table of the duration items can be used for fuel (if it can be)
                        7. \033[1m\033[92mfood items\033[0;0m - Table of the hunger and saturation stats given when a food item is consumed
                        8. \033[1m\033[92mcooldown\033[0;0m - Table of the cooldown of items (if it applies)

                        After choosing your view you will be prompted to enter terms for the search by
                        selecting between searching by the item ID or item name followed by your search
                        parameter and the order type (ascending - ASC, or descending - DESC). The data is
                        always ordered by the item ID.
                            Ex. 'id wood ASC' would provide all tuples with 'wood' in the id in ascending
                            order by the item ID.
                        
                        If you would like to pull up all results just press enter. If you would like to find 
                        all results in descending order use '%' as the search parameter like below.
                            Ex. 'id % DESC' would provide all tuples in descending order by the item ID.
                        
                        \033[1m\033[92m'add'\033[0;0m: Command that allows superusers to add new items to the database. Only superusers can
                        access this command. After choosing this command it will go through step by step how to input
                        the data and format it and will return errors at every case if present. Since only superusers
                        are using this command more documentation is not provided.
                            """

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

# dictionary of the attributes of every view that become headers
VIEW_HEADERS_DICT = {
    "default": ["ID", "Name", "Stackability", "Attack Speed", "Attack Damage", "Damage Per Second", "Peaceful Obtainable", "Renewable", "Survival Obtainable"],
    "breaking speeds": ["ID", "Name", "Breaking Type", "Breaking Speed"],
    "food effects": ["ID", "Name", "Effect", "Effect Degree", "Time", "Chance"],
    "smelting obtainable": ["ID", "Name", "Smelting Method (Obtained)"],
    "smeltable items": ["ID", "Name", "XP From Smelting", "Smelting Method"],
    "fuel duration": ["ID", "Name", "Fuel Duration"],
    "food items": ["ID", "Name", "Hunger", "Saturation"],
    "cooldown": ["ID", "Name", "Cooldown"]
}

# dictionary of the attributes in the database with descriptions to be used in help commands
ATTRIBUTES_DICT = {
    "id": "Official in game item ID which can be used for in game commands.",
    "name": "The name of the item (usually the same as the items display name in game).",
    "stackability": "Amount of the item that can be stacked in one item slot.",
    "attack speed": "The number of fully charged attacks you can perform per second with the item.",
    "attack damage": "Amount of attack damage points per strike with the item.",
    "damage per second": "The amount of damage points per second (calculated by the attack speed x attack damage).",
    "peaceful obtainable": "Value if the item is obtainable at peaceful difficulty in the survival game mode or not.",
    "renewable": "Value if the item can be farmed, crafted, or traded or not (if it is not a finite resource).",
    "survival obtainable": "Value if the item is obtainable in the survival game mode or not.",
    "breaking type": "The type of block being broken paired with the breaking speed of the item on that block (value of 'default' means most blocks if not all).",
    "breaking speed": "The breaking speed of the item on a block specified by breaking type",
    "effect": "The resulting effect (condition that affects an entity in a good or bad way) after the food item has been consumed.",
    "effect degree": "The numerical degree of the effect from the item after being consumed.",
    "time": "The time that the effect from the consumed item will be applied in seconds.",
    "chance": "The chance that the effect from the consumed item will occur (in decimal format ex. '1' = 100%).",
    "smelting method (Obtained)": "The method of smelting (cooking or obtaining refined goods by putting them in a furnace) by which the item can be obtained.",
    "xp from smelting": "Number of experience points received after smelting the item",
    "smelting method": "The method of smelting (cooking or obtaining refined goods by putting them in a furnace) by which the item can be smelted.",
    "fuel duration": "How many seconds the item can be used as a fuel source in the standard furnace.",
    "hunger": "Number of hunger points the item recovers after being consumed.",
    "saturation": "Number of saturation points the item recovers after being consumed (Saturation points set the amount of time before the hunger bar decreases).",
    "cooldown": "Number of seconds the item takes to cooldown after being used (applications vary)."
}

# Make user login for connection
while (True):
    # ask the user to login in order to connect to the database
    username = input("\033[1mPlease enter you username and password.\033[0m\nUsername: ")
    password = input("Password: ")

    # make sure username and password are right return error otherwise
    if username == "postgres" and password == "Ilikepie13$":
        print("\033[94mLogging in user 'postgres'...\033[0m\n")
        break
    elif username == "standard_user" and password == "password123":
        print("\033[94mLogging in user 'standard_user'...\033[0m\n")
        break
    elif username == "" and password == "":
        exit()
    else:
        print("\033[91mERROR IMPROPER LOGIN INFORMATION! PLEASE TRY AGAIN!\033[0m")


try:
    # connection to minecraft_items database
    connection = connect(f'dbname=minecraft_items user={username} password={password} port=5432')

    # display help message
    print(inspect.cleandoc(TUTORIAL_MESSAGE))

    # start while loop to prompt user until the quit
    while True:
        # prompt for input
        query_type = input("Select either 'view', 'add', or 'help' to start (or 'exit' to exit): ").lower()

        # decision logic for query type and onward
        # decision logic for views queries
        if query_type == "view":
            # prompt user again for what view
            view_type = input("Select what view you want to see (use 'help' followed by 'tutorial' to see a list): ").lower()

            # check for view
            try:
                # translate view command to actual view value
                view = VIEW_DICT[view_type]

                # translate view command to table header
                attributes = VIEW_HEADERS_DICT[view_type]
                
            except BaseException:
                # send error message
                print("\033[91mERROR INVALID VIEW NAME! TRY AGAIN!\033[0m")
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
                    print("\033[91mERROR INVALID AMOUNT OF INPUTS! MAKE SURE IT LOOKS LIKE 'id stone ASC'!\033[0m")
                    continue
                
                # test and reassign search_attr
                if search_attr == "id":
                    search_attr = "item_id"
                elif search_attr == "name":
                    search_attr = "item_name"
                else:
                    print("\033[91mERROR INVALID SEARCH ATTRIBUTE! ONLY USE 'id' OR 'name'!\033[0m")
                    continue
                    
                # test order_type
                if order_type != "ASC" and order_type != "DESC":
                    print("\033[91mERROR INVALID ORDER TYPE! ONLY USE 'ASC' OR 'DESC'!\033[0m")
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
                print("\033[91mERROR INVALID AMOUNT OF INPUTS!\033[0m")
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
                    print("\033[91mERROR INVALID AMOUNT OF INPUTS!\033[0m")
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
        
        # output help statement if requested
        elif query_type == "help":
            # prompt the user for either the tutorial or attributes
            help_type = input("Enter what type of help you want ('tutorial' or 'attributes'): ").lower()

            if help_type == "tutorial":
                # display tutorial message
                print(inspect.cleandoc(TUTORIAL_MESSAGE))
            
            elif help_type == "attributes":
                # enter into ifinite while so they can keep prompting
                while(True):
                    # prompt for what attribute they want help with
                    attribute = input("What attribute do you want to know about? (use 'all' for all and use 'menu' to go back): ").lower()

                    # if all print list of all
                    if attribute == "all":
                        # initial space
                        print("")
                        # use for loop to print all
                        for key in ATTRIBUTES_DICT:
                            print("\033[1m\033[92m" + key + "\033[0;0m - " + ATTRIBUTES_DICT[key])
                        # final space
                        print("")
                    
                    # if they want to exit let them exit
                    elif attribute == "menu":
                        break
                    
                    # otherwise print specific if no error
                    else:
                        try:
                            print("\n\033[1m\033[92m" + attribute + "\033[0;0m: " + ATTRIBUTES_DICT[attribute] + "\n")
                        except:
                            # print error and options if they get it wrong
                            print("\033[91mERROR INVALID ATTRIBUTE INPUT! ONLY USE THE FOLLOWING TERMS:\033[0m\n\n\033[1m\033[92mall")
                            for key in ATTRIBUTES_DICT:
                                print("\033[1m\033[92m" + key)
                            # print end color code and enter to format
                            print("\033[0m")
            
            # account for error if wrong selection
            else:
                print("\033[91mERROR INVALID INPUT! ONLY USE 'tutorial' OR 'attributes'.\033[0m")

        # break out of loop with proper command
        elif query_type == "exit" or query_type == "quit":
            break

        # give error message for anything else
        else:
            print("\033[91mERROR UNREGISTERED COMMAND! TRY AGAIN\033[0m")

# use finally to close connection
finally:
    if connection:
        connection.close()