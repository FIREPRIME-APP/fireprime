import 'dart:io';

import 'package:fireprime/model/event_probability.dart';
import 'package:flutter/services.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:easy_localization/easy_localization.dart';

class PdfCreator {
  static Future<File> generateResultsPdf(
      String pdfName,
      double risk,
      double hazard,
      double vulnerability,
      Map<String, EventProbability> subProbabilities,
      Map<String, List<String>> mitigationsText,
      String riskInfo) async {
    final fireprimeLogo =
        await rootBundle.load('assets/images/logos/FIREPRIME_Logo_A.png');
    final fireprimeLogoBytes = fireprimeLogo.buffer.asUint8List();

    final ueLogo = await rootBundle.load('assets/images/logos/ue.png');
    final ueLogoBytes = ueLogo.buffer.asUint8List();

    print(mitigationsText);
    final pdf = pw.Document();
    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(50),
        header: (context) => logosHeader(fireprimeLogoBytes, ueLogoBytes),
        footer: (context) => customFooter(context),
        build: (context) => [
          customHeader('result'.tr()),
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
          pw.Text(
            '${'house_vulnerability'.tr()}: ${(vulnerability * 100).toStringAsFixed(0)}',
            style: const pw.TextStyle(fontSize: 13),
          ),
          pw.SizedBox(height: 15),
          pw.Text(
            riskInfo,
            style: const pw.TextStyle(fontSize: 13),
            textAlign: pw.TextAlign.justify,
          ),
          ...subProbabilities.entries.map(
            (entry) => pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                pw.SizedBox(height: 15),
                pw.Text(
                  entry.key.tr(),
                  style: pw.TextStyle(
                      fontSize: 15, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 10),
                pw.Column(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    ...entry.value.subEvents!.entries.expand(
                      (subProb) => [
                        pw.Padding(
                          padding: const pw.EdgeInsets.only(left: 20),
                          child: pw.Text(
                            '${subProb.key.tr()}: ${(subProb.value.probability * 100).toStringAsFixed(0)}',
                            style: const pw.TextStyle(fontSize: 12),
                          ),
                        ),
                        pw.SizedBox(height: 5),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
          pw.SizedBox(height: 10),
          pw.NewPage(),
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
    return savePdf(pdfName: 'results.pdf', pdf: pdf);
  }

  static Future<File> savePdf({
    required String pdfName,
    required pw.Document pdf,
  }) async {
    final root = Platform.isAndroid
        ? await getExternalStorageDirectory()
        : await getApplicationDocumentsDirectory();
    final pdfFile = File('${root!.path}/$pdfName');
    await pdfFile.writeAsBytes(await pdf.save());
    return pdfFile;
  }

  static Future<void> openPdf(File file) async {
    final path = file.path;
    await OpenFile.open(path);
  }

  static pw.Widget logosHeader(fireprimeLogoBytes, Uint8List ueLogoBytes) {
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
}
