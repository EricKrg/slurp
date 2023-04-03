import 'package:flutter/foundation.dart';
import 'package:slurp/model/SlurpAim.dart';
import 'package:slurp/model/SlurpAtom.dart';
import 'package:slurp/model/NotificationPlan.dart';

abstract class DatabaseObject extends ChangeNotifier {
  late String id;
  Map<String, dynamic> toMap();
}

/// Add factory functions for every Type and every constructor you want to make available to `make`
final factories = <Type, Function>{
  SlurpAtom: (Map<String, dynamic> x) => SlurpAtom.fromMap(x),
  NotificationPlan: (Map<String, dynamic> x) => NotificationPlan.fromMap(x),
  SlurpAim: (Map<String, dynamic> x) => SlurpAim.fromMap(x),
};

T make<T>(Map<String, dynamic> x) {
  return factories[T]!(x);
}
