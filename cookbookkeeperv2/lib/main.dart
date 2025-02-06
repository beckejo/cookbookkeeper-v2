import 'package:flutter/material.dart';
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
      title: 'Cookbook Keeper',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'Cookbook Keeper Home Page'),
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
  void _navigateToNewRecipeScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const NewRecipeScreen()),
    );
  }

  void _navigateToSavedRecipesScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SavedRecipesScreen()),
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
              'Welcome to Cookbook Keeper',
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
