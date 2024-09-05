import 'package:fireprime/controller/house_controller.dart';
import 'package:fireprime/european_countries.dart';
import 'package:fireprime/model/house.dart';
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

  String? _selectedEnvironment;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Add house',
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
                  'Fill your house information',
                  style: Theme.of(context).textTheme.displayMedium!,
                ),
                const SizedBox(height: 30.0),
                const Text(
                  'Name:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                const Text(
                  'Address:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
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
                const Text(
                  'Country:',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10.0),
                DropdownButtonFormField<String>(
                  value: _selectedEnvironment,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedEnvironment = newValue!;
                    });
                  },
                  items: europeanCountries.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
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
                  child: OutlinedButton(
                    onPressed: () {
                      if (_address.text.isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            backgroundColor: Color.fromARGB(255, 242, 246, 255),
                            content: Text(
                              'Please fill your house address',
                              style: TextStyle(
                                  color: Color.fromARGB(255, 86, 97, 123),
                                  fontSize: 16.0),
                            ),
                          ),
                        );
                      } else if (_address.text.isNotEmpty &&
                          _name.text.isNotEmpty &&
                          _selectedEnvironment != null) {
                        House newHouse = House(
                            _name.text, _address.text, _selectedEnvironment!);
                        house.addHouse(newHouse);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Text(
                      'Add house',
                      style: TextStyle(color: Theme.of(context).primaryColor),
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
