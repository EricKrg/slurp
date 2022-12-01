import 'package:flutter/material.dart';
import 'package:slurp/widgets/GreatDaysCounter.dart';
import 'package:slurp/widgets/bar-chart.widget.dart';

class InformationWidget extends StatelessWidget {
  const InformationWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.blue,
      child: Column(children: const [PastWeekBarChart(), GreatDaysCounter()]),
    );
  }
}
