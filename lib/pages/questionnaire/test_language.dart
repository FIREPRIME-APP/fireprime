import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TestLanguageWidget extends StatefulWidget {
  const TestLanguageWidget({super.key});

  @override
  State<TestLanguageWidget> createState() => _TestLanguageWidgetState();
}

class _TestLanguageWidgetState extends State<TestLanguageWidget> {
  String? title;

  @override
  void initState() {
    super.initState();
    getJson().then((value) {
      setState(() {
        title = value;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: title == null
          ? const CircularProgressIndicator()
          : Text(
              AppLocalizations.of(context)!.start(title!),
            ),
    );
  }
}

Future<String> getJson() async {
  try {
    final String taskJson =
        await rootBundle.loadString('assets/test_language.json');
    final Map<String, dynamic> taskMap = json.decode(taskJson);
    print(taskMap);
    String title = taskMap['steps'][0]['title'];
    print(title);
    return title;
  } catch (e) {
    print('Error: $e');
    rethrow;
  }
}
