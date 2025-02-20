import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/result/result_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ResultsLoadingPage extends StatelessWidget {
  final House house;
  final double probability;
  final Map<String, EventProbability> allProbabilities;
  final DateTime endDate;

  const ResultsLoadingPage(
      {super.key,
      required this.house,
      required this.probability,
      required this.allProbabilities,
      required this.endDate});

  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<HouseProvider>(context, listen: false);
    return Scaffold(
      body: FutureBuilder<void>(
        future: houseProvider.setCompleted(
            true, probability, allProbabilities, endDate),
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
