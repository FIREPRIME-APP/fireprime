import 'dart:convert';

import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final deviceId = await getDeviceId();
  final deviceDetails = await getDeviceDetails(context);
  print('Device ID: $deviceId');
  print('Device Details: $deviceDetails');
  // save device data to the server
  final deviceRef =
      FirebaseFirestore.instance.collection('devices').doc(deviceId);
  final exists = (await deviceRef.get()).exists;

  if (!exists) {
    print('Device does not exist');
    await deviceRef.set({
      'timestamp': FieldValue.serverTimestamp(),
      'device_id': deviceId,
      'os': deviceDetails['os'],
      'type': deviceDetails['type'],
    });
  }
}
