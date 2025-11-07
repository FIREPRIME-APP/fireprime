import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
//import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/pages/house/choose_mode.dart';
import 'package:fireprime/pages/mitigation/advanced/mitigation_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/button_card.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:fireprime/pages/house/edit_house_page.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/questionnaire/questionnaire.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fireprime/pages/questionnaire/advanced/questionnaire_page.dart';
import 'package:fireprime/pages/result/advanced/historical_results_page.dart';
import 'package:fireprime/pages/result/advanced/result_page.dart';
import 'package:fireprime/widgets/card_text.dart';
import 'package:fireprime/widgets/house_delete_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HousePage extends StatefulWidget {
  const HousePage({super.key});

  @override
  State<HousePage> createState() => _HousePageState();
}

class _HousePageState extends State<HousePage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkLatLong();
    });
  }

  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<HouseProvider>(context, listen: true);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('advanced_mode'),
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
        /*Image.asset(
          Constants.logoA,
          fit: BoxFit.contain,
          height: 25,
        ),*/
        // centerTitle: true,
        leading: IconButton(
          onPressed: () {
            //saveEventdata(screenId: 'house_page', buttonId: 'back');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const ChooseMode(); //TODO
                },
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        actions: [
          IconButton(
            onPressed: () {
              //saveEventdata(screenId: 'house_page', buttonId: 'choose_mode');
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return const HouseListPage();
                  },
                ),
              );
            },
            icon: const Icon(Icons.home),
          ),
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 0) {
                //saveEventdata(screenId: 'house_page', buttonId: 'edit_house');
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
                //saveEventdata(screenId: 'house_page', buttonId: 'delete_house');
                await showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return const DeleteAlert();
                  },
                );
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
          if (currentHouse.riskAssessmentIds.isNotEmpty) {
            riskAssessment = houseProvider.getLastRiskAssessment();
          }
          RiskAssessment? lastCompletedRiskAssessment =
              houseProvider.getCompletedRiskAssessment();

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
                  //_buildVulnerabilityResults(
                  //  context, houseProvider, currentHouse),
                  _buildVulnerabilityResults(
                      context,
                      lastCompletedRiskAssessment,
                      currentHouse,
                      houseProvider.checkIfShowHazard()),
                  const SizedBox(
                    height: 20,
                  ),

                  if (riskAssessment != null && riskAssessment.completed)
                    ButtonCard(
                      currentHouse: currentHouse,
                      description: context.tr('update_questionnaire_intro'),
                      buttonText: context.tr('update'),
                      cardColor: const Color.fromARGB(255, 184, 194, 219),
                      onPressed: () {
                        /* saveEventdata(
                            screenId: 'house_page',
                            buttonId: 'update_questionnaire');*/
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              Questionnaire().setEnvironment(
                                  currentHouse.environment); //TODO: CHECK
                              return const QuestionnairePage();
                            },
                          ),
                        );
                      },
                      enabled: true,
                    ),
                  if (riskAssessment == null)
                    ButtonCard(
                      currentHouse: currentHouse,
                      description: context.tr('start_questionnaire_intro'),
                      buttonText: context.tr('check'),
                      cardColor: const Color.fromARGB(255, 184, 194, 219),
                      onPressed: () {
                        /*  saveEventdata(
                            screenId: 'house_page',
                            buttonId: 'start_first_questionnaire');*/
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              Questionnaire()
                                  .setEnvironment(currentHouse.environment);
                              return const QuestionnairePage(
                                  //  answers: {},
                                  );
                            },
                          ),
                        );
                      },
                      enabled: true,
                    ),
                  if (riskAssessment != null && !riskAssessment.completed) ...[
                    ButtonCard(
                      currentHouse: currentHouse,
                      description: context.tr('continue_questionnaire_intro'),
                      buttonText: context.tr('continue'),
                      cardColor: const Color.fromARGB(255, 184, 194, 219),
                      onPressed: () {
                        /* saveEventdata(
                            screenId: 'house_page',
                            buttonId: 'continue_questionnaire');*/
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              Questionnaire().setEnvironment(
                                  currentHouse.environment); //TODO: CHECK
                              print(
                                  'Last step id: ${riskAssessment?.lastStepId}');
                              if (riskAssessment?.lastStepId != null) {
                                return const QuestionnairePage(
                                    // answers: riskAssessment!.answers,
                                    // lastQuestionId: riskAssessment.lastStepId,
                                    );
                              } else {
                                return const QuestionnairePage(
                                    //   answers: riskAssessment!.answers,
                                    );
                              }
                            },
                          ),
                        );
                      },
                      enabled: true,
                    ),
                  ],
                  const SizedBox(
                    height: 20,
                  ),
                  ButtonCard(
                    currentHouse: currentHouse,
                    description: context.tr('mitigation_intro'),
                    buttonText: context.tr('check_improvements'),
                    cardColor: const Color.fromARGB(255, 159, 171, 201),
                    onPressed: () {
                      /*  saveEventdata(
                          screenId: 'house_page',
                          buttonId: 'check_improvements');*/
                      if (lastCompletedRiskAssessment != null) {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              return const MitigationPage();
                            },
                          ),
                        );
                      }
                    },
                    enabled: lastCompletedRiskAssessment != null,
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  ButtonCard(
                    currentHouse: currentHouse,
                    description: context.tr('results_history_intro'),
                    buttonText: context.tr('my_results'),
                    cardColor: const Color.fromARGB(255, 132, 149, 189),
                    onPressed: () {
                      /* saveEventdata(
                          screenId: 'house_page',
                          buttonId: 'view_results_history');*/
                      List<RiskAssessment> riskAssessments =
                          house.getRiskAssessments();
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (BuildContext context) {
                            return HistoricalResultsPage(
                              riskAssessments: riskAssessments,
                              showHazard: houseProvider.checkIfShowHazard(),
                            );
                          },
                        ),
                      );
                    },
                    enabled: _enableButton(
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

  //Widget _buildVulnerabilityResults(
  //  BuildContext context, HouseProvider houseProvider, House currentHouse) {
  Widget _buildVulnerabilityResults(BuildContext context,
      RiskAssessment? lastRiskAssessment, House currentHouse, bool showHazard) {
    DateFormat dateFormat = DateFormat('dd-MM-yyyy');

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
              if (lastRiskAssessment != null) ...[
                CardText(
                    title: context.tr('date'),
                    text: dateFormat.format(lastRiskAssessment.fiDate),
                    size: 15),
                const SizedBox(
                  height: 10,
                ),
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
                                lastRiskAssessment.risk * 100,
                                10,
                                4,
                              ),
                            ),
                          ),
                          Column(children: [
                            const SizedBox(
                              height: 75,
                            ),
                            Center(
                              child: CardText(
                                title: showHazard
                                    ? context.tr('risk')
                                    : context.tr('vulnerability'),
                                text: (lastRiskAssessment.risk * 100)
                                    .toStringAsFixed(0),
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
                                /*   saveEventdata(
                                    screenId: 'house_page',
                                    buttonId: 'viewResults');*/
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return const ResultPage();
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
              ]
              /*tileText(context.tr('risk'),
                                  lastProbability * 100, 20),*/

              else
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
              /* if (lastResults.isNotEmpty)
                ...lastResults.entries.map(
                  (entry) {
                    print('-----------last results: $lastResults');
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
                ),*/
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

  void _checkLatLong() {
    final houseProvider = Provider.of<HouseProvider>(context, listen: false);
    House currentHouse = houseProvider.getHouse(houseProvider.currentHouse!);
    if (currentHouse.lat == null || currentHouse.long == null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(context.tr('unable_to_get_latlong_title'),
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
            content: Text(context.tr('unable_to_get_latlong_message'),
                style: const TextStyle(fontSize: 15)),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  /*  saveEventdata(
                      screenId: 'house_page',
                      buttonId: 'noLatLong_warning_accept'); */
                  Navigator.of(context).pop();
                },
                child: Text(context.tr('accept')),
              ),
              TextButton(
                onPressed: () {
                  /*  saveEventdata(
                      screenId: 'house_page',
                      buttonId: 'noLatLong_warning_edit_house'); */
                  Navigator.of(context).pop();
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return EditHousePage(
                          currentHouse: houseProvider.currentHouse!,
                        );
                      },
                    ),
                  );
                },
                child: Text(context.tr('edit')),
              )
            ],
          );
        },
      );
    } else {
      print('Lat: ${currentHouse.lat}');
      print('Long: ${currentHouse.long}');
    }
  }
}
