// ignore_for_file: library_prefixes, depend_on_referenced_packages

import 'dart:convert';

import 'package:http/http.dart' as http;

class ApiService {
  var client = http.Client();
  Future pushNotification(
      {required String authorization,
      required String title,
      required String body,
      required String token}) async {
    await http.post(
      Uri.parse('https://fcm.googleapis.com/fcm/send'),
      headers: {
        'Authorization': 'key=$authorization',
        'content-type': 'application/json'
      },
      body: json.encode(
        {
          'notification': {
            'title': title,
            'body': body,
            "sound": "default",
            "badge": "1"
          },
          'to': '/token/$token',
        },
      ),
    );
  }
}
