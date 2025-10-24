import 'dart:convert';

import 'package:easy_localization/easy_localization.dart';
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
                                  data: section['content'] ?? '',
                                  styleSheet: styleSheet),
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
                            await launchUrl(Uri.parse(href));
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Could not launch $href')),
                            );
                          }
                        }
                      },
                    ),
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
