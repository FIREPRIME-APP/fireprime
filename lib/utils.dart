import 'package:flutter/material.dart';

class Utils {
  static Color pointerColor(double probability) {
    if (probability < 25) {
      return Colors.green;
    } else if (probability < 50) {
      return Colors.yellow;
    } else if (probability < 75) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static LinearGradient linearGradientProb(double probability) {
    List<Color> colors = [Colors.lightGreen, Colors.green];
    if (probability > 25) {
      colors.add(Colors.yellow);
    }
    if (probability > 50) {
      colors.add(Colors.orange);
    }
    if (probability > 75) {
      colors.add(Colors.red);
    }

    return LinearGradient(
      colors: colors,
    );
  }

  static textColor(double value) {
    if (value < 25) {
      return Colors.green;
    }
    if (value < 50) {
      return const Color.fromARGB(255, 210, 192, 24);
    }
    if (value < 75) {
      return Colors.orange;
    }
    return Colors.red;
  }

  static Widget cardText(String title, String text, double size) {
    return RichText(
      text: TextSpan(
          style: TextStyle(
              fontSize: size, color: Colors.black, fontFamily: 'OpenSans'),
          children: <TextSpan>[
            TextSpan(
                text: '$title: ',
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontFamily: 'OpenSans')),
            TextSpan(text: text)
          ]),
    );
  }

  static SnackBar snackBar(String text) {
    return SnackBar(
      backgroundColor: const Color.fromARGB(255, 242, 246, 255),
      content: Text(
        text,
        style: const TextStyle(
            color: Color.fromARGB(255, 86, 97, 123), fontSize: 16.0),
      ),
    );
  }
}
