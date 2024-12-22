import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// void main() {
//   runApp(const ObesityAnalysisApp());
// }
//
// class ObesityAnalysisApp extends StatelessWidget {
//   const ObesityAnalysisApp({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       debugShowCheckedModeBanner: false,
//       theme: ThemeData.dark(),
//       home: const ObesityAnalysisScreen(),
//     );
//   }
// }

class ObesityAnalysisScreen extends StatelessWidget {
  const ObesityAnalysisScreen({super.key});

  final int maxScale = 60; // Maximum scale value (0-60)
  final double value1= 30.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(
        "Obesity analysis",
        style: TextStyle(
          fontSize: 22,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),),
      backgroundColor: Colors.grey.shade500,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Colors.blueAccent,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  "Obesity analysis",
                  style: TextStyle(
                    fontSize: 22,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // Table Header
            _buildTableHeader(),


            // BMI Row
            _buildTableRow(
              title: "BMI(kg/m²)",
              range: "(18.5~23.9)",
              value: value1,
                progressColor: value1 < 20
                    ? Colors.yellow
                    : value1 <= 40
                    ? Colors.teal
                    : Colors.red, // You can change Colors.red for >40 to suit your design
              scaleColor: Colors.yellow,
              context: context
            ),

            // Body Fat Row
            _buildTableRow(
              title: "Body fat percentage(%)",
              range: "(10.0~20.0)",
              value: 13.4,
                progressColor: value1 < 20
                    ? Colors.yellow
                    : value1 <= 40
                    ? Colors.teal
                    : Colors.red, // You can change Colors.red for >40 to suit your design
                context: context
            ),

            // Obesity Row
            _buildTableRow(
              title: "Obesity",
              range: "(10.0~20.0)",
              value: 17.2,
                progressColor: value1 < 20
                    ? Colors.yellow
                    : value1 <= 40
                    ? Colors.teal
                    : Colors.red, // You can change Colors.red for >40 to suit your design
                context: context
            ),
          ],
        ),
      ),
    );
  }

  // Table Header
  Widget _buildTableHeader() {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(6),
      },
      children: [
        TableRow(
          decoration: BoxDecoration(color: Colors.black54),
          children: [
            _buildHeaderCell("data\n(normal range)"),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: const [
                Expanded(
                  child: Center(
                    child: Text(
                      "On the low side",
                      style: TextStyle(color: Colors.amber, fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "standard",
                      style: TextStyle(color: Colors.teal, fontSize: 12),
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      "On the high side",
                      style: TextStyle(color: Colors.redAccent, fontSize: 12),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  // Table Row
  Widget _buildTableRow({
    required String title,
    required String range,
    required double value,
    required Color progressColor,
    Color scaleColor = Colors.white,
    required BuildContext context,
  }) {
    return Table(
      columnWidths: const {
        0: FlexColumnWidth(2),
        1: FlexColumnWidth(6),
      },
      children: [
        TableRow(
          children: [
            // First Column: Title and Range
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    range,
                    style: const TextStyle(
                      color: Colors.white54,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Second Column: Scale, Dots, and Progress Bar
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Scale Numbers, Lines, and Dots
                Container(
                  width: double.infinity,
                  height: .5,
                  color: scaleColor, // Scale line color
                ),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: List.generate(
                    (maxScale ~/ 5) + 1,
                        (index) => Column(
                      children: [


                        // const SizedBox(height: 4),
                        // Scale Line and Dot
                        Container(
                          width: .5,
                          height: 8,
                          color: scaleColor, // Scale line color
                        ),
                        const SizedBox(height: 2),
                        // Scale Numbers
                        Text(
                          (index * 5).toString(),
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 10,
                          ),
                        ),
                        /*Container(
                          width: 6,
                          height: 6,
                          decoration: BoxDecoration(
                            color: scaleColor,
                            shape: BoxShape.circle,
                          ),
                        ),*/
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 0),

                // Progress Bar with Value Text
                Stack(
                  alignment: Alignment.centerLeft,
                  children: [

                    Container(
                      height: 20,
                      width: (value / maxScale) * MediaQuery.of(context).size.width * 0.8,
                    ),

                    // Background Progress Bar
                    Container(
                      height: 0,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Foreground Progress Bar
                    Container(
                      height: 8,
                      width: (value / maxScale) * MediaQuery.of(context).size.width * 0.8,
                      decoration: BoxDecoration(
                        color: progressColor,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                    // Value Text placed **outside** the progress bar

                    Positioned(
                      left: (value / maxScale) * MediaQuery.of(context).size.width * 0.8 + 4,
                      child: Text(
                        value.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            ),
          ],
        ),
      ],
    );
  }


  // Header Cell for Table
  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
