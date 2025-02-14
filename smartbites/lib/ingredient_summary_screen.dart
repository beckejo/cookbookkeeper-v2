import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'saved_recipes_screen.dart';

class IngredientSummaryScreen extends StatelessWidget {
  final String description;
  final List<Map<String, dynamic>> nutrients;

  const IngredientSummaryScreen({
    super.key,
    required this.description,
    required this.nutrients,
  });

  Future<void> _saveRecipe(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipesString = prefs.getString('savedRecipes') ?? '[]';
    final savedRecipes = List<Map<String, dynamic>>.from(json.decode(savedRecipesString));

    final newRecipe = {
      'description': description,
      'nutrients': nutrients,
    };

    savedRecipes.add(newRecipe);
    prefs.setString('savedRecipes', json.encode(savedRecipes));

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const SavedRecipesScreen()),
      (Route<dynamic> route) => false,
    );
  }

  void _addAnotherIngredient(BuildContext context) {
    Navigator.pop(context, {'description': description, 'nutrients': nutrients});
  }

  void _showConfirmationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Recipe'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Description: $description'),
              const SizedBox(height: 10),
              const Text('Nutrients:'),
              ...nutrients.map((nutrient) {
                return Text('${nutrient['nutrientName']}: ${nutrient['value']} ${nutrient['unitName']}');
              }).toList(),
            ],
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
                _saveRecipe(context);
              },
              child: const Text('Save Recipe'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _addAnotherIngredient(context);
              },
              child: const Text('Add Another Ingredient'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ingredient Summary'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              description,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: nutrients.length,
                itemBuilder: (context, index) {
                  final nutrient = nutrients[index];
                  return ListTile(
                    title: Text(
                      '${nutrient['nutrientName']}: ${nutrient['value']} ${nutrient['unitName']}',
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => _showConfirmationDialog(context),
              child: const Text('Finish'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () => _addAnotherIngredient(context),
              child: const Text('Add Another Ingredient'),
            ),
          ],
        ),
      ),
    );
  }
}