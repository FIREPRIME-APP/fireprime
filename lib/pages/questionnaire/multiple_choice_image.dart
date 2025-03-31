import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/customised_image.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:survey_kit/survey_kit.dart';

class MultipleChoiceImageStep extends Step {
  final String title;
  final String text;
  final String description;
  final List<CustomisedImage> images;
  final AnswerFormat answerFormat;
  final bool otherOption;

  MultipleChoiceImageStep({
    required super.stepIdentifier,
    super.isOptional = false,
    required this.title,
    required this.text,
    required this.description,
    required this.otherOption,
    required this.images,
    required this.answerFormat,
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
  final MultipleChoiceImageStep questionStep;
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
//  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _multipleChoiceAnswerFormat =
        widget.questionStep.answerFormat as MultipleChoiceAnswerFormat;
    _selectedChoices =
        widget.result?.result ?? _multipleChoiceAnswerFormat.defaultSelection;
    _startDate = DateTime.now();
    // _controller = TextEditingController();
  }

  void _toggleDescription() {
    if (_showDescription) {
      saveEventdata(screenId: 'questionnaire_page', buttonId: 'hide_desc');
    } else {
      saveEventdata(screenId: 'questionnaire_page', buttonId: 'show_desc');
    }
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
        saveEventdata(
            screenId: 'questionnaire_page', buttonId: 'next_question');
        return MultipleChoiceQuestionResult(
          id: widget.questionStep.stepIdentifier,
          startDate: _startDate,
          endDate: DateTime.now(),
          valueIdentifier:
              _selectedChoices.map((choices) => choices.value).join(','),
          result: _selectedChoices,
        );
      },
      isValid: widget.questionStep.isOptional || _selectedChoices.isNotEmpty,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 5.0, left: 20.0, right: 20.0),
            child: Text(
              widget.questionStep.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 20.0),
            child: const Text('max_multiple_choices',
                    // '${context.tr('max_multiple_choices', _multipleChoiceAnswerFormat.maxAnswers)}',
                    style: TextStyle(fontSize: 13),
                    textAlign: TextAlign.justify)
                .tr(args: [_multipleChoiceAnswerFormat.maxAnswers.toString()]),
          ),
          Center(
            child: TextButton(
              onPressed: _toggleDescription,
              child: Text(
                _showDescription
                    ? context.tr('hide_descdescription')
                    : context.tr('show_description'),
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ),
          if (_showDescription) showDescription(),
          Column(
            children: [
              const Divider(
                color: Colors.grey,
              ),
              ..._multipleChoiceAnswerFormat.textChoices.map(
                (TextChoice tc) {
                  return SelectionListTile(
                    text: tc.text,
                    onTap: () {
                      setState(() {
                        if (_selectedChoices.contains(tc)) {
                          _selectedChoices.remove(tc);
                        } else {
                          if (_multipleChoiceAnswerFormat.maxAnswers >
                              _selectedChoices.length) {
                            _selectedChoices = [..._selectedChoices, tc];
                          }
                        }
                      });
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
              /* if (widget.questionStep.otherOption)
                Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14.0),
                      child: ListTile(
                        title: _isEditing
                            ? TextField(
                                enabled: _isEditing,
                                style:
                                    Theme.of(context).textTheme.headlineSmall,
                                decoration: InputDecoration(
                                    hintText: context.tr('other')),
                                onSubmitted: (editedText) {
                                  setState(() {
                                    _selectedChoice = TextChoice(
                                        text: editedText, value: editedText);
                                    _editableText = editedText;
                                    _isEditing = false;
                                  });
                                  print(editedText);
                                },
                                controller:
                                    TextEditingController(text: _editableText),
                              )
                            : Text(
                                _editableText.isEmpty
                                    ? context.tr('other')
                                    : _editableText,
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineSmall
                                    ?.copyWith(
                                      color:
                                          _selectedChoice?.text == _editableText
                                              ? Theme.of(context).primaryColor
                                              : Theme.of(context)
                                                  .textTheme
                                                  .headlineSmall
                                                  ?.color,
                                    ),
                              ),
                        onTap: () {
                          _toggleEditing();
                          if (_selectedChoice == null ||
                              _selectedChoice?.text != _editableText) {
                            setState(() {
                              _selectedChoice = TextChoice(
                                  text: _editableText, value: _editableText);
                            });
                          }
                        },
                        trailing: _selectedChoice?.text == _editableText
                            ? Icon(Icons.check,
                                size: 32, color: Theme.of(context).primaryColor)
                            : const SizedBox(
                                width: 32,
                                height: 32,
                              ),
                      ),
                    ),
                    const Divider(
                      color: Colors.grey,
                    )
                  ],
                ),*/
            ],
          )
        ],
      ),
    );
  }

  Widget showDescription() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Column(
        children: [
          Text(
            widget.questionStep.description,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          if (widget.images.isNotEmpty) imageWidget(),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  Widget imageWidget() {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 20.0),
        scrollDirection: Axis.horizontal,
        itemCount: widget.images.length,
        separatorBuilder: (context, _) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return Column(
            children: [
              Expanded(
                child: Image.asset(
                  widget.images[index].path,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(height: 4),
              Text(widget.images[index].description,
                  style: Theme.of(context).textTheme.bodySmall),
            ],
          );
        },
      ),
    );
  }
}
