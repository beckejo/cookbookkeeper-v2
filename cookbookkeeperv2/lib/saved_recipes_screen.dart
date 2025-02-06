import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedRecipesScreen extends StatefulWidget {
  final List<Map<String, dynamic>> savedRecipes;

  const SavedRecipesScreen({super.key, required this.savedRecipes});

  @override
  _SavedRecipesScreenState createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  List<Map<String, dynamic>> _savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _savedRecipes = widget.savedRecipes;
  }

  Future<void> _deleteRecipe(int index) async {
    setState(() {
      _savedRecipes.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('savedRecipes', json.encode(_savedRecipes));
  }

  void _navigateToRecipeDetailsScreen(
      BuildContext context, Map<String, dynamic> recipe) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailsScreen(recipe: recipe),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Recipes'),
      ),
      body: ListView.builder(
        itemCount: _savedRecipes.length,
        itemBuilder: (context, index) {
          final recipe = _savedRecipes[index];
          return Dismissible(
            key: Key(recipe['name']),
            onDismissed: (direction) {
              _deleteRecipe(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${recipe['name']} deleted')),
              );
            },
            background: Container(color: Colors.red),
            child: ListTile(
              title: Text(recipe['name']),
              onTap: () => _navigateToRecipeDetailsScreen(context, recipe),
            ),
          );
        },
      ),
    );
  }
}

class RecipeDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> recipe;

  const RecipeDetailsScreen({super.key, required this.recipe});

  @override
  Widget build(BuildContext context) {
    final ingredients = recipe['ingredients'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
      ),
      body: ListView.builder(
        itemCount: ingredients.length,
        itemBuilder: (context, index) {
          final ingredient = ingredients[index];
          return ListTile(
            title: Text('UPC: ${ingredient['upc']}'),
            subtitle: Text('Weight: ${ingredient['weight']} grams'),
          );
        },
      ),
    );
  }
}
