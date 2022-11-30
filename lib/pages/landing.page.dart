import 'package:avatar_glow/avatar_glow.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slurp/elements/particles.dart';
import 'package:slurp/model/SlurpAtom.dart';
import 'package:slurp/widgets/information.dart';
import 'package:slurp/services/database.service.dart';
import 'package:slurp/widgets/amount-display.widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<StatefulWidget> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final int rate = 1;
  Offset currentPos = Offset(0, 0);

  late SlurpAtom slurpAtom;
  final DatabaseService databaseService = DatabaseService.instance;

  ParticlesInteractiveExample particles = ParticlesInteractiveExample(
      from: Colors.white, to: Colors.blueAccent, zoom: 5.0);

  final ValueNotifier<bool> _isSubstracting = ValueNotifier<bool>(false);

  @override
  void initState() {
    super.initState();
  }

  void _incrementCounter(SlurpAtom slurpAtom) {
    final add = (slurpAtom.aim * rate / 1000).toInt();
    slurpAtom.setValue(slurpAtom.value + add);
    particles.increasePcount(relation: slurpAtom.value / slurpAtom.aim);
    databaseService.update(slurpAtom);
  }

  void _decrementCounter(SlurpAtom slurpAtom) {
    final sub = (slurpAtom.aim * rate / 1000).toInt();
    if (slurpAtom.value - sub < 0) {
      slurpAtom.setValue(0);
    } else {
      slurpAtom.setValue(slurpAtom.value - sub);
    }
    particles.decreasePcount(relation: slurpAtom.value / slurpAtom.aim);
    databaseService.update(slurpAtom);
  }

  void _setCounter(int count) {
    particles.setPcount(count);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SlurpAtom?>(
        future: databaseService.getById(
            "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}"),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: CircularProgressIndicator());
          }
          if (snapshot.hasData &&
              snapshot.connectionState == ConnectionState.done) {
            slurpAtom = snapshot.data!;
            particles
                .setPcount((slurpAtom.value / slurpAtom.aim * 1000).floor());
          } else {
            slurpAtom = SlurpAtom(0, 2500, DateTime.now());
            databaseService.insert(slurpAtom);
          }
          return ChangeNotifierProvider(
              create: ((context) => slurpAtom),
              child: Scaffold(
                  body: ValueListenableBuilder(
                      valueListenable: _isSubstracting,
                      builder: (context, value, child) {
                        return GestureDetector(
                          onDoubleTap: () {
                            showModalBottomSheet<void>(
                                context: context,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.0),
                                ),
                                clipBehavior: Clip.antiAlias,
                                builder: (BuildContext context) {
                                  return InformationWidget(
                                    key: UniqueKey(),
                                  );
                                });
                          },
                          onVerticalDragUpdate: ((details) {
                            particles.setGlobalPos(details.globalPosition);
                            if (value) {
                              _decrementCounter(slurpAtom);
                            } else {
                              _incrementCounter(slurpAtom);
                            }
                          }),
                          onHorizontalDragUpdate: (details) {
                            particles.setGlobalPos(details.globalPosition);
                            if (value) {
                              _decrementCounter(slurpAtom);
                            } else {
                              _incrementCounter(slurpAtom);
                            }
                          },
                          child: Stack(
                            alignment: Alignment.center,
                            // Center is a layout widget. It takes a single child and positions it
                            // in the middle of the parent.
                            children: [
                              GameWidget(game: particles),
                              Consumer<SlurpAtom>(
                                  builder:
                                      (context, slurpAtomConsumer, child) =>
                                          AmountDisplay(
                                              aim: slurpAtom.aim,
                                              currentValue:
                                                  slurpAtomConsumer.value))
                            ],
                          ),
                        );
                      }),
                  floatingActionButtonLocation:
                      FloatingActionButtonLocation.centerDocked,
                  floatingActionButton: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: <Widget>[
                          ValueListenableBuilder(
                              valueListenable: _isSubstracting,
                              builder: (context, value, child) {
                                return AvatarGlow(
                                    endRadius: 60,
                                    child: FloatingActionButton(
                                      mini: true,
                                      enableFeedback: true,
                                      backgroundColor: Colors.lightBlue,
                                      onPressed: () {
                                        _isSubstracting.value = !value;
                                      },
                                      child: Icon(
                                        value
                                            ? Icons.remove_rounded
                                            : Icons.add_rounded,
                                        color: Colors.black,
                                      ),
                                    ));
                              })
                        ],
                      ))));
        });
  }
}
