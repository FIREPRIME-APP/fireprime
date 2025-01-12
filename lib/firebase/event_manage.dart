import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fireprime/firebase/device_manage.dart';

Future<void> saveEventdata({
  required String screenId,
  required String buttonId,
}) async {
  if (await canSaveEventData() == false) {
    return;
  }
  final eventRef = FirebaseFirestore.instance.collection('events').doc();
  final deviceId = await getDeviceId();
  try {
    await eventRef.set({
      'device_id': deviceId,
      'screen_id': screenId,
      'button_id': buttonId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  } catch (e) {
    print('Error adding event: $e');
  }
}
