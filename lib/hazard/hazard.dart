import 'package:http/http.dart' as http;
//import 'dart:convert';

//bbox and xy coordenates of the map
Future<double> getHazard(String country) async {
  Uri url;
  if (country == 'spain') {
    url = Uri.parse(
        'https://maps.effis.emergency.copernicus.eu/effis?map=/mnt/efs/mapfiles/wfra.map&REQUEST=GetFeatureInfo&INFO_FORMAT=text/html&CRS=EPSG:3857&VERSION=1.3.0&LAYERS=danger-by-weather-fwi30-days&QUERY_LAYERS=danger-by-weather-fwi30-days&SERVICE=wms&width=800&height=800&x=400&y=400&bbox=225593.1754,5069147.2194,243700.3554,5084428.5094');
  } else if (country == 'sweden') {
    url = Uri.parse(
        'https://maps.effis.emergency.copernicus.eu/effis?map=/mnt/efs/mapfiles/wfra.map&REQUEST=GetFeatureInfo&INFO_FORMAT=text/html&CRS=EPSG:3857&VERSION=1.3.0&LAYERS=danger-by-weather-fwi30-days&QUERY_LAYERS=danger-by-weather-fwi30-days&SERVICE=wms&width=800&height=800&x=400&y=400&bbox=1306589.0348,7909759.9630,1317443.1304,7918737.6295');
  } else if (country == 'austria') {
    url = Uri.parse(
        'https://maps.effis.emergency.copernicus.eu/effis?map=/mnt/efs/mapfiles/wfra.map&REQUEST=GetFeatureInfo&INFO_FORMAT=text/html&CRS=EPSG:3857&VERSION=1.3.0&LAYERS=danger-by-weather-fwi30-days&QUERY_LAYERS=danger-by-weather-fwi30-days&SERVICE=wms&width=800&height=800&x=400&y=400&bbox=1256879.5475,5990038.1762,1289135.9735,6013112.9240');
  } else {
    return 1.0;
  }
  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final data = response.body;
      double hazard = getHazardValue(data);
      return hazard;
    } else {
      print('Failed to get hazard data:' + response.statusCode.toString());
      return -1.0;
    }
  } catch (e) {
    print('Failed to get hazard data' + e.toString());
    return -1.0;
  }
}

double getHazardValue(String data) {
  final regex = RegExp(r'(\d+\.\d+)'); // Captura cualquier número con decimales
  final value = regex.firstMatch(data);

  if (value != null) {
    double hazard = double.parse(value.group(1)!);
    print('Hazard value: $hazard');
    return hazard;
  } else {
    return 1.0;
  }
}
