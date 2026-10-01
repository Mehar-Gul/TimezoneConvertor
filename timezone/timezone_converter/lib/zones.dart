/// Time zone data with DST rules, no external packages required.
enum DstRule { none, usa, eu, aus, nz, mexico, chile, iran }

class CityZone {
  final String city;
  final String country;
  final String abbrStandard;
  final String abbrDaylight;
  final int standardOffsetMinutes;
  final DstRule rule;

  const CityZone({
    required this.city,
    required this.country,
    required this.abbrStandard,
    required this.abbrDaylight,
    required this.standardOffsetMinutes,
    this.rule = DstRule.none,
  });

  String get label => '$city, $country';

  bool isDst(DateTime utc) {
    switch (rule) {
      case DstRule.none:
        return false;
      case DstRule.usa:
        // 2nd Sunday March 02:00 local -> 1st Sunday November 02:00 local
        final start = _nthWeekdayUtc(utc.year, 3, DateTime.sunday, 2, 2, standardOffsetMinutes);
        final end = _nthWeekdayUtc(utc.year, 11, DateTime.sunday, 1, 2, standardOffsetMinutes + 60);
        return utc.isAfter(start) && utc.isBefore(end);
      case DstRule.eu:
        // Last Sunday March 01:00 UTC -> last Sunday October 01:00 UTC
        final start = _lastWeekdayUtc(utc.year, 3, DateTime.sunday, 1, 0);
        final end = _lastWeekdayUtc(utc.year, 10, DateTime.sunday, 1, 0);
        return utc.isAfter(start) && utc.isBefore(end);
      case DstRule.aus:
        // 1st Sunday October -> 1st Sunday April (southern hemisphere)
        final start = _nthWeekdayUtc(utc.year, 10, DateTime.sunday, 1, 2, standardOffsetMinutes);
        final end = _nthWeekdayUtc(utc.year, 4, DateTime.sunday, 1, 3, standardOffsetMinutes + 60);
        return utc.isAfter(start) || utc.isBefore(end);
      case DstRule.nz:
        // Last Sunday September -> 1st Sunday April
        final start = _lastWeekdayUtc(utc.year, 9, DateTime.sunday, 2, standardOffsetMinutes);
        final end = _nthWeekdayUtc(utc.year, 4, DateTime.sunday, 1, 3, standardOffsetMinutes + 60);
        return utc.isAfter(start) || utc.isBefore(end);
      case DstRule.mexico:
        return false; // abolished in 2022
      case DstRule.chile:
        // 1st Sunday September -> 1st Sunday April
        final start = _nthWeekdayUtc(utc.year, 9, DateTime.sunday, 1, 4, standardOffsetMinutes);
        final end = _nthWeekdayUtc(utc.year, 4, DateTime.sunday, 1, 3, standardOffsetMinutes + 60);
        return utc.isAfter(start) || utc.isBefore(end);
      case DstRule.iran:
        return false; // abolished in 2022
    }
  }

  int offsetMinutes(DateTime utc) =>
      standardOffsetMinutes + (isDst(utc) ? 60 : 0);

  String abbr(DateTime utc) => isDst(utc) ? abbrDaylight : abbrStandard;

  DateTime toLocal(DateTime utc) =>
      utc.add(Duration(minutes: offsetMinutes(utc)));

  /// Interpret [wallClock] as a local time in this zone and return UTC.
  DateTime toUtc(DateTime wallClock) {
    var guess = wallClock.subtract(Duration(minutes: standardOffsetMinutes));
    guess = wallClock.subtract(Duration(minutes: offsetMinutes(guess)));
    return guess;
  }

  static DateTime _nthWeekdayUtc(
      int year, int month, int weekday, int nth, int hourLocal, int offsetMin) {
    var d = DateTime.utc(year, month, 1);
    int count = 0;
    while (true) {
      if (d.weekday == weekday) {
        count++;
        if (count == nth) break;
      }
      d = d.add(const Duration(days: 1));
    }
    return DateTime.utc(year, month, d.day, hourLocal)
        .subtract(Duration(minutes: offsetMin));
  }

  static DateTime _lastWeekdayUtc(
      int year, int month, int weekday, int hourLocal, int offsetMin) {
    var d = DateTime.utc(year, month + 1, 1).subtract(const Duration(days: 1));
    while (d.weekday != weekday) {
      d = d.subtract(const Duration(days: 1));
    }
    return DateTime.utc(year, month, d.day, hourLocal)
        .subtract(Duration(minutes: offsetMin));
  }
}

const List<CityZone> allZones = [
  CityZone(city: 'Honolulu', country: 'USA', abbrStandard: 'HST', abbrDaylight: 'HST', standardOffsetMinutes: -600),
  CityZone(city: 'Anchorage', country: 'USA', abbrStandard: 'AKST', abbrDaylight: 'AKDT', standardOffsetMinutes: -540, rule: DstRule.usa),
  CityZone(city: 'Los Angeles', country: 'USA', abbrStandard: 'PST', abbrDaylight: 'PDT', standardOffsetMinutes: -480, rule: DstRule.usa),
  CityZone(city: 'Vancouver', country: 'Canada', abbrStandard: 'PST', abbrDaylight: 'PDT', standardOffsetMinutes: -480, rule: DstRule.usa),
  CityZone(city: 'Denver', country: 'USA', abbrStandard: 'MST', abbrDaylight: 'MDT', standardOffsetMinutes: -420, rule: DstRule.usa),
  CityZone(city: 'Phoenix', country: 'USA', abbrStandard: 'MST', abbrDaylight: 'MST', standardOffsetMinutes: -420),
  CityZone(city: 'Mexico City', country: 'Mexico', abbrStandard: 'CST', abbrDaylight: 'CST', standardOffsetMinutes: -360, rule: DstRule.mexico),
  CityZone(city: 'Chicago', country: 'USA', abbrStandard: 'CST', abbrDaylight: 'CDT', standardOffsetMinutes: -360, rule: DstRule.usa),
  CityZone(city: 'Bogota', country: 'Colombia', abbrStandard: 'COT', abbrDaylight: 'COT', standardOffsetMinutes: -300),
  CityZone(city: 'New York', country: 'USA', abbrStandard: 'EST', abbrDaylight: 'EDT', standardOffsetMinutes: -300, rule: DstRule.usa),
  CityZone(city: 'Toronto', country: 'Canada', abbrStandard: 'EST', abbrDaylight: 'EDT', standardOffsetMinutes: -300, rule: DstRule.usa),
  CityZone(city: 'Santiago', country: 'Chile', abbrStandard: 'CLT', abbrDaylight: 'CLST', standardOffsetMinutes: -240, rule: DstRule.chile),
  CityZone(city: 'Sao Paulo', country: 'Brazil', abbrStandard: 'BRT', abbrDaylight: 'BRT', standardOffsetMinutes: -180),
  CityZone(city: 'Buenos Aires', country: 'Argentina', abbrStandard: 'ART', abbrDaylight: 'ART', standardOffsetMinutes: -180),
  CityZone(city: 'Reykjavik', country: 'Iceland', abbrStandard: 'GMT', abbrDaylight: 'GMT', standardOffsetMinutes: 0),
  CityZone(city: 'London', country: 'UK', abbrStandard: 'GMT', abbrDaylight: 'BST', standardOffsetMinutes: 0, rule: DstRule.eu),
  CityZone(city: 'Lisbon', country: 'Portugal', abbrStandard: 'WET', abbrDaylight: 'WEST', standardOffsetMinutes: 0, rule: DstRule.eu),
  CityZone(city: 'Lagos', country: 'Nigeria', abbrStandard: 'WAT', abbrDaylight: 'WAT', standardOffsetMinutes: 60),
  CityZone(city: 'Paris', country: 'France', abbrStandard: 'CET', abbrDaylight: 'CEST', standardOffsetMinutes: 60, rule: DstRule.eu),
  CityZone(city: 'Berlin', country: 'Germany', abbrStandard: 'CET', abbrDaylight: 'CEST', standardOffsetMinutes: 60, rule: DstRule.eu),
  CityZone(city: 'Madrid', country: 'Spain', abbrStandard: 'CET', abbrDaylight: 'CEST', standardOffsetMinutes: 60, rule: DstRule.eu),
  CityZone(city: 'Rome', country: 'Italy', abbrStandard: 'CET', abbrDaylight: 'CEST', standardOffsetMinutes: 60, rule: DstRule.eu),
  CityZone(city: 'Amsterdam', country: 'Netherlands', abbrStandard: 'CET', abbrDaylight: 'CEST', standardOffsetMinutes: 60, rule: DstRule.eu),
  CityZone(city: 'Cairo', country: 'Egypt', abbrStandard: 'EET', abbrDaylight: 'EEST', standardOffsetMinutes: 120, rule: DstRule.eu),
  CityZone(city: 'Athens', country: 'Greece', abbrStandard: 'EET', abbrDaylight: 'EEST', standardOffsetMinutes: 120, rule: DstRule.eu),
  CityZone(city: 'Johannesburg', country: 'South Africa', abbrStandard: 'SAST', abbrDaylight: 'SAST', standardOffsetMinutes: 120),
  CityZone(city: 'Istanbul', country: 'Turkey', abbrStandard: 'TRT', abbrDaylight: 'TRT', standardOffsetMinutes: 180),
  CityZone(city: 'Moscow', country: 'Russia', abbrStandard: 'MSK', abbrDaylight: 'MSK', standardOffsetMinutes: 180),
  CityZone(city: 'Nairobi', country: 'Kenya', abbrStandard: 'EAT', abbrDaylight: 'EAT', standardOffsetMinutes: 180),
  CityZone(city: 'Tehran', country: 'Iran', abbrStandard: 'IRST', abbrDaylight: 'IRST', standardOffsetMinutes: 210, rule: DstRule.iran),
  CityZone(city: 'Dubai', country: 'UAE', abbrStandard: 'GST', abbrDaylight: 'GST', standardOffsetMinutes: 240),
  CityZone(city: 'Karachi', country: 'Pakistan', abbrStandard: 'PKT', abbrDaylight: 'PKT', standardOffsetMinutes: 300),
  CityZone(city: 'New Delhi', country: 'India', abbrStandard: 'IST', abbrDaylight: 'IST', standardOffsetMinutes: 330),
  CityZone(city: 'Mumbai', country: 'India', abbrStandard: 'IST', abbrDaylight: 'IST', standardOffsetMinutes: 330),
  CityZone(city: 'Kathmandu', country: 'Nepal', abbrStandard: 'NPT', abbrDaylight: 'NPT', standardOffsetMinutes: 345),
  CityZone(city: 'Dhaka', country: 'Bangladesh', abbrStandard: 'BST', abbrDaylight: 'BST', standardOffsetMinutes: 360),
  CityZone(city: 'Bangkok', country: 'Thailand', abbrStandard: 'ICT', abbrDaylight: 'ICT', standardOffsetMinutes: 420),
  CityZone(city: 'Jakarta', country: 'Indonesia', abbrStandard: 'WIB', abbrDaylight: 'WIB', standardOffsetMinutes: 420),
  CityZone(city: 'Singapore', country: 'Singapore', abbrStandard: 'SGT', abbrDaylight: 'SGT', standardOffsetMinutes: 480),
  CityZone(city: 'Hong Kong', country: 'China', abbrStandard: 'HKT', abbrDaylight: 'HKT', standardOffsetMinutes: 480),
  CityZone(city: 'Beijing', country: 'China', abbrStandard: 'CST', abbrDaylight: 'CST', standardOffsetMinutes: 480),
  CityZone(city: 'Perth', country: 'Australia', abbrStandard: 'AWST', abbrDaylight: 'AWST', standardOffsetMinutes: 480),
  CityZone(city: 'Tokyo', country: 'Japan', abbrStandard: 'JST', abbrDaylight: 'JST', standardOffsetMinutes: 540),
  CityZone(city: 'Seoul', country: 'South Korea', abbrStandard: 'KST', abbrDaylight: 'KST', standardOffsetMinutes: 540),
  CityZone(city: 'Brisbane', country: 'Australia', abbrStandard: 'AEST', abbrDaylight: 'AEST', standardOffsetMinutes: 600),
  CityZone(city: 'Sydney', country: 'Australia', abbrStandard: 'AEST', abbrDaylight: 'AEDT', standardOffsetMinutes: 600, rule: DstRule.aus),
  CityZone(city: 'Melbourne', country: 'Australia', abbrStandard: 'AEST', abbrDaylight: 'AEDT', standardOffsetMinutes: 600, rule: DstRule.aus),
  CityZone(city: 'Auckland', country: 'New Zealand', abbrStandard: 'NZST', abbrDaylight: 'NZDT', standardOffsetMinutes: 720, rule: DstRule.nz),
];

CityZone zoneByLabel(String label) =>
    allZones.firstWhere((z) => z.label == label, orElse: () => allZones.first);
