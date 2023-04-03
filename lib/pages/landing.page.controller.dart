import 'package:flutter/material.dart';
import 'package:slurp/elements/particles.dart';
import 'package:slurp/model/SlurpAim.dart';
import 'package:slurp/model/SlurpAtom.dart';
import 'package:slurp/services/database.service.dart';
import 'dart:async' as async;

import 'package:slurp/services/notifications.service.dart';

class LandingPageController {
  final DatabaseService databaseService = DatabaseService.instance;

  final ValueNotifier<int> currentInput = ValueNotifier<int>(0);
  async.Timer inputTimer = async.Timer(const Duration(seconds: 0), () {});

  void incrementCounter(
      SlurpAtom slurpAtom, ParticlesInteractive particles, int rate) {
    final add = (slurpAtom.aim * rate / 1000).toInt();
    slurpAtom.setValue(slurpAtom.value + add);
    particles.increasePcount(relation: slurpAtom.value / slurpAtom.aim);
    databaseService.update<SlurpAtom>(obj: slurpAtom, table: slurpTable);

    currentInput.value = currentInput.value + add;
    inputTimer.cancel();
    inputTimer = async.Timer(const Duration(seconds: 2), () {
      currentInput.value = 0;
    });
  }

  void decrementCounter(
      SlurpAtom slurpAtom, ParticlesInteractive particles, int rate) {
    final sub = (slurpAtom.aim * rate / 1000).toInt();
    if (slurpAtom.value - sub < 0) {
      slurpAtom.setValue(0);
    } else {
      slurpAtom.setValue(slurpAtom.value - sub);
    }
    particles.decreasePcount(relation: slurpAtom.value / slurpAtom.aim);
    databaseService.update<SlurpAtom>(obj: slurpAtom, table: slurpTable);

    currentInput.value = currentInput.value - sub;
    inputTimer.cancel();
    inputTimer = async.Timer(const Duration(seconds: 2), () {
      currentInput.value = 0;
    });
  }

  Future<void> createNewSlurp() async {
    int currentAim;
    try {
      currentAim = (await databaseService.getById<SlurpAim>(
              id: "current", table: slurpAimTable))!
          .aim;
    } catch (e) {
      currentAim = 2500;
    }

    final slurpAtom = SlurpAtom(0, currentAim, DateTime.now(), {});
    await databaseService.insert<SlurpAtom>(slurpAtom, slurpTable);
  }
}
