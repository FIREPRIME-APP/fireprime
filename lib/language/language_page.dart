import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fireprime/controller/language_change_controller.dart';
import 'package:easy_localization/easy_localization.dart';

enum Language { english, spanish, catalan }

const List<String> languagesOriginal = <String>[
  'English',
  'Castellano',
  'Català'
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
    ];
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('preferedLang'), //AppLocalizations.of(context)!.lang,
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Consumer<LanguageChangeController>(
        builder: (context, provider, child) {
          int? selectedIndex = provider.selectedIndex;
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
                      provider.changeLanguage(
                          const Locale('en'), index, context);
                    } else if (index == 1) {
                      provider.changeLanguage(
                          const Locale('es'), index, context);
                    } else {
                      provider.changeLanguage(
                          const Locale('ca'), index, context);
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
