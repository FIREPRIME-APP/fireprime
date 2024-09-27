import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/controller/house_controller.dart';
import 'package:fireprime/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class EditHousePage extends StatefulWidget {
  final String currentHouse;

  const EditHousePage({super.key, required this.currentHouse});

  @override
  State<EditHousePage> createState() => _EditHousePageState();
}

class _EditHousePageState extends State<EditHousePage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();
  final TextEditingController _environment = TextEditingController();

  @override
  void initState() {
    super.initState();
    final house = Provider.of<HouseController>(context, listen: false)
        .getHouse(widget.currentHouse);

    _name.text = house.name;
    _address.text = house.address;
    _environment.text = house.environment;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('edit'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Consumer<HouseController>(
        builder: (context, house, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.tr('editHouse'),
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                const SizedBox(height: 30.0),
                Text(
                  '${context.tr('name')}: ',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  controller: _name,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 10.0),
                Text(
                  '${context.tr('address')}: ',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  cursorColor: Theme.of(context).primaryColor,
                  controller: _address,
                  decoration: const InputDecoration(
                      border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  )),
                ),
                const SizedBox(height: 10.0),
                Text(
                  '${context.tr('country')}: ',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                TextField(
                  cursorColor: Theme.of(context).primaryColor,
                  controller: _environment,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                  enabled: false,
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 86, 97, 123),
                        elevation: 5.0),
                    onPressed: () {
                      if (_name.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          Utils.snackBar(context.tr('plsFillName')),
                        );
                      } else if (_address.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          Utils.snackBar(context.tr('plsFillAddress')),
                        );
                      } else if (house.houses[house.currentHouse].name !=
                              _name.text &&
                          house.existsHouse(_name.text)) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          Utils.snackBar(context.tr('houseExists')),
                        );
                      } else if (_address.text.isNotEmpty &&
                          _name.text.isNotEmpty) {
                        house.editHouse(_name.text, _address.text);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      context.tr('save'),
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                )
              ],
            ),
          );
        },
      ),
    );
  }
}
