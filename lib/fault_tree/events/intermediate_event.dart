import 'package:fireprime/fault_tree/gates/gate.dart';
import 'package:fireprime/fault_tree/node.dart';

class IntermediateEvent extends Node {
  double probability = 0.0;
  Gate gate;
  double weight = 1.0;

  IntermediateEvent(super.id, this.gate, this.weight);

  @override
  double calculateProbability() {
    probability = gate.calculateProbability();
    return probability;
  }

  @override
  double getProbability() {
    return probability;
  }
}
