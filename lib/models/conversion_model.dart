import 'package:cloud_firestore/cloud_firestore.dart';

class ConversionModel {
  final String userId;
  final String conversionData;
  final DateTime convertedDate;
  final String imageUrl;

  ConversionModel({
    required this.userId,
    required this.conversionData,
    required this.convertedDate,
    required this.imageUrl,
  });

  factory ConversionModel.fromMap(Map<String, dynamic> map) {
    return ConversionModel(
      userId: map['userId'],
      conversionData: map['conversionData'],
      convertedDate: (map['convertedDate'] as Timestamp).toDate(),
      imageUrl: map['imageUrl'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'userId': userId,
      'conversionData': conversionData,
      'convertedDate': convertedDate,
      'imageUrl': imageUrl,
    };
  }
}
