import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:share_plus/share_plus.dart';

class ScreenCaptureExample extends StatefulWidget {
  const ScreenCaptureExample({super.key});

  @override
  _ScreenCaptureExampleState createState() => _ScreenCaptureExampleState();
}

class _ScreenCaptureExampleState extends State<ScreenCaptureExample> {
  final GlobalKey _globalKey = GlobalKey();


  Future<ui.Image> _captureImage() async {
    // Wait for the current frame to complete rendering
    await Future.delayed(Duration(milliseconds: 100));

    RenderRepaintBoundary boundary =
    _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary;

    // Check if the boundary needs painting
    if (boundary.debugNeedsPaint) {
      // Wait for the next frame if it hasn't been painted yet
      await Future.delayed(Duration(milliseconds: 50));
    }

    // Capture the image
    ui.Image image = await boundary.toImage(pixelRatio: 3.0);
    return image;
  }

  Future<void> _createPdfAndShareSinglePage(ui.Image capturedImage) async {
    if (await Permission.storage.request().isGranted) {
      try {
        // Step 1: Get image dimensions
        final int imageHeight = capturedImage.height;
        final int imageWidth = capturedImage.width;

        // Step 2: Divide the image height into three equal parts
        final int segmentHeight = (imageHeight / 2).ceil();

        // Step 3: Create a PDF document
        final pdf = pw.Document();
        for (int i = 0; i < 2; i++) {
          final ByteData? byteData = await capturedImage.toByteData(format: ui.ImageByteFormat.png);
          final Uint8List fullImageBytes = byteData!.buffer.asUint8List();

          print("--------------imageWidth------>>  $imageWidth");
          print("--------------segmentHeight------>>  $segmentHeight");
          print("--------------i * segmentHeight------>>  $i * segmentHeight");


          // Step 4: Extract the segment
          final segment = await _cropImageSegment(fullImageBytes, imageWidth, segmentHeight, i * segmentHeight);

          // Step 5: Add the segment to a PDF page
          final segmentImage = pw.MemoryImage(segment);
          pdf.addPage(
            pw.Page(
              build: (pw.Context context) => pw.Container(
                alignment: pw.Alignment.center,
                child: pw.Image(segmentImage),
              ),
            ),
          );
        }

        // Step 6: Define the Downloads folder path
        final Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        final DateTime now = DateTime.now();
        final String formattedTime = now.toIso8601String().replaceAll(':', '-'); // You can customize the format
        final String filePath = "${downloadsDirectory.path}/health_report_$formattedTime.pdf";
        final File file = File(filePath);

        // Step 7: Save the PDF to the Downloads folder
        await file.writeAsBytes(await pdf.save());
        print("PDF saved to $filePath");

        // Step 8: Share the file using Share Plus
        Share.shareFiles([filePath], text: "Here's the PDF!");
      } catch (e) {
        print("Error saving or sharing the PDF: $e");
      }
    } else {
      print("Storage permission not granted.");
      if (await Permission.storage.isPermanentlyDenied) {
        openAppSettings();
      } else {
        final status = await Permission.storage.request();
        if (status.isGranted) {
          await _createPdfAndShare(capturedImage);
        } else {
          openAppSettings();
        }
      }
    }
  }


  Future<Uint8List> _cropImageSegment(
      Uint8List imageBytes,
      int imageWidth,
      int segmentHeight,
      int offsetY,
      ) async {
    final codec = await ui.instantiateImageCodec(imageBytes);
    final frameInfo = await codec.getNextFrame();
    final ui.Image originalImage = frameInfo.image;

    // Crop the image segment
    final ui.PictureRecorder recorder = ui.PictureRecorder();
    final Canvas canvas = Canvas(recorder);
    final Rect cropRect = Rect.fromLTWH(0, offsetY.toDouble(), imageWidth.toDouble(), segmentHeight.toDouble());

    canvas.drawImageRect(
      originalImage,
      cropRect,
      Rect.fromLTWH(0, 0, imageWidth.toDouble(), segmentHeight.toDouble()),
      Paint(),
    );

    // Get the cropped image from the recorder
    final ui.Image croppedImage = await recorder.endRecording().toImage(imageWidth, segmentHeight);
    // Convert the cropped image to bytes
    final ByteData? croppedBytes = await croppedImage.toByteData(format: ui.ImageByteFormat.png);
    return croppedBytes!.buffer.asUint8List();
  }


  // Single page image pdf

  Future<void> _createPdfAndShare(ui.Image capturedImage) async {
    // Step 1: Request storage permission
    if (await Permission.storage.request().isGranted) {
      try {
        // Step 2: Create a PDF document
        final pdf = pw.Document();
        final ByteData? byteData =
        await capturedImage.toByteData(format: ui.ImageByteFormat.png);
        final Uint8List imageBytes = byteData!.buffer.asUint8List();

        final image = pw.MemoryImage(imageBytes);

        pdf.addPage(pw.Page(
          build: (pw.Context context) => pw.Center(child: pw.Image(image)),
        ));

        // Step 3: Define the Downloads folder path
        final Directory downloadsDirectory = Directory('/storage/emulated/0/Download');
        if (!downloadsDirectory.existsSync()) {
          downloadsDirectory.createSync(recursive: true);
        }

        // final String filePath = "${downloadsDirectory.path}/health_report.pdf";
        final DateTime now = DateTime.now();
        final String formattedTime = now.toIso8601String().replaceAll(':', '-'); // You can customize the format
        final String filePath = "${downloadsDirectory.path}/health_report_$formattedTime.pdf";
        final File file = File(filePath);

        // Step 4: Save the PDF to the Downloads folder
        await file.writeAsBytes(await pdf.save());
        print("PDF saved to $filePath");

        // Step 5: Share the file using Share Plus
        Share.shareFiles([filePath], text: "Here's the PDF!");
      } catch (e) {
        print("Error saving or sharing the PDF: $e");
      }
    } else {
      print("Storage permission not granted.");
      // Handle the case where storage permission is not granted
      if (await Permission.storage.isPermanentlyDenied) {
        print("--------------1---------->>");
        print("Storage permission is permanently denied.");
        openAppSettings();
      } else {
        print("----------2-------------->>");
        // Retry requesting permission
        final status = await Permission.storage.request();
        if (status.isGranted) {
          print("------------3------------>>");
          // Permission granted, retry the operation
          await _createPdfAndShare(capturedImage);
        } else {
          print("-----------4------------->>");
          openAppSettings();
        }
      }

      print("------------------------>>");
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Capture Screen Example"),
        actions: [
          IconButton(
            icon: Icon(Icons.picture_as_pdf_outlined),
            onPressed: () async {
              ui.Image image = await _captureImage();
              await _createPdfAndShare(image);
            },
          ),
          IconButton(
            icon: Icon(Icons.picture_as_pdf_sharp),
            onPressed: () async {
              ui.Image image = await _captureImage();
              await _createPdfAndShareSinglePage(image);
            },
          ),
        ],),

      body: SingleChildScrollView(
        child: RepaintBoundary(
          key: _globalKey,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),

            child: Column(
              mainAxisSize: MainAxisSize.min, // Ensures Column doesn't expand infinitely
              children: [
                // ElevatedButton(
                //   onPressed: () async {
                //     ui.Image image = await _captureImage();
                //     await _createPdfAndShare(image);
                //     print("Screen captured!");
                //   },
                //   child: Text("Capture Screen"),
                // ),
                SizedBox(height: 16),
                ContactCard(
                  name: "John Smith",
                  profession: "Business Consultant",
                  phone: "+1 356 3255 3654",
                  email: "johnsmith@mail.com",
                  backgroundColor: Colors.blue,
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "Amanda Black",
                  profession: "Dentist",
                  phone: "+1 356 3255 3654",
                  email: "amandablack@mail.com",
                  backgroundColor: Colors.red,
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "David Hill",
                  profession: "Designer",
                  phone: "+1 356 3255 3654",
                  email: "davidhill@mail.com",
                  backgroundColor: Colors.orange,
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "David Hill",
                  profession: "Designer",
                  phone: "+1 356 3255 3654",
                  email: "davidhill@mail.com",
                  backgroundColor: Colors.orange,
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "David Hill",
                  profession: "Designer",
                  phone: "+1 356 3255 3654",
                  email: "davidhill@mail.com",
                  backgroundColor: Colors.orange,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Table(
                    border: TableBorder.all(color: Colors.grey.shade200),
                    children: const [
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Project"),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Measured Value"),
                          ),
                        ],
                      ),
                      TableRow(
                        children: [
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("Standard weight"),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text("65.0kg"),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 4,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Weight Information
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: const [
                                  Icon(Icons.water_drop, color: Colors.blue),
                                  SizedBox(width: 4),
                                  Text("Total body water: 39.1kg"),
                                ],
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.album, color: Colors.red),
                                  SizedBox(width: 4),
                                  Text("Protein mass: 12.0kg"),
                                ],
                              ),
                              Row(
                                children: const [
                                  Icon(Icons.album, color: Colors.orange),
                                  SizedBox(width: 4),
                                  Text("Mineral: 7.3kg"),
                                ],
                              ),
                            ],
                          ),
                          // Pie chart placeholder
                          Container(
                            width: 80,
                            height: 80,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              shape: BoxShape.circle,
                            ),
                            child: const Center(
                              child: Text(
                                "67.8\nWeight (kg)",
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "David Hill",
                  profession: "Designer",
                  phone: "+1 356 3255 3654",
                  email: "davidhill@mail.com",
                  backgroundColor: Colors.orange,
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "Amanda Black",
                  profession: "Dentist",
                  phone: "+1 356 3255 3654",
                  email: "amandablack@mail.com",
                  backgroundColor: Colors.red,
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "David Hill",
                  profession: "Designer",
                  phone: "+1 356 3255 3654",
                  email: "davidhill@mail.com",
                  backgroundColor: Colors.orange,
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "Amanda Black",
                  profession: "Dentist",
                  phone: "+1 356 3255 3654",
                  email: "amandablack@mail.com",
                  backgroundColor: Colors.red,
                ),
                SizedBox(height: 16),
                ContactCard(
                  name: "David Hill",
                  profession: "Designer",
                  phone: "+1 356 3255 3654",
                  email: "davidhill@mail.com",
                  backgroundColor: Colors.orange,
                ),
              ],
            ),
          ),
        ),
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
        boxShadow: [
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
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    profession,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.edit, color: Colors.white),
                  SizedBox(width: 8),
                  Icon(Icons.info, color: Colors.white),
                ],
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            children: [
              Icon(Icons.phone, color: Colors.white),
              SizedBox(width: 8),
              Text(
                phone,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
          SizedBox(height: 8),
          Row(
            children: [
              Icon(Icons.email, color: Colors.white),
              SizedBox(width: 8),
              Text(
                email,
                style: TextStyle(color: Colors.white),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
