import 'package:flutter/material.dart';
import 'package:slurp/widgets/great_days_counter.dart';
import 'package:slurp/widgets/bar_chart.widget.dart';

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
