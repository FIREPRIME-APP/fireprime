class Questionnaire {
  static final Questionnaire _instance = Questionnaire._internal();

  Questionnaire._internal();

  factory Questionnaire() {
    return _instance;
  }
  String version = '1.0';

  List<Map<String, dynamic>> questions = [
    {
      'stepId': 'material-1',
      'textChoices': ['timber', 'vinylSiding', 'concreteBricks'],
      'otherOption': true,
    },
    {
      'stepId': 'roof-1',
      'textChoices': ['roofFireRated', 'roofNonFireRated'],
      'otherOption': false,
    },
    {
      'stepId': 'roof-2',
      'textChoices': ['roofPoorlyMaintaned', 'roofWellMaintained'],
      'otherOption': false,
    },
    {
      'stepId': 'glazing-1',
      'textChoices': ['singlePane', 'doublePane', 'tempered'],
      'otherOption': false,
    },
    {
      'stepId': 'glazing-2',
      'textChoices': [
        'notAllProtected',
        'wood',
        'aluminium',
        'pvc',
        'fireRated'
      ],
      'otherOption': false
    },
    {
      'stepId': 'vents-1',
      'textChoices': ['noVentProtection', 'allProtected', 'noVents'],
      'otherOption': false
    },
    {
      'stepId': 'vents-2',
      'textChoices': [
        'combustibleProtection',
        'nonCombBadCond',
        'nonCombGoodCond'
      ],
      'otherOption': false
    },
    {
      'stepId': 'semiConf-1',
      'textChoices': ['yesSemiConf', 'noSemiConf'],
      'otherOption': false,
    },
    {
      'stepId': 'semiConf-2',
      'textChoices': ['glazingSystems', 'noGlazingSystems'],
      'otherOption': false
    },
    {
      'stepId': 'semiConf-3',
      'textChoices': ['combustibleEnvelope', 'nonCombThin', 'nonCombThick'],
      'otherOption': false
    }
  ];

  List<Map<String, dynamic>> navigations = [
    {
      'stepId': 'material-1',
      'type': 'saveResult',
      'nextStep': 'roof-1',
    },
    {
      'stepId': 'glazing-1',
      'type': 'saveResult',
      'nextStep': 'glazing-2',
    },
    {
      'stepId': 'vents-1',
      'type': 'conditional',
      'conditions': {
        'noVentProtection': 'semiConf-1',
        'noVents': 'semiConf-1',
        'allProtected': 'vents-2',
      },
    },
    {
      'stepId': 'semiConf-1',
      'type': 'conditionalSavedResult',
      'conditions': {
        'yesSemiConf': 'semiConf-2',
      },
      'savedResult': {
        'id': 'glazing-1',
        'conditions': {
          'singlePane': 'completionStep',
          'doublePane': 'completionStep',
          'tempered': 'completionStep',
        },
      }
    }
  ];

  String environment = 'default';

  void setEnvironment(String environment) {
    this.environment = environment;
  }
}
