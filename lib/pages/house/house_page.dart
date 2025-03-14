import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/pages/mitigation/mitigation_actions.dart';
import 'package:fireprime/pages/mitigation/mitigation_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:fireprime/pages/house/edit_house_page.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/questionnaire.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fireprime/pages/questionnaire/questionnaire_page.dart';
import 'package:fireprime/pages/result/historical_results_page.dart';
import 'package:fireprime/pages/result/result_page.dart';
import 'package:fireprime/widgets/utils.dart';
import 'package:fireprime/widgets/card_text.dart';
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
    final houseProvider = Provider.of<HouseProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Image.asset(
          Constants.logoA,
          fit: BoxFit.contain,
          height: 25,
        ),
        centerTitle: true,
        leading: IconButton(
          onPressed: () {
            saveEventdata(screenId: 'house_page', buttonId: 'back');
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
                saveEventdata(screenId: 'house_page', buttonId: 'edit_house');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return EditHousePage(
                        currentHouse: houseProvider.currentHouse!,
                      );
                    },
                  ),
                );
              } else if (value == 1) {
                saveEventdata(screenId: 'house_page', buttonId: 'delete_house');
                _deleteAlert(context);
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(value: 0, child: Text(context.tr('edit_house'))),
                PopupMenuItem(
                    value: 1, child: Text(context.tr('delete_house'))),
              ];
            },
          )
        ],
      ),
      body: Consumer<HouseProvider>(
        builder: (context, house, child) {
          final House currentHouse;
          if (house.currentHouse != null) {
            currentHouse = house.getHouse(house.currentHouse!);
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          RiskAssessment? riskAssessment;
          print('currenthouse riskIds:');
          print(currentHouse.riskAssessmentIds);
          if (currentHouse.riskAssessmentIds.isNotEmpty) {
            riskAssessment = houseProvider.getLastRiskAssessment();
          }
          RiskAssessment? lastCompletedRiskAssessment =
              houseProvider.getRiskAssessment();

          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    currentHouse.name,
                    style: const TextStyle(
                      fontSize: 20,
                      color: Constants.blueDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  _buildVulnerabilityResults(
                      context, houseProvider, currentHouse),
                  const SizedBox(
                    height: 20,
                  ),
                  _buttonCard(
                    currentHouse,
                    context.tr('mitigation_intro'),
                    context.tr('check_improvements'),
                    const Color.fromARGB(255, 159, 171, 201),
                    () {
                      saveEventdata(
                          screenId: 'house_page',
                          buttonId: 'check_improvements');
                      if (lastCompletedRiskAssessment != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return MitigationPage(
                                answers: lastCompletedRiskAssessment.answers,
                              );
                            },
                          ),
                        );
                      }
                    },
                    lastCompletedRiskAssessment != null,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  if (riskAssessment != null && riskAssessment.completed)
                    _buttonCard(
                      currentHouse,
                      context.tr('update_questionnaire_intro'),
                      context.tr('update'),
                      const Color.fromARGB(255, 184, 194, 219),
                      () {
                        saveEventdata(
                            screenId: 'house_page',
                            buttonId: 'update_questionnaire');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              Questionnaire().setEnvironment(
                                  currentHouse.environment); //TODO: CHECK
                              return QuestionnairePage(
                                answers: riskAssessment!.answers,
                              );
                            },
                          ),
                        );
                      },
                      true,
                    ),
                  if (riskAssessment == null)
                    _buttonCard(
                      currentHouse,
                      context.tr('start_questionnaire_intro'),
                      context.tr('check'),
                      const Color.fromARGB(255, 184, 194, 219),
                      () {
                        saveEventdata(
                            screenId: 'house_page',
                            buttonId: 'first_questionnaire');
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
                  if (riskAssessment != null && !riskAssessment.completed) ...[
                    _buttonCard(
                      currentHouse,
                      context.tr('continue_questionnaire_intro'),
                      context.tr('continue'),
                      const Color.fromARGB(255, 184, 194, 219),
                      () {
                        saveEventdata(
                            screenId: 'house_page',
                            buttonId: 'continue_questionnaire');
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              Questionnaire().setEnvironment(
                                  currentHouse.environment); //TODO: CHECK
                              return QuestionnairePage(
                                answers: riskAssessment!.answers,
                              );
                            },
                          ),
                        );
                      },
                      true,
                    ),
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  _buttonCard(
                    currentHouse,
                    context.tr('results_history_intro'),
                    context.tr('myResults'),
                    const Color.fromARGB(255, 132, 149, 189),
                    () {
                      saveEventdata(
                          screenId: 'house_page',
                          buttonId: 'view_results_history');
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
                    _enableButton(
                        currentHouse.riskAssessmentIds.length, riskAssessment),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buttonCard(House currentHouse, String description, String buttonText,
      Color cardColor, VoidCallback onPressed, bool enabled) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Constants.blueDark,
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

  Widget _buildVulnerabilityResults(
      BuildContext context, HouseProvider houseProvider, House currentHouse) {
    final lastProbability = houseProvider.getLastProbability();
    final lastResults = houseProvider.getLastResults();
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('last_evaluation'),
                style: const TextStyle(
                    fontSize: 17,
                    color: Constants.blueDark,
                    fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              if (lastProbability != null)
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
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
                              child: CardText(
                                title: context.tr('risk'),
                                text:
                                    (lastProbability * 100).toStringAsFixed(0),
                                size: 18,
                                color:
                                    null, //Utils.textColor(lastProbability * 100),
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            ElevatedButton(
                              onPressed: () {
                                saveEventdata(
                                    screenId: 'house_page',
                                    buttonId: 'viewResults');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return ResultPage(house: currentHouse);
                                    },
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: Constants.blueDark,
                                  elevation: 5.0),
                              child: Text(
                                context.tr('details'),
                                style: const TextStyle(color: Colors.white),
                              ),
                            )
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
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    context.tr('no_results_available'),
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
                      child: CardText(
                        title: context.tr(entry.key),
                        text: (entry.value * 100).toStringAsFixed(0),
                        size: 15,
                        color: Utils.textColor(entry.value * 100),
                      ),
                    );
                  },
                ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteAlert(BuildContext context) {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(context.tr('delete_house_warning_intro'),
              style:
                  const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          content: Text(context.tr('delete_house_warning_text'),
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
                    Provider.of<HouseProvider>(context, listen: false);
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

  bool _enableButton(int length, RiskAssessment? lastRiskAssessment) {
    if (lastRiskAssessment != null && length > 1) {
      if (lastRiskAssessment.completed || length > 2) {
        return true;
      } else {
        return false;
      }
    } else {
      return false;
    }
  }
}
