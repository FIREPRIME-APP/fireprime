import 'package:easy_localization/easy_localization.dart';
import 'package:fireprime/firebase/event_manage.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class AboutPage extends StatelessWidget {
  const AboutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('more_info_title'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
            saveEventdata(screenId: 'about_page', buttonId: 'back');
            Navigator.of(context).pop();
          },
          icon: const Icon(Icons.arrow_back),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(25.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(
                width: MediaQuery.of(context).size.width,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const SizedBox(
                      height: 10,
                    ),
                    Image.asset(
                      'assets/images/logos/FIREPRIME_Logo_D.png',
                      width: 100,
                      height: 100,
                    ),
                    const Text(
                      'Fireprime',
                      style: TextStyle(
                          color: Color.fromARGB(255, 86, 97, 123),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      context.tr('about_intro'),
                      style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'OpenSans',
                          fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // customisedProjectText(context),
              const Divider(
                height: 25,
                color: Colors.grey,
              ),
              Text(
                context.tr('about_text'),
                style: const TextStyle(fontSize: 13, fontFamily: 'OpenSans'),
              ),
              //customisedDevelopementText(context),
              const Divider(
                height: 25,
                color: Colors.grey,
              ),
              Image.asset(
                alignment: AlignmentDirectional.bottomCenter,
                'assets/images/logos/ue.png',
                width: 100,
              ),
              const SizedBox(
                height: 10,
              ),
              Text(
                context.tr('about_text_eu'),
                style: const TextStyle(fontSize: 13, fontFamily: 'OpenSans'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
