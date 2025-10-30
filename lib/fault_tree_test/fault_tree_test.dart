import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/fault_tree/node.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/widgets.dart';

void main() {
  setUpAll(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await FaultTree().loadFaultTree('assets/fault_tree_1.json');
  });

  /* Map<String, double> q9 = {
    "glazingSystemsSinglePane": 0.825,
    "glazingSystemsMultiplePane": 0.257,
    "glazingSystemsTempered": 0.09,
    "noGlazingSystems": 0.0,
  };
  Map<String, double> q10 = {
    "combustibleEnvelope": 0.75,
    "nonCombThin": 0.4,
    "nonCombThick": 0.183,
  };

  Map<String, double> q24 = {
    "concreteLess2": 0.08,
    "noDelimitation": 0.5,
    "metalPosts": 0.1,
    "chainLink": 0.1,
    "concreteMore2": 0.05,
    "hedgerowHigh": 0.8,
    "hedgerowLow": 0.05,
    "woodenFence": 0.1
  };

  group('Or gate Test', () {
    for (var keyQ9 in q9.keys) {
      for (var keyQ10 in q10.keys) {
        test('Or gate test with $keyQ9 and $keyQ10', () {
          var results = {
            "Q9": keyQ9,
            "Q10": keyQ10,
          };

          FaultTree().setSelectedOptions(results);
          Node? node = FaultTree().getNode('semi_confined');

          double expectedResult = 1 - (1 - q9[keyQ9]!) * (1 - q10[keyQ10]!);
          print('Expected: $expectedResult');
          expect(node?.calculateProbability(), expectedResult);
        });
      }
    }

    test('Or gate test with Q24_1', () {
      var results = {
        "Q24": "concreteLess2,metalPosts,hedgerowLow",
      };

      FaultTree().setSelectedOptions(results);
      Node? node = FaultTree().getNode('property_perimeter');

      double expectedResult = 1 -
          (1 - q24['concreteLess2']!) *
              (1 - q24['metalPosts']!) *
              (1 - q24['hedgerowLow']!);

      print('Expected: $expectedResult');
      expect(node?.calculateProbability().toStringAsFixed(3),
          expectedResult.toStringAsFixed(3));
    });

    test('Or gate test with Q24_2', () {
      var results = {
        "Q24": "noDelimitation,hedgerowLow",
      };

      FaultTree().setSelectedOptions(results);
      Node? node = FaultTree().getNode('property_perimeter');

      double expectedResult =
          1 - (1 - q24['noDelimitation']!) * (1 - q24['hedgerowLow']!);

      expect(node?.calculateProbability().toStringAsFixed(3),
          expectedResult.toStringAsFixed(3));
    });
    test('Or gate test with Q24_3', () {
      var results = {
        "Q24": "concreteMore2",
      };

      FaultTree().setSelectedOptions(results);
      Node? node = FaultTree().getNode('property_perimeter');

      double expectedResult = 1 - (1 - q24['concreteMore2']!);

      expect(node?.calculateProbability().toStringAsFixed(3),
          expectedResult.toStringAsFixed(3));
    });

    test('Or gate test with calculated gates_1', () {
      var results = {
        "Q1": "100comb",
        "Q2": "height41to60",
        "Q3": "roofFireRated",
        "Q4": "roofPoorlyMaintaned-1",
        "Q5": "doublePane",
        "Q6": "noShutters",
        "Q7": "ventCombProtection",
        "Q8": "yesSemiConf",
        "Q9": "glazingSystemsSinglePane",
        "Q10": "nonCombThick",
      };

      FaultTree().setSelectedOptions(results);
      Node? node = FaultTree().getNode('structural_vulnerabilities');

      double expectedResult = 0.985;

      expect(node?.calculateProbability().toStringAsFixed(3),
          expectedResult.toStringAsFixed(3));
    });
    test('Or gate test with calculated gates_2', () {
      var results = {
        "Q11": "7closeToGlazing",
        "Q12": "closeToRoof",
        "Q13": "fuelsNotAgainstFacade",
        "Q14": "contSurf",
        "Q15": "farFromLPG",
        "Q16": "spacingMore5",
        "Q17": "placedIn20",
        "Q19": "noVegIn30",
        "Q20": "lowFlam",
        "Q21": "discontVeg",
        "Q22": "lowSurfaceLess10",
        "Q23": "noDeadVeg",
        "Q18": "pruning",
        "Q24": "hedgerowLow",
      };

      FaultTree().setSelectedOptions(results);
      Node? node = FaultTree().getNode('fire_reaches_building');

      double expectedResult = 0.999;

      expect(node?.calculateProbability().toStringAsFixed(3),
          expectedResult.toStringAsFixed(3));
    });
  });*/

  group('Fault Tree Test', () {
    test('Fault Tree Test WORST CASE', () {
      var results = {
        "Q1": "100comb",
        "Q2": "height0",
        "Q3": "roofNonFireRated",
        "Q4": "roofPoorlyMaintaned-1",
        "Q5": "singlePane",
        "Q6": "noShutters",
        "Q7": "noVentProtection",
        "Q8": "yesSemiConf",
        "Q9": "glazingSystemsSinglePane",
        "Q10": "combustibleEnvelope",
        "Q11": "7closeToGlazing,closeToRoof",
        "Q12": "fuelsNotAgainstFacade",
        "Q13": "contSurf",
        "Q14": "closeToLPG",
        "Q15": "spacingLess5,placedIn20",
        "Q16": "VegIn30",
        "Q17": "highFlam",
        "Q18": "contVeg",
        "Q19": "lowSurfaceMore10",
        "Q20": "deadVeg",
        "Q21": "noPruning",
        "Q22": "hedgerowHigh",
        "Q23": "upperSlope",
      };

      FaultTree().setSelectedOptions(results);

      double expectedResult = 0.993;

      expect(
          FaultTree()
              .calculateProbability(FaultTree().topEvent)
              .toStringAsFixed(3),
          expectedResult.toStringAsFixed(3));
    });

    test('Fault Tree Test BEST CASE', () {
      var results = {
        "Q1": "0comb",
        "Q3": "roofFireRated",
        "Q4": "roofWellMaintained-2",
        "Q5": "tempered",
        "Q6": "fireRatedShutters",
        "Q7": "nonCombGoodCond",
        "Q8": "yesSemiConf",
        "Q9": "noGlazingSystems",
        "Q10": "nonCombThick",
        "Q11": "7farFromGlazing,farFromRoof",
        "Q12": "fuelsAgainstFacade",
        "Q13": "discontSurf",
        "Q14": "noLPG",
        "Q15": "spacingMore5,placedFurther20",
        "Q16": "noVegIn30",
        "Q17": "lowFlam",
        "Q18": "discontVeg",
        "Q19": "lowSurfaceLess10",
        "Q20": "noDeadVeg",
        "Q21": "pruning",
        "Q22": "concreteMore2",
        "Q23": "flatTerrain",
      };

      FaultTree().setSelectedOptions(results);

      double expectedResult = 0.104;

      expect(
          FaultTree()
              .calculateProbability(FaultTree().topEvent)
              .toStringAsFixed(3),
          expectedResult.toStringAsFixed(3));
    });
  });
}
