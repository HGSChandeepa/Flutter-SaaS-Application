import 'dart:io';
import 'package:flutter/material.dart';
import 'package:langvify/constants/colors.dart';

class ImagePreview extends StatelessWidget {
  const ImagePreview({
    Key? key,
    required this.imagePath,
  }) : super(key: key);

  final String? imagePath;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: mainColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: mainColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: imagePath == null
          ? const Center(
              child: Icon(
                Icons.image,
                size: 300,
                color: mainColor,
              ),
            )
          : Image.file(
              File(imagePath!),
              fit: BoxFit.contain,
            ),
    );
  }
}
