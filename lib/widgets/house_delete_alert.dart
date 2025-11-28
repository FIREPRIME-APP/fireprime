import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class DeleteAlert extends StatelessWidget {
  const DeleteAlert({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(context.tr('delete_house_warning_intro'),
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
      content: Text(context.tr('delete_house_warning_text'),
          style: const TextStyle(fontSize: 15)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(context.tr('cancel')),
        ),
        TextButton(
          onPressed: () {
            var houseCtrl = Provider.of<HouseProvider>(context, listen: false);
            houseCtrl.deleteHouse();

            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (BuildContext context) {
                  return const HouseListPage();
                },
              ),
            );
          },
          child: Text(context.tr('delete')),
        ),
      ],
    );
  }
}
