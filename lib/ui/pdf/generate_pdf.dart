import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:pdf/pdf.dart';

void main() {
  runApp(MaterialApp(home: ScreenshotAndPdf()));
}

class ScreenshotAndPdf extends StatefulWidget {
  const ScreenshotAndPdf({super.key});

  @override
  _ScreenshotAndPdfState createState() => _ScreenshotAndPdfState();
}

class _ScreenshotAndPdfState extends State<ScreenshotAndPdf> {
  final GlobalKey bodyHeightKey = GlobalKey();
  final GlobalKey bodyWeightKey = GlobalKey();
  final GlobalKey fullBodyDetailsKey = GlobalKey();
  final GlobalKey fullBodyDetailsKey4 = GlobalKey();
  final GlobalKey fullBodyDetailsKey5 = GlobalKey();
  final GlobalKey fullBodyDetailsKey6 = GlobalKey();
  final GlobalKey fullBodyDetailsKey7 = GlobalKey();
  final GlobalKey fullBodyDetailsKey8 = GlobalKey();

  Future<Uint8List> _captureScreenshot(GlobalKey key) async {
    try {
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null)
        throw Exception("Unable to find boundary for key: $key");
      final image =
          await boundary.toImage(pixelRatio: 3.0); // High-quality image
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData!.buffer.asUint8List();
    } catch (e) {
      throw Exception("Error capturing screenshot: $e");
    }
  }

  // Future<String> _savePdf(List<Uint8List> images) async {
  //
  //     final directory = await getTemporaryDirectory();
  //     final DateTime now = DateTime.now();
  //     final String formattedTime = now.toIso8601String().replaceAll(':', '-');
  //     final String filePath = "${directory.path}/health_report_$formattedTime.pdf";
  //
  //     // Create PDF
  //     final pdf = pw.Document();
  //     for (var image in images) {
  //       final pdfImage = pw.MemoryImage(image);
  //       pdf.addPage(pw.Page(build: (pw.Context context) => pw.Center(child: pw.Image(pdfImage))));
  //     }
  //
  //     final file = File(filePath);
  //     await file.writeAsBytes(await pdf.save());
  //     return filePath;
  // }

  // Future<String> _savePdf(List<Uint8List> images) async {
  //   final directory = await getTemporaryDirectory();
  //   final DateTime now = DateTime.now();
  //   final String formattedTime = now.toIso8601String().replaceAll(':', '-');
  //   final String filePath = "${directory.path}/health_report_$formattedTime.pdf";
  //
  //   // Create PDF
  //   final pdf = pw.Document();
  //
  //   // Define the grid layout
  //   pdf.addPage(
  //     pw.Page(
  //       build: (pw.Context context) {
  //         return pw.Wrap(
  //           spacing: 10, // Horizontal spacing between items
  //           runSpacing: 10, // Vertical spacing between items
  //           children: images.map((image) {
  //             final pdfImage = pw.MemoryImage(image);
  //             return pw.Container(
  //               width: (context.page.pageFormat.availableWidth - 30) / 2, // Half-width
  //               height: 300,
  //               child: pw.Image(
  //                 pdfImage,
  //                 fit: pw.BoxFit.contain, // Ensures the image is fully visible without cropping
  //               ),
  //             );
  //           }).toList(),
  //         );
  //       },
  //     ),
  //   );
  //
  //   // Write PDF to file
  //   final file = File(filePath);
  //   await file.writeAsBytes(await pdf.save());
  //   return filePath;
  // }

  Future<String> _savePdf(List<Uint8List> images) async {
    final directory = await getTemporaryDirectory();
    final DateTime now = DateTime.now();
    final String formattedTime = now.toIso8601String().replaceAll(':', '-');
    final String filePath =
        "${directory.path}/health_report_$formattedTime.pdf";

    // Create PDF
    final pdf = pw.Document();

    // Define the grid layout
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4, // Use the correct PageFormat from pw
        build: (pw.Context context) {
          final availableWidth = context.page.pageFormat.availableWidth;
          final itemWidth = (availableWidth - 30) / 2; // Half-width with spacing
          const gridItemHeight = 150.0; // Fixed height for grid items
          const fullWidthItemHeight = 160.0; // Fixed height for first and last items

          // Ensure images list has at least 3 elements (first, middle, last)
          final firstImage = images.isNotEmpty ? images.first : null;
          final lastImage = images.length > 1 ? images.last : null;
          final remainingImages = images.length > 2
              ? images.sublist(1, images.length - 1)
              : [];

          return pw.Align(
            alignment: pw.Alignment.topCenter, // Align content to the top-center
            child: pw.Container(
              decoration: pw.BoxDecoration(
                color: PdfColors.grey500, // Optional background color
              ),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  // Full-width first image
                  if (firstImage != null)
                    pw.Container(
                      width: context.page.pageFormat.width, // Correctly use the full width of the PDF page
                      height: fullWidthItemHeight,
                      child: pw.Image(
                        pw.MemoryImage(firstImage),
                        fit: pw.BoxFit.fill, // Ensures the image fits fully within the container
                      ),
                    ),
                  // Grid for remaining images
                  if (remainingImages.isNotEmpty)
                    pw.Wrap(
                      spacing: 22.5, // Horizontal spacing
                      runSpacing: 10, // Vertical spacing
                      children: remainingImages.map((image) {
                        final pdfImage = pw.MemoryImage(image);
                        return pw.Container(
                          width: itemWidth,
                          height: gridItemHeight,
                          child: pw.Image(
                            pdfImage,
                            fit: pw.BoxFit.contain, // Ensures the image is fully visible
                          ),
                        );
                      }).toList(),
                    ),
                  // Full-width last image
                  if (lastImage != null)
                    pw.Container(
                      width: context.page.pageFormat.width,
                      height: fullWidthItemHeight,
                      child: pw.Image(
                        pw.MemoryImage(lastImage),
                        fit: pw.BoxFit.fill, // Adjust fit if cropping isn't needed
                      ),
                    ),
                ],
              ),
            )
          );


        },
      ),
    );

    // Write PDF to file
    final file = File(filePath);
    await file.writeAsBytes(await pdf.save());
    return filePath;
  }

  Future<void> _captureAndGeneratePdf() async {
    try {
      // Capture individual screenshots
      final bodyHeightImage = await _captureScreenshot(bodyHeightKey);
      final bodyWeightImage = await _captureScreenshot(bodyWeightKey);
      final fullBodyDetailsImage = await _captureScreenshot(fullBodyDetailsKey);
      final fullBodyDetailsImage4 =
          await _captureScreenshot(fullBodyDetailsKey);
      final fullBodyDetailsImage5 =
          await _captureScreenshot(fullBodyDetailsKey);
      final fullBodyDetailsImage6 =
          await _captureScreenshot(fullBodyDetailsKey);
      final fullBodyDetailsImage7 =
          await _captureScreenshot(fullBodyDetailsKey);
      final fullBodyDetailsImage8 =
          await _captureScreenshot(fullBodyDetailsKey);

      // Save PDF to Downloads folder
      final pdfPath = await _savePdf([
        bodyHeightImage,
        bodyWeightImage,
        fullBodyDetailsImage,
        fullBodyDetailsImage4,
        fullBodyDetailsImage5,
        fullBodyDetailsImage6,
        fullBodyDetailsImage7,
        fullBodyDetailsImage8
      ]);

      final xFile = XFile(pdfPath);
      await Share.shareXFiles([xFile]);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Capture and Share Report"),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _captureAndGeneratePdf,
          )
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            RepaintBoundary(
              key: bodyHeightKey,
              child: _segmentCard("Body Height",
                  "This section contains details about body height."),
            ),
            RepaintBoundary(
              key: bodyWeightKey,
              child: _segmentCard("Body Weight",
                  "This section contains details about body weight."),
            ),
            RepaintBoundary(
              key: fullBodyDetailsKey,
              child: _segmentCard("Full Body Details",
                  "This section contains full body details."),
            ),
            RepaintBoundary(
              key: fullBodyDetailsKey4,
              child: _segmentCard("Full Body Details",
                  "This section contains full body details."),
            ),
            RepaintBoundary(
              key: fullBodyDetailsKey5,
              child: _segmentCard("Full Body Details",
                  "This section contains full body details."),
            ),
            RepaintBoundary(
              key: fullBodyDetailsKey6,
              child: _segmentCard("Full Body Details",
                  "This section contains full body details."),
            ),
            RepaintBoundary(
              key: fullBodyDetailsKey7,
              child: _segmentCard("Full Body Details",
                  "This section contains full body details."),
            ),
            RepaintBoundary(
              key: fullBodyDetailsKey8,
              child: _segmentCard("Full Body Details",
                  "This section contains full body details."),
            ),
          ],
        ),
      ),
    );
  }

  Widget _segmentCard(String title, String description) {
    return Container(
      padding: EdgeInsets.only(left: 20,top: 0,bottom: 0,right: 20),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          ContactCard(
            name: "John Smith",
            profession: "Business Consultant",
            phone: "+1 356 3255 3654",
            email: "johnsmith@mail.com",
            backgroundColor: Colors.blue,
          ),
          SizedBox(height: 16),
        ],
      ),
    );
  }
}

class ContactCard extends StatelessWidget {
  final String name;
  final String profession;
  final String phone;
  final String email;
  final Color backgroundColor;

  const ContactCard({
    required this.name,
    required this.profession,
    required this.phone,
    required this.email,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    profession,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              const Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 8),
                  Icon(Icons.info, color: Colors.white),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.phone, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                phone,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.email, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                email,
                style: const TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
