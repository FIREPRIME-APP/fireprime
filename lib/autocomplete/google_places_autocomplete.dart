import 'dart:convert';

import 'package:http/http.dart' as http;

class GooglePlacesAutoComplete {
  Future<List<dynamic>> getPredictions(String input, String apiKey,
      String languageCode, String countryCode) async {
    String baseURL = 'https://places.googleapis.com/v1/places:autocomplete/';

    var response = await http.post(Uri.parse(baseURL), body: {
      'input': input,
      'languageCode': languageCode,
      'includedRegionCodes': countryCode,
    }, headers: {
      "X-Goog-Api-Key": apiKey,
    });
    if (response.statusCode == 200) {
      if (json.decode(response.body)['suggestions'] != null) {
        final suggestions = await json.decode(response.body)['suggestions'];
        return suggestions;
      }
      return [];
    } else {
      return [];
    }
  }

  Future<Map<String, dynamic>> getLatLong(String placeId, String apiKey) async {
    String baseUrl = 'https://places.googleapis.com/v1/places/$placeId';
    var response = await http.get(Uri.parse(baseUrl),
        headers: {"X-Goog-Api-Key": apiKey, "X-Goog-FieldMask": 'location'});

    if (response.statusCode == 200) {
      if (json.decode(response.body)['location'] != null) {
        final location = await json.decode(response.body)['location'];
        return location;
      }
      return {};
    } else {
      return {};
    }
  }
}
