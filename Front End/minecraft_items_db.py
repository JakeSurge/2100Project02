# import psycopg as pg
from psycopg import connect, sql

def select_view(view):
    cursor = connection.cursor()  # cursor for db connection

    # string variable for the select statement
    cmd = sql.SQL("SELECT * FROM {};").format(sql.Identifier(view))

    # execute the select statement
    cursor.execute(cmd, )

    # take the output
    output = cursor.fetchall()

    # print output
    for row in output:
        print(row)

    # close the cursor
    cursor.close()


try:
    # variable for help message in program to give command instructions
    HELP_MESSAGE = """This is a database that consists of all items in Minecraft (Java Edition) 1.19"""

    # dictionary of the different views partnered with their command
    # counterpart
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

    # connection to minecraft_items database
    connection = connect(
        'dbname=minecraft_items user=postgres password=Ilikepie13$ port=5432')

    # display help message
    print(HELP_MESSAGE)

    # start while loop to prompt user until the quit
    while True:
        # prompt for input
        query_type = input(
            "Select either 'preset' or 'custom' to start querying:").lower()

        # decision logic for query type and onward
        if query_type == "preset":
            # prompt user again for what view
            view_type = input(
                "Select what view you want to see (default, breaking speeds, food effects, smelting obtainable, smeltable items, fuel duration, food items, cooldown):").lower()

            # check for view
            try:
                # translate view command to actual view value
                view = VIEW_DICT[view_type]

                # pass view value to select_view function
                select_view(view)
            except BaseException:
                # send error message
                print("ERROR INCORRECT INPUT!!! TRY AGAIN!!!")
        
        elif query_type == "custom":
            #put code here later
            print("Provide a list of attributes, the item ID and name will automatically be included so do not put them in the list.")
        
        elif query_type == "exit" or query_type == "quit":
            #break out of loop
            break
finally:
    if connection:
        connection.close()