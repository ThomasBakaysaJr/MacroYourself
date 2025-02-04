# import csv
import os       # needed for clear screen   
import sys
import mysql.connector

cnx = mysql.connector.connect(user='root', password='5737',
                              host='localhost',
                              database='macroyourself')

def main():
    menu()

def menu():
    loop = 1
    choice = 0
    #menu selection loop
    while loop == 1:
        ClearConsole()

        choice = input("""
                       1: Show Recipes
                       2: Show ingredients for recipe
                       3: Insert new recipe
                       4: Add Ingredients to recipe
                       Q: Quit
                       
                       Please Input Choice: """)
        if choice == "1":
            ShowRecipes()
        elif choice == "2":
            ShowIngredients()
        elif choice == "3":
            InsertRecipe()
        elif choice == "4":
            StartInsertIngredients()
        elif choice == 'Q' or choice == 'q':
            cnx.close()
            sys.exit
            loop = 0
        else:
            print("Invalid Selection")
            print("Please try again.")

def ShowRecipes():
    ClearConsole()
    # Show the recipes bro
    cursor = cnx.cursor()
    query = "select createdDate, recId, recFamily, recVariation, recVersion from recipe"
    cursor.execute(query)
    for (createdDate, recId, recFamily, recVariation, recVersion) in cursor:
        print ("{}\t{}\t{}: {}".format(createdDate, recId, recFamily, recVariation))

    cursor.close()
    WaitForKeypress()

def ShowIngredients():
    ClearConsole()

    inIng = input("Input recipe number: ")
    cursor = cnx.cursor()    
    query = ("select recId, recFamily, recVariation, ingName, amountused, servingmeasurement from listRecIng where recId = %s")
    cursor.execute(query, (inIng,))
    for (recId, recFamily, recVariation, ingName, amountused, servingmeasurement) in cursor:
        print("{}\t{} {}".format(ingName, amountused, servingmeasurement))
    
    cursor.close()
    WaitForKeypress()
    # Do the recipe thing

# todo: Need to find a solution to updating a recipe that is used in a meal, so that the already made meal
# keeps the nutrition it already has. Probably give the option to change "recursively" or just make a new recipe
# BIG CHANGE: Will probably scrap the multiple version number of recipes idea and just store the ingredients
# used in a course in a seperate table. So once you make a course, it takes the recipe and creates the 
# the entries in the associated table, this way changes to the recipe will not affect courses that were made already.
# If you want to change the ingredients the course used, code-wise, we would be changing the course's ingredient
# and not the recipe's. This way recipe's stay sepereated from courses and we wont have such a large number of 
# recipes (Like omelette version 1, version 2, version 3 etc)
def InsertRecipe():
    ClearConsole()
    #input
    inRecFamily = input("Input Recipe name (Omelette etc): ")

    while inRecFamily.isspace() or not inRecFamily:
        print("Invalid name.")
        inRecFamily = input("Input Recipe name (Omelette etc): ")

    inRecVariation = input("Input variation. Press enter for default (Original)")
    if inRecVariation.isspace() or not inRecVariation:
        inRecVariation = "Original"

    cursor = cnx.cursor()
    # see if this recipe already exists, i should probably turn this into a store procedure
    query = ("select recVersion from recipe where recFamily = %s and recVariation = %s limit 1")
    cursor.execute(query, (inRecFamily, inRecVariation,))
    result_args = cursor.fetchone()
    #if the recipe exists, get its current version number otherwise set it to 1
    printStatement = inRecFamily + " : " + inRecVariation
    if not result_args:
        printStatement += " is a new recipe. \nCreate new recipe?"
        inVersion = 1
    else:
        printStatement += " already exists. \nCourses and meals made with this recipe will not be affected by changes. \nUpdate recipe?"
            
    print(printStatement)
    #Confirm that this is what the user wants to do
    if not WaitForYesNo():
        print("Aborting add recipe")
        WaitForKeypress()
        return

    #this will be cleaned up to actually let you input ingredients and their amounts, eventually
    #Send the recipe in
    args = (inRecFamily, inRecVariation, inVersion)
    cursor.callproc("ma_InsertRecipe", args)
    #No commits just yet, don't want to add a bunch of random stuff to the database if I dont have to
    cnx.commit()
    cursor.close()
    print ("recipe was successfully inserted.")
    WaitForKeypress()

# Standard way. Primarily will be used to determine which recipe we adding ingredients to
def StartInsertIngredients():
    ClearConsole()
    ListRecipes()
    recipe = input("Select recipe number to add ingredients to. Leave blank to return: ")
    if recipe.isspace() or not recipe:
        print("Cancelled. Returning to main menu.")
        WaitForKeypress()
        return
    determineIngredients(recipe)

def determineIngredients(inRecId):
    listIng = list()
    listAmount = list()
    ListIngredients()

    #Keep adding ingredients. Add the actual ingredient and then the amount of the ingredient added
    print(('\nInsert an ingredient number,\n'
            'type DONE when finished.\n'
            'type cancel at any time to return main menu.\n'))
    while 1 == 1:
        # Will not allow a non-int to be used.
        tempStr = input("Ingredient: ")

        # Test if done adding. If so, send to function that actually adds the ingredients
        if tempStr.lower() == "cancel":
            return
        if tempStr.lower() == "done":
            if len(listIng) > 0:
                InsertIngredients(inRecId, listIng, listAmount)
                return
            else:
                print ("no ingredients added to list, returning to main menu.")
                WaitForKeypress()
                return

        # Test if the input is an int, throw em back if it isnt.
        try:
            tempStr = int(tempStr)
        except:
            print(tempStr + " is not a valid ingredient number.")
            continue

        listIng.append(tempStr)
        tempStr = 0
        
        while not (tempStr > 0):  
            tempStr = input("Amount: ")

            if tempStr.lower() == "cancel":
                return
                    
            # Test if the input is an int, throw em back if it isnt.
            try:
                tempStr = int(tempStr)
            except:
                print(tempStr + " is not a valid amount.")
                tempStr = 0
                continue
        
        listAmount.append(tempStr)

        print("Ingredient " + str(listIng[-1]) + " with amount " + str(listAmount[-1]) + " added.")


    if not len(listIng):
        print("No ingredients added, returning to main menu.")
        return
    
    # NEED TO ADD OPTION TO ADD AMOUNTS, SINCE YOU'RE PUTTING A CERTAIN PORTION OF INGREDIENTS
    # Add each ingredient to the recipe
    count = 0;
    print ("The following ingredients and amounts will be added to recipe #" + inRecId)
    for ing in listIng:
        print(ing + ": " + listAmount[count])

    InsertIngredients(inRecId, listIng, listAmount)
    WaitForKeypress()

# Try adding the ingredients. Will error out if invalid numbers are inserted.
# Rollback transaction if even one ingredient fails to add. Finish and commit otherwise.
def InsertIngredients(inRecId, listIng, listAmount):
    cursor = cnx.cursor()
    try:
        for ing, amount in zip(listIng, listAmount):
            args = (inRecId, ing, amount)
            cursor.callproc("ma_addIngredientToRecipe", args)
    except:
        print("Something went wrong. Ingredient numbers may not exist.")
        cnx.rollback()
        cursor.close()
        WaitForKeypress()
        return
    cursor.close()
    cnx.commit()
    return


def WaitForKeypress():
    input("Press Enter to continue...")

def WaitForYesNo():
    while 1 == 1:
        answer = input("Y/N : ")
        if answer.lower() == "y" or answer.lower() == "yes":
            return True
        elif answer.lower() == "n" or answer.lower() == "no":
            return False
        else:
            print("Invalid choice.")


# List functions. To print things in a nice readable way.
def ListIngredients():
    cursor = cnx.cursor()
    query = "select * from listAllIng"
    cursor.execute(query,)
    print("ID\tName\tMeasured by")
    for (ingId, ingName, servingMeasurement) in cursor:
        print("{}\t{}\t{}".format(ingId, ingName, servingMeasurement))
    cursor.close()
    return

def ListRecipes():
    cursor = cnx.cursor()
    query =  "select * from listAllRec"
    cursor.execute(query,)
    print ("Date Created\tID\tName and Variation")

    for (recId, recName, recVar, date) in cursor:
        print ("{}\t{}\t{}: {}".format(date, recId, recName, recVar))


def ClearConsole():
    os.system('cls')      # windows

if __name__ == '__main__':
    main()
