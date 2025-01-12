import 'dart:ffi';

import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/pages/information/about_page.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/firebase/device_manage.dart';
import 'package:fireprime/pages/house/create_house_page.dart';
import 'package:fireprime/pages/language/language_page.dart';
import 'package:fireprime/widgets/house_card.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HouseListPage extends StatefulWidget {
  const HouseListPage({super.key});

  @override
  State<HouseListPage> createState() => _HouseListPageState();
}

class _HouseListPageState extends State<HouseListPage> {
  bool _showPopup = false;

  @override
  void initState() {
    super.initState();
    // _checkIfAcceptedPrivacy();
  }

  /*Future<void> _checkIfAcceptedPrivacy() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    bool accepted = prefs.getBool('accepted_privacy') ?? false;
    print('accepted: $accepted');
    setState(() {
      _showPopup = !accepted;
    });
  }*/

  /* Future<void> _saveAccepted() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('accepted_privacy', true);
    setState(() {
      _showPopup = false;
    });
  }*/

  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<HouseProvider>(context, listen: false);
    // houseProvider.deleteRiskAssessments();

    return Scaffold(
      body: FutureBuilder<bool>(
        future: houseProvider.initialiseBox(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Error'));
          } else {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              /*  if (_showPopup) {
                _showPrivacyPopup(context);
              }*/
              saveDeviceData(context);
            });
            return Consumer<HouseProvider>(
              builder: (context, houseProvider, child) {
                final houses = houseProvider.getHouses();
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: SingleChildScrollView(
                    padding: EdgeInsets.fromLTRB(
                        20,
                        MediaQuery.of(context).padding.top + 20,
                        20,
                        MediaQuery.of(context).padding.bottom + 20),
                    child: Column(
                      children: [
                        _buildHeader(context),
                        const SizedBox(
                          height: 20.0,
                        ),
                        if (houses.isNotEmpty)
                          ...houses.entries.map(
                            (entry) {
                              return Padding(
                                padding:
                                    const EdgeInsets.symmetric(vertical: 10.0),
                                child: HouseCard(
                                    houseKey: entry.key, house: entry.value),
                              );
                            },
                          ),
                        _buildFooter(context),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Row(children: [
      const Expanded(
        child: Center(
          child: Image(
            image: AssetImage(
              Constants.logoA,
            ),
            fit: BoxFit.contain,
          ),
        ),
      ),
      const Spacer(),
      /*IconButton(
          onPressed: () {
            saveEventdata(screenId: 'house_list', buttonId: 'about');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const AboutPage();
                },
              ),
            );
          },
          icon: const Icon(Icons.info)),*/
      IconButton(
        onPressed: () {
          saveEventdata(screenId: 'house_list', buttonId: 'change_language');
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const LanguagePage();
              },
            ),
          );
        },
        icon: const Icon(Icons.language),
      )
    ]);
  }

  Widget _buildFooter(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Constants.blueDark, elevation: 5.0),
          onPressed: () {
            saveEventdata(screenId: 'house_list', buttonId: 'add_house');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const CreateHousePage();
                },
              ),
            );
          },
          icon: const Icon(Icons.add_circle_outlined, color: Colors.white),
          label: Text(
            context.tr('addHouse'),
            style: const TextStyle(color: Colors.white),
          ),
        ),
        ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
              backgroundColor: Constants.blueDark, elevation: 5.0),
          onPressed: () {
            saveEventdata(screenId: 'house_list', buttonId: 'more_info');
            //TODO
            //saveEventdata(screenId: 'house_list', buttonId: 'about');
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const AboutPage();
                },
              ),
            );
          },
          icon: const Icon(Icons.info_outline_rounded, color: Colors.white),
          label: Text(
            context.tr('more_info'),
            style: const TextStyle(color: Colors.white),
          ),
        )
      ],
    );
  }

  /* Future<void> _showPrivacyPopup(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          icon: const Icon(Icons.info),
          title: Text(context.tr('privacy_title'),
              style: const TextStyle(fontWeight: FontWeight.bold)),
          content: Text(
            context.tr('privacy_text'),
            style: const TextStyle(fontSize: 16),
            textAlign: TextAlign.justify,
          ),
          actions: [
            ElevatedButton(
              onPressed: () async {
                //await _saveAccepted();
                Navigator.of(context).pop();
              },
              child: Text(context.tr('agreed')),
            ),
          ],
        );
      },
    );
  }*/

  /* Widget houseCard(HouseProvider houseProvider, String houseKey, House house) {
    // return Consumer<HouseProvider>(
    //  builder: (context, houseCtrl, child) {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () async {
          await saveEventdata(
              screenId: 'house_list', buttonId: '${house.name}_card');
          houseProvider.setCurrentHouse(houseKey);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (BuildContext context) {
                return const HousePage();
              },
            ),
          );
        },
        child: Stack(
          children: [
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.house,
                              size: 40,
                              color: Constants.blueDark,
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            Text(
                              house.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'OpenSans',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10.0),
                        CardText(
                            title: context.tr('address'),
                            text: house.address,
                            size: 15),
                        const SizedBox(height: 10.0),
                        CardText(
                            title: context.tr('country'),
                            text: context
                                .tr('european_countries.${house.environment}'),
                            size: 15),
                        const SizedBox(height: 10.0),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Positioned(
              bottom: 3,
              top: 3,
              right: 0,
              child: Container(
                width: 25,
                decoration: const BoxDecoration(
                  color: Constants.blueDark,
                  borderRadius: BorderRadius.only(
                    topRight: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
                child: const Icon(Icons.arrow_right,
                    color: Colors.white, size: 24),
              ),
            )
          ],
        ),
      ),
      //    );
      //  },
    );
  }*/
}
