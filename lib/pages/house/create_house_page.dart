import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/autocomplete/autocomplete.dart';
import 'package:fireprime/autocomplete/google_places_autocomplete.dart';
import 'package:fireprime/config.dart';
import 'package:fireprime/firebase/api_key_manage.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/widgets/utils.dart';
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

  String? _selectedPlace;
  String? _selectedCountryCode;

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

  Future<void> _handleAddHouse(HouseProvider house) async {
    if (_name.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('warning_unfilled_name')),
      );
    } else if (_address.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('warning_unfilled_address')),
      );
    } else if (_selectedEnvironment == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('warning_unselected_country')),
      );
    } else if (house.existsHouse(_name.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('warning_house_name_exists')),
      );
    } else if (_address.text.isNotEmpty &&
        _name.text.isNotEmpty &&
        _selectedEnvironment != null) {
      saveEventdata(screenId: 'create_house_page', buttonId: 'create_house');

      if (_selectedPlace == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(context.tr('unable_to_get_latlong_title'),
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold)),
              content: Text(context.tr('unable_to_get_latlong_message'),
                  style: const TextStyle(fontSize: 15)),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    saveEventdata(
                        screenId: 'create_house_page',
                        buttonId: 'noLatLong_warning_accept');
                    Navigator.of(context).pop();
                    House newHouse =
                        House(_name.text, _address.text, _selectedEnvironment!);
                    house.addHouse(newHouse);
                    Navigator.of(context).pop();
                  },
                  child: Text(context.tr('accept')),
                ),
                TextButton(
                  onPressed: () {
                    saveEventdata(
                        screenId: 'create_house_page',
                        buttonId: 'noLatLong_warning_try_again');
                    Navigator.of(context).pop();
                  },
                  child: Text(context.tr('try_again')),
                ),
              ],
            );
          },
        );
      } else {
        Map<String, dynamic> latLong = await GooglePlacesAutoComplete()
            .getLatLong(_selectedPlace!, Config.API_KEY);
        House newHouse =
            House(_name.text, _address.text, _selectedEnvironment!);
        newHouse.lat = latLong['latitude'];
        newHouse.long = latLong['longitude'];
        house.addHouse(newHouse);

        Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final Map<String, String> sortedCountries = _getStoredCountries(context);
    if (Config.API_KEY == '') {
      getApiKey();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('add_house'),
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
                  context.tr('add_house_intro'),
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
                /*InputField(
                  label: '*  ${context.tr('address')}:',
                  controller: _address,
                  screenId: 'create_house_page',
                  buttonId: 'address',
                ),*/
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
                        screenId: 'create_house_page',
                        buttonId: 'select_country');
                    setState(() {
                      _selectedEnvironment = newValue!;
                      _selectedCountryCode = Constants
                          .europeanCountriesCode[_selectedEnvironment!];
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
                const SizedBox(height: 10.0),
                if (_selectedCountryCode != null)
                  AutoCompleteWidget(
                    apiKey: Config.API_KEY,
                    controller: _address,
                    onPlaceSelected: (placeId) => setState(() {
                      _selectedPlace = placeId;
                    }),
                    screenId: 'create_house_page',
                    selectedCountryCode: _selectedCountryCode!,
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
                      context.tr('add_house'),
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
