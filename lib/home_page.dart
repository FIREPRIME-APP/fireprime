import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/house/house_list_page.dart';
import 'package:fireprime/language/language_page.dart';
import 'package:fireprime/questionnaire/questionnaire_page.dart';
import 'package:flutter/material.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    assert(context.localizationDelegates.isNotEmpty,
        'localizationDelegates isEmpty');

    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.tr('home'),
              style: Theme.of(context).textTheme.displayMedium!,
              textAlign: TextAlign.center,
            ).tr(),
            const SizedBox(
              height: 50.0,
            ),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const QuestionnairePage(
                        environment: 'spain',
                        answers: {},
                      );
                    },
                  ),
                );
              },
              child: Text(
                context.tr('questionnaire'),
                //AppLocalizations.of(context)!.questionnaire,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const LanguagePage();
                    },
                  ),
                );
              },
              child: Text(
                context.tr('languages'),
                //AppLocalizations.of(context)!.changLang,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
            const SizedBox(height: 20.0),
            OutlinedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (BuildContext context) {
                      return const HouseListPage();
                    },
                  ),
                );
              },
              child: Text(
                'Your houses',
                //AppLocalizations.of(context)!.changLang,
                style: TextStyle(color: Theme.of(context).primaryColor),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
