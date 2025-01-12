import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/utils.dart';
import 'package:fireprime/widgets/input_field.dart';
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

  Map<String, String> _getStoredCountries(BuildContext context) {
    final Map<String, String> countries = {};
    for (var country in Constants.europeanCountries) {
      countries[country] = context.tr('european_countries.$country');
    }
    return Map.fromEntries(
      countries.entries.toList()
        ..sort(
          (e1, e2) => e1.value.compareTo(e2.value),
        ),
    );
  }

  void _handleAddHouse(HouseProvider house) {
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
      saveEventdata(screenId: 'create_house_page', buttonId: 'create_house');
      House newHouse = House(_name.text, _address.text, _selectedEnvironment!);
      house.addHouse(newHouse);

      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> sortedCountries = _getStoredCountries(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('addHouse'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            saveEventdata(screenId: 'create_house_page', buttonId: 'back');
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Consumer<HouseProvider>(
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
                InputField(
                  label: '*  ${context.tr('name')}:',
                  controller: _name,
                  screenId: 'create_house_page',
                  buttonId: 'name',
                ),
                const SizedBox(height: 10.0),
                InputField(
                  label: '*  ${context.tr('address')}:',
                  controller: _address,
                  screenId: 'create_house_page',
                  buttonId: 'address',
                ),
                const SizedBox(height: 10.0),
                Text(
                  '*  ${context.tr('country')}: ',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: _selectedEnvironment,
                  onChanged: (String? newValue) {
                    saveEventdata(
                        screenId: 'create_house_page', buttonId: 'country');
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
                        backgroundColor: Constants.blueDark,
                        disabledBackgroundColor: Colors.grey.shade400,
                        elevation: 5.0),
                    onPressed: _enabled ? () => _handleAddHouse(house) : null,
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
