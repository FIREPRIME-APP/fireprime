import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/customised_image.dart';
//import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/widgets/selection_list_tile.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:styled_text/styled_text.dart';
import 'package:survey_kit/survey_kit.dart';

class SpecialMultipleChoiceImageStep extends Step {
  final String title;
  final String text;
  final String description;
  final List<CustomisedImage> images;
  final AnswerFormat answerFormat;

  final Map<String, String> rules;
  final List<TextChoice> initialSelection;
  final String specialSelection;
  final Map<String, TextChoice> allTextChoices;

  SpecialMultipleChoiceImageStep({
    required super.stepIdentifier,
    super.isOptional = false,
    required this.title,
    required this.text,
    required this.description,
    required this.images,
    required this.answerFormat,
    required super.buttonText,
    required this.rules,
    required this.initialSelection,
    required this.specialSelection,
    required this.allTextChoices,
  });

  @override
  Widget createView({required QuestionResult? questionResult}) {
    final key = ObjectKey(stepIdentifier.id);
    return MultipleChoiceImageView(
        key: key,
        questionStep: this,
        result: questionResult as MultipleChoiceQuestionResult?,
        images: images);
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class MultipleChoiceImageView extends StatefulWidget {
  final SpecialMultipleChoiceImageStep questionStep;
  final MultipleChoiceQuestionResult? result;
  final List<CustomisedImage> images;

  const MultipleChoiceImageView({
    super.key,
    required this.questionStep,
    required this.result,
    required this.images,
  });

  @override
  State<MultipleChoiceImageView> createState() => _CustomViewState();
}

class _CustomViewState extends State<MultipleChoiceImageView> {
  late final DateTime _startDate;
  late final MultipleChoiceAnswerFormat _multipleChoiceAnswerFormat;

  bool _showDescription = false;

  List<TextChoice> _selectedChoices = [];

  bool _oneOptionSelected = false;

  @override
  void initState() {
    super.initState();
    _multipleChoiceAnswerFormat =
        widget.questionStep.answerFormat as MultipleChoiceAnswerFormat;
    print('Default selection: ${_multipleChoiceAnswerFormat.defaultSelection}');

    if (widget.result?.result != null && widget.result!.result!.isNotEmpty) {
      _selectedChoices = widget.result!.result!;
    } else if (_multipleChoiceAnswerFormat.defaultSelection.isNotEmpty) {
      print('++++');
      _selectedChoices = _multipleChoiceAnswerFormat.defaultSelection;
      print(
          'Setting default selection: ${_multipleChoiceAnswerFormat.defaultSelection}');
    } else {
      print('----');
      _selectedChoices = widget.questionStep.initialSelection;
    }
    /*  _selectedChoices =
        widget.result?.result ?? _multipleChoiceAnswerFormat.defaultSelection;*/
    for (var choice in _selectedChoices) {
      print('Selected choice at init: ${choice.value}');
    }
    _startDate = DateTime.now();

    _oneOptionSelected = checkIfOneOptionSelected();
  }

  void _toggleDescription() {
    /*  if (_showDescription) {
      saveEventdata(screenId: 'questionnaire_page', buttonId: 'hide_help');
    } else {
      saveEventdata(screenId: 'questionnaire_page', buttonId: 'show_help');
    } */
    setState(() {
      _showDescription = !_showDescription;
    });
  }

  /*void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }*/

  /*@override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }*/

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () {
        /*  saveEventdata(
            screenId: 'questionnaire_page', buttonId: 'next_question');
        */
        return MultipleChoiceQuestionResult(
          id: widget.questionStep.stepIdentifier,
          startDate: _startDate,
          endDate: DateTime.now(),
          valueIdentifier:
              _selectedChoices.map((choices) => choices.value).join(','),
          result: _selectedChoices,
        );
      },
      isValid: _selectedChoices.isNotEmpty && _oneOptionSelected,
      title: widget.questionStep.title.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                widget.questionStep.title,
                style: Theme.of(context).textTheme.titleLarge,
                textAlign: TextAlign.center,
              ),
            )
          : const SizedBox.shrink(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 5.0, left: 20.0, right: 20.0),
            child: StyledText(
              text: widget.questionStep.text,
              tags: {
                'b': StyledTextTag(
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              },
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 10),
          if (widget.questionStep.description.isNotEmpty &&
              widget.questionStep.description != '')
            ElevatedButton(
              onPressed: _toggleDescription,
              style: ElevatedButton.styleFrom(
                backgroundColor: _showDescription
                    ? const Color.fromARGB(255, 223, 225, 228)
                    : const Color.fromARGB(255, 252, 252, 252),
              ),
              child: Text(
                context.tr('help'),
              ),
            ),
          if (_showDescription) showDescription(),
          //const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20.0),
            child: imageWidget(),
          ),
          /* if (widget.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: imageWidget(),
            ), */
          Column(
            children: [
              const Divider(
                color: Colors.grey,
              ),
              ..._multipleChoiceAnswerFormat.textChoices.map(
                (TextChoice tc) {
                  return CustomisedSelectionListTile(
                    text: tc.text,
                    onTap: () {
                      print(widget.questionStep.rules);
                      String? newSelectionValue =
                          widget.questionStep.rules[tc.value];
                      print('Regla para ${tc.value}: $newSelectionValue');
                      TextChoice? newSelection = newSelectionValue != null
                          ? widget
                              .questionStep.allTextChoices[newSelectionValue]
                          : null;

                      print(newSelection != null
                          ? 'Nueva seleccion relacionada: ${newSelection.value}'
                          : 'No hay nueva seleccion relacionada');

                      for (var choice in widget.questionStep.initialSelection) {
                        print(
                            'Initial selection antes de setState: ${choice.value}');
                      }

                      setState(
                        () {
                          for (var choice
                              in widget.questionStep.initialSelection) {
                            print('Initial selection: ${choice.value}');
                          }
                          if (tc.value !=
                              widget.questionStep.specialSelection) {
                            if (_selectedChoices.first.value ==
                                widget.questionStep.specialSelection) {
                              _selectedChoices = [];
                              for (var textChoiceValue
                                  in widget.questionStep.rules.values) {
                                TextChoice? textChoice = widget.questionStep
                                    .allTextChoices[textChoiceValue];
                                print(textChoice != null
                                    ? 'Añadiendo opcion por defecto relacionada: ${textChoice.value}'
                                    : 'No hay opcion por defecto relacionada para el valor: $textChoiceValue');
                                if (textChoice != null) {
                                  _selectedChoices = [
                                    ..._selectedChoices,
                                    textChoice
                                  ];
                                }
                              }
                            }
                            /*   _selectedChoices.removeWhere((element) =>
                                element.value ==
                                widget.questionStep.specialSelection); */

                            if (_selectedChoices.contains(tc)) {
                              _selectedChoices.remove(tc);

                              if (newSelection != null) {
                                _selectedChoices = [
                                  ..._selectedChoices,
                                  newSelection
                                ];
                                print(
                                    'Si se habia seleccionado la opcion que se muestra. Se ha eliminado $tc, se añade $newSelection');
                                for (var choice in _selectedChoices) {
                                  print('Seleccionada: ${choice.value}');
                                }
                              }
                            } else if (!_selectedChoices.contains(tc)) {
                              print('newSelection: ${newSelection!.value}');
                              _selectedChoices.remove(newSelection);
                              _selectedChoices = [..._selectedChoices, tc];
                              //}
                              print(
                                  'Si aun no se habia seleccionado la opcion que se muestra. Se ha eliminado $newSelection, se añade $tc');
                              for (var choice in _selectedChoices) {
                                print('Seleccionada: ${choice.value}');
                              }
                            }

                            _oneOptionSelected = checkIfOneOptionSelected();
                          } else if (tc.value ==
                              widget.questionStep.specialSelection) {
                            if (_selectedChoices.contains(tc)) {
                              _selectedChoices = [];
                              _oneOptionSelected = false;
                            } else {
                              _selectedChoices = [tc];
                              _oneOptionSelected = true;
                            }
                            // If special selection is tapped
                            //  if (_selectedChoices.contains(tc)) {
                            for (var textChoiceValue
                                in widget.questionStep.rules.values) {
                              TextChoice? textChoice = widget
                                  .questionStep.allTextChoices[textChoiceValue];
                              print(textChoice != null
                                  ? 'Añadiendo opcion por defecto relacionada: ${textChoice.value}'
                                  : 'No hay opcion por defecto relacionada para el valor: $textChoiceValue');

                              if (textChoice != null) {
                                _selectedChoices = [
                                  ..._selectedChoices,
                                  textChoice
                                ];
                              }
                            }
                            print(
                                'Si se habia seleccionado la opcion especial: $_selectedChoices. Se ha eliminado todo y se añaden las opciones por defecto');
                            for (var choice in _selectedChoices) {
                              print('Seleccionada: ${choice.value}');
                            }

                            /*} else {
                              // If not selected, clear others and add it
                              _selectedChoices = [tc];
                              print(
                                  'Si no se habia seleccionado la opcion especial: $_selectedChoices. Se ha eliminado todo y se añade la especial $tc');
                              for (var choice in _selectedChoices) {
                                print('Seleccionada: ${choice.value}');
                              }
                            }*/
                          }
                        },
                      );
                      /*  if (_selectedChoice == tc) {
                        _selectedChoice = null;
                      } else {
                        _selectedChoice = tc;
                      }
                      setState(() {});
                      _isEditing = false;*/
                    },
                    isSelected: _selectedChoices.contains(tc),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }

  bool checkIfOneOptionSelected() {
    for (var choice in _selectedChoices) {
      if (choice.value == widget.questionStep.specialSelection) {
        return true;
      }
      if (!widget.questionStep.rules.values.contains(choice.value)) {
        return true;
      }
    }
    return false;
  }

  Widget showDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          StyledText(
            text: widget.questionStep.description,
            style: Theme.of(context).textTheme.bodySmall,
            tags: {
              'b': StyledTextTag(
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            },
          ),
          //if (widget.images.isNotEmpty) imageWidget(),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget imageWidget() {
    if (widget.images.length == 1) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.only(top: 20.0),
          child: SizedBox(
            child: Column(
              children: [
                InstaImageViewer(
                  child: Image.asset(
                    widget.images[0].path,
                    height: 200,
                    //fit: BoxFit.fitHeight,
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 200,
                  child: Text(widget.images[0].description,
                      style: Theme.of(context).textTheme.bodySmall,
                      textAlign: TextAlign.center),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Expanded(
                child: InstaImageViewer(
                  child: Image.asset(
                    widget.images[index].path,
                    fit: BoxFit.fitWidth,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 200,
                child: Text(widget.images[index].description,
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center),
              ),
            ],
          );
        },
      ),
    );
  }
}
