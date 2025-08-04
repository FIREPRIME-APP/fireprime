import 'dart:convert';

import 'package:http/http.dart' as http;

class ZipCode {
  Future<Map<String, dynamic>> getLatLongByZipCode(
      String input, String countryCode) async {
    Map<String, dynamic> latLong = {};
    String baseURL = 'https://api.zippopotam.us/$countryCode/$input';

    Uri url = Uri.parse(baseURL);

    print('Fetching lat/long for zip code: $baseURL');

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        print('Response: ${response.body}');
        final data = json.decode(response.body);
        if (data['places'] != null) {
          latLong['latitude'] = data['places'][0]['latitude'];
          latLong['longitude'] = data['places'][0]['longitude'];
          return latLong;
        }
        return {};
      } else {
        print('Error: ${response.statusCode} - ${response.body}');
        return {};
      }
    } catch (e) {
      print('Error: $e');
      return {};
    }
  }
}
