import 'dart:collection';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:slurp/model/SlurpAtom.dart';

class DayMap extends StatefulWidget {
  final SlurpAtom slurpAtom;
  const DayMap({super.key, required this.slurpAtom});

  @override
  State<DayMap> createState() => _DayMapState();
}

class _DayMapState extends State<DayMap> {
  final ValueNotifier<bool> currentTap = ValueNotifier<bool>(false);

  double _minLength(int value, int aim, {bool normalize = false}) {
    double len = 0;
    if (normalize) {
      len = sqrt((value.toDouble() / aim)) * 500;
      return len > 120 ? len : 120;
    } else {
      len = (value.toDouble() / aim) * 120;
      return len <= 0 ? 0 : len;
    }
  }

  @override
  Widget build(BuildContext context) {
    List<int> hours = Iterable<int>.generate(24).toList();
    for (final i in hours) {
      widget.slurpAtom.dayMap.putIfAbsent("$i", () => 0);
    }
    List<Widget> entries = [];
    var sortedByKeyMap =
        SplayTreeMap<String, int>.from(widget.slurpAtom.dayMap, (k1, k2) {
      return int.parse(k1).compareTo(int.parse(k2));
    });
    sortedByKeyMap.forEach(
      (key, value) {
        entries.add(
          GestureDetector(
              onTap: () {
                currentTap.value = !currentTap.value;
              },
              child: ValueListenableBuilder(
                valueListenable: currentTap,
                builder: ((context, tapKey, child) {
                  final show = tapKey && value > 0;
                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    curve: Curves.linear,
                    height: show ? 30 : 15,
                    width: show
                        ? _minLength(value, widget.slurpAtom.aim,
                            normalize: true)
                        : _minLength(value, widget.slurpAtom.aim),
                    decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                            bottomRight: Radius.circular(5),
                            topRight: Radius.circular(5)),
                        color: show ? Colors.blue : Colors.blue),
                    child: AnimatedOpacity(
                      opacity: show ? 1 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: show
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(left: 4.0),
                                    child: Text("$key h",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText2),
                                  ),
                                ),
                                Flexible(
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 4.0),
                                    child: Text("+$value ml",
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyText1),
                                  ),
                                )
                              ],
                            )
                          : null,
                    ),
                  );
                }),
              )),
        );
      },
    );

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: entries);
  }
}
