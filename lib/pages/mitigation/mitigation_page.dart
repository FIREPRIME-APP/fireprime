import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MitigationPage extends StatefulWidget {
  final Map<String, String?> answers;

  const MitigationPage({
    super.key,
    required this.answers,
  });

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

class _MitigationPageState extends State<MitigationPage> {
  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    String languageCode = currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('mitigation_title'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: IconButton(
              icon: const Icon(Icons.home),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const HouseListPage();
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadMitigations(languageCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            Map<String, dynamic> mitigations = snapshot.data!;
            Map<String, List<String>> mitigationTexts = {};
            for (var mitigation in mitigations.entries) {
              for (var answer in widget.answers.entries) {
                if (answer.value != null &&
                    answer.value!.split(',').contains(mitigation.key)) {
                  if (mitigationTexts[mitigation.value['title']] == null) {
                    mitigationTexts[mitigation.value['title']] = [
                      mitigation.value['text']
                    ];
                  } else {
                    mitigationTexts[mitigation.value['title']]!
                        .add(mitigation.value['text']);
                  }
                }
              }
            }
            return SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 10),
                  for (var mitigation in mitigationTexts.entries)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 22.0),
                              child: Text(
                                mitigation.key,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        for (var text in mitigation.value)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(26, 10, 26, 0),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  '\u2022',
                                  style: TextStyle(
                                    fontSize: 15,
                                    height: 1.55,
                                  ),
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                Expanded(
                                  child: Text(
                                    text,
                                    textAlign: TextAlign.left,
                                    softWrap: true,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      height: 1.55,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  const SizedBox(height: 10),
                ],
              ),
            );
          }
          return const SizedBox
              .shrink(); // Add this line to return an empty widget if no data is available
        },
      ),
    );
  }

  Future<Map<String, dynamic>>? _loadMitigations(String languageCode) async {
    try {
      String filePath = 'assets/mitigations_text/$languageCode.json';
      String data = await rootBundle.loadString(filePath);

      print(data);
      return json.decode(data);
    } catch (e) {
      print(e);
      throw Exception('Failed to load mitigations');
    }
  }
}
