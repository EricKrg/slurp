import 'dart:async';
import 'dart:ffi';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:slurp/model/NotificationPlan.dart';
import 'package:slurp/model/SlurpAtom.dart';
import 'package:slurp/services/database.service.dart';
import 'package:sqflite/sqflite.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzData;

// TODO:
// - add notification controller to avoid mixing controller logic with service logic

/// Note: permissions aren't requested here just to demonstrate that can be
/// done later
const DarwinInitializationSettings initializationSettingsDarwin =
    DarwinInitializationSettings(
        requestAlertPermission: true,
        requestBadgePermission: true,
        requestSoundPermission: false);
const DarwinNotificationDetails iosNotificationDetails =
    DarwinNotificationDetails(
  categoryIdentifier: "",
);
const noticeDetail = NotificationDetails(
  iOS: iosNotificationDetails,
  // android: androidDetail,
);

class ScheduledNotificationConfig {
  int hours = 15;
  String titel = "Slurp reminder!";
  String body = "Time to hydrate.";
  Future<bool> Function() shouldTrigger = (() => Future(() => true));

  ScheduledNotificationConfig(
      this.hours, this.titel, this.body, this.shouldTrigger);
}

final defaultTrigger = (() async {
  final currentHour = DateTime.now().hour;
  // todo: make night time configurable
  if (currentHour > 22 || currentHour < 5) {
    // dont remind after 10 or before 6
    return false;
  }
  // was there hydration in the last hour, if not send reminder
  final currentSlurp = await DatabaseService.instance.getById<SlurpAtom>(
      id: "${DateTime.now().year}${DateTime.now().month}${DateTime.now().day}",
      table: slurpTable);
  if (currentSlurp == null) {
    return true;
  }

  final slurpedLastHour = currentSlurp.dayMap[currentHour.toString()]! > 100;
  print(
      "should trigger ${!slurpedLastHour} ${currentSlurp.aim} ${currentSlurp.value}");
  return !slurpedLastHour && currentSlurp.value < currentSlurp.aim;
});

class LocalNoticeService {
  // Singleton of the LocalNoticeService
  static final LocalNoticeService _notificationService =
      LocalNoticeService._internal();

  final _localNotificationsPlugin = FlutterLocalNotificationsPlugin();

  ScheduledNotificationConfig? currentConfig;

  factory LocalNoticeService() {
    return _notificationService;
  }
  LocalNoticeService._internal();

  Future<void> setup() async {
    tzData.initializeTimeZones();
    // const androidSetting = AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(
        //android: androidSetting,
        iOS: initializationSettingsDarwin);

    await _localNotificationsPlugin.initialize(initSettings).then((_) {
      print('setupPlugin: setup success');
    }).catchError((Object error) {
      print('Error: $error');
    });
    // // init hourly notifications
    await scheduleNotificationsFromDBPlan(
        "Slurp reminder!", "Your hourly reminder to stay hydrated!");
  }

  Future<void> scheduleNotificationsFromDBPlan(
      String title, String body) async {
    var notificationPlan = await DatabaseService.instance
        .getById<NotificationPlan>(id: "current", table: notifiactionTable);

    if (notificationPlan == null ||
        !isToday(notificationPlan.planFrom, DateTime.now())) {
      // init notifiaction plan
      print("NO CURRENT PLAN FOR TODAY, INIT PLAN");
      notificationPlan = NotificationPlan(
          planFrom: DateTime.now(),
          tmpClosed: [],
          closed: [0, 1, 2, 3, 4, 5, 6, 23, 24],
          open: [7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22]);
      await DatabaseService.instance
          .insert<NotificationPlan>(notificationPlan, notifiactionTable);
    }

    if (notificationPlan.shouldRemind) {
      scheduleNotificationsFromPlan(notificationPlan.createPlan(), title, body);
    }
  }

  void scheduleNotificationsFromPlan(
      Map<int, bool> plan, String title, String body) {
    final now = DateTime.now();

    for (var entry in plan.entries) {
      if (entry.value) {
        final scheduleTime =
            DateTime(now.year, now.month, now.day, entry.key, 30);
        print("sheduled for ${scheduleTime.toIso8601String()}");
        addNotification(
            title, body, scheduleTime.millisecondsSinceEpoch + 1000, entry.key,
            dateTimeComponents: DateTimeComponents.time);
      }
    }
  }

  Future<void> addNotification(String title, String body, int endTime, int id,
      {String sound = '',
      String channel = 'default',
      DateTimeComponents? dateTimeComponents}) async {
    final scheduleTime =
        tz.TZDateTime.fromMillisecondsSinceEpoch(tz.local, endTime);
    print("add ${scheduleTime.toIso8601String()}");
    const DarwinNotificationDetails iosNotificationDetails =
        DarwinNotificationDetails(
      categoryIdentifier: "",
    );
    // final androidDetail = AndroidNotificationDetails(
    //     channel, // channel Id
    //     channel, // channel Name
    //     playSound: true,
    //     sound: notificationSound);

    const noticeDetail = NotificationDetails(
      iOS: iosNotificationDetails,
      // android: androidDetail,
    );
    await _localNotificationsPlugin.zonedSchedule(
        id, title, body, scheduleTime, noticeDetail,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        androidAllowWhileIdle: true,
        matchDateTimeComponents: dateTimeComponents);
    return;
  }

  Future<void> scheduleNotifications(
      int id, ScheduledNotificationConfig config, DateTime start) async {
    currentConfig = config;

    print(
        "setup schedule notificiations ${config.hours} ${start.toIso8601String()}");
    if (await config.shouldTrigger()) {
      LocalNoticeService().addNotification(
          config.titel,
          config.body,
          start.add(Duration(minutes: config.hours)).millisecondsSinceEpoch +
              1000,
          id,
          channel: 'main');
    }
  }

  void setPeriodically(
      {String titel = "Slurp reminder!",
      String body = "Time to hydrate.",
      RepeatInterval interval = RepeatInterval.daily}) {
    _localNotificationsPlugin
        .periodicallyShow(
          2,
          titel,
          body,
          interval,
          noticeDetail,
          () async => true,
        )
        .then((_) => null);
  }

  Future<void> setReminder(NotificationPlan plan) async {
    print("set reminder ${plan.shouldRemind}");

    addNotification(
        "Slurp setting",
        "switched slurp reminder ${plan.shouldRemind ? "on" : "off"}.",
        DateTime.now().millisecondsSinceEpoch + 1000,
        100);

    await DatabaseService.instance
        .update<NotificationPlan>(obj: plan, table: notifiactionTable);
    if (!plan.shouldRemind) {
      cancelAllNotification();
    } else {
      setPeriodically();
      await scheduleNotificationsFromDBPlan(
          "Slurp reminder!", "Your hourly reminder to stay hydrated!");
    }
  }

  void addTmpClosed({required int hour}) async {
    final plan = await DatabaseService.instance
        .getById<NotificationPlan>(id: "current", table: notifiactionTable);
    if (plan != null) {
      plan.tmpClosed.add(hour);
      _localNotificationsPlugin.cancel(hour);
      // update plan in db
      DatabaseService.instance
          .update<NotificationPlan>(obj: plan, table: notifiactionTable);
      // reschedule notifications
      scheduleNotificationsFromPlan(plan.createPlan(), "Slurp reminder!",
          "Your hourly reminder to stay hydrated!");
    }
  }

  void cancelAllNotification() {
    _localNotificationsPlugin.cancelAll();
  }
}

bool isToday(DateTime a, DateTime b) {
  return a.day == b.day && a.month == b.month && a.year == b.year;
}
