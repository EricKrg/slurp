import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:slurp/model/DatabaseObject.dart';
import 'package:slurp/services/notifications.service.dart';

const slurpTable = "slurp";
const hourlyAim = 200;

class SlurpAtom extends DatabaseObject {
  int value;
  int aim;
  final DateTime dateTime;

  final Map<String, int> dayMap;

  SlurpAtom(this.value, this.aim, this.dateTime, this.dayMap) {
    id = "${dateTime.year}${dateTime.month}${dateTime.day}";
  }

  void setValue(int newValue) {
    final currentH = "${DateTime.now().hour}";
    final update = newValue - value;
    dayMap.putIfAbsent(currentH, () => update);
    if (dayMap.containsKey(currentH)) {
      final currentHDone = dayMap[currentH]! > hourlyAim;
      dayMap[currentH] = dayMap[currentH]! + update;

      // notification
      if (dayMap[currentH]! > 200 && !currentHDone) {
        LocalNoticeService().addNotification(
            "Success",
            "You fullfilled your hourly hydration goal",
            DateTime.now().millisecondsSinceEpoch + 1000,
            101);
        LocalNoticeService().addTmpClosed(hour: int.parse(currentH));
      }
    }

    value = newValue;
    // print("slurp set");
    // print(this.toMap());
    notifyListeners();
  }

  void setAim(int newAim) {
    aim = newAim;
    notifyListeners();
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'aim': aim,
      'dateTime': dateTime.toUtc().millisecondsSinceEpoch,
      'dayMap': json.encode(dayMap)
    };
  }

  factory SlurpAtom.fromMap(Map<String, dynamic> map) {
    Map<String, int> dayMap = {};
    try {
      final Map<String, dynamic> dmap = json.decode(map['dayMap']);
      dayMap = dmap.map((key, value) {
        return MapEntry(key, value);
      });
    } catch (e) {
      print("error decoding");
      print(e);
    }
    return SlurpAtom(map['value'], map['aim'],
        DateTime.fromMillisecondsSinceEpoch(map['dateTime']), dayMap);
  }
}
