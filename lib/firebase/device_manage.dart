import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<bool> canSaveEventData() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  return prefs.getBool('accepted_privacy') ?? false;
}

Future<String> getDeviceId() async {
  final deviceInfo = DeviceInfoPlugin();
  String deviceUniqueId;

  if (Platform.isAndroid) {
    final androidInfo = await deviceInfo.androidInfo;
    deviceUniqueId = androidInfo.id;
  } else if (Platform.isIOS) {
    final iosInfo = await deviceInfo.iosInfo;
    deviceUniqueId = iosInfo.identifierForVendor ?? 'unknown';
  } else {
    deviceUniqueId = 'unknown';
  }

  return sha256.convert(utf8.encode(deviceUniqueId)).toString();
}

Future<Map<String, String>> getDeviceDetails(BuildContext context) async {
  if (Platform.isAndroid) {
    return {
      'os': 'android',
      'type': isSmartphone(context) ? 'smartphone' : 'tablet',
    };
  } else if (Platform.isIOS) {
    return {
      'os': 'ios',
      'type': isSmartphone(context) ? 'smartphone' : 'tablet',
    };
  } else {
    return {'os': 'unknown', 'type': 'unknown'};
  }
}

bool isSmartphone(BuildContext context) {
  var shortestSide = MediaQuery.of(context).size.shortestSide;
  return shortestSide < 550;
}

Future<void> saveDeviceData(BuildContext context) async {
  if (await canSaveEventData() == false) {
    return;
  }
  final deviceId = await getDeviceId();

  if (!context.mounted) {
    throw Exception('Widget not mounted');
  }

  final deviceDetails = await getDeviceDetails(context);
  final deviceRef =
      FirebaseFirestore.instance.collection('devices').doc(deviceId);
  final exists = (await deviceRef.get()).exists;

  if (!exists) {
    try {
      await deviceRef.set({
        'timestamp': FieldValue.serverTimestamp(),
        'device_id': deviceId,
        'os': deviceDetails['os'],
        'type': deviceDetails['type'],
      });
    } catch (e) {
      print('Error adding event: $e');
    }
  }
}
