import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;

enum ApiServiceMethodType {
  get,
  post,
}

const baseUrl = 'https://api.stripe.com/v1';
final Map<String, String> requestHeaders = {
  'Content-Type': 'application/x-www-form-urlencoded',
  'Authorization': 'Bearer ${dotenv.env['STRIPE_SECRET_KEY']}',
};

Future<Map<String, dynamic>?> apiService({
  required ApiServiceMethodType requestMethod,
  required String endpoint,
  Map<String, dynamic>? requestBody,
}) async {
  final requestUrl = '$baseUrl/$endpoint';

  try {
    final requestResponse = requestMethod == ApiServiceMethodType.get
        ? await http.get(Uri.parse(requestUrl), headers: requestHeaders)
        : await http.post(Uri.parse(requestUrl),
            headers: requestHeaders, body: requestBody);

    if (requestResponse.statusCode == 200) {
      return json.decode(requestResponse.body);
    } else {
      debugPrint('Error: ${requestResponse.body}');
      throw Exception('Failed to fetch data: ${requestResponse.body}');
    }
  } catch (err) {
    debugPrint("Error: $err");
    return null; // Return null if there's an error
  }
}
