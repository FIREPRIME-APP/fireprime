import 'dart:convert';

import 'package:fireprime/fault_tree/gates/and_gate.dart';
import 'package:fireprime/fault_tree/events/basic_event.dart';
import 'package:fireprime/fault_tree/gates/gate.dart';
import 'package:fireprime/fault_tree/events/intermediate_event.dart';
import 'package:fireprime/fault_tree/node.dart';
import 'package:fireprime/fault_tree/gates/or_gate.dart';
import 'package:fireprime/fault_tree/gates/xor_gate.dart';
import 'package:fireprime/fault_tree/selectedOptions.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

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
    topEvent = _parseTree(jsonMap['fault_tree'][0]);
  }

  Node _parseTree(Map<String, dynamic> faultTree) {
    if (faultTree['type'] == 'event') {
      if (faultTree.containsKey('gate')) {
        Gate gate = _parseTree(faultTree['gate'][0]) as Gate;
        return IntermediateEvent(faultTree['event_id'], gate);
      } else {
        BasicEvent(faultTree['event_id'], faultTree['probability']);
        if (faultTree['depends_on'] != null) {
          return BasicEvent(faultTree['event_id'], faultTree['probability'])
            ..dependsOn = faultTree['depends_on'];
        } else {
          return BasicEvent(faultTree['event_id'], faultTree['probability']);
        }
      }
    } else {
      List<Node> inputEvents = [];
      if (faultTree.containsKey('input_events')) {
        inputEvents = (faultTree['input_events'] as List)
            .map((event) => _parseTree(event))
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

  /*void traverseTree(Node node, int level) {
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
  }*/

  /*Map<String, double> getProbabilities(Node node) {
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
  }*/

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

  /*IntermediateEvent? findIntermediateEvent(Node node, String eventId) {
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
*/
  /*Map<String, double> getSubNodeProbabilities(String eventId) {
    IntermediateEvent? event = findIntermediateEvent(topEvent, eventId);
    if (event != null) {
      return getProbabilities(event);
    } else {
      return {};
    }
  }*/

  /*Map<String, double> getNodeProbabilitiesByLevel(
      Node node, int level, Map<String, double> probabilities) {
    if (level == 0) {
      if (node is IntermediateEvent) {
        probabilities[node.id] = node.probability;
      }
    } else {
      if (node is Gate) {
        for (var inputEvent in node.inputEvents) {
          probabilities =
              getNodeProbabilitiesByLevel(inputEvent, level - 1, probabilities);
        }
      } else if (node is IntermediateEvent) {
        probabilities =
            getNodeProbabilitiesByLevel(node.gate, level, probabilities);
      }
    }
    return probabilities;
  }*/
/*
  Map<String, Node> getSubNodes(Node node, Map<String, Node> subNodes) {
    if (node is IntermediateEvent) {
      for (int i = 0; i < node.gate.inputEvents.length; ++i) {
        Node event = node.gate.inputEvents[i];
        if (event is IntermediateEvent) {
          subNodes[event.id] = event;
        }
      }
    }
    return subNodes;
  }*/

  /*int getDepth(Node node, int depth) {
    if (node is BasicEvent) {
      return depth;
    } else if (node is IntermediateEvent) {
      return getDepth(node.gate, depth + 1);
    } else if (node is Gate) {
      int maxDepth = 0;
      for (var inputEvent in node.inputEvents) {
        int currentDepth = getDepth(inputEvent, depth);
        if (currentDepth > maxDepth) {
          maxDepth = currentDepth;
        }
      }
      return maxDepth;
    }
    return 0;
  }
*/
  /*void printTree() {
    traverseTree(topEvent, 0);
  }*/

  void setSelectedOptions(Map<String, String?> selectedOptions) {
    SelectedOptions().selectedOptions = selectedOptions;
  }

  double calculateProbability(Node node) {
    return node.calculateProbability();
  }

  double getProbability(Node node) {
    if (node is IntermediateEvent) {
      return node.probability;
    } else {
      return 0.0;
    }
  }

  Map<String, EventProbability> getAllNodePorbabilities(
      Node node, Map<String, EventProbability> allProbabilities) {
    if (node is BasicEvent) {
      allProbabilities[node.id] =
          EventProbability(node.id, node.getProbability(), null);
    } else if (node is IntermediateEvent) {
      Map<String, EventProbability> subEvents = {};

      for (var event in node.gate.inputEvents) {
        subEvents = getAllNodePorbabilities(event, subEvents);
      }
      allProbabilities[node.id] =
          EventProbability(node.id, node.getProbability(), subEvents);
    }
    return allProbabilities;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  Map<String, String?> selectedOptions = {
    "bece70fd-793f-40b7-98c0-7c2fdff51731": "instruction",
    "Q1": "0comb",
    "Q3": "roofFireRated",
    "Q4-2": "roofWellMaintained-2",
    "Q5": "doublePane",
    "Q6": "aluminiumShutters",
    "Q7": "noVents",
    "Q8": "yesSemiConf",
    "Q9": "glazingSystems",
    "Q10": "nonCombThick",
    "Q11-2": "5farFromGlazing",
    "Q12": "farFromRoof",
    "Q14": "discontSurf",
    "Q15": "noLPG",
    "Q16": "spacingMore5",
    "Q17": "placedIn20",
    "Q18": "vegIn30",
    "Q19": "highFlam",
    "Q20": "contVeg",
    "Q21": "lowSurfaceMore10",
    "Q22": "deadVeg",
    "Q23": "noPurning",
    "Q24": "chainLink",
    "completionStep": "completion"
  };

  FaultTree faultTree = FaultTree();
  await faultTree.loadFaultTree('assets/fault_tree_1.json');
  faultTree.setSelectedOptions(selectedOptions);

  var allProbabilities =
      faultTree.getAllNodePorbabilities(faultTree.topEvent, {});
  printProbabilities(allProbabilities);
}

void printProbabilities(Map<String, EventProbability> probabilities) {
  for (var key in probabilities.keys) {
    EventProbability event = probabilities[key]!;
    print('${event.eventId}: ${event.probability}');
    if (event.subEvents != null) {
      printProbabilities(event.subEvents!);
    }
  }
}
