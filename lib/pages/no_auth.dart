import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/providers/language_change_controller.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class NoAuth extends StatelessWidget {
  const NoAuth({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) =>
              LanguageChangeProvider(selectedIndex: 0, context: context),
        ),
      ],
      child: Consumer<LanguageChangeProvider>(
        builder: (context, provider, child) {
          return MaterialApp(
            debugShowCheckedModeBanner: false,
            localizationsDelegates: context.localizationDelegates,
            supportedLocales: context.supportedLocales,
            locale: provider.appLocale, // Usa el idioma del proveedor
            home: const Authorization(),
          );
        },
      ),
    );
  }
}

class Authorization extends StatelessWidget {
  const Authorization({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Center(
          child: Text(
            context.tr('no_auth'),
          ),
        ),
      ),
    );
  }
}
