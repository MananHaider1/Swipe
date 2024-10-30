import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart';
import 'package:uuid/uuid.dart';

import 'package:lamatdating/constants.dart';

final apiKeyProvider = StateProvider<String?>((ref) => null);
final String uuid = const Uuid().v4();

final baseUrlProvider = Provider<String>((ref) {
  // Replace with the base URL for your environment (sandbox or production)
  // return "https://momodeveloper.mtn.com";
  return "https://sandbox.momodeveloper.mtn.com";
});

Future<String?> fetchApiKey(WidgetRef ref) async {
  final url = Uri.parse("${ref.watch(baseUrlProvider)}/apiuser/$uuid/apikey");
  // final response = await get(url);
  final response = await post(
    url,
    headers: {
      "Ocp-Apim-Subscription-Key": subscriptionKey,
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data["apiKey"];
  } else {
    debugPrint("${response.statusCode}: ${response.body}");
    // Handle error getting API key
    return null;
  }
}

Future<String?> createApiUser(WidgetRef ref) async {
  final url = Uri.parse("${ref.watch(baseUrlProvider)}/apiuser");
  // final response = await get(url);
  final response = await post(
    url,
    headers: {
      "X-Reference-Id": uuid,
      "Ocp-Apim-Subscription-Key": "d484a1f0d34f4301916d0f2c9e9106a2"
    },
  );

  if (response.statusCode == 201) {
    //  final data = jsonDecode(response.body) as Map<String, dynamic>;
    return "Success";
  } else {
    debugPrint("${response.statusCode}: ${response.body}");
    return null;
  }
}

Future<String?> fetchAccessToken(WidgetRef ref) async {
  final apiKey = await fetchApiKey(ref);

  if (apiKey == null) {
    // Handle missing API Key (error or prompt user to generate)
    return null;
  }

  final url = Uri.parse("${ref.watch(baseUrlProvider)}/token");
  final response = await post(
    url,
    headers: {
      "Authorization":
          "Basic ${base64Encode(utf8.encode("$apiKey:$subscriptionKey"))}",
    },
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return data["access_token"];
  } else {
    debugPrint("${response.statusCode}: ${response.body}");
    return null;
  }
}

Future<bool> requestToPay(
  WidgetRef ref, {
  String? amount,
  String? currency,
  String? partyId1,
  String? type,
}) async {
  await createApiUser(ref);
  await fetchApiKey(ref);
  final accessToken = await fetchAccessToken(ref);
  final url =
      Uri.parse("${ref.watch(baseUrlProvider)}/collection/v1_0/requesttopay");
  // final response = await get(url);
  final response = await post(url,
      headers: {
        "Authorization": "Bearer $accessToken",
        "X-Reference-Id": uuid,
        "X-Target-Environment": "sandbox",
      },
      body: jsonEncode({
        "amount": amount,
        "currency": currency,
        "payer": {"partyIdType": "MSISDN", "partyId": partyId1},
        "payerMessage": type,
        "payeeNote": type,
        "payee": {"partyIdType": "MSISDN", "partyId": partyId}
      }));

  if (response.statusCode == 202) {
    return true;
  } else {
    debugPrint("${response.statusCode}: ${response.body}");
    return false;
  }
}
