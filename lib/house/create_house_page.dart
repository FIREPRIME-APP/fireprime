import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/controller/house_controller.dart';
import 'package:fireprime/european_countries.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateHousePage extends StatefulWidget {
  const CreateHousePage({super.key});

  @override
  State<CreateHousePage> createState() => _CreateHousePageState();
}

class _CreateHousePageState extends State<CreateHousePage> {
  final TextEditingController _name = TextEditingController();
  final TextEditingController _address = TextEditingController();

  Map<String, String> countries = {};

  String? _selectedEnvironment;

  bool _enabled = false;

  @override
  void initState() {
    super.initState();
    _name.addListener(_checkInput);
    _address.addListener(_checkInput);
  }

  void _checkInput() {
    setState(() {
      if (_name.text.isNotEmpty &&
          _address.text.isNotEmpty &&
          _selectedEnvironment != null) {
        _enabled = true;
      } else {
        _enabled = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    for (var country in europeanCountries) {
      countries[country] = context.tr('european_countries.$country');
    }

    Map<String, String> sortedCountries = Map.fromEntries(
        countries.entries.toList()
          ..sort((e1, e2) => e1.value.compareTo(e2.value)));

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('addHouse'),
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
                  context.tr('fillInfo'),
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
                DropdownButtonFormField<String>(
                  value: _selectedEnvironment,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEnvironment = newValue!;
                      _checkInput();
                    });
                  },
                  items: sortedCountries.entries.map((entry) {
                    return DropdownMenuItem<String>(
                      value: entry.key,
                      child: Text(entry.value),
                    );
                  }).toList(),
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(10.0)),
                    ),
                  ),
                ),
                const SizedBox(height: 20.0),
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 86, 97, 123),
                        disabledBackgroundColor: Colors.grey.shade400,
                        elevation: 5.0),
                    onPressed: _enabled
                        ? () {
                            if (_name.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                Utils.snackBar(context.tr('plsFillName')),
                              );
                            } else if (_address.text.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                Utils.snackBar(context.tr('plsFillAddress')),
                              );
                            } else if (_selectedEnvironment == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                Utils.snackBar(context.tr('plsSelectCountry')),
                              );
                            } else if (house.existsHouse(_name.text)) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                Utils.snackBar(context.tr('houseExists')),
                              );
                            } else if (_address.text.isNotEmpty &&
                                _name.text.isNotEmpty &&
                                _selectedEnvironment != null) {
                              print(_selectedEnvironment);
                              House newHouse = House(_name.text, _address.text,
                                  _selectedEnvironment!);
                              house.addHouse(newHouse);

                              Navigator.of(context).pop();
                            }
                          }
                        : null,
                    child: Text(
                      context.tr('addHouse'),
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
