import 'dart:convert';
import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/house/house_list_page.dart';
import 'package:fireprime/mitigation/mitigation_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MitigationMenuPage extends StatefulWidget {
  final String mitigationId;

  const MitigationMenuPage({super.key, required this.mitigationId});

  @override
  State<MitigationMenuPage> createState() => _MitigationMenuPageState();
}

class _MitigationMenuPageState extends State<MitigationMenuPage> {
  @override
  Widget build(BuildContext context) {
    Locale currentLocale = Localizations.localeOf(context);
    String languageCode = currentLocale.languageCode;

    return Scaffold(
      appBar: AppBar(
        title: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            context.tr('mitigations_actions'),
            style: Theme.of(context).textTheme.titleLarge!,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: IconButton(
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
          )
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _loadMitigations(languageCode),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error: ${snapshot.error}',
                style: const TextStyle(fontFamily: 'OpenSans'),
              ),
            );
          }
          if (snapshot.hasData) {
            Map<String, dynamic> mitigations = snapshot.data!;
            if (mitigations.containsKey(widget.mitigationId)) {
              var mitigationsById = mitigations[widget.mitigationId];

              if (mitigationsById == null) {
                return Center(
                  child: Text(
                    context.tr('no_mitigations'),
                    style: const TextStyle(fontFamily: 'OpenSans'),
                    textAlign: TextAlign.center,
                  ),
                );
              }

              var menuItems = mitigationsById['mitigations_menu'];

              return SingleChildScrollView(
                child: Column(
                  children: [
                    for (var item in menuItems)
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 20.0),
                        child: SizedBox(
                          width: double.infinity,
                          child: Card(
                            child: GestureDetector(
                              onTap: () {
                                print('tap');
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return MitigationPage(
                                        mitigationTitle: item['title'],
                                        mitigationActions: item['mitigations'],
                                      );
                                    },
                                  ),
                                );
                              },
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    vertical: 16.0, horizontal: 15.0),
                                child: Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        item['title'],
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                    ),
                                    const Icon(Icons.arrow_right,
                                        color: Color.fromARGB(255, 86, 97, 123),
                                        size: 30),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      )
                  ],
                ),
              );
            } else {
              return Center(
                child: Text(
                  context.tr('no_mitigations'),
                  style: const TextStyle(fontFamily: 'OpenSans'),
                  textAlign: TextAlign.center,
                ),
              );
            }
          }
          return Center(
            child: Text(
              context.tr('no_mitigations'),
              style: const TextStyle(fontFamily: 'OpenSans'),
              textAlign: TextAlign.center,
            ),
          );
        },
      ),
    );
  }

  Future<Map<String, dynamic>> _loadMitigations(String languageCode) async {
    try {
      String filePath = 'assets/mitigations_text/$languageCode.json';
      String data = await rootBundle.loadString(filePath);
      return json.decode(data);
    } catch (e) {
      print(e);
      throw Exception('Failed to load mitigations');
    }
  }
}
