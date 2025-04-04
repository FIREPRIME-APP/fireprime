import 'package:fireprime/fault_tree/node.dart';

class BasicEvent extends Node {
  double probability;
  String? dependsOn;
  BasicEvent(super.id, this.probability);

  @override
  double calculateProbability() {
    return probability;
  }

  @override
  double getProbability() {
    return probability;
  }
}
