import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireprime/firebase/device_manage.dart';

Future<void> saveAnswerData({
  required String houseId,
  required String houseAddress,
  required Map<String, dynamic> answers,
  required double lat,
  required double long,
  required double vulnerability,
  required double totalRisk,
}) async {
  final deviceId = await getDeviceId();
  final answerRef = FirebaseFirestore.instance
      .collection('answers')
      .doc(deviceId)
      .collection('answers');
  try {
    await answerRef.add({
      'device_id': deviceId,
      'house_id': houseId,
      'house_address': houseAddress,
      'answers': answers,
      'lat': lat,
      'long': long,
      'vulnerability': vulnerability,
      'total_risk': totalRisk,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Error adding event: $e');
  }
}
