import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/autocomplete/google_places_autocomplete.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:flutter/material.dart';

class AutoCompleteWidget extends StatefulWidget {
  const AutoCompleteWidget(
      {super.key,
      required this.apiKey,
      required this.controller,
      required this.onPlaceSelected,
      required this.screenId,
      required this.selectedCountryCode});

  final String apiKey;
  final TextEditingController controller;
  final Function(String) onPlaceSelected;
  final String screenId;
  final String selectedCountryCode;

  @override
  State<AutoCompleteWidget> createState() => _AutoCompleteState();
}

class _AutoCompleteState extends State<AutoCompleteWidget> {
  bool showSuggestions = false;
  late FocusNode _focusNode;
  bool isEditing = false;
  bool addressVerified = false;
  String? selectedPlace;

  @override
  void initState() {
    super.initState();
    _focusNode = FocusNode();
    _focusNode.addListener(_onFocusChange);
    widget.controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String languageCode = Localizations.localeOf(context).languageCode;
    return Column(
      children: [
        Row(
          children: [
            Text('* ${context.tr('address')}:',
                style:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
          ],
        ),
        const SizedBox(height: 10.0),
        TextField(
          controller: widget.controller,
          focusNode: _focusNode,
          decoration: const InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(10.0)),
            ),
          ),
        ),
        FutureBuilder<List<dynamic>>(
          future: GooglePlacesAutoComplete().getPredictions(
              widget.controller.text,
              widget.apiKey,
              languageCode,
              widget.selectedCountryCode),
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<dynamic> suggestions = snapshot.data!;
              if (showSuggestions) {
                double suggestionsHeight = suggestions.length * 60.0;
                return SizedBox(
                  height: suggestionsHeight < 150 ? suggestionsHeight : 150,
                  child: Scrollbar(
                    child: ListView.separated(
                      padding: EdgeInsets.zero,
                      shrinkWrap: true,
                      itemCount: suggestions.length,
                      separatorBuilder: (context, index) => const Divider(
                        color: Colors.grey,
                      ),
                      itemBuilder: (context, index) {
                        return InkWell(
                          onTap: () async {
                            saveEventdata(
                                screenId: widget.screenId, buttonId: 'address');
                            widget.controller.text = suggestions[index]
                                ['placePrediction']['text']['text'];
                            setState(() {
                              showSuggestions = false;
                            });
                            selectedPlace = suggestions[index]
                                ['placePrediction']['placeId'];
                            widget.onPlaceSelected(selectedPlace!);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                if (suggestions[index]['placePrediction']
                                            ['text'] !=
                                        null &&
                                    widget.controller.text !=
                                        suggestions[index]['placePrediction']
                                            ['text']) ...[
                                  Expanded(
                                    child: Text(
                                        suggestions[index]['placePrediction']
                                            ['text']['text'],
                                        style: const TextStyle(fontSize: 16)),
                                  )
                                ]
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                );
              } else {
                return const SizedBox();
              }
            } else {
              return const SizedBox();
            }
          },
        ),
      ],
    );
  }

  void _onTextChanged() {
    setState(() {
      if (widget.controller.text.isNotEmpty && isEditing) {
        showSuggestions = true;
      } else {
        showSuggestions = false;
      }
    });
  }

  void _onFocusChange() {
    setState(() {
      if (_focusNode.hasFocus) {
        isEditing = true;
        saveEventdata(screenId: "", buttonId: "address");
        if (widget.controller.text.isNotEmpty) {
          showSuggestions = true;
        }
      } else {
        isEditing = false;
        showSuggestions = false;
      }
    });
  }
}
