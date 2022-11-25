import 'package:flutter/foundation.dart';

class SlurpAtom extends ChangeNotifier {
  late String id;
  int value;
  final int aim;
  final DateTime dateTime;

  SlurpAtom(this.value, this.aim, this.dateTime) {
    id = "${dateTime.year}${dateTime.month}${dateTime.day}";
    print("id $id");
  }

  void setValue(int newValue) {
    value = newValue;
    notifyListeners();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'value': value,
      'aim': aim,
      'dateTime': dateTime.toUtc().millisecondsSinceEpoch
    };
  }
}
