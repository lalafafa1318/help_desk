// 실제 처리시간을 구별하는 enum
// 정확히 말하면 분(Minute)을 구별한다.
enum MinuteClassification {
  // 00분
  ZERO_ZERO_MINUTE,

  // 05분
  ZERO_FIVE_MINUTE,

  // 10분
  TEN_MINUTE,

  // 15분
  FIFTEEN_MINUTE,

  // 20분
  TWENTY_MINUTE,

  // 25분
  TWENTY_FIVE_MINUTE,

  // 30분
  THIRTY_MINUTE,

  // 35분
  THIRTY_FIVE_MINUTE,

  // 40분
  FORTY_MINUTE,

  // 45분
  FORTY_FIVE_MINUTE,

  // 50분
  FIFTY_MINUTE,

  // 55분
  FIFTY_FIVE_MINUTE,
}

extension MinuteClassificationExtension on MinuteClassification {
  String get asText {
    switch (this) {
      case MinuteClassification.ZERO_ZERO_MINUTE:
        return '00분';
      case MinuteClassification.ZERO_FIVE_MINUTE:
        return '05분';
      case MinuteClassification.TEN_MINUTE:
        return '10분';
      case MinuteClassification.FIFTEEN_MINUTE:
        return '15분';
      case MinuteClassification.TWENTY_MINUTE:
        return '20분';
      case MinuteClassification.TWENTY_FIVE_MINUTE:
        return '25분';
      case MinuteClassification.THIRTY_MINUTE:
        return '30분';
      case MinuteClassification.THIRTY_FIVE_MINUTE:
        return '35분';
      case MinuteClassification.FORTY_MINUTE:
        return '40분';
      case MinuteClassification.FORTY_FIVE_MINUTE:
        return '45분';
      case MinuteClassification.FIFTY_MINUTE:
        return '50분';
      default:
        return '55분';
    }
  }
}
