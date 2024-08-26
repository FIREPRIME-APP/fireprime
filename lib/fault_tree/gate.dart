import 'package:fireprime/fault_tree/event.dart';

class Gate {
  final String gateId;
  final List<Event> inputs;

  Gate({required this.gateId, required this.inputs});

  String getGateId() => gateId;

  dynamic getInput(String inputId) {}

  void setNewInput(dynamic gate) {}

  double calculateProbability() {
    return 0.0;
  }
}

class AndGate extends Gate {
  AndGate({required super.gateId, required super.inputs});

  @override
  double calculateProbability() {
    return 0.0;
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
    return 0.0;
  }
}

class OrGate extends Gate {
  OrGate({required super.gateId, required super.inputs});

  @override
  double calculateProbability() {
    return 0.0;
  }
}
