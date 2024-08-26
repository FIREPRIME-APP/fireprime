import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:survey_kit/survey_kit.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:path_provider/path_provider.dart';

class QuestionnaireJSON extends StatelessWidget {
  const QuestionnaireJSON({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.white,
        child: Align(
          alignment: Alignment.center,
          child: FutureBuilder<Task>(
            future: getJsonTask(),
            builder: (BuildContext context, AsyncSnapshot<Task> snapshot) {
              if (snapshot.connectionState == ConnectionState.done &&
                  snapshot.hasData &&
                  snapshot.data != null) {
                final Task task = snapshot.data!;
                return SurveyKit(
                  onResult: (SurveyResult result) {
                    // print(result.finishReason);
                    final jsonResult = result.toJson();
                    debugPrint(jsonEncode(jsonResult));
                    writeResults(jsonResult);
                    readResults();
                    Navigator.pushNamed(context, '/');
                  },
                  task: task,
                  showProgress: true,
                  localizations: <String, String>{
                    'cancel': AppLocalizations.of(context)!.cancel,
                    'next': AppLocalizations.of(context)!.next,
                  },
                  themeData: Theme.of(context),
                  surveyProgressbarConfiguration: SurveyProgressConfiguration(
                    backgroundColor: Colors.white,
                  ),
                );
              }
              return const CircularProgressIndicator.adaptive();
            },
          ),
        ),
      ),
    );
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    print('Path: $path');
    return File('$path/results.json');
  }

  Future<File> writeResults(jsonResult) async {
    final file = await _localFile;
    return file.writeAsString('$jsonResult');
  }

  Future<String> readResults() async {
    try {
      final file = await _localFile;
      final contents = await file.readAsString();
      print('contents: $contents');
      return contents;
    } catch (e) {
      return 'no value';
    }
  }

  Future<Task> getJsonTask() async {
    try {
      SharedPreferences sp = await SharedPreferences.getInstance();
      String? languageCode = sp.getString('language_code');
      print('sharedPreferences: $languageCode');
      final String taskJson =
          await rootBundle.loadString('assets/test_language.json');
      final Map<String, dynamic> taskMap = json.decode(taskJson);
      return Task.fromJson(taskMap);
    } catch (e) {
      print('Error: $e');
      rethrow;
    }
  }

  Locale getCurrentAppLocale(BuildContext context) {
    return View.of(context).platformDispatcher.locale;
  }
}
