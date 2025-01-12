import 'package:easy_localization/easy_localization.dart';
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
          context.tr('about_firePrime'),
          style: Theme.of(context).textTheme.titleLarge!,
        ),
        leading: IconButton(
          onPressed: () {
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
                      'FirePrime',
                      style: TextStyle(
                          color: Color.fromARGB(255, 86, 97, 123),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                ),
              ),
              const Divider(
                color: Colors.grey,
              ),
              customisedProjectText(context),
              const Divider(
                height: 25,
                color: Colors.grey,
              ),
              customisedDevelopementText(context),
              const Divider(
                height: 25,
                color: Colors.grey,
              ),
              Text(context.tr('privacy_title'),
                  style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(
                height: 10,
              ),
              Text(
                context.tr('privacy_text'),
                style: const TextStyle(
                    fontSize: 15, height: 1.5, fontFamily: 'OpenSans'),
                textAlign: TextAlign.justify,
              ),
              Image.asset(
                'assets/images/logos/ue.jpg',
                width: 100,
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget customisedProjectText(BuildContext context) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15.0,
          color: Colors.black,
          height: 1.5,
          fontFamily: 'OpenSans',
        ),
        children: <TextSpan>[
          TextSpan(
            text: context.tr('about_projText1'),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          TextSpan(
            text: context.tr('about_projText2'),
          ),
          TextSpan(
            text: 'GESSI Research Group',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.underline), // Italica
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                Uri url = Uri.parse('https://gessi.upc.edu/en');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
          ),
          TextSpan(
            text: context.tr('about_projText3'),
          ),
          TextSpan(
            text: 'EU Fireprime project',
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.blue,
                decoration: TextDecoration.underline), // Italica
            recognizer: TapGestureRecognizer()
              ..onTap = () async {
                Uri url = Uri.parse(
                    'https://civil-protection-knowledge-network.europa.eu/projects/fireprime');
                if (!await launchUrl(url)) {
                  throw Exception('Could not launch $url');
                }
              },
          ),
          TextSpan(
            text: context.tr('about_projText4'),
          ),
          const TextSpan(
            text: 'UCPM-101140381-FIREPRIME ',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(
            text: context.tr('about_projText5'),
          ),
          const TextSpan(
            text: 'EU Union Civil Protection Knowledge Network program.',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget customisedDevelopementText(BuildContext context) {
    return RichText(
      textAlign: TextAlign.justify,
      text: TextSpan(
        style: const TextStyle(
          fontSize: 15.0,
          color: Colors.black,
          height: 1.5,
          fontFamily: 'OpenSans',
        ),
        children: <TextSpan>[
          TextSpan(
            text: context.tr('about_devText1'),
          ),
          const TextSpan(
            text: 'Huihui Xu ',
            style: TextStyle(fontWeight: FontWeight.bold), // Italica
          ),
          TextSpan(
            text: context.tr('about_devText2'),
          ),
          const TextSpan(
            text: 'Marc Oriol ',
            style: TextStyle(fontWeight: FontWeight.bold), // Italica
          ),
          TextSpan(
            text: context.tr('and'),
          ),
          const TextSpan(
            text: 'Lidia Lopez ',
            style: TextStyle(fontWeight: FontWeight.bold), // Italica
          ),
          TextSpan(
            text: context.tr('about_devText3'),
          ),
          const TextSpan(
            text: 'Xavier Franch',
            style: TextStyle(fontWeight: FontWeight.bold), // Italica
          ),
        ],
      ),
    );
  }
}
