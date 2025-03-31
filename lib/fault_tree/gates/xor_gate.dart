import 'package:fireprime/fault_tree/gates/gate.dart';
import 'package:fireprime/fault_tree/selectedOptions.dart';

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
    return probability;
  }
}
