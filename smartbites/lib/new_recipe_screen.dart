import 'package:flutter/material.dart';
import 'scan_ingredient_screen.dart';

class NewRecipeScreen extends StatefulWidget {
  const NewRecipeScreen({super.key});

  @override
  _NewRecipeScreenState createState() => _NewRecipeScreenState();
}

class _NewRecipeScreenState extends State<NewRecipeScreen> {
  final List<Map<String, dynamic>> _ingredients = [];

  void _navigateToScanIngredientScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ScanIngredientScreen()),
    );

    if (result != null) {
      setState(() {
        _ingredients.add(result);
      });
    }
  }

  void _finishRecipe() async {
    final TextEditingController recipeNameController = TextEditingController();

    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Enter Recipe Name'),
          content: TextField(
            controller: recipeNameController,
            decoration: const InputDecoration(
              labelText: 'Recipe Name',
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, recipeNameController.text);
              },
              child: const Text('Save'),
            ),
          ],
        );
      },
    );

    final recipeName = recipeNameController.text;
    if (recipeName.isNotEmpty) {
      // Save the recipe with the ingredients list
      // For now, just print the recipe name and ingredients
      print('Recipe saved: $recipeName with ingredients: $_ingredients');
      Navigator.pop(context, {'name': recipeName, 'ingredients': _ingredients});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('New Recipe'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView.builder(
                itemCount: _ingredients.length,
                itemBuilder: (context, index) {
                  final ingredient = _ingredients[index];
                  return ListTile(
                    title: Text('UPC: ${ingredient['upc']}'),
                    subtitle: Text('Weight: ${ingredient['weight']} grams'),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _navigateToScanIngredientScreen,
              child: const Text('Add Ingredient'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _finishRecipe,
              child: const Text('Finish'),
            ),
          ],
        ),
      ),
    );
  }
}
