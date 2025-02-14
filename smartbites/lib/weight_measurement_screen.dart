import 'package:flutter/material.dart';

class WeightMeasurementScreen extends StatefulWidget {
  const WeightMeasurementScreen({super.key});

  @override
  _WeightMeasurementScreenState createState() =>
      _WeightMeasurementScreenState();
}

class _WeightMeasurementScreenState extends State<WeightMeasurementScreen> {
  final TextEditingController initialWeightController = TextEditingController();
  final TextEditingController finalWeightController = TextEditingController();

  void _calculateWeightUsed() {
    final initialWeight = double.tryParse(initialWeightController.text) ?? 0;
    final finalWeight = double.tryParse(finalWeightController.text) ?? 0;
    final weightUsed = initialWeight - finalWeight;

    Navigator.pop(context, weightUsed);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Weight Measurement'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: initialWeightController,
              decoration: const InputDecoration(
                labelText: 'Initial Weight (grams)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: finalWeightController,
              decoration: const InputDecoration(
                labelText: 'Final Weight (grams)',
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _calculateWeightUsed,
              child: const Text('Next'),
            ),
          ],
        ),
      ),
    );
  }
}
