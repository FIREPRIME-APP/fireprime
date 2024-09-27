import 'package:fireprime/utils.dart';
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
        trackStyle: TrackStyle(
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
      double probability, String description, double space) {
    return Padding(
      padding: const EdgeInsets.only(top: 120),
      child: Center(
        child: Column(
          children: [
            Text(
              probability.toStringAsFixed(2),
              style: const TextStyle(fontSize: 15),
            ),
            SizedBox(height: space),
            Text(
              description,
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  static Widget linearGaugeProb(String title, double probability,
      double pointerSize, double thickness, double borderRadius) {
    return Column(
      children: [
        Text('$title: ${probability.toStringAsFixed(0)} %',
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
        const SizedBox(height: 10),
        LinearGauge(
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
        ),
      ],
    );
  }
}
