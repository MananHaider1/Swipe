// ignore_for_file: depend_on_referenced_packages

import 'dart:convert';

import 'package:http/http.dart' as http;

import 'package:lamatdating/models/location_prediction_model.dart';

import '../constants.dart';

Future<List<Prediction>?> getLocationPrediction(String input) async {
  var url = Uri.parse(
      'https://maps.googleapis.com/maps/api/place/queryautocomplete/json?input=$input&language=en&key=$locationApiKey');
  var response = await http.get(url, headers: {"Accept": "application/json"});

  if (response.statusCode == 200) {
    var data = json.decode(response.body);
    var predictions = data['predictions'];

    List<Prediction> predictionList = [];
    for (var prediction in predictions) {
      Map<String, dynamic> predictionMap = prediction;
      predictionList.add(Prediction.fromMap(predictionMap));
    }
    return predictionList;
  } else {
    return null;
  }
}
