import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/widgets/gauge.dart';
import 'package:flutter/material.dart' as wg;
import 'package:flutter/services.dart';
import 'package:htmltopdfwidgets/htmltopdfwidgets.dart';
import 'package:media_store_plus/media_store_plus.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:easy_localization/easy_localization.dart';
import 'package:screenshot/screenshot.dart';

class PdfCreator {
  static Future<File> generateAdvancedResultsPdf(
    double risk,
    double hazard,
    double vulnerability,
    Map<String, EventProbability> subProbabilities,
    Map<String, List<String>> mitigationsText,
    String riskInfo,
    bool showHazard,
    // Uint8List? gaugeImage,
    // Map<String, Uint8List> linearGaugesImage,
  ) async {
    ScreenshotController screenshotController = ScreenshotController();

    final fireprimeLogoBytes =
        await getImageFromAssets('assets/images/logos/FIREPRIME_Logo_A.png');

    final ueLogoBytes = await getImageFromAssets('assets/images/logos/ue.png');

    Uint8List gaugeImage = await screenshotController.captureFromWidget(
      wg.Container(
        height: 200,
        width: 200,
        padding: const wg.EdgeInsets.all(20),
        color: wg.Colors.transparent,
        child: Gauge.radialGauge(risk * 100, 15, 6),
      ),
    );

    Uint8List hazardImage = await screenshotController.captureFromWidget(
      Gauge.linearGauge(hazard * 100, 10, 7, 20, null, false, 8),
    );

    Uint8List vulnerabilityImage = await screenshotController.captureFromWidget(
      Gauge.linearGauge(vulnerability * 100, 10, 7, 20, null, false, 8),
    );

    Map<String, Uint8List> linearGaugesImage =
        await linearGauges(subProbabilities, screenshotController);

    print(linearGaugesImage.keys);

    final List<pw.Widget> subProbWidgets =
        getSubProbWidgets(linearGaugesImage, subProbabilities);

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        header: (context) => logosHeader(fireprimeLogoBytes, ueLogoBytes),
        footer: (context) => customFooter(context),
        build: (context) => [
          customHeader('result'.tr()),
          addImage(gaugeImage, 100, 100),
          if (showHazard) ...[
            pw.Text(
              '${'risk'.tr()}: ${(risk * 100).toStringAsFixed(0)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              '${'hazard'.tr()}: ${(hazard * 100).toStringAsFixed(0)}',
              style: const pw.TextStyle(fontSize: 13),
            ),
            pw.SizedBox(height: 5),
            addImage(hazardImage, null, 100),
            pw.SizedBox(height: 5),
            pw.Text(
              '${'house_vulnerability'.tr()}: ${(vulnerability * 100).toStringAsFixed(0)}',
              style: const pw.TextStyle(fontSize: 13),
            ),
            pw.SizedBox(height: 5),
            addImage(vulnerabilityImage, null, 100),
            pw.SizedBox(height: 15),
          ],
          if (!showHazard) ...[
            pw.Text(
              '${'vulnerability'.tr()}: ${(vulnerability * 100).toStringAsFixed(0)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
          ],
          pw.Text(
            riskInfo,
            style: const pw.TextStyle(fontSize: 13),
            textAlign: pw.TextAlign.justify,
          ),
          pw.NewPage(),
          ...subProbWidgets,
          pw.SizedBox(height: 10),
          pw.Text('mitigation_title'.tr(),
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
          ...mitigationsText.entries.map(
            (mitigation) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.Text(
                  mitigation.key,
                  style: pw.TextStyle(
                    fontSize: 14,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
                pw.SizedBox(height: 5),
                ...mitigation.value.map(
                  (text) => pw.Bullet(
                    text: text,
                    style: const pw.TextStyle(fontSize: 12),
                    textAlign: pw.TextAlign.justify,
                    bulletMargin: const pw.EdgeInsets.only(top: 10, right: 10),
                  ),
                ),
                pw.SizedBox(height: 10),
              ],
            ),
          ),
        ],
      ),
    );
    String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return savePdf(pdfName: 'advanced_results_$timestamp.pdf', pdf: pdf);
  }

  static Future<File> savePdf({
    required String pdfName,
    required pw.Document pdf,
  }) async {
    MediaStore.appFolder = 'FirePrime';
    final mediaStore = MediaStore();

    final root = Platform.isAndroid
        ? await getTemporaryDirectory()
        : await getApplicationDocumentsDirectory();
    final pdfFile = File('${root.path}/$pdfName');
    await pdfFile.writeAsBytes(await pdf.save());
    print('saving pdf: ${pdfFile.path}');

    final result = await mediaStore.saveFile(
      tempFilePath: pdfFile.path,
      dirType: DirType.download,
      dirName: DirName.download,
    );
    if (Platform.isAndroid) await openWithIntent(result!.uri.toString());
    //final result = await OpenFile.open(pdfFile.path);
    //print('open file result: ${result.message}');
    return pdfFile;
  }

  static Future<void> openWithIntent(String contentUri) async {
    print(contentUri);
    final intent = AndroidIntent(
      action: 'action_view',
      data: contentUri,
      type: 'application/pdf',
      flags: <int>[
        Flag.FLAG_GRANT_READ_URI_PERMISSION,
        Flag.FLAG_ACTIVITY_NEW_TASK,
      ],
    );
    await intent.launch();
  }

  static Future<void> openPdf(File file) async {
    if (!await file.exists()) {
      print('pdf not found');
      return;
    }
    final path = file.path;
    print('pdf_path: $path');

    // if (await Permission.manageExternalStorage.request().isGranted) {
    await OpenFile.open(path);
    //}
  }

  static Future<Uint8List> getImageFromAssets(String path) async {
    final image = await rootBundle.load(path);
    final imageBytes = image.buffer.asUint8List();
    return imageBytes;
  }

  static pw.Widget logosHeader(
      Uint8List fireprimeLogoBytes, Uint8List ueLogoBytes) {
    return pw.Container(
      padding: const pw.EdgeInsets.only(bottom: 20),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Image(pw.MemoryImage(fireprimeLogoBytes), width: 100, height: 100),
          pw.Image(pw.MemoryImage(ueLogoBytes), width: 100, height: 100),
        ],
      ),
    );
  }

  static pw.Widget customHeader(String headerText) {
    return pw.Container(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.SizedBox(height: 10),
          pw.Text(headerText,
              style:
                  pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
          pw.SizedBox(height: 10),
        ],
      ),
    );
  }

  static pw.Widget customFooter(pw.Context context) {
    return pw.Container(
      alignment: pw.Alignment.bottomRight,
      child: pw.Text(
        '${context.pageNumber}',
        style: const pw.TextStyle(fontSize: 10),
      ),
    );
  }

  static pw.Widget addImage(
      Uint8List imageBytes, double? width, double? height) {
    print('addimage ----');
    return pw.Container(
      child: pw.Image(pw.MemoryImage(imageBytes), width: width, height: height),
    );
  }

  static Future<Map<String, Uint8List>> linearGauges(
    Map<String, EventProbability> subProbabilities,
    ScreenshotController screenshotController,
  ) async {
    Map<String, Uint8List> linearGauges = {};
    for (var subProb in subProbabilities.entries) {
      if (!linearGauges.containsKey(subProb.key)) {
        linearGauges[subProb.key] =
            await screenshotController.captureFromWidget(
          Gauge.linearGauge(
              subProb.value.probability * 100, 12, 9, 22, null, false, 10),
        );
      }
      for (var subEntry in subProb.value.subEvents!.entries) {
        linearGauges[subEntry.key] =
            await screenshotController.captureFromWidget(
          Gauge.linearGauge(
              subEntry.value.probability * 100, 10, 7, 20, null, false, 8),
        );
      }
    }
    return linearGauges;
  }

  static List<pw.Widget> getSubProbWidgets(
      Map<String, Uint8List> linearGaugesImage,
      Map<String, EventProbability> subProbabilities) {
    List<pw.Widget> subProbWidgets = [];
    for (var entry in subProbabilities.entries) {
      final List<pw.Widget> columnContent = [
        if (linearGaugesImage.containsKey(entry.key)) ...[
          pw.Text(
            '${entry.key.tr()}: ${(entry.value.probability * 100).toStringAsFixed(0)}',
            style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          if (linearGaugesImage.containsKey(entry.key))
            addImage(linearGaugesImage[entry.key]!, null, 100),
          pw.SizedBox(height: 10),
        ],
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: entry.value.subEvents!.entries
              .expand((subProb) => [
                    pw.Padding(
                      padding: const pw.EdgeInsets.only(bottom: 5, top: 5),
                      child: pw.Text(
                        '${subProb.key.tr()}: ${(subProb.value.probability * 100).toStringAsFixed(0)}',
                        style: const pw.TextStyle(fontSize: 12),
                      ),
                    ),
                    pw.SizedBox(height: 5),
                    if (linearGaugesImage.containsKey(subProb.key))
                      addImage(linearGaugesImage[subProb.key]!, null, 100),
                    pw.SizedBox(height: 5),
                  ])
              .toList(),
        ),
      ];
      subProbWidgets.add(
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: columnContent,
        ),
      );
      subProbWidgets.add(pw.NewPage());
    }
    return subProbWidgets;
  }

  static Future<File> generateBasicResultsPdf(int risk, String markdownText,
      String riskLevel, String riskText, Color riskColor) async {
    final pdf = pw.Document();

    final fireprimeLogoBytes =
        await getImageFromAssets('assets/images/logos/FIREPRIME_Logo_A.png');
    final ueLogoBytes = await getImageFromAssets('assets/images/logos/ue.png');

    final List<pw.Widget> markDownWidgets =
        await HTMLToPdf().convertMarkdown(markdownText,
            tagStyle: HtmlTagStyle(
              h1Style: TextStyle(
                fontSize: 100,
                fontWeight: FontWeight.bold,
              ),
              h2Style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
            ));

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        header: (context) => logosHeader(fireprimeLogoBytes, ueLogoBytes),
        footer: (context) => customFooter(context),
        build: (context) => [
          customHeader('result'.tr()),
          pw.Container(
            color: getRiskColor(riskColor),
            child: pw.Padding(
              padding: const pw.EdgeInsets.all(8.0),
              child: pw.Text(
                '$risk/10',
                style:
                    pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
              ),
            ),
          ),
          pw.SizedBox(height: 10),
          pw.Text(
            '${'result_intro'.tr()}: $riskLevel',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 5),
          pw.Text(
            riskText,
            style: const pw.TextStyle(fontSize: 13),
          ),
          pw.SizedBox(height: 20),
          pw.NewPage(),
          customHeader('advices'.tr()),
          markDownWidgets.isNotEmpty
              ? pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: markDownWidgets,
                )
              : pw.SizedBox.shrink(),
        ],
      ),
    );
    String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return savePdf(pdfName: 'basic_results_$timestamp.pdf', pdf: pdf);
  }

  static PdfColor getRiskColor(Color color) {
    return PdfColor.fromInt(color.value);
  }
}
