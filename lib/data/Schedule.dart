import 'dart:convert';

import 'package:http/http.dart' as http;

enum Direction {
  toOdintsovo,
  fromOdintsovo,
  toSlavyanskiy,
  fromSlavyanskiy,
  toMolodezhnaya,
  fromMolodezhnaya
}

class Schedule {
  final Map<Direction, List<String>> weekdays;
  final Map<Direction, List<String>> saturday;
  final Map<Direction, List<String>> sunday;

  const Schedule({
    required this.weekdays,
    required this.saturday,
    required this.sunday,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {

    Map<Direction, List<String>> sunday = {};
    sunday[Direction.toOdintsovo] = List<String>.from(
        (json['To']['Sunday']['Odintsovo'] as List<dynamic>)
            .map((trip) => trip['start']));
    sunday[Direction.fromOdintsovo] = List<String>.from(
        (json['From']['Sunday']['Odintsovo'] as List<dynamic>)
            .map((trip) => trip['start']));
    sunday[Direction.toMolodezhnaya] = List<String>.from(
        (json['To']['Sunday']['Molodezhnaya'] as List<dynamic>)
            .map((trip) => trip['start']));
    sunday[Direction.fromMolodezhnaya] = List<String>.from(
        (json['From']['Sunday']['Molodezhnaya'] as List<dynamic>)
            .map((trip) => trip['start']));
    sunday[Direction.toSlavyanskiy] = List<String>.from(
        (json['To']['Sunday']['Slavyanskiy'] as List<dynamic>)
            .map((trip) => trip['start']));
    sunday[Direction.fromSlavyanskiy] = List<String>.from(
        (json['From']['Sunday']['Slavyanskiy'] as List<dynamic>)
            .map((trip) => trip['start']));

    Map<Direction, List<String>> saturday = {};
    saturday[Direction.toOdintsovo] = List<String>.from(
        (json['To']['Saturday']['Odintsovo'] as List<dynamic>)
            .map((trip) => trip['start']));
    saturday[Direction.fromOdintsovo] = List<String>.from(
        (json['From']['Saturday']['Odintsovo'] as List<dynamic>)
            .map((trip) => trip['start']));
    saturday[Direction.toMolodezhnaya] = List<String>.from(
        (json['To']['Saturday']['Molodezhnaya'] as List<dynamic>)
            .map((trip) => trip['start']));
    saturday[Direction.fromMolodezhnaya] = List<String>.from(
        (json['From']['Saturday']['Molodezhnaya'] as List<dynamic>)
            .map((trip) => trip['start']));
    saturday[Direction.toSlavyanskiy] = List<String>.from(
        (json['To']['Saturday']['Slavyanskiy'] as List<dynamic>)
            .map((trip) => trip['start']));
    saturday[Direction.fromSlavyanskiy] = List<String>.from(
        (json['From']['Saturday']['Slavyanskiy'] as List<dynamic>)
            .map((trip) => trip['start']));

    Map<Direction, List<String>> weekdays = {};
    weekdays[Direction.toOdintsovo] = List<String>.from(
        (json['To']['Weekdays']['Odintsovo'] as List<dynamic>)
            .map((trip) => trip['start']));
    weekdays[Direction.fromOdintsovo] = List<String>.from(
        (json['From']['Weekdays']['Odintsovo'] as List<dynamic>)
            .map((trip) => trip['start']));
    weekdays[Direction.toMolodezhnaya] = List<String>.from(
        (json['To']['Weekdays']['Molodezhnaya'] as List<dynamic>)
            .map((trip) => trip['start']));
    weekdays[Direction.fromMolodezhnaya] = List<String>.from(
        (json['From']['Weekdays']['Molodezhnaya'] as List<dynamic>)
            .map((trip) => trip['start']));
    weekdays[Direction.toSlavyanskiy] = List<String>.from(
        (json['To']['Weekdays']['Slavyanskiy'] as List<dynamic>)
            .map((trip) => trip['start']));
    weekdays[Direction.fromSlavyanskiy] = List<String>.from(
        (json['From']['Weekdays']['Slavyanskiy'] as List<dynamic>)
            .map((trip) => trip['start']));

    return Schedule(weekdays: weekdays, saturday: saturday, sunday: sunday);
  }
}

Future<Schedule> getSchedule() async {
  final response = await http
      .get(Uri.parse('https://rashion.net/dubovozka/schedule/schedule.json'));

  if (response.statusCode == 200) {
    // If the server did return a 200 OK response,
    // then parse the JSON.
    return Schedule.fromJson(jsonDecode(response.body));
  } else {
    // If the server did not return a 200 OK response,
    // then throw an exception.
    throw Exception('Failed to load schedule');
  }
}
