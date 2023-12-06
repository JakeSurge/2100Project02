import psycopg as pg
#from psycopg import connect, sql

def select_view(view):
    cursor = connection.cursor()  # cursor for db connection

    # string variable for the select statement
    cmd = ("SELECT * FROM %s;")\
    #    .format(sql.Identifier("*"),
    #            sql.Placeholder())

    # execute the select statement
    cursor.execute(cmd, (view, ))

    # take the output
    output = cursor.fetchall()

    # do something with output?
    print(output)

    # close the cursor
    cursor.close()


try:
    # variable for help message in program to give command instructions
    HELP_MESSAGE = """"""

    # dictionary of the different views partnered with their command
    # counterpart
    VIEW_DICT = {
        "default": "public.default",
        "breaking speeds": "public.breaking_speeds_view",
        "food effects": "public.food_effects_view",
        "smelting obtainable": "public.smelting_obtainable_view",
        "smeltable items": "public.smeltable_items_view",
        "fuel duration": "public.fuel_duration_view",
        "food items": "public.food_items_view",
        "cooldown": "public.cooldown_view"
    }

    # connection to minecraft_items database
    connection = pg.connect(
        'dbname=minecraft_items user=postgres password=Ilikepie13$ port=5432')

    # display help message
    print(HELP_MESSAGE)

    select_view("public.food_effects_view")

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
            # work on this later
        #elif query_type == "quit" or query_type == "exit":
            break
        else:
            print("ERROR INCORRECT INPUT!!! TRY AGAIN!!!")
finally:
    if connection:
        connection.close()