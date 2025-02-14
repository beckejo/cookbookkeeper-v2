import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'new_recipe_screen.dart';
import 'saved_recipes_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartBites',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'SmartBites Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
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

  Future<void> _saveRecipes() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('savedRecipes', json.encode(_savedRecipes));
  }

  void _navigateToNewRecipeScreen() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewRecipeScreen()),
    );

    if (result != null) {
      setState(() {
        _savedRecipes.add(result);
      });
      _saveRecipes();
    }
  }

  void _navigateToSavedRecipesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const SavedRecipesScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'Welcome to SmartBites',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToNewRecipeScreen,
              child: const Text('New Recipe'),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _navigateToSavedRecipesScreen,
              child: const Text('Saved Recipes'),
            ),
          ],
        ),
      ),
    );
  }
}
