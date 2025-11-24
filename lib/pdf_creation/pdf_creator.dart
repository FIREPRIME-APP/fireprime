import 'dart:io';

import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/model/house.dart';
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
      House house,
      String date) async {
    ScreenshotController screenshotController = ScreenshotController();
    final sw = Stopwatch()..start();

    final assetsFutures = Future.wait([
      getImageFromAssets('assets/images/logos/FIREPRIME_Logo_A.png'),
      getImageFromAssets('assets/images/logos/ue.png')
    ]);

    final gaugeImageFuture = screenshotController.captureFromWidget(
      wg.Container(
        height: 200,
        width: 200,
        padding: const wg.EdgeInsets.all(20),
        color: wg.Colors.transparent,
        child: Gauge.radialGauge(risk * 100, 15, 6, hazard),
      ),
    );

    final hazardImageFuture = screenshotController.captureFromWidget(
      Gauge.linearGauge(hazard * 100, 10, 7, 20, null, false, 8),
    );

    final vulnerabilityImageFuture = screenshotController.captureFromWidget(
      Gauge.linearGauge(vulnerability * 100, 10, 7, 20, null, false, 8),
    );

    final linearGaugeImageFuture =
        linearGauges(subProbabilities, screenshotController);

    final results = await Future.wait([
      assetsFutures,
      gaugeImageFuture,
      hazardImageFuture,
      vulnerabilityImageFuture,
      linearGaugeImageFuture,
    ]);

    final fireprimeLogoBytes = (results[0] as List)[0] as Uint8List;
    final ueLogoBytes = (results[0] as List)[1] as Uint8List;
    final gaugeImage = results[1] as Uint8List;
    final hazardImage = results[2] as Uint8List;
    final vulnerabilityImage = results[3] as Uint8List;
    final linearGaugesImage = results[4] as Map<String, Uint8List>;

    final List<pw.Widget> subProbWidgets =
        getSubProbWidgets(linearGaugesImage, subProbabilities);

    print(
        "All images (including linear gauges) tardó: ${sw.elapsedMilliseconds} ms");

    sw.reset();

    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        header: (context) => logosHeader(fireprimeLogoBytes, ueLogoBytes),
        footer: (context) => customFooter(context, date),
        build: (context) => [
          customHeader('advanced_result_pdf_title'.tr()),
          houseInformation(house),
          addImage(gaugeImage, 100, 100),
          if (showHazard) ...[
            pw.Text(
              '${'risk'.tr()}: ${(risk * 100).toStringAsFixed(0)}',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
            pw.SizedBox(height: 10),
            pw.Text(
              riskInfo,
              style: const pw.TextStyle(fontSize: 13),
              textAlign: pw.TextAlign.justify,
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
    //  return pdf;
    return savePdf(pdfName: 'advanced_results_$timestamp.pdf', pdf: pdf);
  }

  static Future<File> savePdf({
    required String pdfName,
    required pw.Document pdf,
  }) async {
    final File pdfFile;
    if (Platform.isAndroid) {
      print('saving pdf on android');
      MediaStore.appFolder = 'FirePrime';
      final mediaStore = MediaStore();

      final root = await getTemporaryDirectory();
      pdfFile = File('${root.path}/$pdfName');
      await pdfFile.writeAsBytes(await pdf.save());
      print('saving pdf: ${pdfFile.path}');

      final result = await mediaStore.saveFile(
        tempFilePath: pdfFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      await openWithIntent(result!.uri.toString());
    } else {
      final root = await getApplicationDocumentsDirectory();
      pdfFile = File('${root.path}/$pdfName');
      await pdfFile.writeAsBytes(await pdf.save());
    }
    return pdfFile;
  }

  /* static Future<File> savePdfiOS({
    required String pdfName,
    required pw.Document pdf,
  }) async {
    final File pdfFile;

    final root = await getApplicationDocumentsDirectory();
    pdfFile = File('${root.path}/$pdfName');
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfFile;
  }

  static Future<SaveInfo?> savePdfAndroid({
    required String pdfName,
    required pw.Document pdf,
  }) async {
    final File pdfFile;
    if (Platform.isAndroid) {
      print('saving pdf on android');
      MediaStore.appFolder = 'FirePrime';
      final mediaStore = MediaStore();

      final root = await getTemporaryDirectory();
      pdfFile = File('${root.path}/$pdfName');
      await pdfFile.writeAsBytes(await pdf.save());
      print('saving pdf: ${pdfFile.path}');

      return await mediaStore.saveFile(
        tempFilePath: pdfFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      // await openWithIntent(result!.uri.toString());
    }
    return null;
  }
 */
  static Future<void> openWithIntent(String contentUri) async {
    print(contentUri);
    final intent = AndroidIntent(
      action: 'android.intent.action.VIEW',
      data: contentUri,
      type: 'application/*',
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

  static pw.Widget customFooter(pw.Context context, String date) {
    return pw.Container(
      padding: const pw.EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(date, style: const pw.TextStyle(fontSize: 10)),
          pw.Text(
            '${context.pageNumber}',
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
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

  static Future<File> generateBasicResultsPdf(
      int risk,
      Map<String, dynamic> markdownText,
      String riskLevel,
      String riskText,
      Color riskColor,
      House house,
      String date) async {
    final pdf = pw.Document();

    final fireprimeLogoBytes =
        await getImageFromAssets('assets/images/logos/FIREPRIME_Logo_A.png');
    final ueLogoBytes = await getImageFromAssets('assets/images/logos/ue.png');

    final sw = Stopwatch()..start();

    final List<List<pw.Widget>> markDownWidgets =
        await _getMarkdownWidgets(markdownText);

    print('text basic: ${sw.elapsedMilliseconds} ms');
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        header: (context) => logosHeader(fireprimeLogoBytes, ueLogoBytes),
        footer: (context) => customFooter(context, date),
        build: (context) => [
          customHeader('basic_result_pdf_title'.tr()),
          houseInformation(house),
          pw.SizedBox(height: 10),
          pw.Text(
            '${'result_intro'.tr()}: $riskLevel',
            style: pw.TextStyle(fontSize: 20, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
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
            riskText,
            style: const pw.TextStyle(fontSize: 13),
          ),
          pw.SizedBox(height: 20),
          pw.NewPage(),
          customHeader('advices'.tr()),
          ...markDownWidgets.expand((widgetList) {
            return [
              ...widgetList,
              pw.SizedBox(height: 20),
            ];
          }),
        ],
      ),
    );
    String timestamp = DateTime.now().toIso8601String().replaceAll(':', '-');
    return savePdf(pdfName: 'basic_results_$timestamp.pdf', pdf: pdf);
  }

  static PdfColor getRiskColor(Color color) {
    return PdfColor.fromInt(color.value);
  }

  static Future<List<List<Widget>>> _getMarkdownWidgets(
      Map<String, dynamic> markdownText) async {
    List<List<pw.Widget>> widgets = [];
    HtmlTagStyle tagStyle = HtmlTagStyle(
      h1Style: pw.TextStyle(
        fontSize: 28,
        fontWeight: pw.FontWeight.bold,
      ),
      h2Style: pw.TextStyle(
        fontSize: 25,
        fontWeight: pw.FontWeight.bold,
      ),
    );

    widgets.add(
      await HTMLToPdf().convertMarkdown(
        markdownText['title'] ?? '',
        tagStyle: tagStyle,
      ),
    );

    widgets.add(
      await HTMLToPdf().convertMarkdown(
        markdownText['content'] ?? '',
        tagStyle: tagStyle,
      ),
    );

    for (var section in markdownText['sections']) {
      widgets.add(
        await HTMLToPdf().convertMarkdown(
          section['title'] ?? '',
          tagStyle: tagStyle,
        ),
      );
      widgets.add(
        await HTMLToPdf().convertMarkdown(
          section['content'] ?? '',
          tagStyle: tagStyle,
        ),
      );
      if (section['items'] != null) {
        for (var content in section['items']) {
          print(content['image']);
          var image = await getImageFromAssets(
              'assets/advices/icons/${content['image']}');
          widgets
              .add([pw.Image(pw.MemoryImage(image), width: 100, height: 100)]);
          widgets.add(await HTMLToPdf().convertMarkdown(
            '- ${content['text']}',
            tagStyle: tagStyle,
          ));
        }
      }
    }

    widgets.add(
      await HTMLToPdf().convertMarkdown(
        markdownText['more_info'] ?? '',
        tagStyle: tagStyle,
      ),
    );

    return widgets;
  }

  static pw.Widget houseInformation(House house) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        houseInformationRichText(18, 'house'.tr(), house.name),
        pw.SizedBox(height: 5),
        house.address != null && house.address != ''
            ? houseInformationRichText(14, 'address'.tr(), house.address!)
            : pw.Container(),
        pw.SizedBox(height: 5),
        houseInformationRichText(14, 'zip_code'.tr(), house.zipCode!),
        pw.SizedBox(height: 5),
        houseInformationRichText(
            14, 'country'.tr(), 'european_countries.${house.environment}'.tr()),
        pw.SizedBox(height: 10),
      ],
    );
  }

  static pw.RichText houseInformationRichText(
      double fontSize, String title, String text) {
    return pw.RichText(
      text: pw.TextSpan(
        text: '$title: ',
        style: pw.TextStyle(fontSize: fontSize, fontWeight: pw.FontWeight.bold),
        children: [
          pw.TextSpan(
            text: text,
            style: pw.TextStyle(
                fontSize: fontSize, fontWeight: pw.FontWeight.normal),
          ),
        ],
      ),
    );
  }

  static Future<File> savePdfByBytes(
      {required String pdfName, required pdf}) async {
    final File pdfFile;
    if (Platform.isAndroid) {
      MediaStore.appFolder = 'FirePrime';
      final mediaStore = MediaStore();

      final root = await getTemporaryDirectory();
      pdfFile = File('${root.path}/$pdfName');
      await pdfFile.writeAsBytes(pdf.buffer.asUint8List());

      final result = await mediaStore.saveFile(
        tempFilePath: pdfFile.path,
        dirType: DirType.download,
        dirName: DirName.download,
      );
      await openWithIntent(result!.uri.toString());
    } else {
      final root = await getApplicationDocumentsDirectory();
      pdfFile = File('${root.path}/$pdfName');
      await pdfFile.writeAsBytes(pdf.buffer.asUint8List());
    }
    return pdfFile;
  }
}
