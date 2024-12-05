import 'dart:convert';

import 'package:flutter/services.dart';

class SelectedOptions {
  static final SelectedOptions _options = SelectedOptions._internal();
  late Map<String, String?> selectedOptions;

  factory SelectedOptions() {
    return _options;
  }

  SelectedOptions._internal();
}

class FaultTree {
  static final FaultTree _instance = FaultTree._internal();

  late Node topEvent;

  FaultTree._internal();

  factory FaultTree() {
    return _instance;
  }

  Future<void> loadFaultTree(String path) async {
    String jsonString = await rootBundle.loadString('assets/fault_tree_1.json');
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    print('load-fault-tree');
    topEvent = parseTree(jsonMap['fault_tree'][0]);
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
        throw Exception(
            'Does not exist this type of gate: ${faultTree['type']}');
      }
    }
  }

  Node? getNode(String eventId) {
    return findNode(topEvent, eventId);
  }

  Node? findNode(Node node, String eventId) {
    if (node.id == eventId && node is IntermediateEvent) {
      return node;
    }

    if (node is Gate) {
      for (var inputEvent in node.inputEvents) {
        Node? result = findNode(inputEvent, eventId);
        if (result != null) {
          return result;
        }
      }
    }

    if (node is IntermediateEvent) {
      Node? result = findNode(node.gate, eventId);
      if (result != null) {
        return result;
      }
    }
    return null;
  }

  void traverseTree(Node node, int level) {
    String indent = ' ' * level * 2;
    if (node is BasicEvent) {
      print('${indent}Basic Event: ${node.id}, ${node.probability}');
    } else if (node is IntermediateEvent) {
      print('${indent}Intermediate Event: ${node.id}, ${node.probability}');
      traverseTree(node.gate, level + 1);
    } else if (node is Gate) {
      print('${indent}Gate: ${node.gateType}, ${node.id}');
      for (var inputEvent in node.inputEvents) {
        traverseTree(inputEvent, level + 1);
      }
    }
  }

  Map<String, double> getProbabilities(Node node) {
    Map<String, double> probabilities = {};
    if (node is IntermediateEvent) {
      for (int i = 0; i < node.gate.inputEvents.length; ++i) {
        Node event = node.gate.inputEvents[i];
        if (event is IntermediateEvent) {
          probabilities[event.id] = event.probability;
        }
      }
    }
    return probabilities;
  }

  Map<String, double> getBasicEvents(Node node, String id) {
    Map<String, double> basicEvents = {};
    if (node is IntermediateEvent && node.id == id) {
      for (int i = 0; i < node.gate.inputEvents.length; ++i) {
        Node event = node.gate.inputEvents[i];
        if (event is BasicEvent) {
          basicEvents[event.id] = event.probability;
        }
      }
    } else {
      if (node is Gate) {
        for (var inputEvent in node.inputEvents) {
          basicEvents = getBasicEvents(inputEvent, id);
          if (basicEvents.isNotEmpty) {
            break;
          }
        }
      } else if (node is IntermediateEvent) {
        basicEvents = getBasicEvents(node.gate, id);
      }
    }
    return basicEvents;
  }

  IntermediateEvent? findIntermediateEvent(Node node, String eventId) {
    if (node is IntermediateEvent && node.id == eventId) {
      return node;
    }

    if (node is Gate) {
      for (var inputEvent in node.inputEvents) {
        var foundEvent = findIntermediateEvent(inputEvent, eventId);
        if (foundEvent != null) {
          return foundEvent;
        }
      }
    }

    // Si el nodo es un IntermediateEvent, revisa su gate asociado
    if (node is IntermediateEvent) {
      var foundEvent = findIntermediateEvent(node.gate, eventId);
      if (foundEvent != null) {
        return foundEvent;
      }
    }

    // Devuelve null si no se encuentra el nodo
    return null;
  }

  Map<String, double> getSubNodeProbabilities(String eventId) {
    IntermediateEvent? event = findIntermediateEvent(topEvent, eventId);
    if (event != null) {
      return getProbabilities(event);
    } else {
      return {};
    }
  }

  void printTree() {
    traverseTree(topEvent, 0);
  }

  void setSelectedOptions(Map<String, String?> selectedOptions) {
    SelectedOptions().selectedOptions = selectedOptions;
  }

  double calculateProbability(Node node) {
    return node.calculateProbability();
  }
}

abstract class Node {
  String id;
  Node(this.id);

  double calculateProbability();
}

class BasicEvent extends Node {
  double probability;
  BasicEvent(super.id, this.probability);

  @override
  double calculateProbability() {
    return probability;
  }
}

class IntermediateEvent extends Node {
  double probability = 0.0;
  Gate gate;

  IntermediateEvent(super.id, this.gate);

  @override
  double calculateProbability() {
    probability = gate.calculateProbability();
    return probability;
  }
}

class Gate extends Node {
  List<Node> inputEvents;
  String gateType = 'gate';
  Gate(super.id, this.inputEvents);

  @override
  double calculateProbability() {
    return 0.0;
  }
}

class AndGate extends Gate {
  AndGate(super.id, super.inputEvents) {
    super.gateType = 'and_gate';
  }

  @override
  double calculateProbability() {
    double probability = 1.0;
    for (var event in inputEvents) {
      probability *= event.calculateProbability();
    }
    print("$id: $probability");
    return probability;
  }
}

class XorGate extends Gate {
  XorGate(super.id, super.inputEvents) {
    super.gateType = 'xor_gate';
  }

  @override
  double calculateProbability() {
    Map<String, String?> selectedOptions = SelectedOptions().selectedOptions;
    double probability = 0.0;
    for (var event in inputEvents) {
      if (selectedOptions.containsValue(event.id)) {
        probability = event.calculateProbability();
        break;
      }
    }
    print("$id: $probability");
    return probability;
  }
}

class OrGate extends Gate {
  List<Node> selectedInputs = [];

  OrGate(super.id, super.inputEvents) {
    super.gateType = 'or_gate';
  }

  @override
  double calculateProbability() {
    selectedInputs = [];
    if (inputEvents[0] is BasicEvent) {
      Map<String, String?> selectedOptions = SelectedOptions().selectedOptions;
      for (var event in inputEvents) {
        if (selectedOptions.containsValue(event.id)) {
          selectedInputs.add(event);
        }
      }
    } else {
      selectedInputs = inputEvents;
    }
    double probability = 1.0;
    for (var event in selectedInputs) {
      probability *= (1 - event.calculateProbability());
    }
    print("$id: ${1 - probability}");
    return probability = 1 - probability;
  }
}
