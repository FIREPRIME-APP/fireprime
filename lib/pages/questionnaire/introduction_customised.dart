import 'package:flutter/material.dart' hide Step;
import 'package:survey_kit/survey_kit.dart';

class IntroductionResult extends QuestionResult<String> {
  IntroductionResult(Identifier id, DateTime startDate, DateTime endDate)
      : super(
          id: id,
          startDate: startDate,
          endDate: endDate,
          valueIdentifier: 'introduction',
          result: 'introdution',
        );

  @override
  List<Object?> get props => [id, startDate, endDate, valueIdentifier];
}

class IntroductionCustomisedStep extends Step {
  final String title;
  final String text;

  IntroductionCustomisedStep({
    required super.stepIdentifier,
    super.isOptional = true,
    required this.title,
    required this.text,
  });

  @override
  Widget createView({required QuestionResult? questionResult}) {
    final key = ObjectKey(stepIdentifier.id);
    return IntroductionCustomisedView(
      key: key,
      introductionStep: this,
      result: questionResult as IntroductionResult?,
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // TODO: implement toJson
    throw UnimplementedError();
  }
}

class IntroductionCustomisedView extends StatefulWidget {
  final IntroductionCustomisedStep introductionStep;
  final IntroductionResult? result;
  final DateTime _startDate = DateTime.now();

  IntroductionCustomisedView(
      {super.key, required this.introductionStep, required this.result});

  @override
  State<IntroductionCustomisedView> createState() =>
      _IntroductionCustomisedViewState();
}

class _IntroductionCustomisedViewState
    extends State<IntroductionCustomisedView> {
  @override
  Widget build(BuildContext context) {
    return StepView(
      step: widget.introductionStep,
      title: Text(
        widget.introductionStep.title,
        style: Theme.of(context).textTheme.displayMedium,
        textAlign: TextAlign.center,
      ),
      resultFunction: () => IntroductionResult(
        widget.introductionStep.stepIdentifier,
        widget._startDate,
        DateTime.now(),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14.0),
        child: Text(
          widget.introductionStep.text,
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
