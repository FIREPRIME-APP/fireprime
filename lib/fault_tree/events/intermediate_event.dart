import 'package:fireprime/fault_tree/gates/gate.dart';
import 'package:fireprime/fault_tree/node.dart';

class IntermediateEvent extends Node {
  double probability = 0.0;
  Gate gate;

  IntermediateEvent(super.id, this.gate);

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
