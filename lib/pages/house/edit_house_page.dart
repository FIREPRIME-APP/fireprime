import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/firebase/event_manage.dart';
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

  void _handleEditHouse(HouseProvider house) {
    if (_name.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('plsFillName')),
      );
    } else if (_address.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('plsFillAddress')),
      );
    } else if (house.houses[house.currentHouse].name != _name.text &&
        house.existsHouse(_name.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        Utils.snackBar(context.tr('houseExists')),
      );
    } else if (_address.text.isNotEmpty && _name.text.isNotEmpty) {
      house.editHouse(_name.text, _address.text);
      saveEventdata(screenId: 'edit_house_page', buttonId: 'save_house');
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
    final house = Provider.of<HouseProvider>(context, listen: false)
        .getHouse(widget.currentHouse);

    _environment.text = context.tr('european_countries.${house.environment}');

    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('edit'),
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
                  context.tr('editHouse'),
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
                InputField(
                  label: '*  ${context.tr('address')}:',
                  controller: _address,
                  screenId: 'edit_house_page',
                  buttonId: 'address',
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
