import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/firebase/answer_manage.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/result/result_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultsLoadingPage extends StatelessWidget {
  final House house;
  final double vulnerability;
  final Map<String, EventProbability> allProbabilities;
  final DateTime endDate;
  final Map<String, String?> answers;

  const ResultsLoadingPage(
      {super.key,
      required this.house,
      required this.vulnerability,
      required this.allProbabilities,
      required this.endDate,
      required this.answers});

  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<HouseProvider>(context, listen: false);
    Future<double> risk;
    return Scaffold(
      body: FutureBuilder<void>(
        future: risk = houseProvider.setCompleted(
            true, vulnerability, allProbabilities, endDate),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 10,
                ),
                Text(
                  context.tr('calculating'),
                  style: const TextStyle(fontSize: 15),
                )
              ],
            ));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Map<String, String?> answersAdapted = {};

              answers.forEach((key, value) {
                if (value != null) {
                  answersAdapted[key] = context.tr(value);
                }
              });
              print('answersAdapted: $answersAdapted');

              /*   risk.then((calculatedRisk) {
                saveAnswerData(
                  houseId: house.name,
                  houseAddress: house.address,
                  answers: answersAdapted,
                  lat: house.lat ?? 0.0,
                  long: house.long ?? 0.0,
                  vulnerability: vulnerability,
                  totalRisk: calculatedRisk,
                );
              });*/

              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return ResultPage(
                      house: house,
                    );
                  },
                ),
              );
            });
            return Container();
          }
        },
      ),
    );
  }
}
