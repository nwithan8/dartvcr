enum CommonTimeFrame { never, forever }

/// A class representing a time frame.
class TimeFrame {
  /// The number of days in the time frame.
  final int days;

  /// The number of hours in the time frame.
  final int hours;

  /// The number of minutes in the time frame.
  final int minutes;

  /// The number of seconds in the time frame.
  final int seconds;

  /// A common time frame.
  final CommonTimeFrame? _commonTimeFrame;

  /// Creates a new [TimeFrame] with the given [days], [hours], [minutes] and [seconds], or [commonTimeFrame].
  TimeFrame({
    this.days = 0,
    this.hours = 0,
    this.minutes = 0,
    this.seconds = 0,
    CommonTimeFrame? commonTimeFrame,
  }) : _commonTimeFrame = commonTimeFrame;

  /// Returns true if the given [fromTime] is before the time frame (has lapsed).
  bool hasLapsed(DateTime fromTime) {
    DateTime startTimePlusFrame = _timePlusFrame(fromTime);
    return startTimePlusFrame.isBefore(DateTime.now());
  }

  /// Calculate the [DateTime] that is the given [fromTime] plus the time frame.
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

  /// A common time frame that will always be in the past.
  static TimeFrame get never =>
      TimeFrame(commonTimeFrame: CommonTimeFrame.never);

  /// A common time frame that will always be in the future.
  static TimeFrame get forever =>
      TimeFrame(commonTimeFrame: CommonTimeFrame.forever);

  /// A common time frame that is 1 calendar month (30 days).
  static TimeFrame get months1 => TimeFrame(days: 30);

  /// A common time frame that is 2 calendar months (61 days).
  static TimeFrame get months2 => TimeFrame(days: 61);

  /// A common time frame that is 3 calendar months (91 days).
  static TimeFrame get months3 => TimeFrame(days: 91);

  /// A common time frame that is 6 calendar months (182 days).
  static TimeFrame get months6 => TimeFrame(days: 182);

  /// A common time frame that is 12 calendar months (365 days).
  static TimeFrame get months12 => TimeFrame(days: 365);
}
