import 'dart:async' as async;

import 'package:avatar_glow/avatar_glow.dart';
import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:slurp/elements/particles.dart';
import 'package:slurp/model/SlurpAtom.dart';
import 'package:slurp/pages/landing.page.controller.dart';
import 'package:slurp/services/notifications.service.dart';
import 'package:slurp/widgets/day_map.dart';
import 'package:slurp/widgets/information.dart';
import 'package:slurp/services/database.service.dart';
import 'package:slurp/widgets/amount_display.widget.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<StatefulWidget> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> with WidgetsBindingObserver {
  final int rate = 1;
  Offset currentPos = const Offset(0, 0);

  late SlurpAtom slurpAtom;
  final DatabaseService databaseService = DatabaseService.instance;
  final LandingPageController controller = LandingPageController();

  ParticlesInteractive particles = ParticlesInteractive(
      from: Colors.white, to: Colors.blueAccent, zoom: 5.0);

  final ValueNotifier<bool> _isSubstracting = ValueNotifier<bool>(false);

  late final ValueNotifier<int> currentInput;
  late final async.Timer inputTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    currentInput = controller.currentInput;
    inputTimer = controller.inputTimer;
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // App is resumed from the background
      print('App resumed from background');
      // refresh notification plan if needed
      if (slurpAtom.value <= slurpAtom.aim) {
        // only shedule if aim is not reached
        LocalNoticeService().scheduleNotificationsFromDBPlan(
            "Slurp reminder!", "Your hourly reminder to stay hydrated!");
      } else {
        // needs to be tested before
        // LocalNoticeService().cancelAllNotification();
      }

      if (!isToday(slurpAtom.dateTime, DateTime.now())) {
        // create a new slurp entry if the date changes between pick ups
        controller.createNewSlurp();
        setState(() {});
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<SlurpAtom?>(
        future: databaseService.getById(
            id: "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}",
            table: slurpTable),
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
            slurpAtom = SlurpAtom(0, 2500, DateTime.now(), {});
            databaseService.insert<SlurpAtom>(slurpAtom, slurpTable);
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
                            if (!isToday(slurpAtom.dateTime, DateTime.now())) {
                              // create a new slurp entry if the date changes between pick ups
                              controller.createNewSlurp();
                              setState(() {});
                            }
                            if (value) {
                              controller.decrementCounter(
                                  slurpAtom, particles, rate);
                            } else {
                              controller.incrementCounter(
                                  slurpAtom, particles, rate);
                            }
                          }),
                          onHorizontalDragUpdate: (details) {
                            if (!isToday(slurpAtom.dateTime, DateTime.now())) {
                              // create a new slurp entry if the date changes between pick ups
                              controller.createNewSlurp();
                              setState(() {});
                            }
                            particles.setGlobalPos(details.globalPosition);
                            if (value) {
                              controller.decrementCounter(
                                  slurpAtom, particles, rate);
                            } else {
                              controller.incrementCounter(
                                  slurpAtom, particles, rate);
                            }
                          },
                          child: Stack(
                            alignment: Alignment.centerLeft,
                            children: [
                              Stack(
                                alignment: Alignment.center,
                                // Center is a layout widget. It takes a single child and positions it
                                // in the middle of the parent.
                                children: [
                                  GameWidget(game: particles),
                                  Consumer<SlurpAtom>(
                                      builder: (context, slurpAtomConsumer,
                                              child) =>
                                          ValueListenableBuilder(
                                              valueListenable: currentInput,
                                              builder: ((context, value,
                                                      child) =>
                                                  AmountDisplay(
                                                      slurpAtom:
                                                          slurpAtomConsumer,
                                                      currentInput: value)))),
                                ],
                              ),
                              Consumer<SlurpAtom>(
                                  builder:
                                      (context, slurpAtomConsumer, child) =>
                                          DayMap(
                                            slurpAtom: slurpAtomConsumer,
                                          ))
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
                              builder: (context, isSub, child) {
                                return AvatarGlow(
                                    endRadius: 60,
                                    duration: const Duration(seconds: 3),
                                    curve: Curves.easeInOut,
                                    showTwoGlows: true,
                                    glowColor: isSub
                                        ? Colors.redAccent
                                        : Colors.blueAccent,
                                    child: FloatingActionButton(
                                      mini: true,
                                      enableFeedback: true,
                                      backgroundColor: Colors.white,
                                      onPressed: () {
                                        _isSubstracting.value = !isSub;
                                      },
                                      child: Icon(
                                        isSub
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
