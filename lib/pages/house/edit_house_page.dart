import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/autocomplete/autocomplete.dart';
import 'package:fireprime/autocomplete/google_places_autocomplete.dart';
import 'package:fireprime/config.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/firebase/api_key_manage.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/widgets/utils.dart';
import 'package:fireprime/widgets/input_field.dart';
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

  bool _enabled = true;
  String? _selectedPlace;
  String? _selectedCountryCode;

  @override
  void initState() {
    super.initState();
    final house = Provider.of<HouseProvider>(context, listen: false)
        .getHouse(widget.currentHouse);

    _name.text = house.name;
    _address.text = house.address;

    _name.addListener(_checkInput);
    _address.addListener(_checkInput);
  }

  Future<void> _handleEditHouse(HouseProvider house) async {
    if (_name.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('warning_unfilled_name')),
      );
    } else if (_address.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('warning_unfilled_address')),
      );
    } else if (house.houses[house.currentHouse].name != _name.text &&
        house.existsHouse(_name.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('warning_house_name_exists')),
      );
    } else if (_address.text.isNotEmpty && _name.text.isNotEmpty) {
      if (_selectedPlace == null) {
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(context.tr('unable_to_get_latlong_title')),
              content: Text(context.tr('unable_to_get_latlong_message')),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    saveEventdata(
                        screenId: 'edit_house',
                        buttonId: 'noLatLong_warning_accept');
                    Navigator.of(context).pop();
                    house.editHouse(_name.text, _address.text);
                    Navigator.of(context).pop();
                  },
                  child: Text(context.tr('accept')),
                ),
                TextButton(
                  onPressed: () {
                    saveEventdata(
                        screenId: 'edit_house',
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
        House currentHouse = house.getHouse(house.currentHouse!);
        currentHouse.lat = latLong['latitude'];
        currentHouse.long = latLong['longitude'];
        house.editHouse(_name.text, _address.text);
      }

      house.editHouse(_name.text, _address.text);
      saveEventdata(screenId: 'edit_house_page', buttonId: 'save_edited_house');

      Navigator.of(context).pop();
    }
  }

  void _checkInput() {
    setState(
      () {
        if (_name.text.isNotEmpty && _address.text.isNotEmpty) {
          _enabled = true;
        } else {
          _enabled = false;
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    if (Config.API_KEY == '') {
      getApiKey();
    }

    final house = Provider.of<HouseProvider>(context, listen: false)
        .getHouse(widget.currentHouse);

    _environment.text = context.tr('european_countries.${house.environment}');
    _selectedCountryCode = Constants.europeanCountriesCode[house.environment];

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('edit_house'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            saveEventdata(screenId: 'edit_house_page', buttonId: 'back');
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
                  context.tr('edit_house_intro'),
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                const SizedBox(height: 30.0),
                InputField(
                  label: '*  ${context.tr('name')}:',
                  controller: _name,
                  screenId: 'edit_house_page',
                  buttonId: 'name',
                ),
                const SizedBox(height: 10.0),
                /* InputField(
                  label: '*  ${context.tr('address')}:',
                  controller: _address,
                  screenId: 'edit_house_page',
                  buttonId: 'address',
                ),*/
                AutoCompleteWidget(
                  apiKey: Config.API_KEY,
                  controller: _address,
                  onPlaceSelected: (placeId) => setState(() {
                    _selectedPlace = placeId;
                  }),
                  screenId: 'edit_house_page',
                  selectedCountryCode: _selectedCountryCode!,
                ),
                const SizedBox(height: 10.0),
                Text(
                  '${context.tr('country')}:',
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
                    onPressed: _enabled ? () => _handleEditHouse(house) : null,
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
