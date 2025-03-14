import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/fault_tree/node.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FaultTree().loadFaultTree('assets/fault_tree_1.json');
  });

  group(
    'DependsOn Test',
    () {
      test(
        'DependsOn Test with SinglePane',
        () {
          var results = {
            "Q5": "singlePane",
            "Q9": "glazingSystems",
          };

          FaultTree().setSelectedOptions(results);
          Node? node = FaultTree().getNode('semi_confined');

          expect(node?.calculateProbability(), 0.825);
        },
      );
      test(
        'DependsOn Test with doublePane',
        () {
          var results = {
            "Q5": "doublePane",
            "Q9": "glazingSystems",
          };

          FaultTree().setSelectedOptions(results);
          Node? node = FaultTree().getNode('semi_confined');

          expect(node?.calculateProbability(), 0.257);
        },
      );
      test(
        'DependsOn Test with tempered',
        () {
          var results = {
            "Q5": "tempered",
            "Q9": "glazingSystems",
          };

          FaultTree().setSelectedOptions(results);
          Node? node = FaultTree().getNode('semi_confined');
          double? probability = node?.calculateProbability();
          expect(double.parse(probability!.toStringAsFixed(2)), 0.09);
        },
      );
      test(
        'DependsOn Test with noGlazingSystem',
        () {
          var results = {
            "Q5": "tempered",
            "Q9": "noGlazingSystems",
          };

          FaultTree().setSelectedOptions(results);
          Node? node = FaultTree().getNode('semi_confined');

          expect(node?.calculateProbability(), 0.0);
        },
      );
      test(
        'DependsOn Test with SinglePane and CombustibleEnvelope',
        () {
          var results = {
            "Q5": "singlePane",
            "Q9": "glazingSystems",
            "Q10": "combustibleEnvelope",
          };

          FaultTree().setSelectedOptions(results);
          Node? node = FaultTree().getNode('semi_confined');
          expect(node?.calculateProbability(), 0.95625);
        },
      );
      test(
        'DependsOn Test with noGlazingSystem and combustibleEnvelope',
        () {
          var results = {
            "Q5": "singlePane",
            "Q9": "noGlazingSystems",
            "Q10": "combustibleEnvelope",
          };

          FaultTree().setSelectedOptions(results);
          Node? node = FaultTree().getNode('semi_confined');
          expect(node?.calculateProbability(), 0.75);
        },
      );
      test(
        'Other or test',
        () {
          var results = {
            "Q5": "singlePane",
            "Q9": "glazingSystems",
            "Q10": "combustibleEnvelope",
            "Q24": "Hedgerow,woodenFence"
          };

          FaultTree().setSelectedOptions(results);
          Node? node = FaultTree().getNode('property_perimeter');
          expect(node?.calculateProbability(), 0.9456);
        },
      );
    },
  );
}
