import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/house/house_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/card_text.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HouseCard extends StatelessWidget {
  final String houseKey;
  final House house;

  const HouseCard({super.key, required this.houseKey, required this.house});

  @override
  Widget build(BuildContext context) {
    final houseProvider = Provider.of<HouseProvider>(context, listen: false);

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: GestureDetector(
        onTap: () async {
          saveEventdata(screenId: 'house_list', buttonId: 'house_card');
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
                            size: 15,
                            color: Colors.black),
                        const SizedBox(height: 10.0),
                        CardText(
                            title: context.tr('country'),
                            text: context
                                .tr('european_countries.${house.environment}'),
                            size: 15,
                            color: Colors.black),
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
  }
}
