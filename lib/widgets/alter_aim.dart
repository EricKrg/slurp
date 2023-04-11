import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:slurp/model/NotificationPlan.dart';
import 'package:slurp/services/database.service.dart';
import 'package:slurp/services/notifications.service.dart';
import 'package:sqflite/sqflite.dart';

class AimAlert extends StatefulWidget {
  final int currentAim;
  const AimAlert({super.key, required this.currentAim});

  @override
  State<AimAlert> createState() => _AimAlertState();
}

class _AimAlertState extends State<AimAlert> {
  int newAim = 2500; // default 2.5l
  final int minAim = 1500; // cant go lower
  final int maxAim = 5000; // cant go higher

  final noticeService = LocalNoticeService();

  final border = const OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10.0)),
      borderSide: BorderSide(color: Colors.white60, width: 1));
  final _formKey = GlobalKey<FormState>();
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16.0))),
      backgroundColor: Colors.blue,
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('${widget.currentAim} ml',
              style: Theme.of(context).textTheme.displayMedium),
          Form(
            key: _formKey,
            child: TextFormField(
              keyboardType: TextInputType.number,
              inputFormatters: <TextInputFormatter>[
                FilteringTextInputFormatter.digitsOnly
              ],
              onFieldSubmitted: ((value) {
                if (_formKey.currentState!.validate()) {
                  newAim = int.parse(value);
                  Navigator.of(context).pop(newAim);
                }
              }),
              onChanged: ((value) {
                try {
                  newAim = int.parse(value);
                } catch (e) {
                  newAim = 2500;
                }
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
                  if (val < minAim) {
                    return "Your aim should not be lower then $minAim ml";
                  }

                  if (val > maxAim) {
                    return "Your aim should not be higher then $maxAim ml";
                  }
                } catch (e) {
                  return "Please enter a valid number";
                }
                return null;
              },
              autofocus: true,
              cursorColor: Colors.black,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                  fillColor: Colors.white,
                  focusedBorder: border,
                  border: border,
                  errorBorder: border,
                  suffix:
                      Text("ml", style: Theme.of(context).textTheme.bodyMedium),
                  labelStyle: Theme.of(context).textTheme.bodyMedium,
                  hintStyle: TextStyle(
                      color: Colors.black.withAlpha(100),
                      fontSize: 18,
                      fontFamily: "OdiBeeSans"),
                  errorStyle: Theme.of(context).textTheme.titleMedium,
                  errorMaxLines: 2,
                  labelText: 'New Slurp Aim',
                  hintText: "Enter your new Slurp aim here"),
            ),
          ),
        ],
      ),
      actionsPadding: const EdgeInsets.all(2),
      actionsAlignment: MainAxisAlignment.center,
      actions: <Widget>[
        IconButton(
            onPressed: (() {
              if (_formKey.currentState!.validate()) {
                Navigator.of(context).pop(newAim);
              }
            }),
            icon: const Icon(Icons.check_circle_outline_rounded,
                color: Colors.white)),
        Row(mainAxisSize: MainAxisSize.min, children: [
          Text(
            "Remind me",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          FutureBuilder(
              future: DatabaseService.instance.getById<NotificationPlan>(
                  id: "current", table: notifiactionTable),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  final currentPlan = snapshot.data!;
                  return CupertinoSwitch(
                      activeColor: Colors.black,
                      // boolean variable value
                      value: currentPlan.shouldRemind,
                      // changes the state of the switch
                      onChanged: (value) {
                        currentPlan.shouldRemind = value;
                        noticeService.setReminder(currentPlan);
                        setState(() {});
                      });
                }
                return const Text("...");
              })
        ])
      ],
    );
  }
}
