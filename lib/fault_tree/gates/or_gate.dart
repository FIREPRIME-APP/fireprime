import 'package:fireprime/fault_tree/events/basic_event.dart';
import 'package:fireprime/fault_tree/gates/gate.dart';
import 'package:fireprime/fault_tree/node.dart';
import 'package:fireprime/fault_tree/selectedOptions.dart';

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
        for (var option in selectedOptions.entries) {
          if (option.value != null &&
              option.value!.split(',').contains(event.id)) {
            selectedInputs.add(event);
          }
        }
      }
    } else {
      selectedInputs = inputEvents;
    }
    double probability = 1.0;
    for (var event in selectedInputs) {
      /* if (event is BasicEvent && event.dependsOn != null) {
        String dependsOn = event.dependsOn!;
        Node? node = FaultTree().getNode(dependsOn);
        if (node != null) {
          print('node: ${node.id}');
          print('node-probability: ${node.calculateProbability()}');
          probability *= (1 - node.calculateProbability());
          print(probability);
        }
      } else {*/
      probability *= (1 - event.calculateProbability());
      //}
      //probability *= (1 - event.calculateProbability());
    }
    return probability = 1 - probability;
  }
}
