import 'package:fireprime/firebase/event_manage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fireprime/providers/language_change_controller.dart';
import 'package:easy_localization/easy_localization.dart';

enum Language { english, spanish, catalan, german, swedish }

const List<String> languagesOriginal = <String>[
  'English',
  'Castellano',
  'Català',
  'Deutsch',
  'Svenska'
];

class LanguagePage extends StatefulWidget {
  const LanguagePage({super.key});

  @override
  State<LanguagePage> createState() => _LanguagePageState();
}

class _LanguagePageState extends State<LanguagePage> {
  @override
  Widget build(BuildContext context) {
    List<String> languages = <String>[
      context.tr('english'),
      context.tr('spanish'),
      context.tr('catalan'),
      context.tr('german'),
      /*context.tr('swedish')*/
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context
              .tr('language_page_title'), //AppLocalizations.of(context)!.lang,
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Consumer<LanguageChangeProvider>(
        builder: (context, language, child) {
          int? selectedIndex = language.selectedIndex;
          return ListView.separated(
            itemCount: languages.length,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: ListTile(
                  title: index == selectedIndex
                      ? Text(
                          '${languages[index]} - ${languagesOriginal[index]}',
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color.fromARGB(255, 86, 97, 123)),
                        )
                      : Text(
                          '${languages[index]} - ${languagesOriginal[index]}'),
                  trailing: index == selectedIndex
                      ? const Icon(
                          Icons.check,
                          color: Color.fromARGB(255, 86, 97, 123),
                        )
                      : null,
                  onTap: () {
                    if (index == 0) {
                      saveEventdata(screenId: 'language_page', buttonId: 'en');
                      language.changeLanguage(
                          const Locale('en'), index, context);
                    } else if (index == 1) {
                      saveEventdata(screenId: 'language_page', buttonId: 'es');
                      language.changeLanguage(
                          const Locale('es'), index, context);
                    } else if (index == 2) {
                      saveEventdata(screenId: 'language_page', buttonId: 'ca');
                      language.changeLanguage(
                          const Locale('ca'), index, context);
                    } else if (index == 3) {
                      language.changeLanguage(
                          const Locale('de'), index, context);
                      //}
                      /*else if (index == 4) {
                      provider.changeLanguage(
                          const Locale('sv'), index, context);*/
                    } else {
                      language.changeLanguage(
                          const Locale('en'), index, context);
                    }
                  },
                ),
              );
            },
            separatorBuilder: (BuildContext context, int index) =>
                const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: Divider(
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }
}
