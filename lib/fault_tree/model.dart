//import 'dart:convert';

import 'package:fireprime/fault_tree/ifault_tree.dart';
import 'package:flutter/material.dart';
//import 'package:flutter/services.dart';

/*Future<FaultTree> buildFaultTree() async {
  String taskJson = await rootBundle.loadString('assets/fault_tree_1.json');

  final Map<String, dynamic> faultTree = json.decode(taskJson);

  Node root = parseTree(faultTree['fault_tree'][0]);
  return FaultTree();
}

Node parseTree(Map<String, dynamic> faultTree) {
  if (faultTree['type'] == 'event') {
    if (faultTree.containsKey('gate')) {
      Gate gate = parseTree(faultTree['gate'][0]) as Gate;
      return IntermediateEvent(faultTree['event_id'], gate);
    } else {
      return BasicEvent(faultTree['event_id'], faultTree['probability']);
    }
  } else {
    List<Node> inputEvents = [];
    if (faultTree.containsKey('input_events')) {
      inputEvents = (faultTree['input_events'] as List)
          .map((event) => parseTree(event))
          .toList();
    }
    if (faultTree['type'] == 'xor_gate') {
      return XorGate(faultTree['gate_id'], inputEvents);
    } else if (faultTree['type'] == 'and_gate') {
      return AndGate(faultTree['gate_id'], inputEvents);
    } else if (faultTree['type'] == 'or_gate') {
      return OrGate(faultTree['gate_id'], inputEvents);
    } else {
      throw Exception('Does not exist this type of gate: ${faultTree['type']}');
    }
  }
}*/

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  FaultTree faultTree = FaultTree();

  await faultTree.loadFaultTree('assets/fault_tree_1.json');

  Map<String, String?> selectedOptions = {
    "combustibleFacade": "concreteBricks",
    "glazingFailure": "doublePane",
    "shutterFailure": "notAllProtected",
    "roofMaterial": "roofFireRated",
    "roofMaintenance": "roofPoorlyMaintaned",
    "vents": "combustibleProtection",
    "semiConfined": "nonCombThick",
  };

  faultTree.setSelectedOptions(selectedOptions);
  double probability = faultTree.calculateProbability(faultTree.topEvent);
  Map<String, double> probabilities =
      faultTree.getProbabilities(faultTree.topEvent);
  print("PROBABILITIES: $probabilities");
  print("PROBABILITY: $probability");
}
