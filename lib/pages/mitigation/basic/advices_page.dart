import 'dart:convert';
import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/pdf_creation/pdf_creator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvicesPage extends StatefulWidget {
  final String area;
  const AdvicesPage({super.key, required this.area});

  @override
  State<AdvicesPage> createState() => _AdvicesPageState();
}

class _AdvicesPageState extends State<AdvicesPage> {
  String markDownData = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final ScrollController scrollCtrl = ScrollController();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('advices_title'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        //future: _loadMarkdownData(context, widget.area),
        future: _loadMarkdownData(context, widget.area),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading data'));
          }

          print(snapshot.data);
          Map<String, dynamic> data = snapshot.data!;
/*
          
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  MarkdownBody(
                    data: snapshot.data!,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 15, fontFamily: 'OpenSans'),
                      h1: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      h2: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        if (await canLaunchUrl(Uri.parse(href))) {
                          await launchUrl(Uri.parse(href));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch $href')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );*/
          MarkdownStyleSheet styleSheet = MarkdownStyleSheet(
            p: const TextStyle(fontSize: 15, fontFamily: 'OpenSans'),
            h1: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            h2: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            h3: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            listBullet: const TextStyle(fontSize: 15),
          );

          return SingleChildScrollView(
            controller: scrollCtrl,
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MarkdownBody(
                      data: data['title'] ?? '',
                      styleSheet: styleSheet,
                    ),
                    const SizedBox(height: 10),
                    MarkdownBody(
                        data: data['content'] ?? '', styleSheet: styleSheet),
                    const SizedBox(height: 20),
                    Column(
                      children: data['sections'].map<Widget>((section) {
                        return ExpansionTile(
                            title: MarkdownBody(
                              data: section['title'] ?? '',
                              styleSheet: styleSheet,
                            ),
                            children: [
                              MarkdownBody(
                                  data: section['intro'] ?? '',
                                  styleSheet: styleSheet),
                              const SizedBox(height: 10),
                              //if (section['content'] != null)
                              MarkdownBody(
                                  data: section['content'] ?? '',
                                  styleSheet: styleSheet),
                              if (section['items'] != null) ...[
                                for (var content in section['items'])
                                  if (content['image'] != null &&
                                      content['image']
                                          .toString()
                                          .isNotEmpty) ...[
                                    Column(
                                      children: [
                                        Image.asset(
                                          'assets/advices/icons/${content['image']}',
                                          fit: BoxFit.contain,
                                        ),
                                        if (content['text'] != null &&
                                            content['text']
                                                .toString()
                                                .isNotEmpty)
                                          Center(
                                            child: Text(
                                              content['text'],
                                              style: const TextStyle(
                                                  fontSize: 15,
                                                  fontFamily: 'OpenSans'),
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        const SizedBox(height: 10),
                                      ],
                                    ),
                                  ] else
                                    MarkdownBody(
                                      data: content['text'] ?? '',
                                      styleSheet: styleSheet,
                                    ),
                              ],
                              const SizedBox(height: 10),
                            ],
                            onExpansionChanged: (expanded) {
                              if (expanded) {
                                print('------');
                                scrollCtrl.animateTo(
                                  scrollCtrl.offset + 300,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              }
                            });
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    MarkdownBody(
                      data: data['more_info'] ?? '',
                      styleSheet: styleSheet,
                      onTapLink: (text, href, title) async {
                        if (href != null) {
                          if (await canLaunchUrl(Uri.parse(href))) {
                            await launchUrl(
                              Uri.parse(href),
                              mode: LaunchMode.externalApplication,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not launch $href')),
                            );
                          }
                        }
                      },
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    if (widget.area == 'spain')
                      Center(
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Constants.blueDark,
                              elevation: 5.0),
                          child: Text(
                            context.tr('download_advices'),
                            style: const TextStyle(color: Colors.white),
                          ),
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
                              ByteData pdf =
                                  await loadAdvicesPdf(context, widget.area);
                              print('loading pdf');
                              print(pdf.runtimeType);
                              String timestamp = DateTime.now()
                                  .toIso8601String()
                                  .replaceAll(':', '-');
                              File file = await PdfCreator.savePdfByBytes(
                                  pdfName:
                                      'Preparedness_and_Safety_Tips_$timestamp.pdf',
                                  pdf: pdf);

                              if (Platform.isIOS) PdfCreator.openPdf(file);

                              Navigator.of(context).pop();
                            } catch (e) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(context.tr('pdf_error')),
                                ),
                              );
                              Navigator.of(context).pop();
                            }
                          },
                        ),
                      ),
                    const SizedBox(height: 10),
                  ]),
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadMarkdownData(
      BuildContext context, String area) async {
    final localeCode = context.locale.languageCode;
    final path = 'assets/advices/$area/$localeCode.json';
    try {
      return jsonDecode(await rootBundle.loadString(path));
    } catch (e) {
      try {
        final defaultPath = 'assets/advices/$area/en.json';
        return jsonDecode(await rootBundle.loadString(defaultPath));
      } catch (e) {
        const defaultPath = 'assets/advices/default/en.json';
        return jsonDecode(await rootBundle.loadString(defaultPath));
      }
    }
  }

  Future<ByteData> loadAdvicesPdf(BuildContext context, String area) async {
    final localeCode = context.locale.languageCode;
    final path = 'assets/advices/$area/pdf/$localeCode.pdf';

    print(path);

    try {
      return await rootBundle.load(path);
    } catch (e) {
      const defaultPath = 'assets/advices/spain/en.pdf';
      return await rootBundle.load(defaultPath);
    }
  }
/*
  Future<Map<String, dynamic>> _loadData(
      BuildContext context, String area) async {
    const path = 'assets/advices/default/en.json';
    try {
      String jsonData = await rootBundle.loadString(path);
      print('jsonData: $jsonData');
      var jsonMap = jsonDecode(jsonData);
      print('jsonMap: $jsonMap');
      return jsonMap;
    } catch (e) {
      // Handle error
      print('Error loading JSON data: $e');
      return {};
    }
  }*/
}
