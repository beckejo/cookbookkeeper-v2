import 'package:flutter/material.dart';

class WeightMeasurementScreen extends StatelessWidget {
  final String upc;
  const WeightMeasurementScreen({super.key, required this.upc});

  @override
  Widget build(BuildContext context) {
    final TextEditingController initialWeightController =
        TextEditingController();
    final TextEditingController finalWeightController = TextEditingController();

    void saveIngredient() {
      final initialWeight = double.tryParse(initialWeightController.text) ?? 0;
      final finalWeight = double.tryParse(finalWeightController.text) ?? 0;
      final weightUsed = initialWeight - finalWeight;

      Navigator.pop(context, {'upc': upc, 'weight': weightUsed});
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Measurement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: initialWeightController,
              decoration: const InputDecoration(
                labelText: 'Initial Weight (grams)',
              ),
              keyboardType: TextInputType.number,
            ),
            TextField(
              controller: finalWeightController,
              decoration: const InputDecoration(
                labelText: 'Final Weight (grams)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: saveIngredient,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
