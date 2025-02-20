import 'package:fireprime/widgets/info_dialog.dart';
import 'package:fireprime/widgets/utils.dart';
import 'package:flutter/material.dart';
import 'package:geekyants_flutter_gauges/geekyants_flutter_gauges.dart';

class Gauge {
  static RadialGauge radialGauge(
      double probability, double thickness, double pointerWidth) {
    return RadialGauge(
      track: RadialTrack(
        start: 0,
        end: 100,
        thickness: thickness,
        trackStyle: const TrackStyle(
          labelStyle: TextStyle(color: Colors.black),
          showLabel: false,
          showPrimaryRulers: false,
          showSecondaryRulers: false,
        ),
        hideTrack: false,
      ),
      valueBar: [
        RadialValueBar(
          value: 100,
          valueBarThickness: thickness,
          gradient: const LinearGradient(
            colors: [Colors.green, Colors.yellow, Colors.orange, Colors.red],
          ),
        ),
      ],
      needlePointer: [
        NeedlePointer(
          value: probability,
          tailColor: const Color.fromARGB(255, 75, 75, 75),
          needleHeight: 100,
          needleWidth: pointerWidth,
          tailRadius: thickness,
          needleStyle: NeedleStyle.flatNeedle,
          color: const Color.fromARGB(255, 75, 75, 75),
        )
      ],
    );
  }

  static Widget gaugeProbabilityText(
      double probability, String description, double space, String info) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Column(
          children: [
            Text(
              probability.toStringAsFixed(0),
              style: const TextStyle(fontSize: 15),
            ),
            SizedBox(height: space),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  description,
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 5),
                InfoDialog(
                  icon: Icons.info_outline,
                  iconSize: 20.0,
                  text: info,
                  fontSize: 12,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget linearGaugeWithTitle(
      String title,
      double probability,
      double pointerSize,
      double thickness,
      double borderRadius,
      double? lastProbability) {
    // print('lastProbability: $lastProbability');

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  '$title: ${probability.toStringAsFixed(0)}',
                  style: const TextStyle(
                      fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              lastProbability != null
                  ? comparisonIcon(probability, lastProbability)
                  : const SizedBox(width: 0),
            ],
          ),
        ),
        linearGauge(
            probability, pointerSize, thickness, borderRadius, lastProbability),
        const SizedBox(height: 10),
      ],
    );
  }

  static Icon comparisonIcon(double probability, double lastProbability) {
    if (probability > lastProbability) {
      return const Icon(Icons.arrow_upward, color: Colors.red, size: 25);
    } else if (probability < lastProbability) {
      return const Icon(
        Icons.arrow_downward,
        color: Colors.green,
        size: 25,
      );
    } else {
      return const Icon(
        Icons.remove,
        color: Color.fromARGB(255, 86, 97, 123),
        size: 25,
      );
    }
  }

  static Widget linearGauge(double probability, double pointerSize,
      double thickness, double borderRadius, double? lastProbability) {
    return LinearGauge(
      gaugeOrientation: GaugeOrientation.horizontal,
      rulers: RulerStyle(
        rulerPosition: RulerPosition.bottom,
        showPrimaryRulers: false,
        showSecondaryRulers: false,
      ),
      pointers: [
        Pointer(
          height: pointerSize,
          width: pointerSize,
          isInteractive: false,
          value: probability,
          color: Utils.pointerColor(probability),
          shape: PointerShape.circle,
          pointerPosition: PointerPosition.center,
          animationType: Easing.legacyDecelerate,
        )
      ],
      customLabels: const [
        CustomRulerLabel(text: '0', value: 0),
        CustomRulerLabel(text: '25', value: 25),
        CustomRulerLabel(text: '50', value: 50),
        CustomRulerLabel(text: '75', value: 75),
        CustomRulerLabel(text: '100', value: 100),
      ],
      valueBar: [
        ValueBar(
          linearGradient: Utils.linearGradientProb(probability),
          value: probability,
          valueBarThickness: thickness,
          borderRadius: borderRadius,
          edgeStyle: LinearEdgeStyle.bothCurve,
          enableAnimation: true,
          animationType: Easing.legacyDecelerate,
        ),
      ],
      linearGaugeBoxDecoration: LinearGaugeBoxDecoration(
          thickness: thickness,
          borderRadius: borderRadius,
          backgroundColor: const Color.fromARGB(255, 232, 235, 244),
          edgeStyle: LinearEdgeStyle.bothCurve),
    );
  }
}
