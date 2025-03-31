import 'package:fireprime/fault_tree/gates/gate.dart';

class AndGate extends Gate {
  AndGate(super.id, super.inputEvents) {
    super.gateType = 'and_gate';
  }

  @override
  double calculateProbability() {
    double probability = 1.0;
    for (var event in inputEvents) {
      if (event.calculateProbability() != 0) {
        probability *= event.calculateProbability();
      }
    }
    return probability;
  }
}
