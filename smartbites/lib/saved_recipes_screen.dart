import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class SavedRecipesScreen extends StatefulWidget {
  const SavedRecipesScreen({super.key});

  @override
  _SavedRecipesScreenState createState() => _SavedRecipesScreenState();
}

class _SavedRecipesScreenState extends State<SavedRecipesScreen> {
  List<Map<String, dynamic>> _savedRecipes = [];

  @override
  void initState() {
    super.initState();
    _loadSavedRecipes();
  }

  Future<void> _loadSavedRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    final savedRecipesString = prefs.getString('savedRecipes') ?? '[]';
    setState(() {
      _savedRecipes = List<Map<String, dynamic>>.from(json.decode(savedRecipesString));
    });
  }

  Future<void> _deleteRecipe(int index) async {
    setState(() {
      _savedRecipes.removeAt(index);
    });
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('savedRecipes', json.encode(_savedRecipes));
  }

  void _navigateToRecipeDetailsScreen(BuildContext context, Map<String, dynamic> recipe) {
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
            key: Key(recipe['description']),
            onDismissed: (direction) {
              _deleteRecipe(index);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('${recipe['description']} deleted')),
              );
            },
            background: Container(color: Colors.red),
            child: ListTile(
              title: Text(recipe['description']),
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
    final nutrients = recipe['nutrients'] as List<Map<String, dynamic>>;

    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['description']),
      ),
      body: ListView.builder(
        itemCount: nutrients.length,
        itemBuilder: (context, index) {
          final nutrient = nutrients[index];
          return ListTile(
            title: Text('${nutrient['nutrientName']}: ${nutrient['value']} ${nutrient['unitName']}'),
          );
        },
      ),
    );
  }
}
