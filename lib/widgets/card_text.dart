import 'package:flutter/material.dart';

class CardText extends StatelessWidget {
  final String title;
  final String text;
  final double size;
  final Color color;
  const CardText(
      {super.key,
      required this.title,
      required this.text,
      required this.size,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: TextStyle(
            fontSize: size, color: Colors.black, fontFamily: 'OpenSans'),
        children: <TextSpan>[
          TextSpan(
              text: '$title: ',
              style: const TextStyle(
                  fontWeight: FontWeight.bold, fontFamily: 'OpenSans')),
          TextSpan(
            text: text,
            style: TextStyle(
              fontFamily: 'OpenSans',
              color: color,
            ),
          )
        ],
      ),
    );
  }
}
