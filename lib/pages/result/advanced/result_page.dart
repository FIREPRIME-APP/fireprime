import 'dart:io';
import 'dart:ui';

import 'package:fireprime/constants.dart';
//import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/mitigation/advanced/mitigation.dart';
import 'package:fireprime/pages/mitigation/advanced/mitigation_page.dart';
import 'package:fireprime/pdf_creation/pdf_creator.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:fireprime/pages/house/advanced/house_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/info_dialog.dart';
import 'package:fireprime/widgets/card_text.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

class ResultPage extends StatefulWidget {
  //final House house;

  const ResultPage({
    super.key,
    /*required this.house*/
  });

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

  bool _showHazard = true;

  String riskAssessmentId = '';

  DateTime date = DateTime.now();

  final ScrollController scrollCtrl = ScrollController();

  late HouseProvider houseProvider;

  bool _toggleFactors() {
    setState(() {
      //  saveEventdata(screenId: 'result_page', buttonId: 'details');
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

    houseProvider = Provider.of<HouseProvider>(context, listen: false);

    _showHazard = houseProvider.checkIfShowHazard();

    RiskAssessment? riskAssessment = houseProvider.getCompletedRiskAssessment();
    RiskAssessment? oldRiskAssessment = houseProvider.getOldRiskAssessment();

    if (riskAssessment != null) {
      risk = riskAssessment.risk;
      allProbabilities = riskAssessment.allProbabilities;
      if (riskAssessment.hazard != null && _showHazard) {
        hazard = riskAssessment.hazard!;
      } else {
        hazard = 1.0;
      }
      vulnerability = riskAssessment.vulnerability!;
      answers = riskAssessment.answers;
      date = riskAssessment.fiDate;

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
          /*  saveEventdata(
              screenId: 'result_page',
              buttonId: 'hide_${_showLinearGauge[key]}_details');
        */
        } else {
          _showLinearGauge.updateAll((key, value) => false);
          _showLinearGauge[key] = true;

          /* saveEventdata(
              screenId: 'result_page', buttonId: 'show_${key}_details');
        */
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    //Map<String, GlobalKey> linearGaugesKeys =

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('result'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            //saveEventdata(screenId: 'result_page', buttonId: 'back');
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
        controller: scrollCtrl,
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            //radialGauge(risk, screenshotController),
            _showHazard
                ? Text(context.tr('result_intro'),
                    style: Theme.of(context).textTheme.titleLarge!)
                : Text(context.tr('vulnerability_intro'),
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
                      child: Gauge.radialGauge(risk * 100, 15, 6, hazard),
                    ),
                  ),
                  Gauge.gaugeProbabilityText(
                    risk * 100,
                    _showHazard
                        ? context.tr('risk')
                        : context.tr('vulnerability'),
                    20,
                    getRiskInfo(hazard * 100, vulnerability * 100, risk * 100,
                        context, _showHazard),
                    hazard,
                    context,
                    context.tr('ideal_risk_info'),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 10, 10, 20),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 200,
                        ),
                        if (_showHazard) ...[
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
                                color: Colors.black,
                                textBold: false,
                              ),
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
                          Gauge.linearGauge(
                              (hazard * 100), 20, 15, 15, null, true, 12),
                          const SizedBox(
                            height: 15,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: CardText(
                                  title: context.tr('house_vulnerability'),
                                  text:
                                      (vulnerability * 100).toStringAsFixed(0),
                                  size: 15,
                                  color: null,
                                  textBold:
                                      false, //Utils.textColor(vulnerability * 100)
                                ),
                              ),
                              const SizedBox(
                                width: 5,
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: _showFactors
                                        ? const Color.fromARGB(
                                            255, 223, 225, 228)
                                        : const Color.fromARGB(
                                            255, 252, 252, 252)),
                                onPressed: () {
                                  _toggleFactors();
                                  scrollCtrl.animateTo(
                                    scrollCtrl.position.extentTotal,
                                    duration:
                                        const Duration(milliseconds: 1000),
                                    curve: Curves.easeInOut,
                                  );
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
                          Gauge.linearGauge((vulnerability * 100), 20, 15, 15,
                              null, true, 12),
                          const SizedBox(
                            height: 15,
                          ),
                        ],
                        if (_showFactors || !_showHazard) ...[
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
                                        color: null,
                                        textBold: false,
                                      ),
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
/*                                         saveEventdata(
                                            screenId: 'result_page',
                                            buttonId: 'show_details');
                               */
                                        _toggleLinearGauge(entry.key);
                                        scrollCtrl.animateTo(
                                          scrollCtrl.position.extentTotal,
                                          duration: const Duration(
                                              milliseconds: 1000),
                                          curve: Curves.easeInOut,
                                        );
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
                                    20, 15, 15, null, true, 12)
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

            //Segon nivell de linear gauge
            for (var entry in _showLinearGauge.entries)
              if (entry.value && (_showFactors || !_showHazard))
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
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.blueDark, elevation: 5.0),
              child: Text(
                context.tr('check_improvements'),
                style: const TextStyle(color: Colors.white),
              ),
              onPressed: () {
                /*    saveEventdata(
                    screenId: 'result_page', buttonId: 'check_improvements');
              */
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const MitigationPage();
                    },
                  ),
                );
              },
            ),

            const SizedBox(
              height: 15,
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Constants.blueDark, elevation: 5.0),
              child: Text(context.tr('results_download'),
                  style: const TextStyle(color: Colors.white)),
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
                  Map<String, dynamic>? mitigations =
                      await Mitigation.loadMitigations(
                          Localizations.localeOf(context).languageCode);
                  Map<String, List<Map<String, String>>> mitigationsTexts =
                      Mitigation.getMitigationsTextsByAnswer(
                          mitigations!, answers);

                  Map<String, List<String>> mitigationsTextPdf = {};
                  mitigationsTexts.forEach((key, value) {
                    mitigationsTextPdf[key] =
                        value.map((e) => e['text']!).toList();
                  });

                  /*  saveEventdata(
                      screenId: 'result_page', buttonId: 'download_results');
 */
                  House house =
                      houseProvider.getHouse(houseProvider.currentHouse!);

                  File pdf = await PdfCreator.generateAdvancedResultsPdf(
                    risk,
                    hazard,
                    vulnerability,
                    subProbabilities,
                    mitigationsTextPdf,
                    getRiskInfo(hazard * 100, vulnerability * 100, risk * 100,
                        context, _showHazard),
                    _showHazard,
                    house,
                    DateFormat('dd-MM-yyyy').format(date),
                  );
                  if (Platform.isIOS) await PdfCreator.openPdf(pdf);
                  Navigator.of(context).pop();
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
            //Enganxar el codi del botó de check improvements aquí si es vol que es quedi al final
          ],
        ),
      ),
    );
  }

  Future<Uint8List> captureGaugeAsImage(GlobalKey key) async {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    var image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  double? getLastSubProb(String key1, String key2) {
    if (lastSubProbabilities.containsKey(key1)) {
      if (lastSubProbabilities[key1]!.subEvents!.containsKey(key2)) {
        return lastSubProbabilities[key1]!.subEvents![key2]!.probability * 100;
      }
    }
    return null;
  }

  String getRiskInfo(double hazard, double vulnerability, double risk,
      BuildContext context, bool showHazard) {
    String hazardLevel = getLevel(hazard);
    String vulnerabilityLevel = getLevel(vulnerability);
    String textId = showHazard
        ? getInfoText(hazardLevel, vulnerabilityLevel)
        : '${vulnerabilityLevel}_text';
    String riskLevel = getRiskLevel(risk);

    if (showHazard) {
      return context.tr('hazard_vulnerability_text.$textId', namedArgs: {
        'hazard_level': context.tr('hazard_levels.$hazardLevel'),
        'vulnerability_level':
            context.tr('vulnerability_levels.$vulnerabilityLevel'),
        'risk': context.tr('risk_levels.$riskLevel'),
      });
    } else {
      return context.tr('vulnerability_text.$textId', namedArgs: {
        'vulnerability_level':
            context.tr('vulnerability_levels.$vulnerabilityLevel'),
        'risk': context.tr('risk_levels.$riskLevel'),
      });
    }
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

  Future<Uint8List> captureAsImage(GlobalKey key) async {
    RenderRepaintBoundary boundary =
        key.currentContext!.findRenderObject() as RenderRepaintBoundary;

    var image = await boundary.toImage(pixelRatio: 3.0);
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    return byteData!.buffer.asUint8List();
  }

  /* Widget radialGauge(double value, ScreenshotController screenshotController) {
    print('in screenshoot');
    return Screenshot(
      controller: screenshotController,
      child: Stack(
        children: [
          Center(
            child: Container(
              height: 200,
              width: 200,
              padding: const EdgeInsets.all(20),
              color: Colors.transparent,
              child: Gauge.radialGauge(value * 100, 15, 6),
            ),
          ),
        ],
      ),
    );
    //Uint8List radialGauge = await captureAsImage(gaugeKey);
  }*/

  /*Future<Map<String, Uint8List>> linearGauges(
      Map<String, EventProbability> subProbabilities) async {
    Map<String, Uint8List> linearGauges = {};
    for (var subProb in subProbabilities.entries) {
      GlobalKey linearKey = GlobalKey();
      Offstage(
        child: RepaintBoundary(
          key: linearKey,
          child: Gauge.linearGauge(
              subProb.value.probability * 100, 25, 15, 30, null, true, 12),
        ),
      );

      linearGauges[subProb.key] = await captureAsImage(linearKey);
    }
    return linearGauges;
  }*/
}
