class Questionnaire {
  static final Questionnaire _instance = Questionnaire._internal();

  Questionnaire._internal();

  factory Questionnaire() {
    return _instance;
  }
  String version = '1.0';

  List<Map<String, dynamic>> questions = [
    /* {
      'stepId': 'material-1',
      'textChoices': ['100comb', 'more50comb', '50comb', 'less50comb', '0comb'],
      'otherOption': false,
    },
    {
      'stepId': 'material-2',
      'textChoices': [
        'foundComb',
        'height0to20',
        'height21to40',
        'height41to60',
        'height61to80',
        'height81to100',
        'heightMore100'
      ],
      'otherOption': false,
    },*/
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
    /* {
      'stepId': 'vents-1',
      'textChoices': [
        'noVents',
        'noVentProtection',
        'ventCombProtection',
        'ventNonCombBadCond',
        'ventNonCombGoodCond'
      ],
      'otherOption': false
    },*/
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
    },
    /* {
      'stepId': 'fuels-1a',
      'textChoices': ['7closeToGlazing', '7farFromGlazing'],
      'otherOption': false
    },
    {
      'stepId': 'fuels-1b',
      'textChoices': ['5closeToGlazing', '5farFromGlazing'],
      'otherOption': false
    },
    {
      'stepId': 'fuels-2',
      'textChoices': ['closeToRoof', 'farFromRoof'],
      'otherOption': false
    },
    {
      'stepId': 'fuels-3',
      'textChoices': ['fuelsAgainstFacade', 'fuelsNotAgainstFacade'],
      'otherOption': false
    },
    {
      'stepId': 'fuels-4',
      'textChoices': ['discontSurf', 'contSurf'],
      'otherOption': false
    },
    {
      'stepId': 'artFuels-1',
      'textChoices': ['closeToLPG', 'farFromLPG', 'noLPG'],
      'otherOption': false
    },
    {
      'stepId': 'artFuels-2',
      'textChoices': ['spacingLess5', 'spacingMore5', 'noSpacing'],
      'otherOption': false
    },
    {
      'stepId': 'artFuels-3',
      'textChoices': ['placedIn20', 'placedFurther20', 'noPlacement'],
      'otherOption': false
    },
    {
      'stepId': 'vegetation-1',
      'textChoices': ['vegIn30', 'noVegIn30', 'noApplicableVegIn30'],
      'otherOption': false
    },
    {
      'stepId': 'vegetation-2',
      'textChoices': [
        'closelyLeaves',
        'highOils',
        'looseBark',
        'denseBranching',
        'grass',
        'noVeg'
      ],
      'otherOption': false
    },
    {
      'stepId': 'vegetation-3',
      'textChoices': ['discontVeg', 'contVeg', 'noApplicableDiscVeg'],
      'otherOption': false
    },
    {
      'stepId': 'vegetation-4',
      'textChoices': [
        'lowSurfaceLess10',
        'lowSurfaceMore10',
        'noLowSurface',
      ],
      'otherOption': false
    },
    {
      'stepId': 'vegetation-5',
      'textChoices': ['deadVeg', 'noDeadVeg'],
      'otherOption': false
    },
    {
      'stepId': 'vegetation-6',
      'textChoices': ['puring', 'noPuring', 'noApplicablePuring'],
      'otherOption': false
    },
    {
      'stepId': 'vegetation-7',
      'textChoices': [
        'woodenFence',
        'Hedgerow',
        'metalPosts',
        'chainLink',
        'concreteMore2',
        'concreteLess2',
        'noDelimitation'
      ],
      'otherOption': false
    },*/
  ];

  List<Map<String, dynamic>> navigations = [
    /*{
      'stepId': 'material-1',
      'type': 'saveResult',
      'conditions': {
        '100comb': 'material-2',
        'more50comb': 'material-2',
        '50comb': 'material-2',
        'less50comb': 'roof-1',
        '0comb': 'roof-1',
      },
    },*/
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
    /* {
      'stepId': 'semiConf-1',
      'type': 'conditionalSavedResult',
      'conditions': {
        'yesSemiConf': 'semiConf-2',
      },
      'savedResult': {
        'id': 'glazing-1',
        'conditions': {
          'singlePane': 'fuels-1a',
          'doublePane': 'fuels-1b',
          'tempered': 'fuels-1b',
        },
      }
    },*/
    /* {
      'stepId': 'semiConf-3',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'glazing-1',
        'conditions': {
          'singlePane': 'fuels-1a',
          'doublePane': 'fuels-1b',
          'tempered': 'fuels-1b',
        },
      }
    },
    {
      'stepId': 'fuels-2',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'material-1',
        'conditions': {
          '100comb': 'fuels-3',
          'more50comb': 'fuels-3',
          '50comb': 'fuels-3',
          'less50comb': 'fuels-4',
          '0comb': 'fuels-4',
        },
      }
    },*/
  ];

  String environment = 'default';

  Map<String, dynamic> getOptions(questionId) {
    Map<String, dynamic> options = {};

    for (var question in questions) {
      if (question['stepId'] == questionId) {
        options[questionId] = question['textChoices'];
        break;
      }
    }
    return options;
  }

  void setEnvironment(String environment) {
    this.environment = environment;
  }
}
