import 'package:fireprime/about_page.dart';
import 'package:fireprime/controller/house_controller.dart';
import 'package:fireprime/house/create_house_page.dart';
import 'package:fireprime/house/house_page.dart';
import 'package:fireprime/language/language_page.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class HouseListPage extends StatefulWidget {
  const HouseListPage({super.key});

  @override
  State<HouseListPage> createState() => _HouseListPageState();
}

class _HouseListPageState extends State<HouseListPage> {
  @override
  Widget build(BuildContext context) {
    final houseController =
        Provider.of<HouseController>(context, listen: false);
    return Scaffold(
        body: FutureBuilder<bool>(
      future: houseController.initialiseBox(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return const Center(child: Text('Error'));
        } else {
          return Consumer<HouseController>(
            builder: (context, house, child) {
              var houses = house.getHouses();
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
                      Row(
                        children: [
                          const Expanded(
                            child: Center(
                              child: Image(
                                image: AssetImage(
                                  'assets/images/logos/FIREPRIME_Logo_A.png',
                                ),
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          const Spacer(),
                          IconButton(
                              onPressed: () {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (BuildContext context) {
                                      return const AboutPage();
                                    },
                                  ),
                                );
                              },
                              icon: const Icon(Icons.info)),
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (BuildContext context) {
                                    return const LanguagePage();
                                  },
                                ),
                              );
                            },
                            icon: const Icon(Icons.language),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 20.0,
                      ),
                      if (houses.isNotEmpty)
                        ...houses.entries.map((entry) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: houseCard(entry.key, entry.value, context),
                          );
                        }),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 86, 97, 123),
                            elevation: 5.0),
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (BuildContext context) {
                                return const CreateHousePage();
                              },
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_circle_outlined,
                            color: Colors.white),
                        label: Text(
                          context.tr('addHouse'),
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        }
      },
    ));
  }

  Widget houseCard(String houseKey, House house, BuildContext context) {
    return Consumer<HouseController>(
      builder: (context, houseCtrl, child) {
        return SizedBox(
          width: MediaQuery.of(context).size.width,
          child: GestureDetector(
            onTap: () {
              // houseCtrl.buttonVisible(house.name);
              houseCtrl.setCurrentHouse(houseKey);
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
                                  color: Color.fromARGB(255, 86, 97, 123),
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
                            Utils.cardText(
                                context.tr('address'), house.address, 15),
                            const SizedBox(height: 10.0),
                            Utils.cardText(
                                context.tr('country'), house.environment, 15),
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
                      color: Color.fromARGB(255, 86, 97, 123),
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
        );
      },
    );
  }
}
