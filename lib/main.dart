import 'dart:convert';

import 'package:dubovozka/data/schedule_provider.dart';
import 'package:dubovozka/widgets/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'data/Schedule.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

Future<http.Response> postDeviceId(String id) {
  return http.post(
    Uri.parse('https://dubovozka-notification.herokuapp.com/store_device'),
    headers: <String, String>{
      'Content-Type': 'application/json; charset=UTF-8',
    },
    body: jsonEncode(<String, String>{
      'device_id': id,
    }),
  );
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // If you're going to use other Firebase services in the background, such as Firestore,
  // make sure you call `initializeApp` before using other Firebase services.
  await Firebase.initializeApp();

  print("Handling a background message: ${message.messageId}");
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging messaging = FirebaseMessaging.instance;
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  NotificationSettings settings = await messaging.requestPermission(
    alert: true,
    announcement: false,
    badge: true,
    carPlay: false,
    criticalAlert: false,
    provisional: false,
    sound: true,
  );

  print('User granted permission: ${settings.authorizationStatus}');

  FirebaseMessaging.onMessage.listen((RemoteMessage message) {
    print('Got a message whilst in the foreground!');
    print('Message data: ${message.data}');

    if (message.notification != null) {
      print('Message also contained a notification: ${message.notification}');
    }
  });

  final deviceToken = await FirebaseMessaging.instance.getToken();
  final result = await postDeviceId(deviceToken!);
  print('response - ' + result.body);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _pickedDate = ref.watch(pickedDateProvider.notifier);

    return MaterialApp(
      title: 'Dubovozka',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
      ),
      home: Scaffold(
        appBar: CalendarAppBar(
          onDateChanged: (value) => _pickedDate.state = value,
          firstDate: DateTime.now().subtract(const Duration(days: 7)),
          lastDate: DateTime.now().add(const Duration(days: 14)),
          selectedDate: DateTime.now(),
          fullCalendar: true,
          white: Colors.white,
          black: Colors.black,
          accent: Colors.lightGreen,
          backButton: false,
          onBack: () {},
          locale: 'ru',
        ),
        body: const SafeArea(
          child: ScheduleWidget(),
        ),
      ),
    );
  }
}

class ScheduleWidget extends ConsumerStatefulWidget {
  const ScheduleWidget({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState createState() => _ScheduleWidgetState();
}

class _ScheduleWidgetState extends ConsumerState<ScheduleWidget> {
  late Future<Schedule> schedule;

  @override
  void initState() {
    schedule = getSchedule();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final _pickedDate = ref.watch(pickedDateProvider);
    print('VIBRANNAYA ATA');
    print(_pickedDate);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: FutureBuilder<Schedule>(
        future: schedule,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            if (_pickedDate.weekday <= 5) {
            return BusSchedule(schedule: snapshot.data!.weekdays);
            }
            if (_pickedDate.weekday == 6) {
              return BusSchedule(schedule: snapshot.data?.saturday ?? {});
            }
            if (_pickedDate.weekday == 7) {
              return BusSchedule(schedule: snapshot.data?.sunday ?? {});
            }
          } else if (snapshot.hasError) {
            return Text('${snapshot.error}');
          }
          // By default, show a loading spinner.
          return const CircularProgressIndicator();
        },
      ),
    );
  }
}

class BusSchedule extends ConsumerWidget {
  const BusSchedule({Key? key, required this.schedule}) : super(key: key);

  final Map<Direction, List<String>> schedule;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    List<List<Widget>> _getScheduleLists(List<String> items) {
      List<Widget> col1 = [];
      List<Widget> col2 = [];
      List<Widget> col3 = [];
      List<Widget> col4 = [];

      int spot = (items.length / 4).round();

      print(items.getRange(0, spot));

      col1.addAll(items.getRange(0, spot).map((e) => Text(e)));
      col2.addAll(items.getRange(spot, spot * 2).map((e) => Text(e)));
      col3.addAll(items.getRange(spot * 2, spot * 3).map((e) => Text(e)));
      col4.addAll(items.getRange(spot * 3, items.length).map((e) => Text(e)));

      return [col1, col2, col3, col4];
    }

    return SizedBox(
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height - 240,
      child: ListView(
        children: [
          Text('В Одинцово:'),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children:
                      _getScheduleLists(schedule[Direction.toOdintsovo]!)[0],
                ),
                Column(
                  children:
                      _getScheduleLists(schedule[Direction.toOdintsovo]!)[1],
                ),
                Column(
                  children:
                      _getScheduleLists(schedule[Direction.toOdintsovo]!)[2],
                ),
                Column(
                  children:
                      _getScheduleLists(schedule[Direction.toOdintsovo]!)[3],
                )
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Text('Из Одинцово:'),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromOdintsovo]!)[0],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromOdintsovo]!)[1],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromOdintsovo]!)[2],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromOdintsovo]!)[3],
                )
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Text('На Молодежную:'),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.toMolodezhnaya]!)[0],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.toMolodezhnaya]!)[1],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.toMolodezhnaya]!)[2],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.toMolodezhnaya]!)[3],
                )
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Text('От Молодежной:'),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromMolodezhnaya]!)[0],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromMolodezhnaya]!)[1],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromMolodezhnaya]!)[2],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromMolodezhnaya]!)[3],
                )
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Text('На Славянский Бульвар:'),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.toSlavyanskiy]!)[0],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.toSlavyanskiy]!)[1],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.toSlavyanskiy]!)[2],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.toSlavyanskiy]!)[3],
                )
              ],
            ),
          ),

          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(),
          ),
          Text('От Славянского Бульвара:'),
          SizedBox(height: 8),
          SizedBox(
            width: MediaQuery.of(context).size.width,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromSlavyanskiy]!)[0],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromSlavyanskiy]!)[1],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromSlavyanskiy]!)[2],
                ),
                Column(
                  children:
                  _getScheduleLists(schedule[Direction.fromSlavyanskiy]!)[3],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
