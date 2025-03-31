import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireprime/config.dart';

Future<void> getApiKey() async {
  var apiKeySnapshot = await FirebaseFirestore.instance
      .collection('apikey')
      .doc('google_api_key')
      .get();

  Config.API_KEY = apiKeySnapshot.data()?['places'] ?? '';

  print('API Key: ${Config.API_KEY}');
}
