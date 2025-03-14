class Questionnaire {
  static final Questionnaire _instance = Questionnaire._internal();

  Questionnaire._internal();

  factory Questionnaire() {
    return _instance;
  }
  String version = '1.0';

  List<Map<String, dynamic>> questions = [
    {
      'stepId': 'Q1',
      'textChoices': ['100comb', 'more50comb', 'less50comb', '0comb'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q2',
      'textChoices': [
        'height0',
        'height0to20',
        'height21to40',
        'height41to60',
        'height61to80',
        'height81to100',
        'heightMore100'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    /*{
      'stepId': 'material-1',
      'textChoices': ['timber', 'vinylSiding', 'concreteBricks'],
      'otherOption': true,
    },*/
    {
      'stepId': 'Q3',
      'textChoices': ['roofFireRated', 'roofNonFireRated'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q4-1',
      'textChoices': ['roofPoorlyMaintaned-1', 'roofWellMaintained-1'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q4-2',
      'textChoices': ['roofPoorlyMaintaned-2', 'roofWellMaintained-2'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q5',
      'textChoices': ['singlePane', 'doublePane', 'tempered'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q6',
      'textChoices': [
        'noShutters',
        'pvcShutters',
        'woodShutters',
        'aluminiumShutters',
        'fireRatedShutters'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    /* {
      'stepId': 'Q7',
      'textChoices': ['noVentProtection', 'allProtected', 'noVents'],
      'otherOption': false
    },*/
    {
      'stepId': 'Q7',
      'textChoices': [
        'noVents',
        'noVentProtection',
        'ventCombProtection',
        'nonCombBadCond',
        'nonCombGoodCond'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    /* {
      'stepId': 'vents-2',
      'textChoices': [
        'combustibleProtection',
        'nonCombBadCond',
        'nonCombGoodCond'
      ],
      'otherOption': false
    },*/
    {
      'stepId': 'Q8',
      'textChoices': ['yesSemiConf', 'noSemiConf'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q9',
      'textChoices': [
        'glazingSystemsSinglePane',
        'glazingSystemsMultiplePane',
        'glazingSystemsTempered',
        'noGlazingSystems'
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q10',
      'textChoices': ['combustibleEnvelope', 'nonCombThin', 'nonCombThick'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'I1',
      'type': 'instructionStep',
      'title': 'buildSurrondingsTitle',
      'text': 'buildSurrondings',
    },
    {
      'stepId': 'Q11-1',
      'textChoices': ['7farFromGlazing', '7closeToGlazing'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q11-2',
      'textChoices': ['5farFromGlazing', '5closeToGlazing'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q12',
      'textChoices': ['farFromRoof', 'closeToRoof'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q13',
      'textChoices': ['fuelsAgainstFacade', 'fuelsNotAgainstFacade'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q14',
      'textChoices': ['contSurf', 'discontSurf'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q15',
      'textChoices': ['farFromLPG', 'closeToLPG', 'noLPG'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q16',
      'textChoices': ['spacingMore5', 'spacingLess5', 'noSpacing'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q17',
      'textChoices': ['placedFurther20', 'placedIn20', 'noPlacement'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q18',
      'textChoices': ['noVegIn30', 'vegIn30'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q19',
      'textChoices': ['highFlam', 'mediumFlam', 'lowFlam', 'noVeg'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q20',
      'textChoices': ['discontVeg', 'contVeg', 'noApplicableDiscVeg'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q21',
      'textChoices': ['noPurning', 'purning', 'noApplicablePurning'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q22',
      'textChoices': [
        'lowSurfaceLess10',
        'lowSurfaceMore10',
        'noLowSurface',
      ],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q23',
      'textChoices': ['deadVeg', 'noDeadVeg', 'noApplicableDeadVeg'],
      'otherOption': false,
      'type': 'singleChoice',
    },
    {
      'stepId': 'Q24',
      'textChoices': [
        'woodenFence',
        'hedgerowHigh',
        'hedgerowLow',
        'metalPosts',
        'chainLink',
        'concreteMore2',
        'concreteLess2',
        'noDelimitation'
      ],
      'otherOption': false,
      'type': 'multipleChoice',
    },
    {
      'stepId': 'Q25',
      'textChoices': ['flatTerrain', 'midSlope', 'upperSlope'],
      'otherOption': false,
      'type': 'singleChoice',
    }
  ];

  List<Map<String, dynamic>> navigations = [
    {
      'stepId': 'Q1',
      'type': 'saveResult',
      'conditions': {
        '100comb': 'Q2',
        'more50comb': 'Q2',
        'less50comb': 'Q2',
        '0comb': 'Q3',
      },
    },
    {
      'stepId': 'Q3',
      'type': 'conditional',
      'conditions': {
        'roofFireRated': 'Q4-2',
        'roofNonFireRated': 'Q4-1',
      },
    },
    {
      'stepId': 'Q4-1',
      'type': 'conditional',
      'conditions': {
        'roofPoorlyMaintaned-1': 'Q5',
        'roofWellMaintained-1': 'Q5',
      },
    },
    /*{
      'stepId': 'material-1',
      'type': 'saveResult',
      'nextStep': 'roof-1',
    },*/
    {
      'stepId': 'Q5',
      'type': 'saveResult',
      'nextStep': 'Q6',
    },
    /*{
      'stepId': 'vents-1',
      'type': 'conditional',
      'conditions': {
        'noVentProtection': 'semiConf-1',
        'noVents': 'semiConf-1',
        'allProtected': 'vents-2',
      },
    },*/
    /*{
      'stepId': 'Q8',
      'type': 'conditionalSavedResult',
      'conditions': {
        'yesSemiConf': 'Q9',
      },
      'savedResult': {
        'id': 'Q5',
        'conditions': {
          'singlePane': 'Q11-1',
          'doublePane': 'Q11-2',
          'tempered': 'Q11-2',
        },
      }
    }*/
    {
      'stepId': 'Q8',
      'type': 'conditional',
      'conditions': {
        'yesSemiConf': 'Q9',
        'noSemiConf': 'I1',
      },
    },
    {
      'stepId': 'I1',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'Q5',
        'conditions': {
          'singlePane': 'Q11-1',
          'doublePane': 'Q11-2',
          'tempered': 'Q11-2',
        },
      }
    },
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
    /*{
      'stepId': 'Q10',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'Q5',
        'conditions': {
          'singlePane': 'Q11-1',
          'doublePane': 'Q11-2',
          'tempered': 'Q11-2',
        },
      }
    },*/

    {
      'stepId': 'Q11-1',
      'type': 'conditional',
      'conditions': {
        "7farFromGlazing": "Q12",
        '7closeToGlazing': 'Q12',
      },
    },
    {
      'stepId': 'Q12',
      'type': 'conditionalSavedResult',
      'conditions': {},
      'savedResult': {
        'id': 'Q1',
        'conditions': {
          '100comb': 'Q13',
          'more50comb': 'Q13',
          'less50comb': 'Q13',
          '0comb': 'Q14',
        },
      }
    },
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
