import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:slurp/model/SlurpAtom.dart';
import 'package:slurp/services/database.service.dart';

class GreatDaysCounter extends StatefulWidget {
  const GreatDaysCounter({super.key});

  @override
  State<GreatDaysCounter> createState() => _GreatDaysCounterState();
}

class _GreatDaysCounterState extends State<GreatDaysCounter> {
  final dbService = DatabaseService.instance;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  Future<List<SlurpAtom>> getPastWeek() async {
    List<SlurpAtom> res = [];
    await Future.forEach([0, 1, 2, 3, 4, 5, 6], (i) async {
      var date = DateTime.now().subtract(Duration(days: 6 - i));

      var value =
          await dbService.getById("${date.year}${date.month}${date.day}");
      if (value != null) {
        res.add(value);
      }
    });
    return res;
  }

  Future<int> getGreatDays() async {
    List<SlurpAtom> pastWeek = await getPastWeek();

    return pastWeek.where((element) => element.value >= element.aim).length;
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getGreatDays(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          List<Icon> stars = [];
          switch (snapshot.data) {
            case 1:
            case 2:
              stars = [
                const Icon(Icons.star_rate_rounded, color: Colors.white),
              ];
              break;
            case 3:
            case 4:
            case 5:
              stars = [
                const Icon(Icons.star_rate_rounded, color: Colors.white),
                const Icon(Icons.star_rate_rounded, color: Colors.white),
              ];
              break;
            case 6:
            case 7:
              stars = [
                const Icon(Icons.star_rate_rounded, color: Colors.white),
                const Icon(Icons.star_rate_rounded, color: Colors.white),
                const Icon(Icons.star_rate_rounded, color: Colors.white),
              ];
              break;
            default:
              stars = [];
          }
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: RichText(
                    text: TextSpan(
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w300,
                          fontFamily: "OdiBeeSans"),
                      children: <TextSpan>[
                        const TextSpan(text: "You had "),
                        TextSpan(
                            text: "${snapshot.data}",
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 30,
                                color: Colors.black)),
                        const TextSpan(text: " great days in the past week!"),
                      ],
                    ),
                  )),
              Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: stars,
              ),
            ],
          );
        }
        return Container();
      },
    );
  }
}
