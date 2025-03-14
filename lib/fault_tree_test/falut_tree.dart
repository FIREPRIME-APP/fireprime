/*import 'package:fireprime/fault_tree/event.dart';
import 'package:fireprime/fault_tree/gate.dart';

class FaultTree {
  final Map<String, dynamic> nodes = {};
  dynamic topEvent;

  void addEvent(Event event) {
    nodes[event.eventId] = event;
  }

  void updateEventProbability(String eventId, double probability) {
    if (nodes.containsKey(eventId)) {
      nodes[eventId].probability = probability;
    } else {
      throw Exception('Event not found');
    }
  }

  void deleteEvent(String eventId) {
    if (nodes.containsKey(eventId)) {
      nodes.remove(eventId);
      nodes.values.whereType<Gate>().forEach((gate) {
        gate.removeInput(eventId);
      });
    } else {
      throw Exception('Event not found');
    }
  }

  void addGate(Gate gate) {
    nodes[gate.gateId] = gate;
  }

  void deleteGate(String gateId) {
    if (nodes.containsKey(gateId)) {
      nodes.remove(gateId);
      nodes.values.whereType<Gate>().forEach((gate) {
        gate.removeInput(gateId);
      });
    } else {
      throw Exception('Gate not found');
    }
  }

  void addGateInput(String gateId, Event event) {
    if (nodes.containsKey(gateId)) {
      nodes[gateId].addInput(event);
    } else {
      throw Exception('Gate or input not found');
    }
  }

  void removeGateInput(String gateId, String inputId) {
    var gate = nodes[gateId];
    gate.removeInput(inputId);
  }

  void setTopEvent(String topEventId) {
    topEvent = nodes[topEventId];
  }

  double calculateTopEventProbability() {
    if (topEvent == null) {
      throw Exception('Top event not set');
    }
    return topEvent.calculateProbability();
  }

  void setSelectedOptions(Map<String, String> selectedOptions) {
    selectedOptions.forEach((questionId, option) {
      if (nodes.containsKey(questionId) &&
          nodes[questionId] is Gate &&
          nodes[questionId].gateType == 'XOR') {
        nodes[questionId].setSelectedEvent(option);
      }
    });
  }
}*/

import 'package:fireprime/fault_tree_test/event.dart';

class FaultTree {
  Map<String, Event> events = {};
  Map<String, dynamic> gates = {};

  void addEvent(Event event) {
    events[event.eventId] = event;
  }

  void addGate(dynamic gate) {
    gates[gate.gateId] = gate;
  }

  void modifyEvent(Event event) {
    events[event.eventId] = event;
  }

  void modifyGate(dynamic gate, String? updateId) {
    gates[gate.gateId] = gate;
    print(gates);

    if (updateId != 'none') {
      gates[updateId!].setNewInput(gate);
    }
    print(gates[updateId!]);
  }

  dynamic getGate(String gateId) {
    return gates[gateId];
  }

  Map<String, Event> getEvents() => events;
  Map<String, dynamic> getGates() => gates;
}
