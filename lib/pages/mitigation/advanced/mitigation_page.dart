import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
//import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/pages/questionnaire/advanced/mitigation_questionnaire.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:flutter/material.dart';
import 'package:fireprime/pages/mitigation/advanced/mitigation.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class MitigationPage extends StatefulWidget {
  //final Map<String, String?> answers;

  const MitigationPage({
    super.key,
    //  required this.answers,
  });

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

class _MitigationPageState extends State<MitigationPage> {
  @override
  Widget build(BuildContext context) {
    HouseProvider houseCtrl =
        Provider.of<HouseProvider>(context, listen: false);
    Map<String, String?> answers =
        houseCtrl.getCompletedRiskAssessment()!.answers; //lastCompleted

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
                //    saveEventdata(screenId: 'mitigation_page', buttonId: 'home');
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _loadMitigations(
            languageCode), //Mitigation.loadMitigations(languageCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (snapshot.hasData) {
            Map<String, List<Map<String, String>>> mitigationTexts =
                Mitigation.getMitigationsTextsByAnswer(
                    snapshot.data!['mitigations'], answers);
            return SingleChildScrollView(
              child: Column(
                children: [
                  for (var mitigation in mitigationTexts.entries)
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 22.0),
                                child: Text(
                                  mitigation.key,
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        for (var mitigationDetail in mitigation.value) ...[
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
                                    mitigationDetail['text']!,
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
                          if (mitigationDetail['url'] != '') ...[
                            Padding(
                              padding: const EdgeInsets.fromLTRB(35, 5, 26, 0),
                              child: Align(
                                alignment: Alignment.centerLeft,
                                child: GestureDetector(
                                  onTap: () async {
                                    final url =
                                        Uri.parse(mitigationDetail['url']!);
                                    if (await canLaunchUrl(url)) {
                                      await launchUrl(url,
                                          mode: LaunchMode.externalApplication);
                                    } else {
                                      print('Error launching URL: $url');
                                    }
                                  },
                                  child: Text(
                                    mitigationDetail['url_text'] != ''
                                        ? mitigationDetail['url_text']!
                                        : mitigationDetail['url']!,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.blue,
                                      decoration: TextDecoration.underline,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                          if (mitigationDetail['questionId'] != '') ...[
                            Padding(
                              padding:
                                  const EdgeInsets.fromLTRB(26, 10, 26, 10),
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Constants.blueDark,
                                  elevation: 5.0,
                                ),
                                onPressed: () {
                                  print(
                                      'Before pressing improve button $answers');
                                  Navigator.of(context).push(
                                    MaterialPageRoute(
                                      builder: (BuildContext context) {
                                        return MitigationQuestionnaire(
                                          answers: answers,
                                          questionsId:
                                              mitigationDetail['questionId']!,
                                        );
                                      },
                                    ),
                                  );
                                },
                                child: Text(
                                  context.tr('improve'),
                                  style: const TextStyle(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                          const SizedBox(height: 10),
                        ],
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
      Map<String, dynamic>? mitigations =
          await Mitigation.loadMitigations(languageCode);
      Map<String, dynamic>? mitigationNavigation =
          await Mitigation.loadNavigation();
      return {
        'mitigations': mitigations,
        'navigation': mitigationNavigation,
      };
    } catch (e) {
      throw Exception('Failed to load mitigations');
    }
  }

  /*Future<Map<String, dynamic>>? _loadMitigations(String languageCode) async {
    try {
      String filePath = 'assets/mitigations_text/$languageCode.json';
      String data = await rootBundle.loadString(filePath);

      print(data);
      return json.decode(data);
    } catch (e) {
      print(e);
      throw Exception('Failed to load mitigations');
    }
  }*/
}
