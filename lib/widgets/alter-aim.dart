import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';

class AimAlert extends StatelessWidget {
  final int currentAim;
  int newAim;
  AimAlert({super.key, required this.currentAim, this.newAim = 2500});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      // title: const Text('Set a new Slurp aim'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$currentAim ml', style: Theme.of(context).textTheme.bodyText1),
          TextFormField(
            keyboardType: TextInputType.number,
            inputFormatters: <TextInputFormatter>[
              FilteringTextInputFormatter.digitsOnly
            ],
            //onChanged: ((value) => newAim = value),
            onFieldSubmitted: ((value) {
              newAim = int.parse(value);
              Navigator.of(context).pop(newAim);
            }),
            validator: (value) {
              if (value == null) {
                return "Please enter your new aim.";
              }
              if (value.isEmpty) {
                return "Please enter your new aim.";
              }
              try {
                final val = int.parse(value);
                if (val < 2000) {
                  return "Your aim should not be lower then 2000ml";
                }
              } catch (e) {
                return "Please enter a valid number";
              }
              return null;
            },
            decoration: const InputDecoration(
                labelText: 'New Slurp Aim',
                hintText: "Enter your new Slurp aim here"),
          ),
        ],
      ),
      actions: <Widget>[
        TextButton(
          style: TextButton.styleFrom(
            textStyle: Theme.of(context).textTheme.labelLarge,
          ),
          child: const Text('Ok'),
          onPressed: () {
            Navigator.of(context).pop(newAim);
          },
        ),
      ],
    );
  }
}
