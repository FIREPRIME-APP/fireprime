import 'package:fireprime/constants.dart';
import 'package:fireprime/model/house.dart';
import 'package:flutter/material.dart';

class ButtonCard extends StatelessWidget {
  final House currentHouse;
  final String description;
  final String buttonText;
  final Color cardColor;
  final VoidCallback onPressed;
  final bool enabled;

  const ButtonCard({
    super.key,
    required this.currentHouse,
    required this.description,
    required this.buttonText,
    required this.cardColor,
    required this.onPressed,
    required this.enabled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Constants.blueDark,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 0,
            blurRadius: 5,
            offset: const Offset(0, 7),
          ),
        ],
      ),
      child: Card(
        color: cardColor,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                description,
                style: const TextStyle(
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Center(
                child: Container(
                  height: 50,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white, width: 3),
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: const [
                      BoxShadow(
                        color: Colors.black26,
                        spreadRadius: 0,
                        blurRadius: 5,
                        offset: Offset(0, 7),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 112, 126, 158),
                      disabledBackgroundColor: Colors.grey.shade400,
                    ),
                    onPressed: enabled ? onPressed : null,
                    child: Text(
                      buttonText,
                      style: TextStyle(
                        color: enabled ? Colors.black : Colors.black38,
                        fontSize: 16,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
