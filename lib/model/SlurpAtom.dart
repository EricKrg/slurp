import 'package:flutter/foundation.dart';

class SlurpAtom extends ChangeNotifier {
  late String id;
  int value;
  int aim;
  final DateTime dateTime;

  SlurpAtom(this.value, this.aim, this.dateTime) {
    id = "${dateTime.year}${dateTime.month}${dateTime.day}";
    print("id $id");
  }

  void setValue(int newValue) {
    value = newValue;
    notifyListeners();
  }

  void setAim(int newAim) {
    aim = newAim;
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
