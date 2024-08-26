/*import 'package:fireprime/fault_tree/event.dart';
import 'package:fireprime/fault_tree/falut_tree.dart';
import 'package:fireprime/fault_tree/gate.dart';
*/ /*
FaultTree configureFaultTree() {
  var faultTree = FaultTree();

  Event singlePane =
      Event(eventId: 'glazing-1a', gateId: 'singlePane', probability: 0.895);
  Event doubleMultiplePane = Event(
      eventId: 'glazing-1b', gateId: 'doubleMultiplePane', probability: 0.661);

  faultTree.addEvent(singlePane);
  faultTree.addEvent(doubleMultiplePane);

  Gate glazing1 = Gate (gateId: 'glazing-1', gateType: 'XOR');
  faultTree.addGate(glazing1);
  faultTree.addGateInput('glazing-1', singlePane);
  faultTree.addGateInput('glazing-1', doubleMultiplePane);

  Event notAllProtected = Event(eventId: 'glazing-2a', gateId: 'notAllProtected', probability: 0.884);
  Event wood = Event(eventId: 'glazing-2b', gateId: 'wood', probability: 0.665);
  Event aluminium = Event(eventId: 'glazing-2c', gateId: 'aluminium', probability: 0.243);
  Event pvc = Event(eventId: 'glazing-2d', gateId: 'pvc', probability: 0.478);
  Event fireRatedMaterials = Event(
      eventId: 'glazing-2e', gateId: 'fireRatedMaterials', probability: 0.066);

  faultTree.addEvent(notAllProtected);
  faultTree.addEvent(wood);
  faultTree.addEvent(aluminium);
  faultTree.addEvent(pvc);
  faultTree.addEvent(fireRatedMaterials);

  Gate glazing2 = Gate(gateId: 'glazing-2', gateType: 'XOR');
  faultTree.addGate(glazing2);

  faultTree.addGateInput('glazing-2', notAllProtected);
  faultTree.addGateInput('glazing-2', wood);
  faultTree.addGateInput('glazing-2', aluminium);
  faultTree.addGateInput('glazing-2', pvc);
  faultTree.addGateInput('glazing-2', fireRatedMaterials);

  Gate glazingSystems = Gate(gateId: 'glazing systems', gateType: 'AND');
  faultTree.addGate(glazingSystems);
  faultTree.addGateInput(
    'glazing systems',);
  faultTree.addGateInput(
    'glazing systems',
  );

  Event roof1yes = Event(eventId: 'roof-1a', gateId: 'yes', probability: 0.662);
  Event roof1no = Event(eventId: 'roof-1b', gateId: 'no', probability: 0.157);

  faultTree.addEvent(roof1yes);
  faultTree.addEvent(roof1no);

  Event roof2yes = Event(eventId: 'roof-2a', gateId: 'yes', probability: 0.757);
  Event roof2no = Event(eventId: 'roof-2b', gateId: 'no', probability: 0.165);

  faultTree.addEvent(roof2yes);
  faultTree.addEvent(roof2no);

  faultTree.topEvent = faultTree.nodes['glazing systems'];

  return faultTree;
}

void main() {
  Map<String, String> selectedOptions = {
    'glazing-1': 'singlePane',
    'glazing-2': 'notAllProtected',
    'roof-1': 'no',
    'roof-2': 'yes',
  };
  var faultTree = configureFaultTree();
  faultTree.setSelectedOptions(selectedOptions);
  var result = faultTree.calculateTopEventProbability();
  print(result);
}*/

import 'package:fireprime/fault_tree_test/event.dart';
import 'package:fireprime/fault_tree_test/falut_tree.dart';
import 'package:fireprime/fault_tree_test/gate.dart';

var eventSinglePane = Event(eventId: 'singlePane', probability: 0.895);
var eventDoubleMultiplePane =
    Event(eventId: 'doubleMultiplePane', probability: 0.661);
var eventTemperedGlass = Event(eventId: 'temperedGlass', probability: 0.661);

var eventNoShutters = Event(eventId: 'notAllProtected', probability: 0.884);
var eventPVC = Event(eventId: 'pvc', probability: 0.665);
var eventWood = Event(eventId: 'wood', probability: 0.478);
var eventAluminium = Event(eventId: 'aluminium', probability: 0.243);
var eventFireRated = Event(eventId: 'fireRatedMaterials', probability: 0.066);

var glazingFailure = XorGate(
    gateId: 'glazingFailure',
    inputs: [eventSinglePane, eventDoubleMultiplePane, eventTemperedGlass]);

var shutterFailure = XorGate(gateId: 'shutterFailure', inputs: [
  eventNoShutters,
  eventPVC,
  eventWood,
  eventAluminium,
  eventFireRated
]);

var glazingSystems =
    AndGate(gateId: 'glazingSystems', inputs: [glazingFailure, shutterFailure]);

var eventRoofNonFireRated =
    Event(eventId: 'roofNonFireRated', probability: 0.662);
var eventRoofFireRated = Event(eventId: 'roofFireRated', probability: 0.157);

var roofMaterial = XorGate(
    gateId: 'roofMaterial',
    inputs: [eventRoofNonFireRated, eventRoofFireRated]);

var eventRoofPoorlyMaint =
    Event(eventId: 'roofPoorlyMaintaned', probability: 0.757);
var eventRoofWellMaint =
    Event(eventId: 'roofWellMaintaned', probability: 0.165);

var roofMaint = XorGate(
    gateId: 'roofMaint', inputs: [eventRoofPoorlyMaint, eventRoofWellMaint]);

var roof = AndGate(gateId: 'roof', inputs: [roofMaterial, roofMaint]);

var eventNoVents = Event(eventId: 'noVents', probability: 0.811);
var eventCombustibleProtection =
    Event(eventId: 'combustible', probability: 0.402);
var eventNonCombustibleBadCond =
    Event(eventId: 'nonCombBad', probability: 0.425);
var eventNonCombustibleGoodCond =
    Event(eventId: 'nonCombGood', probability: 0.078);

void main() {
  var faultTree = FaultTree();

  faultTree.addEvent(eventSinglePane);
  faultTree.addEvent(eventDoubleMultiplePane);
  faultTree.addEvent(eventTemperedGlass);
  faultTree.addEvent(eventNoShutters);
  faultTree.addEvent(eventPVC);
  faultTree.addEvent(eventWood);
  faultTree.addEvent(eventAluminium);
  faultTree.addEvent(eventFireRated);
  faultTree.addEvent(eventRoofNonFireRated);
  faultTree.addEvent(eventRoofFireRated);
  faultTree.addEvent(eventRoofPoorlyMaint);
  faultTree.addEvent(eventRoofWellMaint);

  faultTree.addGate(glazingFailure);
  faultTree.addGate(shutterFailure);
  faultTree.addGate(glazingSystems);
  faultTree.addGate(roofMaterial);
  faultTree.addGate(roofMaint);
  faultTree.addGate(roof);

  var selectedOptions = {
    'glazingFailure': 'doubleMultiplePane',
    'shutterFailure': 'notAllProtected',
    'roofMaterial': 'roofFireRated',
    'roofMaint': 'roofPoorlyMaintaned',
    'vents': 'noVents',
  };

  var order = [
    'glazingFailure',
    'shutterFailure',
    'glazingSystems',
    'roofMaterial',
    'roofMaint',
    'roof',
  ];

  var updates = {
    'glazingFailure': 'glazingSystems',
    'shutterFailure': 'glazingSystems',
    'glazingSystems': 'none',
    'roofMaterial': 'roof',
    'roofMaint': 'roof',
    'roof': 'none',
  };

  var gates = faultTree.gates;

  for (var i in order) {
    var gate = faultTree.getGate(i);
    if (gate is XorGate) {
      if (selectedOptions.containsKey(i)) {
        var selectedOption = selectedOptions[i];
        var eventId = gates[i].getGateId();
        gates[i].setSelectedEventId(selectedOption);
        var probability = gates[i].calculateProbability();
        var newGate = XorGate(gateId: gates[i].getGateId(), inputs: [
          Event(
            eventId: eventId,
            probability: probability,
          )
        ]);

        faultTree.modifyGate(newGate, updates[i]);

        print(
            'Gate ${gates[i].getGateId()} probability: ${newGate.probability()}');
      }
    } else if (gate is AndGate) {
      var newGate = AndGate(gateId: gates[i].getGateId(), inputs: [
        Event(
            eventId: gates[i].getGateId(),
            probability: gates[i].calculateProbability())
      ]);

      faultTree.modifyGate(newGate, updates[i]);
      print(
          'Gate ${gates[i].getGateId()} probability: ${newGate.probability()}');
    }
  }
}
