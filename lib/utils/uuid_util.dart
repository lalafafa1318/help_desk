import 'package:uuid/uuid.dart';

// Random 형태의 uuid를 발급하는 Util class 입니다.
class UUidUtil {
  static String getUUid() {
    String uuid = const Uuid().v4();

    return uuid;
  }
}
