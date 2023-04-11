import 'dart:convert';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:slurp/model/DatabaseObject.dart';

const notifiactionTable = "notificationplan";

class NotificationPlan extends DatabaseObject {
  bool shouldRemind;
  DateTime planFrom;
  final List<int> open;
  final List<int> closed;
  List<int> tmpClosed;

  NotificationPlan(
      {required this.open,
      required this.closed,
      this.shouldRemind = true,
      required this.tmpClosed,
      required this.planFrom}) {
    id = "current";
  }

  Map<int, bool> createPlan() {
    final Map<int, bool> plan = {};
    for (var o in open) {
      plan[o] = true;
    }

    for (var c in closed) {
      plan[c] = false;
    }

    for (var t in tmpClosed) {
      plan[t] = false;
    }
    return plan;
  }

  factory NotificationPlan.fromMap(Map<String, dynamic> map) {
    try {
      final String openString = map['open'] ?? "";
      final String closedString = map['closed'] ?? "";
      final String tmpString = map['tmpClosed'] ?? "";

      return NotificationPlan(
          planFrom: DateTime.fromMillisecondsSinceEpoch(map['planFrom']),
          shouldRemind: map["shouldRemind"] == 1,
          open: toIntList(openString, ","),
          closed: toIntList(closedString, ","),
          tmpClosed: toIntList(tmpString, ","));
    } catch (e) {
      throw ErrorDescription("Error creating Notification Plan from Map.");
    }
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'planFrom': planFrom.toUtc().millisecondsSinceEpoch,
      'open': open.join(","),
      'closed': closed.join(","),
      'tmpClosed': tmpClosed.join(","),
      'shouldRemind': shouldRemind
    };
  }
}

List<int> toIntList(String input, String separator) {
  if (input.isNotEmpty) {
    return input.split(",").map((e) => int.parse(e)).toList();
  }
  return [];
}
