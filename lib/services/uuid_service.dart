import 'package:uuid/uuid.dart';

class UuidService {
  static var uuid = Uuid();

  String getRandomUuid() {
    return uuid.v4();
  }
}
