import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/pages/house/advanced/house_page.dart';
import 'package:fireprime/pages/house/basic/basic_house.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:flutter/material.dart';

class ChooseMode extends StatelessWidget {
  const ChooseMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('choose_mode'),
          overflow: TextOverflow.visible,
          softWrap: true,
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const HouseListPage()),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                context.tr('basic_mode'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(
                height: 10,
              ),
              _modeButton(context.tr('basic_mode_intro'), context.tr('basic'),
                  () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BasicHousePage()),
                );
              }),
              const SizedBox(
                height: 20,
              ),
              Text(
                context.tr('advanced_mode'),
                style:
                    const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              _modeButton(
                  context.tr('advanced_mode_intro'), context.tr('advanced'),
                  () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const HousePage()));
              })
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(String intro, String buttonText, VoidCallback onPressed) {
    return Column(
      children: [
        Text(
          intro,
          style: const TextStyle(
            fontSize: 14,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
              backgroundColor: Constants.blueDark, elevation: 5.0),
          onPressed: onPressed,
          child: Text(buttonText, style: const TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}
