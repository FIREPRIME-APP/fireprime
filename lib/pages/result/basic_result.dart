import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/questionnaire/basic_questionnaire.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:flutter/material.dart';

class BasicResultPage extends StatelessWidget {
  final BasicQuestionnaire questionnaire;
  final int score;

  const BasicResultPage(
      {super.key, required this.questionnaire, required this.score});

  @override
  Widget build(BuildContext context) {
    String level = questionnaire.getRiskLevel(score);
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
                  return const HouseListPage();
                },
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  color: Colors.grey[200],
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      '$score/${questionnaire.questions.length}',
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
                context.tr('risk_text.${questionnaire.area.name}_$level'),
                style: const TextStyle(
                  fontSize: 15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
