import 'package:fireprime/model/environment.dart';
import 'package:flutter/material.dart';

class EnvironmentController with ChangeNotifier {
  Map<String, Environment> environments = {
    'Catalunya': Environment(
      environmentName: 'Catalunya',
    ),
    'Other': Environment(
      environmentName: 'Other',
    ),
  };

  EnvironmentController();

  void addEnvironment(Environment environment) {
    environments[environment.environmentName] = environment;
    notifyListeners();
  }

  Map<String, Environment> getEnvironments() {
    return environments;
  }

  List<String> getEnvironmentNames() {
    return environments.keys.toList();
  }

  Environment getEnvironment(String environmentName) {
    return environments[environmentName]!;
  }

  void addHouse() {
    notifyListeners();
  }
}
