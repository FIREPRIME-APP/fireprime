import 'package:fireprime/constants.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/pages/mitigation/mitigation_page.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fireprime/pages/house/house_page.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/info_dialog.dart';
import 'package:fireprime/widgets/card_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  final House house;

  const ResultPage({super.key, required this.house});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  double risk = 0.0;

  double? lastProbability;

  double hazard = 1.0;
  double vulnerability = 0.0;

  Map<String, String?> answers = {};

  Map<String, EventProbability>? allProbabilities = {};
  Map<String, EventProbability>? lastAllProbabilities = {};

  Map<String, bool> _showLinearGauge = {};
  Map<String, EventProbability> subProbabilities = {};
  Map<String, EventProbability> lastSubProbabilities = {};

  bool _showFactors = false;

  bool _toggleFactors() {
    setState(() {
      saveEventdata(screenId: 'result_page', buttonId: 'details');
      _showFactors = !_showFactors;
      for (var entry in _showLinearGauge.entries) {
        _showLinearGauge[entry.key] = false;
      }
    });
    return _showFactors;
  }

  @override
  void initState() {
    super.initState();

    final houseProvider = Provider.of<HouseProvider>(context, listen: false);

    RiskAssessment? riskAssessment = houseProvider.getRiskAssessment();
    RiskAssessment? oldRiskAssessment = houseProvider.getOldRiskAssessment();

    if (riskAssessment != null) {
      risk = riskAssessment.risk;
      allProbabilities = riskAssessment.allProbabilities;
      if (riskAssessment.hazard != null) {
        hazard = riskAssessment.hazard!;
      } else {
        hazard = 1.0;
      }
      vulnerability = riskAssessment.vulnerability!;
      answers = riskAssessment.answers;

      for (var entry in allProbabilities!.entries) {
        for (var subEntry in entry.value.subEvents!.entries) {
          subProbabilities[subEntry.key] = subEntry.value;
        }
      }
    }

    if (oldRiskAssessment != null) {
      lastProbability = oldRiskAssessment.risk;
      lastAllProbabilities = oldRiskAssessment.allProbabilities;
      for (var entry in lastAllProbabilities!.entries) {
        for (var subEntry in entry.value.subEvents!.entries) {
          lastSubProbabilities[subEntry.key] = subEntry.value;
        }
      }
    }

    for (var entry in subProbabilities.entries) {
      _showLinearGauge[entry.key] = false;
    }
  }

  void _toggleLinearGauge(String key) {
    if (_showLinearGauge.containsKey(key)) {
      setState(() {
        if (_showLinearGauge[key]!) {
          _showLinearGauge[key] = false;
          saveEventdata(
              screenId: 'result_page',
              buttonId: 'hide_${_showLinearGauge[key]}_details');
        } else {
          _showLinearGauge.updateAll((key, value) => false);
          _showLinearGauge[key] = true;

          saveEventdata(
              screenId: 'result_page', buttonId: 'show_${key}_details');
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('result'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            saveEventdata(screenId: 'result_page', buttonId: 'back');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const HousePage();
                },
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            Text(context.tr('result_intro'),
                style: Theme.of(context).textTheme.titleLarge!),
            Card(
              child: Stack(
                children: [
                  Center(
                    child: Container(
                      height: 200,
                      width: 200,
                      padding: const EdgeInsets.all(20),
                      color: Colors.transparent,
                      child: Gauge.radialGauge(risk * 100, 15, 6),
                    ),
                  ),
                  Gauge.gaugeProbabilityText(
                      risk * 100,
                      context.tr('risk'),
                      20,
                      getRiskInfo(hazard * 100, vulnerability * 100, risk * 100,
                          context)),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 10, 20),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 200,
                        ),
                        const Divider(
                          thickness: 1.5,
                          color: Colors.grey,
                        ),
                        Row(
                          children: [
                            CardText(
                                title: context.tr('hazard'),
                                text: (hazard * 100).toStringAsFixed(0),
                                size: 15,
                                color: Colors.black),
                            const SizedBox(
                              width: 5,
                            ),
                            InfoDialog(
                                icon: Icons.info_outline,
                                iconSize: 15,
                                text: context.tr('hazard_info'),
                                fontSize: 12)
                          ],
                        ),
                        const SizedBox(
                          height: 15,
                        ),
                        Gauge.linearGauge((hazard * 100), 20, 15, 15, null),
                        const SizedBox(
                          height: 15,
                        ),
                        Row(
                          children: [
                            Expanded(
                              child: CardText(
                                title: context.tr('house_vulnerability'),
                                text: (vulnerability * 100).toStringAsFixed(0),
                                size: 15,
                                color:
                                    null, //Utils.textColor(vulnerability * 100)
                              ),
                            ),
                            const SizedBox(
                              width: 5,
                            ),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                  backgroundColor: _showFactors
                                      ? const Color.fromARGB(255, 223, 225, 228)
                                      : const Color.fromARGB(
                                          255, 252, 252, 252)),
                              onPressed: () {
                                _toggleFactors();
                              },
                              child: Text(
                                _showFactors
                                    ? context.tr('hide')
                                    : context.tr('details'),
                                style: const TextStyle(
                                  color: Constants.blueDark,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ],
                        ),
                        Gauge.linearGauge(
                            (vulnerability * 100), 20, 15, 15, null),
                        const SizedBox(
                          height: 15,
                        ),
                        if (_showFactors) ...[
                          const Divider(
                            color: Colors.grey,
                            thickness: 1.5,
                          ),
                          for (var entry in subProbabilities.entries)
                            Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: CardText(
                                          title: context.tr(entry.key),
                                          text: (entry.value.probability * 100)
                                              .toStringAsFixed(0),
                                          size: 15,
                                          color: null),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(
                                          backgroundColor: _showLinearGauge[
                                                          entry.key] !=
                                                      null &&
                                                  _showLinearGauge[entry.key]!
                                              ? const Color.fromARGB(
                                                  255, 223, 225, 228)
                                              : const Color.fromARGB(
                                                  255, 252, 252, 252)),
                                      onPressed: () {
                                        saveEventdata(
                                            screenId: 'result_page',
                                            buttonId: 'show_details');
                                        _toggleLinearGauge(entry.key);
                                      },
                                      child: Text(
                                        _showLinearGauge[entry.key] != null &&
                                                _showLinearGauge[entry.key]!
                                            ? context.tr('hide')
                                            : context.tr('details'),
                                        style: const TextStyle(
                                          color: Constants.blueDark,
                                          fontSize: 13,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Gauge.linearGauge(entry.value.probability * 100,
                                    20, 15, 15, null)
                              ],
                            ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            //En cas que es vulgui moure el botó de check improvements, copiar tot el codi d'ElevatedButton i enganxar-lo després del bucle de for
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.blueDark, elevation: 5.0),
              child: Text(
                context.tr('check_improvements'),
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {
                saveEventdata(
                    screenId: 'result_page', buttonId: 'check_improvements');
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return MitigationPage(answers: answers);
                    },
                  ),
                );
              },
            ),
            //Segon nivell de linear gauge
            for (var entry in _showLinearGauge.entries)
              if (entry.value && _showFactors)
                Column(
                  children: [
                    const Divider(color: Colors.grey, thickness: 1.5),
                    Text(context.tr(entry.key),
                        style: const TextStyle(
                            fontSize: 15, fontWeight: FontWeight.bold)),
                    Card(
                      child: Column(
                        children: [
                          ...subProbabilities[entry.key]!
                              .subEvents!
                              .entries
                              .map(
                            (subProb) {
                              return Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(12.0),
                                    child: Gauge.linearGaugeWithTitle(
                                        context.tr(subProb.key),
                                        subProb.value.probability * 100,
                                        25,
                                        15,
                                        30,
                                        getLastSubProb(
                                            entry.key,
                                            subProb
                                                .key)), //En cas que no es vulgui comparar amb l'anterior reusltat posar getLastSubProb a null
                                  ),
                                ],
                              );
                            },
                          ),
                          const SizedBox(
                            height: 12,
                          ),
                        ],
                      ),
                    )
                  ],
                ),

            //Enganxar el codi del botó de check improvements aquí si es vol que es quedi al final
          ],
        ),
      ),
    );
  }

  double? getLastSubProb(String key1, String key2) {
    if (lastSubProbabilities.containsKey(key1)) {
      if (lastSubProbabilities[key1]!.subEvents!.containsKey(key2)) {
        return lastSubProbabilities[key1]!.subEvents![key2]!.probability * 100;
      }
    }
    return null;
  }

  String getRiskInfo(
      double hazard, double vulnerability, double risk, BuildContext context) {
    String hazardLevel = getLevel(hazard);
    String vulnerabilityLevel = getLevel(vulnerability);
    String textId = getInfoText(hazardLevel, vulnerabilityLevel);
    String riskLevel = getRiskLevel(risk);

    return context.tr('hazard_vulnerability_text.$textId', namedArgs: {
      'hazard_level': context.tr('hazard_levels.$hazardLevel'),
      'vulnerability_level':
          context.tr('vulnerability_levels.$vulnerabilityLevel'),
      'risk': context.tr('risk_levels.$riskLevel'),
    });
  }

  String getLevel(double value) {
    if (value >= 90) {
      return 'extreme';
    } else if (value >= 70) {
      return 'high';
    } else if (value >= 45) {
      return 'moderate';
    } else {
      return 'low';
    }
  }

  String getRiskLevel(double risk) {
    if (risk >= 80) {
      return 'extreme';
    } else if (risk >= 50) {
      return 'high';
    } else if (risk >= 20) {
      return 'moderate';
    } else {
      return 'low';
    }
  }

  String getInfoText(String hazardLevel, String vulnerabilityLevel) {
    if (hazardLevel == 'extreme' || hazardLevel == 'high') {
      if (vulnerabilityLevel == 'extreme' || vulnerabilityLevel == 'high') {
        return 'extreme_high_text';
      } else if (vulnerabilityLevel == 'low') {
        return 'extreme_low_text';
      } else if (hazardLevel == 'extreme' && vulnerabilityLevel == 'moderate') {
        return 'extreme_moderate_text';
      } else if (hazardLevel == 'high' && vulnerabilityLevel == 'moderate') {
        return 'high_moderate_text';
      }
    } else if (hazardLevel == 'moderate') {
      if (vulnerabilityLevel == 'extreme') {
        return 'extreme_high_text';
      } else if (vulnerabilityLevel == 'high') {
        return 'extreme_moderate_text';
      } else if (vulnerabilityLevel == 'moderate') {
        return 'moderate_text';
      } else {
        return 'extreme_low_text';
      }
    } else {
      if (vulnerabilityLevel == 'extreme' || vulnerabilityLevel == 'high') {
        return 'low_extreme_high_text';
      } else if (vulnerabilityLevel == 'moderate') {
        return 'low_moderate_text';
      } else {
        return 'low_text';
      }
    }
    return '';
  }
}
