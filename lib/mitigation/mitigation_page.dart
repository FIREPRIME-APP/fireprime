import 'package:fireprime/house/house_list_page.dart';
import 'package:flutter/material.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

class MitigationPage extends StatefulWidget {
  final List<dynamic> mitigationActions;
  final String mitigationTitle;

  const MitigationPage(
      {super.key,
      required this.mitigationActions,
      required this.mitigationTitle});

  @override
  State<MitigationPage> createState() => _MitigationPageState();
}

class _MitigationPageState extends State<MitigationPage> {
  final PageController _pageController = PageController();

  @override
  Widget build(BuildContext context) {
    final numPages = widget.mitigationActions.length;

    print(numPages);

    print(widget.mitigationActions);
    return Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
              child: IconButton(
                icon: const Icon(Icons.home),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (BuildContext context) {
                        return const HouseListPage();
                      },
                    ),
                  );
                },
              ),
            )
          ],
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(25, 25, 25, 5),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  widget.mitigationTitle,
                  style: Theme.of(context).textTheme.titleLarge!,
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16.0, vertical: 5),
                child: PageView.builder(
                  controller: _pageController,
                  itemCount: numPages,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 15.0, vertical: 8.0),
                              child: Text(
                                widget.mitigationActions[index]['title'],
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'OpenSans',
                                    fontSize: 24),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20.0, vertical: 5.0),
                              child: Text(
                                widget.mitigationActions[index]['description'],
                                style: const TextStyle(
                                    fontFamily: 'OpenSans', fontSize: 16),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(5),
              child: SmoothPageIndicator(
                controller: _pageController,
                count: numPages,
                effect: WormEffect(
                  dotWidth: 10,
                  dotHeight: 10,
                  activeDotColor: const Color.fromARGB(255, 86, 97, 123),
                  dotColor: Colors.grey.withOpacity(0.4),
                ),
              ),
            ),
            const SizedBox(
              height: 50,
            ),
          ],
        ));
  }
}
