import 'package:slurp/model/DatabaseObject.dart';

const slurpAimTable = "slurpaim";

class SlurpAim extends DatabaseObject {
  int aim;
  SlurpAim({required this.aim}) {
    id = "current";
  }
  factory SlurpAim.fromMap(Map<String, dynamic> map) {
    final a = map["aim"] ?? 2500;
    return SlurpAim(aim: a);
  }

  @override
  Map<String, dynamic> toMap() {
    return {'id': id, 'aim': aim};
  }
}
