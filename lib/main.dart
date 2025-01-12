import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:fireprime/model/event_probability.dart';
import 'package:fireprime/providers/environment_provider.dart';
import 'package:fireprime/providers/house_provider.dart';
import 'package:fireprime/providers/images_provider.dart';
import 'package:fireprime/fault_tree/fault_tree.dart';
import 'package:fireprime/pages/house/house_list_page.dart';
import 'package:fireprime/model/house.dart';
import 'package:fireprime/model/risk_assessment.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart' hide Step;
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:fireprime/providers/language_change_controller.dart';
import 'firebase/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();
  Hive.registerAdapter(HouseAdapter());
  Hive.registerAdapter(RiskAssessmentAdapter());
  Hive.registerAdapter(EventProbabilityAdapter());
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    print('Error initializing Firebase: $e');
  }
  await FirebaseAppCheck.instance.activate(
    //androidProvider: AndroidProvider.playIntegrity,
    //appleProvider: AppleProvider.deviceCheck,
    androidProvider: AndroidProvider.debug,
  );

  try {
    String? appCheckToken = await FirebaseAppCheck.instance.getToken();
    print("App Check Token: $appCheckToken");
  } catch (e) {
    print("Error App Check: $e");
  }

  runApp(
    EasyLocalization(
      supportedLocales: const [
        Locale('en'),
        Locale('ca'),
        Locale('es'),
        // Locale('de'),
        // Locale('sv')
      ],
      path: 'assets/translations',
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<void> _loadFaultTree() async {
    final FaultTree faultTree = FaultTree();
    await faultTree.loadFaultTree('assets/fault_tree_1.json');
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              LanguageChangeProvider(selectedIndex: 0, context: context),
        ),
        ChangeNotifierProvider(
          create: (_) => EnvironmentProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => HouseProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => ImagesProvider(),
        ),
      ],
      child: Consumer<LanguageChangeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'FirePrime',
            theme: Theme.of(context).copyWith(
              primaryColor: const Color.fromARGB(255, 86, 97, 123),
              appBarTheme: const AppBarTheme(
                color: Colors.white,
                iconTheme: IconThemeData(
                  color: Color.fromARGB(255, 86, 97, 123),
                ),
                titleTextStyle: TextStyle(
                    color: Color.fromARGB(255, 86, 97, 123),
                    fontFamily: 'OpenSans'),
              ),
              iconTheme: const IconThemeData(
                color: Color.fromARGB(255, 86, 97, 123),
              ),
              textSelectionTheme: const TextSelectionThemeData(
                cursorColor: Color.fromARGB(255, 86, 97, 123),
                selectionColor: Color.fromARGB(255, 86, 97, 123),
                selectionHandleColor: Colors.white,
              ),
              cupertinoOverrideTheme: const CupertinoThemeData(
                primaryColor: Color.fromARGB(255, 86, 97, 123),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: ButtonStyle(
                  minimumSize: MaterialStateProperty.all(
                    const Size(150.0, 60.0),
                  ),
                  side: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> state) {
                      if (state.contains(MaterialState.disabled)) {
                        return const BorderSide(
                          color: Colors.grey,
                          width: 2.0,
                        );
                      }
                      return const BorderSide(
                        color: Color.fromARGB(255, 86, 97, 123),
                        width: 2.0,
                      );
                    },
                  ),
                  shape: MaterialStateProperty.all(
                    RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(25.0),
                    ),
                  ),
                  textStyle: MaterialStateProperty.resolveWith(
                    (Set<MaterialState> state) {
                      if (state.contains(MaterialState.disabled)) {
                        return Theme.of(context).textTheme.labelLarge?.copyWith(
                              color: Colors.grey,
                            );
                      }
                      return Theme.of(context).textTheme.labelLarge?.copyWith(
                            color: const Color.fromARGB(255, 86, 97, 123),
                          );
                    },
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: ButtonStyle(
                  textStyle: MaterialStateProperty.all(
                    Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: const Color.fromARGB(255, 86, 97, 123),
                        ),
                  ),
                ),
              ),
              primaryColorLight: const Color.fromARGB(255, 86, 97, 123),
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                displayMedium: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                displaySmall: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                titleLarge: TextStyle(
                  color: Colors.black,
                  fontSize: 24.0,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'OpenSans',
                ),
                titleSmall: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                bodyLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                bodySmall: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                headlineLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                headlineMedium: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                labelLarge: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                labelMedium: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                labelSmall: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                headlineSmall: TextStyle(
                  fontSize: 24.0,
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                bodyMedium: TextStyle(
                  fontSize: 20.0,
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                titleMedium: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
              ),
              inputDecorationTheme: const InputDecorationTheme(
                labelStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                floatingLabelStyle: TextStyle(
                  color: Colors.black,
                  fontFamily: 'OpenSans',
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    width: 2.0,
                    color: Color.fromARGB(255, 86, 97, 123),
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(10.0)),
                  borderSide: BorderSide(
                    width: 2.0,
                    color: Color.fromARGB(255, 86, 97, 123),
                  ),
                ),
              ),
              colorScheme: ColorScheme.fromSwatch(
                primarySwatch: Colors.blueGrey,
              )
                  .copyWith(
                    onPrimary: Colors.black,
                  )
                  .copyWith(background: Colors.white),
            ),
            localizationsDelegates: context.localizationDelegates,
            /*const [
              //AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],*/
            supportedLocales: context.supportedLocales,
            /*const [
              Locale('en'),
              Locale('es'),
              Locale('ca'),
            ],*/
            locale: provider.appLocale, //provider.appLocale,
            home: FutureBuilder<void>(
              future: _loadFaultTree(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                } else if (snapshot.hasError) {
                  return const Scaffold(
                    body: Center(child: Text('Error loading fault tree')),
                  );
                } else {
                  return const HouseListPage();
                }
              },
            ),
          );
        },
      ),
    );
  }
}
