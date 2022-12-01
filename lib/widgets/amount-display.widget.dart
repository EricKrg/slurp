import 'package:flutter/material.dart';

class AmountDisplay extends StatelessWidget {
  final int aim;
  final int currentValue;
  final int currentInput;
  const AmountDisplay(
      {super.key,
      required this.aim,
      required this.currentValue,
      required this.currentInput});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.max,
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 60),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: [
              SizedBox(
                width: 80,
                child: Text(
                  "$currentValue",
                  style: const TextStyle(
                      color: Colors.lightBlue,
                      fontSize: 40,
                      fontFamily: "OdiBeeSans"),
                ),
              ),
              const Text(
                "ml",
                style: TextStyle(
                    color: Colors.blue, fontSize: 40, fontFamily: "OdiBeeSans"),
              ),
            ],
          ),
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedOpacity(
                opacity: currentValue >= aim ? 1 : 1,
                duration: const Duration(seconds: 1),
                child: Text(
                  "$aim ml",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontFamily: "OdiBeeSans"),
                )),
            AnimatedOpacity(
                opacity: currentValue >= aim ? 1 : 0,
                duration: const Duration(seconds: 1),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 20,
                )),
          ],
        ),
        Padding(
          padding: const EdgeInsets.all(12),
          child: AnimatedOpacity(
              opacity: currentInput == 0 ? 0 : 1,
              duration: const Duration(seconds: 1),
              child: Text(
                "$currentInput ml",
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 40,
                    fontFamily: "OdiBeeSans"),
              )),
        ),
      ],
    );
  }
}
