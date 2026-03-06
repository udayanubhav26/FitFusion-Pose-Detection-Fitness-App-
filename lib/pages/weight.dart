import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WeightCounterPage extends StatefulWidget {
  const WeightCounterPage({super.key});

  @override
  State<WeightCounterPage> createState() => _WeightCounterPageState();
}

class _WeightCounterPageState extends State<WeightCounterPage> {
  final TextEditingController _initialWeightController = TextEditingController();
  final TextEditingController _currentWeightController = TextEditingController();

  double? _weightLoss;

  @override
  void initState() {
    super.initState();
    _loadWeights();
  }

  Future<void> _loadWeights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    _initialWeightController.text = prefs.getDouble('initialWeight')?.toString() ?? '';
    _currentWeightController.text = prefs.getDouble('currentWeight')?.toString() ?? '';
    _calculateWeightLoss();
  }

  Future<void> _saveWeights() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? initialWeight = double.tryParse(_initialWeightController.text);
    double? currentWeight = double.tryParse(_currentWeightController.text);

    if (initialWeight != null && currentWeight != null) {
      await prefs.setDouble('initialWeight', initialWeight);
      await prefs.setDouble('currentWeight', currentWeight);
      _calculateWeightLoss();
    }
  }

  void _calculateWeightLoss() {
    double? initialWeight = double.tryParse(_initialWeightController.text);
    double? currentWeight = double.tryParse(_currentWeightController.text);

    if (initialWeight != null && currentWeight != null) {
      setState(() {
        _weightLoss = initialWeight - currentWeight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Weight Counter"),
        backgroundColor: Colors.deepPurple,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            TextField(
              controller: _initialWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Initial Weight (kg)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _currentWeightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Current Weight (kg)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveWeights,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("Calculate Weight Loss"),
            ),
            const SizedBox(height: 30),
            if (_weightLoss != null)
              Text(
                _weightLoss! >= 0
                    ? "You have lost ${_weightLoss!.toStringAsFixed(1)} kg!"
                    : "You have gained ${(_weightLoss! * -1).toStringAsFixed(1)} kg!",
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
          ],
        ),
      ),
    );
  }
}
