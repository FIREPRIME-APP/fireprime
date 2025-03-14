import 'package:fireprime/fault_tree_test/event.dart';

class Gate {
  final String gateId;
  final List<dynamic> inputs;

  Gate({required this.gateId, required this.inputs});

  String getGateId() => gateId;

  List<double> probability() {
    List<double> prob = [];
    for (var input in inputs) {
      prob.add(input.calculateProbability());
    }
    return prob;
  }

  Event getInput(String inputId) {
    return inputs.firstWhere((input) => input.getEventId() == inputId);
  }

  void setNewInput(dynamic gate) {
    for (var input in inputs) {
      if (input is! Event && gate is! Event) {
        if (input.getGateId() == gate.getGateId()) {
          inputs.remove(input);
          inputs.add(gate.getInput(gate.getGateId()));
        }
      }
    }
  }

  double calculateProbability() {
    return 0.0;
  }
}

class AndGate extends Gate {
  AndGate({required super.gateId, required super.inputs});

  @override
  double calculateProbability() {
    var prob = 1.0;
    for (var input in inputs) {
      prob *= input.calculateProbability();
    }
    return prob;
  }
}

class XorGate extends Gate {
  late String selectedEventId;

  XorGate({required super.gateId, required super.inputs});

  void setSelectedEventId(String selectedEventId) {
    this.selectedEventId = selectedEventId;
  }

  @override
  double calculateProbability() {
    var selectedEvent =
        inputs.firstWhere((input) => input.getEventId() == selectedEventId);
    if (selectedEvent != null) {
      return selectedEvent.calculateProbability();
    } else {
      throw Exception('No event selected for XOR gate');
    }
  }
}

class OrGate extends Gate {
  OrGate({required super.gateId, required super.inputs});

  @override
  double calculateProbability() {
    var prob = 1.0;
    for (var input in inputs) {
      prob *= (1.0 - input.calculateProbability());
    }
    return prob;
  }
}

class ChoiceOrGate {
  final String gateId;
  final List<dynamic> inputs;

  ChoiceOrGate({required this.gateId, required this.inputs});

  double calculateProbability(String selectedEventgateId) {
    var selectedEvent =
        inputs.firstWhere((input) => input.gateId == selectedEventgateId);
    if (selectedEvent != null) {
      return selectedEvent.calculateProbability();
    } else {
      throw Exception('No event selected for XOR gate');
    }
  }
}
/*
class Gate {
  final String gateId;
  final String gateType;
  final List<dynamic> inputs = [];
  Event? selectedEventChoice;

  Gate({required this.gateId, required this.gateType});

  void addInput(dynamic input) {
    inputs.add(input);
  }

  void removeInput(dynamic input) {
    inputs.remove(input);
  }

  void clearInputs() {
    inputs.clear();
  }

  double calculateProbability() {
    if (gateType == 'AND') {
      return inputs.fold(
          1.0, (result, input) => result * input.getProbability());
    } else if (gateType == 'OR') {
      if (selectedEventChoice == null) {
        return inputs.fold(
            1.0, (result, input) => result * (1.0 - input.getProbability()));
      } else {
        var selectedEvent = inputs
            .firstWhere((input) => selectedEventChoice!.gateId == input.gateId);
        return selectedEvent.getProbability();
      }
    } else if (gateType == 'XOR') {
      var selectedEvent =
          inputs.firstWhere((input) => selectedEventChoice!.gateId == input.gateId);
      return selectedEvent.getProbability();
    } else {
      throw Exception('No event selected for XOR gate');
    }
  }

  void setSelectedEvent(Event selectedEvent) {
    if (gateType == 'XOR' || gateType == 'OR') {
      selectedEventChoice = selectedEvent;
    } else {
      throw Exception('Gate type is not XOR or OR');
    }
  }
}*/
