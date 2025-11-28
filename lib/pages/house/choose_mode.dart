import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/pages/house/advanced/house_page.dart';
import 'package:fireprime/pages/house/basic/basic_house.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/pages/mitigation/basic/advices_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChooseMode extends StatelessWidget {
  const ChooseMode({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(context.tr('choose_mode_title'),
            overflow: TextOverflow.visible,
            softWrap: true,
            style: const TextStyle(
                fontSize: 18,
                color: Colors.black,
                fontWeight: FontWeight.bold)),
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
              _modeButton([
                'basic_mode_intro1',
                'basic_mode_intro2',
                'basic_mode_intro3',
                'basic_mode_intro4',
              ], 'basic', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const BasicHousePage()),
                );
              }, context),
              const SizedBox(
                height: 20,
              ),
              _modeButton([
                'advanced_mode_intro1',
                'advanced_mode_intro2',
                'advanced_mode_intro3',
                'advanced_mode_intro4',
                'advanced_mode_intro5',
                'advanced_mode_intro6',
              ], 'advanced', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HousePage()),
                );
              }, context),
              const SizedBox(
                height: 20,
              ),
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Constants.blueDark, elevation: 5.0),
                  onPressed: () {
                    HouseProvider houseProvider =
                        Provider.of<HouseProvider>(context, listen: false);
                    House currentHouse =
                        houseProvider.getHouse(houseProvider.currentHouse!);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            AdvicesPage(area: currentHouse.environment),
                      ),
                    );
                  },
                  child: Text(context.tr('advices'),
                      style: const TextStyle(color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton(List<String> introTexts, String mode,
      VoidCallback onPressed, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.tr('${mode}_mode'),
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(
          height: 10,
        ),
        RichText(
          text: TextSpan(
            style:
                const TextStyle(fontSize: 15, color: Colors.black, height: 1.3),
            children: [
              for (var i = 0; i < introTexts.length; i++)
                if (i % 2 != 0)
                  TextSpan(text: context.tr(introTexts[i]))
                else
                  TextSpan(
                    text: context.tr(introTexts[i]),
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
            ],
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Center(
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Constants.blueDark, elevation: 5.0),
            onPressed: onPressed,
            child: Text(context.tr(mode),
                style: const TextStyle(color: Colors.white)),
          ),
        ),
      ],
    );
  }
}
