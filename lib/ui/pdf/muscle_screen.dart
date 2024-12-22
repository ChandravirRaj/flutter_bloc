import 'package:flutter/material.dart';

class MuscleFatAnalysisApp extends StatefulWidget {
  const MuscleFatAnalysisApp({super.key});

  @override
  State<MuscleFatAnalysisApp> createState() => _MuscleFatAnalysisAppState();
}

class _MuscleFatAnalysisAppState extends State<MuscleFatAnalysisApp> {
  // State variables for Slider values
  double _weightValue = 78.3;
  double _muscleValue = 32.5;
  double _bodyFatValue = 27.2;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: Scaffold(
        backgroundColor: const Color(0xFF171B25),
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 48.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Text
              const Text(
                "Muscle-Fat Analysis",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                "😎 You reduced 2.3% body fat in 6 months. Only 4% to go! Keep it up!",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),

              // Metric Sections with Sliders
              buildMetric(
                title: "WEIGHT",
                value: _weightValue,
                min: 50,
                max: 100,
                color: Colors.greenAccent,
                onChanged: (val) => setState(() => _weightValue = val),
              ),
              buildMetric(
                title: "MUSCLE",
                value: _muscleValue,
                min: 20,
                max: 50,
                color: Colors.blueAccent,
                onChanged: (val) => setState(() => _muscleValue = val),
              ),
              buildMetric(
                title: "BODY FAT",
                value: _bodyFatValue,
                min: 10,
                max: 40,
                color: Colors.redAccent,
                onChanged: (val) => setState(() => _bodyFatValue = val),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Function to build each metric section
  Widget buildMetric({
    required String title,
    required double value,
    required double min,
    required double max,
    required Color color,
    required Function(double) onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 14,
                ),
              ),
              Text(
                value.toStringAsFixed(1),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Slider replacing LinearProgressIndicator
          Slider(
            value: value,
            min: min,
            max: max,
            activeColor: color,
            inactiveColor: Colors.white24,
            label: value.round().toString(),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
