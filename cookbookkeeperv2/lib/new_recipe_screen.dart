import 'package:flutter/material.dart';

class NewRecipeScreen extends StatelessWidget {
  const NewRecipeScreen({super.key});

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
            TextField(
              decoration: const InputDecoration(
                labelText: 'Recipe Name',
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'UPC',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Weight (grams)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Ingredients',
              ),
            ),
            TextField(
              decoration: const InputDecoration(
                labelText: 'Instructions',
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Handle save recipe logic here
              },
              child: const Text('Save Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
