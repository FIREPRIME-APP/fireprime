import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
//import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/basic_result.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/house/choose_mode.dart';
import 'package:fireprime/pages/house/edit_house_page.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/pages/mitigation/basic/advices_page.dart';
import 'package:fireprime/pages/questionnaire/basic/basic_questionnaire.dart';
import 'package:fireprime/pages/result/basic/basic_historical_results_page.dart';
import 'package:fireprime/pages/result/basic/basic_result.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/button_card.dart';
import 'package:fireprime/widgets/card_text.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:fireprime/widgets/house_delete_alert.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class BasicHousePage extends StatelessWidget {
  const BasicHousePage({super.key});

  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<HouseProvider>(context, listen: false);
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('basic_mode'),
          style: const TextStyle(
              fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black),
          softWrap: true,
          overflow: TextOverflow.visible,
        ),
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
          PopupMenuButton<int>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) async {
              if (value == 0) {
                //   saveEventdata(screenId: 'house_page', buttonId: 'edit_house');
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
                //   saveEventdata(screenId: 'house_page', buttonId: 'delete_house');
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
          DateFormat dateFormat = DateFormat('dd-MM-yyyy');

          final House currentHouse;
          final BasicResult? basicResult;
          final BasicResult? lastCompletedBasicResult;

          if (house.currentHouse != null) {
            currentHouse = house.getHouse(house.currentHouse!);
            if (currentHouse.basicResultIds != null &&
                currentHouse.basicResultIds!.isNotEmpty) {
              basicResult = house.getLastBasicResult();
              lastCompletedBasicResult = house.getCompletedBasicResult();
            } else {
              basicResult = null;
              lastCompletedBasicResult = null;
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
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
                        color: Constants.blueDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
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
                              if (lastCompletedBasicResult != null) ...[
                                CardText(
                                  title: context.tr('date'),
                                  text: dateFormat
                                      .format(lastCompletedBasicResult.fiDate),
                                  size: 15,
                                  color: Colors.black,
                                  textBold: false,
                                ),
                                const SizedBox(
                                  height: 10,
                                ),
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
                                                lastCompletedBasicResult.risk
                                                        .ceilToDouble() *
                                                    10,
                                                10,
                                                4,
                                                null,
                                              ),
                                            ),
                                          ),
                                          Column(
                                            children: [
                                              const SizedBox(
                                                height: 75,
                                              ),
                                              Center(
                                                child: CardText(
                                                  title: context.tr('risk'),
                                                  text:
                                                      '${lastCompletedBasicResult.risk}/10',
                                                  size: 18,
                                                  color: null,
                                                  textBold:
                                                      false, //Utils.textColor(lastProbability * 100),
                                                ),
                                              ),
                                              const SizedBox(
                                                height: 10,
                                              ),
                                              ElevatedButton(
                                                onPressed: () {
                                                  /*   saveEventdata(
                                                      screenId: 'house_page',
                                                      buttonId: 'viewResults');
                                                   */
                                                  Navigator.of(context).push(
                                                    MaterialPageRoute(
                                                      builder: (BuildContext
                                                          context) {
                                                        return BasicResultPage();
                                                      },
                                                    ),
                                                  );
                                                },
                                                style: ElevatedButton.styleFrom(
                                                    backgroundColor:
                                                        Constants.blueDark,
                                                    elevation: 5.0),
                                                child: Text(
                                                  context.tr('details'),
                                                  style: const TextStyle(
                                                      color: Colors.white),
                                                ),
                                              )
                                            ],
                                          ),
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
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 8.0),
                                  child: Text(
                                    context.tr('no_results_available'),
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (basicResult != null && basicResult.completed)
                      ButtonCard(
                        currentHouse: currentHouse,
                        description: context.tr('update_questionnaire_intro'),
                        buttonText: context.tr('update'),
                        cardColor: const Color.fromARGB(255, 184, 194, 219),
                        onPressed: () {
                          /*   saveEventdata(
                              screenId: 'house_page',
                              buttonId: 'update_basic_questionnaire');
                         */
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BasicQuestionnairePage(),
                            ),
                          );
                        },
                        enabled: true,
                      ),
                    if (basicResult == null)
                      ButtonCard(
                        currentHouse: currentHouse,
                        description: context.tr('start_questionnaire_intro'),
                        buttonText: context.tr('check'),
                        cardColor: const Color.fromARGB(255, 184, 194, 219),
                        onPressed: () {
                          /*  saveEventdata(
                              screenId: 'house_page',
                              buttonId: 'start_basic_questionnaire');
                         */
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BasicQuestionnairePage(),
                            ),
                          );
                        },
                        enabled: true,
                      ),
                    if (basicResult != null && !basicResult.completed)
                      ButtonCard(
                        currentHouse: currentHouse,
                        description: context.tr('continue_questionnaire_intro'),
                        buttonText: context.tr('continue'),
                        cardColor: const Color.fromARGB(255, 184, 194, 219),
                        onPressed: () {
                          /*  saveEventdata(
                              screenId: 'house_page',
                              buttonId: 'continue_basic_questionnaire');
                         */
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const BasicQuestionnairePage(),
                            ),
                          );
                        },
                        enabled: true,
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
                            buttonId: 'view_basic_results_history');
                       */
                        List<BasicResult> basicResults =
                            house.getBasicResults();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BasicHistoricalResultsPage(
                                basicResults: basicResults),
                          ),
                        );
                      },
                      enabled: _enableHistoryButton(currentHouse, basicResult),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    ButtonCard(
                      currentHouse: currentHouse,
                      description: context.tr('advices_intro'),
                      buttonText: context.tr('advices'),
                      cardColor: const Color.fromARGB(255, 159, 171, 201),
                      onPressed: () {
                        /*  saveEventdata(
                            screenId: 'house_page',
                            buttonId: 'view_basic_advices');
                       */
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AdvicesPage(
                              area: currentHouse.environment,
                            ),
                          ),
                        );
                      },
                      enabled: true,
                    ),
                  ],
                ),
              ));
        },
      ),
    );
  }

  bool _enableHistoryButton(House currentHouse, BasicResult? lastBasicResult) {
    if (currentHouse.basicResultIds != null) {
      int length = currentHouse.basicResultIds!.length;
      if (length > 1) {
        if (length > 2) return true;
        if (lastBasicResult != null && lastBasicResult.completed) {
          return true;
        }
      }
    }
    return false;
  }
}
