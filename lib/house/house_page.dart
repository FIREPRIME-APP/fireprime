import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/controller/house_controller.dart';
import 'package:fireprime/gauge.dart';
import 'package:fireprime/house/edit_house_page.dart';
import 'package:fireprime/house/house_list_page.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/questionnaire.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fireprime/questionnaire/questionnaire_page.dart';
import 'package:fireprime/result/historical_results_page.dart';
import 'package:fireprime/result/result_page.dart';
import 'package:fireprime/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HousePage extends StatefulWidget {
  const HousePage({super.key});

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  @override
  Widget build(BuildContext context) {
    final houseController =
        Provider.of<HouseController>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          'assets/images/logos/FIREPRIME_Logo_A.png',
          fit: BoxFit.contain,
          height: 25,
        ),
        /*Text(
          houseController.currentHouse!,
          style: Theme.of(context).textTheme.titleLarge!,
        ),*/
        centerTitle: true,
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
        actions: [
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 0) {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return EditHousePage(
                        currentHouse: houseController.currentHouse!,
                      );
                    },
                  ),
                );
              } else if (value == 1) {
                deleteAlert(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 0, child: Text(context.tr('edit'))),
                PopupMenuItem(value: 1, child: Text(context.tr('deleteHouse'))),
              ];
            },
          )
        ],
      ),
      body: Consumer<HouseController>(
        builder: (context, house, child) {
          print('${house.currentHouse}');
          House currentHouse;
          if (house.currentHouse != null) {
            currentHouse = house.getHouse(house.currentHouse!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
          double? lastProbability;
          Map<String, double> lastResults = {};

          List<RiskAssessment> riskAssessments = currentHouse.riskAssessments;

          if (riskAssessments.isEmpty) {
            lastProbability = null;
          } else if (riskAssessments.last.completed) {
            lastProbability = riskAssessments.last.probability;
            lastResults = riskAssessments.last.results;
          } else if (riskAssessments.length >= 2 &&
              riskAssessments[riskAssessments.length - 2].completed) {
            lastProbability =
                riskAssessments[riskAssessments.length - 2].probability;
            lastResults = riskAssessments[riskAssessments.length - 2].results;
          }

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    currentHouse.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 86, 97, 123),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: Card(
                      child: GestureDetector(
                        onTap: () {
                          if (lastProbability != null) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  return ResultPage(house: currentHouse);
                                },
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                context.tr('lastResult'),
                                style: const TextStyle(
                                    fontSize: 17,
                                    color: Color.fromARGB(255, 86, 97, 123),
                                    fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (lastProbability != null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Column(
                                    children: [
                                      Stack(
                                        children: [
                                          Center(
                                            child: Container(
                                              height: 100,
                                              width: 100,
                                              color: Colors.transparent,
                                              child: Gauge.radialGauge(
                                                  lastProbability * 100, 10, 4),
                                            ),
                                          ),
                                          Column(children: [
                                            const SizedBox(
                                              height: 75,
                                            ),
                                            Center(
                                              child: tileText(
                                                  context.tr('risk'),
                                                  lastProbability * 100,
                                                  18),
                                            ),
                                          ]),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              /*tileText(context.tr('risk'),
                                  lastProbability * 100, 20),*/

                              if (lastProbability == null)
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    context.tr('noResult'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              const SizedBox(
                                height: 10,
                              ),
                              if (lastResults.isNotEmpty)
                                ...lastResults.entries.map(
                                  (entry) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8.0, vertical: 3),
                                      child: tileText(
                                          entry.key, entry.value * 100, 15),
                                    );
                                  },
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (currentHouse.riskAssessments.isNotEmpty &&
                      currentHouse.riskAssessments.last.completed)
                    buttonCard(
                      currentHouse,
                      context.tr('updateQuestionnaire'),
                      context.tr('update'),
                      const Color.fromARGB(255, 184, 194, 219),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              Questionnaire().setEnvironment(
                                  currentHouse.environment); //TODO: CHECK
                              return QuestionnairePage(
                                answers: house
                                    .getHouse(house.currentHouse!)
                                    .riskAssessments
                                    .last
                                    .answers,
                              );
                            },
                          ),
                        );
                      },
                      true,
                    ),
                  if (currentHouse.riskAssessments.isEmpty)
                    buttonCard(
                      currentHouse,
                      context.tr('fillQuestionnaire'),
                      context.tr('fill'),
                      const Color.fromARGB(255, 184, 194, 219),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              Questionnaire()
                                  .setEnvironment(currentHouse.environment);
                              return const QuestionnairePage(
                                answers: {},
                              );
                            },
                          ),
                        );
                      },
                      true,
                    ),
                  if (currentHouse.riskAssessments.isNotEmpty &&
                      !currentHouse.riskAssessments.last.completed)
                    buttonCard(
                      currentHouse,
                      context.tr('continueQuestionnaire'),
                      context.tr('continue'),
                      const Color.fromARGB(255, 184, 194, 219),
                      () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              Questionnaire().setEnvironment(
                                  currentHouse.environment); //TODO: CHECK
                              return QuestionnairePage(
                                answers: house
                                    .getHouse(house.currentHouse!)
                                    .riskAssessments
                                    .last
                                    .answers,
                              );
                            },
                          ),
                        );
                      },
                      true,
                    ),
                  const SizedBox(
                    height: 20,
                  ),
                  buttonCard(
                    currentHouse,
                    context.tr('resultsHistory'),
                    context.tr('myResults'),
                    const Color.fromARGB(255, 132, 149, 189),
                    () {
                      List<RiskAssessment> riskAssessments =
                          house.getRiskAssessments();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return HistoricalResultsPage(
                              riskAssessments: riskAssessments,
                            );
                          },
                        ),
                      );
                    },
                    enableButton(currentHouse.riskAssessments),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget buttonCard(House currentHouse, String description, String buttonText,
      Color cardColor, VoidCallback onPressed, bool enabled) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color.fromARGB(255, 86, 97, 123),
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Container(
                  width: 150,
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 112, 126, 158),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    onPressed: enabled ? onPressed : null,
                    child: Text(
                      buttonText,
                      style: TextStyle(
                          color: enabled ? Colors.black : Colors.black38,
                          fontSize: 16),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget tileText(String title, double value, double size) {
    return RichText(
      text: TextSpan(
        style: TextStyle(fontSize: size, color: Colors.black),
        children: <TextSpan>[
          TextSpan(
              text: '${context.tr(title)}: ',
              style: const TextStyle(fontWeight: FontWeight.bold)),
          TextSpan(
            text: value.toStringAsFixed(0),
            style: TextStyle(
                color: Utils.textColor(value), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> deleteAlert(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('deleteHouseWarning1'),
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: Text(context.tr('deleteHouseWarning2'),
              style: const TextStyle(fontSize: 15)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(context.tr('cancel')),
            ),
            TextButton(
              onPressed: () {
                var houseCtrl =
                    Provider.of<HouseController>(context, listen: false);
                houseCtrl.deleteHouse();

                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const HouseListPage();
                    },
                  ),
                );
              },
              child: Text(context.tr('delete')),
            ),
          ],
        );
      },
    );
  }

  bool enableButton(List<RiskAssessment> riskAssessments) {
    if (riskAssessments.isNotEmpty && riskAssessments.length > 1) {
      if (riskAssessments.last.completed || riskAssessments.length > 2) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
