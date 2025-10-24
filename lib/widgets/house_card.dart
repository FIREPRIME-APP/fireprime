import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/house/choose_mode.dart';
import 'package:fireprime/pages/house/edit_house_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/card_text.dart';
import 'package:fireprime/widgets/house_delete_alert.dart';
import 'package:flutter/cupertino.dart';
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
                return const ChooseMode();
              },
            ),
          );
        },
        child: Stack(
          children: [
            Card(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      PopupMenuButton<int>(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) async {
                          if (value == 0) {
                            saveEventdata(
                                screenId: 'house_page', buttonId: 'edit_house');
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (BuildContext context) {
                                  houseProvider.setCurrentHouse(houseKey);
                                  return EditHousePage(
                                    currentHouse: houseKey,
                                  );
                                },
                              ),
                            );
                          } else if (value == 1) {
                            houseProvider.setCurrentHouse(houseKey);
                            saveEventdata(
                                screenId: 'house_page',
                                buttonId: 'delete_house');
                            await showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return const DeleteAlert();
                              },
                            );
                          }
                        },
                        itemBuilder: (BuildContext context) {
                          return [
                            PopupMenuItem(
                                value: 0,
                                child: Text(context.tr('edit_house'))),
                            PopupMenuItem(
                                value: 1,
                                child: Text(context.tr('delete_house'))),
                          ];
                        },
                      ),
                      const Icon(
                        Icons.house,
                        size: 40,
                        color: Constants.blueDark,
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.only(right: 30),
                          child: Text(
                            house.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'OpenSans',
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 5, 20, 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (house.address != null && house.address != '') ...[
                          CardText(
                              title: context.tr('address'),
                              text: house.address!,
                              size: 15,
                              color: Colors.black),
                          const SizedBox(height: 10.0),
                        ],
                        if (house.zipCode != null) ...[
                          CardText(
                            title: context.tr('zip_code'),
                            text: house.zipCode!,
                            size: 15,
                            color: Colors.black,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
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
