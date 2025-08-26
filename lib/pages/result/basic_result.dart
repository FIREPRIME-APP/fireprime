import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/model/basic_result.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/house/basic/basic_house.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/pages/mitigation/advices_page.dart';
import 'package:fireprime/pages/questionnaire/questionnaire_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:flutter/material.dart';
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
            Navigator.of(context).pop();
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
                  color: Colors.grey[200],
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
                context.tr('result_intro'),
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.tr('risk_levels.$level')[0].toUpperCase() +
                    context.tr('risk_levels.$level').substring(1),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                context.tr('risk_text.${area}_$level'),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
              const SizedBox(height: 50),
              Center(
                child: Column(
                  children: [
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.blueDark, elevation: 5.0),
                      child: Text(
                        context.tr('advices'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        //TODO ADVICES
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdvicesPage(
                              area: area,
                            ),
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                          backgroundColor: Constants.blueDark, elevation: 5.0),
                      child: Text(
                        context.tr('advanced_mode'),
                        style: const TextStyle(color: Colors.white),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QuestionnairePage(
                                //answers: widget.answers,
                                ),
                          ),
                        );
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
}
