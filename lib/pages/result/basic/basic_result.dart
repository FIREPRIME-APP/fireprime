import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
//import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/basic_result.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/house/basic/basic_house.dart';
import 'package:fireprime/pages/mitigation/basic/advices_page.dart';
import 'package:fireprime/pages/questionnaire/advanced/questionnaire_page.dart';
import 'package:fireprime/pdf_creation/pdf_creator.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/button_card.dart';
import 'package:fireprime/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class BasicResultPage extends StatefulWidget {
  // final BasicQuestionnaire questionnaire;
  // final int score;
  //final House house;

  const BasicResultPage({super.key});

  @override
  State<BasicResultPage> createState() => _BasicResultPageState();
}

class _BasicResultPageState extends State<BasicResultPage> {
  BasicResult? basicResult;
  String level = 'Unknown';
  int risk = 0;
  String area = 'default';

  @override
  Widget build(BuildContext context) {
    final HouseProvider houseProvider =
        Provider.of<HouseProvider>(context, listen: false);

    House? house = houseProvider.getHouse(houseProvider.currentHouse!);
    area = house.environment;

    basicResult = houseProvider.getCompletedBasicResult();

    print(basicResult);

    if (basicResult != null) {
      level = basicResult?.riskLevel ?? 'Unknown';
      risk = basicResult?.risk ?? -1;
    }

    print('level: $level');
    print('risk: $risk');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('result'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const BasicHousePage();
                },
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(25.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  color: Utils.getBasicRiskColor(level),
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$risk/10',
                      style: Theme.of(context).textTheme.bodyMedium!,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 10),
              const Divider(
                color: Colors.grey,
              ),
              Text(
                '${context.tr('result_intro')}: ${context.tr('risk_levels.$level')[0].toUpperCase() + context.tr('risk_levels.$level').substring(1)}',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.tr('risk_text.$level'),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 30),
              Center(
                child: Column(
                  children: [
                    if (level != 'low')
                      ButtonCard(
                        currentHouse: house,
                        description: context.tr('advanced_mode_title'),
                        buttonText: context.tr('advanced_mode'),
                        cardColor: const Color.fromARGB(255, 184, 194, 219),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const QuestionnairePage(),
                            ),
                          );
                        },
                        enabled: true,
                      ),
                    const SizedBox(height: 20),
                    ButtonCard(
                      currentHouse: house,
                      description: context.tr('advices_intro'),
                      buttonText: context.tr('advices'),
                      cardColor: const Color.fromARGB(255, 159, 171, 201),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdvicesPage(
                              area: area,
                            ),
                          ),
                        );
                      },
                      enabled: true,
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.blueDark, elevation: 5.0),
                      child: Text(
                        context.tr('results_download'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) {
                            return AlertDialog(
                                content: Container(
                              height: 80,
                              width: 200,
                              color: Colors.blueGrey[50],
                              child: Center(
                                  child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const CircularProgressIndicator(),
                                  const SizedBox(height: 10),
                                  Text(
                                    context.tr('downloading'),
                                  ),
                                ],
                              )),
                            ));
                          },
                        );
                        try {
                          /*  saveEventdata(
                              screenId: 'result_page',
                              buttonId: 'download_results');
 */
                          Color riskColor = Utils.getBasicRiskColor(level);
                          String riskLevel = context
                                  .tr('risk_levels.$level')[0]
                                  .toUpperCase() +
                              context.tr('risk_levels.$level').substring(1);
                          String riskText = context.tr('risk_text.$level');
                          Map<String, dynamic> markdownText =
                              await _loadMarkdownData(context, area);
                          File pdf = await PdfCreator.generateBasicResultsPdf(
                            risk,
                            markdownText,
                            riskLevel,
                            riskText,
                            riskColor,
                            house,
                            DateFormat('dd-MM-yyyy')
                                .format(basicResult!.fiDate),
                          );
                          Navigator.of(context).pop();
                          if (Platform.isIOS) await PdfCreator.openPdf(pdf);
                        } catch (e) {
                          print('Error generating or opening PDF: $e');
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(context.tr('pdf_error')),
                            ),
                          );
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<Map<String, dynamic>> _loadMarkdownData(
      BuildContext context, String area) async {
    final localeCode = context.locale.languageCode;
    final path = 'assets/advices/$area/$localeCode.json';
    try {
      return jsonDecode(await rootBundle.loadString(path));
    } catch (e) {
      try {
        final defaultPath = 'assets/advices/$area/en.json';
        return jsonDecode(await rootBundle.loadString(defaultPath));
      } catch (e) {
        const defaultPath = 'assets/advices/default/en.json';
        return jsonDecode(await rootBundle.loadString(defaultPath));
      }
    }
  }
}
