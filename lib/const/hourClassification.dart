// 실제 처리시간을 구별하는 enum
// 정확히 말하면 시(Hour)을 구별한다.
enum HourClassification {
  // 01시
  ZERO_ONE_HOUR,

  // 02시
  ZERO_TWO_HOUR,

  // 03시
  ZERO_THREE_HOUR,

  // 04시
  ZERO_FOUR_HOUR,

  // 05시
  ZERO_FIVE_HOUR,

  // 06시
  ZERO_SIX_HOUR,

  // 07시
  ZERO_SEVEN_HOUR,

  // 08시
  ZERO_EIGHT_HOUR,

  // 09시
  ZERO_NINE_HOUR,

  // 10시
  TEN_HOUR,

  // 11시
  ELEVEN_HOUR,

  // 12시
  TWELVE_HOUR,

  // 13시
  THIRTEEN_HOUR,

  // 14시
  FOURTEEN_HOUR,

  // 15시
  FIFTEEN_HOUR,

  // 16시
  SIXTEEN_HOUR,

  // 17시
  SEVENTEEN_HOUR,

  // 18시
  EIGHTEEN_HOUR,

  // 19시
  NINETEEN_HOUR,

  // 20시
  TWENTY_HOUR,

  // 21시
  TWENTYONE_HOUR,

  // 22시
  TWENTYTWO_HOUR,

  // 23시
  TWENTYTHREE_HOUR,

  // 00시
  ZERO_ZERO_HOUR,
}

extension HourClassificationExtension on HourClassification {
  String get asText {
    switch (this) {
      case HourClassification.ZERO_ONE_HOUR:
        return '01시';
      case HourClassification.ZERO_TWO_HOUR:
        return '02시';
      case HourClassification.ZERO_THREE_HOUR:
        return '03시';
      case HourClassification.ZERO_FOUR_HOUR:
        return '04시';
      case HourClassification.ZERO_FIVE_HOUR:
        return '05시';
      case HourClassification.ZERO_SIX_HOUR:
        return '06시';
      case HourClassification.ZERO_SEVEN_HOUR:
        return '07시';
      case HourClassification.ZERO_EIGHT_HOUR:
        return '08시';
      case HourClassification.ZERO_NINE_HOUR:
        return '09시';
      case HourClassification.TEN_HOUR:
        return '10시';
      case HourClassification.ELEVEN_HOUR:
        return '11시';
      case HourClassification.TWELVE_HOUR:
        return '12시';
      case HourClassification.THIRTEEN_HOUR:
        return '13시';
      case HourClassification.FOURTEEN_HOUR:
        return '14시';
      case HourClassification.FIFTEEN_HOUR:
        return '15시';
      case HourClassification.SIXTEEN_HOUR:
        return '16시';
      case HourClassification.SEVENTEEN_HOUR:
        return '17시';
      case HourClassification.EIGHTEEN_HOUR:
        return '18시';
      case HourClassification.NINETEEN_HOUR:
        return '19시';
      case HourClassification.TWENTY_HOUR:
        return '20시';
      case HourClassification.TWENTYONE_HOUR:
        return '21시';
      case HourClassification.TWENTYTWO_HOUR:
        return '22시';
      case HourClassification.TWENTYTHREE_HOUR:
        return '23시';
      default:
        return '00시';
    }
  }
}
