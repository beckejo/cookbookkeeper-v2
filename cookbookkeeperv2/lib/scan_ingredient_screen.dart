import 'package:flutter/material.dart';
import 'weight_measurement_screen.dart';

class ScanIngredientScreen extends StatelessWidget {
  const ScanIngredientScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final TextEditingController _upcController = TextEditingController();

    void _navigateToWeightMeasurementScreen() {
      final upc = _upcController.text;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => WeightMeasurementScreen(upc: upc),
        ),
      ).then((result) {
        if (result != null) {
          Navigator.pop(context, result);
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Ingredient'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _upcController,
              decoration: const InputDecoration(
                labelText: 'UPC',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _navigateToWeightMeasurementScreen,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
