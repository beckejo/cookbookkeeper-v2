import requests
import asyncio
import pandas as pd
from bleak import BleakClient
from statistics import mean
import os

# Bluetooth address of the Decent Scale
SCALE_ADDRESS = "FF:22:07:21:31:03"

#MAC windows needs: "FF:22:07:21:31:03"
#MAC mac needs: "064E1059-7EAD-66F9-9351-0FD518C7276B"
# UUID for reading weight notifications and sending commands
WEIGHT_UUID = "0000FFF4-0000-1000-8000-00805F9B34FB"
WRITE_UUID = "000036F5-0000-1000-8000-00805F9B34FB"

# BLE commands
COMMANDS = {
    'tare': bytes.fromhex("030F000000000C"),
}

# USDA API information
API_KEY = "lbjPLUiSxa5yYaxPJX1QgXuNR2pjqNcYfJOQwoeM"

# Cumulative nutrients dictionary
cumulative_nutrients = {}
cumulative_weight = 0

# Dictionary to store individual ingredient data
individual_ingredients = {}

async def send_command(client, command_name):
    """Sends a command to the scale based on the command name."""
    command = COMMANDS.get(command_name)
    if command:
        await client.write_gatt_char(WRITE_UUID, command)
        await asyncio.sleep(0.3)
        await client.write_gatt_char(WRITE_UUID, command)
    else:
        print("Invalid command name.")

async def get_average_weight(client, duration=3):
    """Calculates the average weight over a specified duration (in seconds)."""
    weights = []

    def handle_weight_data(sender, data):
        if len(data) == 10:  # Firmware 1.2+ expects 10-byte messages
            weight_raw = int.from_bytes(data[2:4], byteorder='big', signed=True)
            weight = weight_raw / 10.0  # Convert to grams
            weights.append(weight)

    await client.start_notify(WEIGHT_UUID, handle_weight_data)
    print(f"Gathering weight data for {duration} seconds...")
    await asyncio.sleep(duration)
    await client.stop_notify(WEIGHT_UUID)

    average_weight = mean(weights) if weights else 0
    return average_weight

async def ingredient_usage_procedure(client):
    """Calculates the amount of ingredient used."""
    while True:
        os.system('cls' if os.name == 'nt' else 'clear')
        user_input = input("Please clear the scale, then press 'T' to tare or Enter to continue: ").strip().lower()
        if user_input == 't':
            await send_command(client, 'tare')
            await asyncio.sleep(1)  # Give time for tare to take effect
        elif user_input == '':
            break
        else:
            print("Invalid input. Please press 'T' to tare or Enter to continue.")

    # Step 2: Prompt user to place unused ingredient on the scale
    while True:
        os.system('cls' if os.name == 'nt' else 'clear')
        user_input = input("Place the unused ingredient on the scale, then press 'T' to tare or Enter to continue: ").strip().lower()
        if user_input == 't':
            await send_command(client, 'tare')
            await asyncio.sleep(1)  # Give time for tare to take effect
        elif user_input == '':
            break
        else:
            print("Invalid input. Please press 'T' to tare or Enter to continue.")

    unused_weight = await get_average_weight(client)
    print(f"Average weight of unused ingredient: {unused_weight:.2f} grams")

    # Step 3: Prompt user to use the ingredient and place back on scale
    while True:
        os.system('cls' if os.name == 'nt' else 'clear')
        user_input = input("Use the ingredient, then place the remaining item back on the scale and press 'T' to tare or Enter to continue: ").strip().lower()
        if user_input == 't':
            await send_command(client, 'tare')
            await asyncio.sleep(1)  # Give time for tare to take effect
        elif user_input == '':
            break
        else:
            print("Invalid input. Please press 'T' to tare or Enter to continue.")

    used_weight = await get_average_weight(client)
    print(f"Average weight after using ingredient: {used_weight:.2f} grams")

    # Step 4: Calculate and display the amount of ingredient used
    amount_used = unused_weight - used_weight
    print(f"Amount Used: {amount_used:.2f} grams\n")

    return amount_used

def get_fdc_data_from_upc(upc_code, api_key):
    """Retrieves per-gram nutritional data from USDA API."""
    search_url = "https://api.nal.usda.gov/fdc/v1/foods/search"
    params = {
        "api_key": api_key,
        "query": upc_code
    }
    try:
        response = requests.get(search_url, params=params)
        response.raise_for_status()
        data = response.json()
        if data['foods']:
            food_item = data['foods'][0]
            return food_item
        else:
            print("No food items found for this UPC code.")
    except requests.RequestException as e:
        print(f"Error: Unable to retrieve data ({e})")
    return None

def accumulate_nutritional_data(food_item, amount_used, ingredient_name):
    """Accumulates nutritional data for the used ingredient."""
    global cumulative_weight
    cumulative_weight += amount_used

    nutrients = food_item.get('foodNutrients', [])
    individual_ingredients[ingredient_name] = {
        'amount_used': amount_used,
        'nutrients': {}
    }

    for nutrient in nutrients:
        name = nutrient.get('nutrientName', 'Unknown Nutrient')
        value = nutrient.get('value', 0)
        unit = nutrient.get('unitName', '')

        # Convert to per gram basis and multiply by amount used
        value_per_gram = value / 100
        total_value = value_per_gram * amount_used

        if name not in cumulative_nutrients:
            cumulative_nutrients[name] = {'total_value': 0, 'unit': unit}

        cumulative_nutrients[name]['total_value'] += total_value
        individual_ingredients[ingredient_name]['nutrients'][name] = {'value': total_value, 'unit': unit}

def export_nutrition_data_to_excel():
    """Exports the cumulative nutritional data, ingredient weights, and individual nutrition data to an Excel file."""
    with pd.ExcelWriter('cumulative_nutrition.xlsx') as writer:
        # Write cumulative nutritional data
        cumulative_df = pd.DataFrame.from_dict(cumulative_nutrients, orient='index')
        cumulative_df.reset_index(inplace=True)
        cumulative_df.columns = ['Nutrient', 'Total Value', 'Unit']
        cumulative_df.to_excel(writer, sheet_name='Cumulative Nutrition', index=False)

        # Write ingredient weight data
        weight_data = {'Ingredient': [], 'Weight (grams)': []}
        weight_data['Ingredient'].append('Total Weight')
        weight_data['Weight (grams)'].append(cumulative_weight)
        for ingredient_name, data in individual_ingredients.items():
            weight_data['Ingredient'].append(ingredient_name)
            weight_data['Weight (grams)'].append(data['amount_used'])

        weight_df = pd.DataFrame(weight_data)
        weight_df.to_excel(writer, sheet_name='Weights', index=False)

        # Write individual ingredient nutritional data
        for ingredient_name, data in individual_ingredients.items():
            ingredient_df = pd.DataFrame.from_dict(data['nutrients'], orient='index')
            ingredient_df.reset_index(inplace=True)
            ingredient_df.columns = ['Nutrient', 'Value', 'Unit']
            ingredient_df.to_excel(writer, sheet_name=ingredient_name[:31], index=False)

async def main():
    async with BleakClient(SCALE_ADDRESS) as client:
        print("Connected to the scale.")
        while True:
            os.system('cls' if os.name == 'nt' else 'clear')
            upc_code = input("Enter the UPC code of the ingredient: ").strip()
            if not upc_code:
                print("UPC code cannot be empty. Please try again.")
                continue

            food_item = get_fdc_data_from_upc(upc_code, API_KEY)
            if food_item:
                ingredient_name = food_item.get('description', 'Unknown Ingredient')
                while True:
                    print(f"Ingredient: {ingredient_name}")
                    confirm = input("Is this correct? (y/n): ").strip().lower()
                    if confirm == 'y':
                        break
                    elif confirm == 'n':
                        upc_code = input("Enter the UPC code of the ingredient: ").strip()
                        food_item = get_fdc_data_from_upc(upc_code, API_KEY)
                        if food_item:
                            ingredient_name = food_item.get('description', 'Unknown Ingredient')
                        else:
                            print("No food items found for this UPC code. Please try again.")
                    else:
                        print("Invalid input. Please enter 'y' or 'n'.")

                amount_used = await ingredient_usage_procedure(client)
                accumulate_nutritional_data(food_item, amount_used, ingredient_name)

            while True:
                another = input("Do you want to add another ingredient? (y/n): ").strip().lower()
                if another in ['y', 'n']:
                    break
                print("Invalid input. Please enter 'y' or 'n'.")

            if another == 'n':
                break

        export_nutrition_data_to_excel()
        print("Cumulative nutritional data has been exported to cumulative_nutrition.xlsx")

# Run the async main function
try:
    asyncio.run(main())
except KeyboardInterrupt:
    print("Program interrupted.")
