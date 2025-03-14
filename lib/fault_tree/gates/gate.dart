import 'package:fireprime/fault_tree/node.dart';

class Gate extends Node {
  List<Node> inputEvents;
  String gateType = 'gate';
  Gate(super.id, this.inputEvents);

  @override
  double calculateProbability() {
    return 0.0;
  }

  @override
  double getProbability() {
    return 0.0;
  }
}
