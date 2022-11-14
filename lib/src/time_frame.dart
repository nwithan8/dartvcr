enum CommonTimeFrame {
  never,
  forever
}

class TimeFrame {
  final int days;
  final int hours;
  final int minutes;
  final int seconds;
  final CommonTimeFrame? _commonTimeFrame;

  TimeFrame({
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    CommonTimeFrame? commonTimeFrame,
  }) : _commonTimeFrame = commonTimeFrame;

  bool hasLapsed(DateTime fromTime) {
    DateTime startTimePlusFrame = _timePlusFrame(fromTime);
    return startTimePlusFrame.isBefore(DateTime.now());
  }

  DateTime _timePlusFrame(DateTime fromTime) {
    if (_commonTimeFrame == CommonTimeFrame.forever) {
      return DateTime(9999); // will always be in the future
    } else if (_commonTimeFrame == CommonTimeFrame.forever) {
      return DateTime(0); // will always be in the past
    }
    return fromTime.add(Duration(
      days: days,
      hours: hours,
      minutes: minutes,
      seconds: seconds,
    ));
  }

  static TimeFrame get never => TimeFrame(commonTimeFrame: CommonTimeFrame.never);

  static TimeFrame get forever => TimeFrame(commonTimeFrame: CommonTimeFrame.forever);

  static TimeFrame get months1 => TimeFrame(days: 30);

  static TimeFrame get months2 => TimeFrame(days: 61);

  static TimeFrame get months3 => TimeFrame(days: 91);

  static TimeFrame get months6 => TimeFrame(days: 182);

  static TimeFrame get months12 => TimeFrame(days: 365);
}

