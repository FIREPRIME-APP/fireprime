import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/constants.dart';
import 'package:fireprime/pages/questionnaire/basic/basic_questionnaire.dart';
import 'package:flutter/material.dart';

class AreaSelection extends StatefulWidget {
  const AreaSelection({super.key});

  @override
  State<AreaSelection> createState() => _AreaSelectionState();
}

class _AreaSelectionState extends State<AreaSelection> {
  String? selectedArea;
  bool _isAreaSelected = false;

  @override
  Widget build(BuildContext context) {
    List<String> areas = Constants.areaCodes;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('area'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              context.tr('area_selection_title'),
              style: const TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              context.tr('area_selection_intro'),
              style: const TextStyle(
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('select_area'),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: selectedArea,
              onChanged: (String? newValue) {
                /* saveEventdata(
                          screenId: 'create_house_page',
                          buttonId: 'select_country');*/
                setState(() {
                  selectedArea = newValue!;
                  _isAreaSelected = true;
                });
              },
              items: areas.map((String area) {
                return DropdownMenuItem<String>(
                  value: area,
                  child: Text(
                    context.tr(area),
                    style: const TextStyle(fontSize: 16),
                  ),
                );
              }).toList(),
              decoration: const InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Constants.blueDark,
                    disabledBackgroundColor: Colors.grey.shade400,
                    elevation: 5.0),
                onPressed: _isAreaSelected
                    ? () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (BuildContext context) {
                              print('Selected Area: $selectedArea');
                              return BasicQuestionnairePage(
                                  //answers: {},
                                  );
                            },
                          ),
                        );
                      }
                    : null,
                child: Text(
                  context.tr('continue'),
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
