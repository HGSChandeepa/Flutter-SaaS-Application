import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';
import 'package:langvify/constants/colors.dart';
import 'package:langvify/widgets/image_preview.dart';
import 'package:langvify/services/store_conversions_firestore.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextRecognizer textRecognizer;
  late ImagePicker imagePicker;

  String? pickedImagePath;
  String recognizedText = "";

  bool isRecognizing = false;
  bool isImagePicked = false;

  @override
  void initState() {
    super.initState();

    textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
    imagePicker = ImagePicker();
  }

  // Function to pick an image
  void _pickImage({required ImageSource source}) async {
    final pickedImage = await imagePicker.pickImage(source: source);

    if (pickedImage == null) {
      return;
    }

    setState(() {
      pickedImagePath = pickedImage.path;
      isImagePicked = true;
    });
  }

  // Function to process the picked image
  void _processImage() async {
    if (pickedImagePath == null) return;

    setState(() {
      isRecognizing = true;
      recognizedText = '';
    });

    try {
      final inputImage = InputImage.fromFilePath(pickedImagePath!);
      final RecognizedText recognisedText =
          await textRecognizer.processImage(inputImage);

      recognizedText = "";

      // store the conversion data in the firestore
      try {
        if (recognisedText.blocks.isNotEmpty) {
          //convert the recognizedText to string

          final String recognizedString = recognisedText.blocks
              .map((block) => block.lines.map((line) => line.text).join("\n"))
              .join("\n\n");
          StoreConversionsFirestore().storeConversionData(
            conversionData: recognizedString,
            convertedDate: DateTime.now(),
            imageFile: File(pickedImagePath!),
          );
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: const Text('Text recognized successfully'),
          ),
        );
      } catch (e) {
        print(e.toString());
      }

      print(recognisedText.blocks[0].lines[4].text);

      // Loop through the recognized text blocks and lines and concatenate them
      for (TextBlock block in recognisedText.blocks) {
        for (TextLine line in block.lines) {
          recognizedText += "${line.text}\n";
        }
      }
    } catch (e) {
      //if the state is not mounted, return
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error recognizing text: $e'),
        ),
      );
    } finally {
      setState(() {
        isRecognizing = false;
      });
    }
  }

  void _chooseImageSourceModal() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from gallery'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(source: ImageSource.gallery);
                },
              ),
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Take a picture'),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(source: ImageSource.camera);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _copyTextToClipboard() async {
    if (recognizedText.isNotEmpty) {
      await Clipboard.setData(ClipboardData(text: recognizedText));
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ML Text Recognition',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
        backgroundColor: mainColor,
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.symmetric(
                  vertical: 20,
                ),
                child: ImagePreview(imagePath: pickedImagePath),
              ),
              if (!isImagePicked) // Show "Pick Image" button if image is not picked
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: isRecognizing ? null : _chooseImageSourceModal,
                      child: const Text(
                        'Pick an image',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ],
                ),
              if (isImagePicked) // Show "Process Image" button if image is picked
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    ElevatedButton(
                      onPressed: isRecognizing ? null : _processImage,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text(
                            'Process Image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                            ),
                          ),
                          if (isRecognizing) ...[
                            const SizedBox(width: 20),
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 1.5,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              Padding(
                padding: const EdgeInsets.only(
                  left: 16,
                  right: 16,
                  bottom: 16,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Recognized Text",
                      style: TextStyle(fontSize: 20),
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.copy,
                        size: 20,
                      ),
                      onPressed: _copyTextToClipboard,
                    ),
                  ],
                ),
              ),
              if (!isRecognizing) ...[
                Expanded(
                  child: Scrollbar(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Flexible(
                            child: SelectableText(
                              recognizedText.isEmpty
                                  ? "No text recognized"
                                  : recognizedText,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
