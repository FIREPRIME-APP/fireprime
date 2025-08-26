import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:url_launcher/url_launcher.dart';

class AdvicesPage extends StatefulWidget {
  final String area;
  const AdvicesPage({super.key, required this.area});

  @override
  State<AdvicesPage> createState() => _AdvicesPageState();
}

class _AdvicesPageState extends State<AdvicesPage> {
  String markDownData = '';

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          context.tr('advices'),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
          overflow: TextOverflow.visible,
          softWrap: true,
        ),
      ),
      body: FutureBuilder<String>(
        future: _loadMarkdownData(context, widget.area),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Error loading data'));
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                children: [
                  MarkdownBody(
                    data: snapshot.data!,
                    styleSheet: MarkdownStyleSheet(
                      p: const TextStyle(fontSize: 15, fontFamily: 'OpenSans'),
                      h1: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      h2: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    onTapLink: (text, href, title) async {
                      if (href != null) {
                        if (await canLaunchUrl(Uri.parse(href))) {
                          await launchUrl(Uri.parse(href));
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Could not launch $href')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Future<String> _loadMarkdownData(BuildContext context, String area) async {
    final localeCode = context.locale.languageCode;
    final path = 'assets/advices/$area/$localeCode.md';
    try {
      return await rootBundle.loadString(path);
    } catch (e) {
      final defaultPath = 'assets/advices/default/$localeCode.md';
      return await rootBundle.loadString(defaultPath);
    }
  }
}
