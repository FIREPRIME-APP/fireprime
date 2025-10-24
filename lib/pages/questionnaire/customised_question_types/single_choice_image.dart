import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/model/customised_image.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:fireprime/widgets/selection_list_tile.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:insta_image_viewer/insta_image_viewer.dart';
import 'package:survey_kit/survey_kit.dart';

class SingleChoiceImageStep extends Step {
  final String title;
  final String text;
  final String description;
  final List<CustomisedImage> images;
  final AnswerFormat answerFormat;
  final bool otherOption;
  bool alwaysShowDescription = false;

  SingleChoiceImageStep(
      {required super.stepIdentifier,
      super.isOptional = false,
      required this.title,
      required this.text,
      required this.description,
      required this.otherOption,
      required this.images,
      required this.answerFormat,
      required super.buttonText
      //required this.alwaysShowDescription,
      });

  @override
  Widget createView({required QuestionResult? questionResult}) {
    final key = ObjectKey(stepIdentifier.id);
    return SingleChoiceImageView(
        key: key,
        questionStep: this,
        result: questionResult as SingleChoiceQuestionResult?,
        images: images);
  }

  @override
  Map<String, dynamic> toJson() {
    throw UnimplementedError();
  }
}

class SingleChoiceImageView extends StatefulWidget {
  final SingleChoiceImageStep questionStep;
  final SingleChoiceQuestionResult? result;
  final List<CustomisedImage> images;

  const SingleChoiceImageView({
    super.key,
    required this.questionStep,
    required this.result,
    required this.images,
  });

  @override
  State<SingleChoiceImageView> createState() => _CustomViewState();
}

class _CustomViewState extends State<SingleChoiceImageView> {
  late final DateTime _startDate;
  late final SingleChoiceAnswerFormat _singleChoiceAnswerFormat;
  TextChoice? _selectedChoice;
  bool _showDescription = false;
  //bool _isEditing = false;

  late final TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _singleChoiceAnswerFormat =
        widget.questionStep.answerFormat as SingleChoiceAnswerFormat;
    _selectedChoice =
        widget.result?.result ?? _singleChoiceAnswerFormat.defaultSelection;
    _startDate = DateTime.now();
    _controller = TextEditingController();
  }

  void _toggleDescription() {
    if (_showDescription) {
      saveEventdata(screenId: 'questionnaire_page', buttonId: 'hide_help');
    } else {
      saveEventdata(screenId: 'questionnaire_page', buttonId: 'show_help');
    }
    setState(() {
      _showDescription = !_showDescription;
    });
  }

  /* void _toggleEditing() {
    setState(() {
      _isEditing = !_isEditing;
    });
  }*/

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.questionStep,
      resultFunction: () {
        saveEventdata(
            screenId: 'questionnaire_page', buttonId: 'next_question');
        return SingleChoiceQuestionResult(
          id: widget.questionStep.stepIdentifier,
          startDate: _startDate,
          endDate: DateTime.now(),
          valueIdentifier: _selectedChoice?.value ?? '',
          result: _selectedChoice,
        );
      },
      isValid: widget.questionStep.isOptional || _selectedChoice != null,
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
        children: [
          Padding(
            padding:
                const EdgeInsets.only(bottom: 5.0, left: 20.0, right: 20.0),
            child: Text(
              widget.questionStep.text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
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
          /* (!widget.questionStep.alwaysShowDescription)
              ? ElevatedButton(
                  onPressed: _toggleDescription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _showDescription
                        ? const Color.fromARGB(255, 223, 225, 228)
                        : const Color.fromARGB(255, 252, 252, 252),
                  ),
                  child: Text(
                    _showDescription
                        ? context.tr('hide_description')
                        : context.tr('show_description'),
                    style: TextStyle(color: Theme.of(context).primaryColor),
                  ),
                )
              : const SizedBox.shrink(),*/
          if (_showDescription /*|| widget.questionStep.alwaysShowDescription*/)
            showDescription(),
          //  const SizedBox(height: 10),
          if (widget.images.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: imageWidget(),
            ),
          Column(
            children: [
              const Divider(
                color: Colors.grey,
              ),
              ..._singleChoiceAnswerFormat.textChoices.map(
                (TextChoice tc) {
                  return CustomisedSelectionListTile(
                    text: tc.text,
                    onTap: () {
                      print("Tapped on: ${tc.text}");
                      if (_selectedChoice == tc) {
                        _selectedChoice = null;
                      } else {
                        _selectedChoice = tc;
                      }
                      setState(() {});
                      //_isEditing = false;
                    },
                    isSelected: _selectedChoice == tc,
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
    // }//);
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
          //if (widget.images.isNotEmpty) imageWidget(),
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
        separatorBuilder: (context, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          // return FutureBuilder<bool>(
          //   future: _checkImageExists(widget.images[index].path),
          //      builder: (context, snapshot) {
          /*if (snapshot.connectionState != ConnectionState.done) {
                return const SizedBox(
                  width: 250,
                  height: 200,
                  child: Center(child: CircularProgressIndicator()),
                );
              }*/
//
          //            if (!snapshot.data!) {
          //            return Container();
          //        }

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
        //   );
        //},
      ),
    );
  }

  /* Future<bool> _checkImageExists(String path) async {
    try {
      await rootBundle.load(path);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<List<CustomisedImage>> getValidImages() async {
    final List<CustomisedImage> validImages = [];
    for (final image in widget.images) {
      if (await _checkImageExists(image.path)) {
        validImages.add(image);
      }
    }
    return validImages;
  }*/
}
