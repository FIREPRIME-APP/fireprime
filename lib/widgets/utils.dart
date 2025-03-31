import 'package:flutter/material.dart';

class Utils {
  static Color pointerColor(double probability) {
    if (probability < 45) {
      return Colors.green;
    } else if (probability < 70) {
      return Colors.yellow;
    } else if (probability < 90) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }

  static LinearGradient linearGradientProb(double probability) {
    List<Color> colors = [Colors.lightGreen, Colors.green];
    if (probability > 45) {
      colors.add(Colors.yellowAccent);
      colors.add(Colors.yellow);
    }
    if (probability > 70) {
      colors.add(Colors.orange);
    }
    if (probability > 90) {
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
