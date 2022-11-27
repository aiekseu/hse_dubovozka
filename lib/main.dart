import 'package:dubovozka/app/schedule/data/schedule_provider.dart';
import 'package:dubovozka/app/schedule/widgets/calendar_appbar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/services.dart';


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
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Your device token:',
              ),
              DeviceToken()
            ],
          ),
        ),
      ),
    );
  }
}

class DeviceToken extends StatefulWidget {
  const DeviceToken({Key? key}) : super(key: key);

  @override
  State<DeviceToken> createState() => _DeviceTokenState();
}

class _DeviceTokenState extends State<DeviceToken> {
  late Future<String?> token;

  @override
  void initState() {
    token = FirebaseMessaging.instance.getToken();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(16.0),
      child: FutureBuilder<String?>(
        future: token,
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return GestureDetector(
              onTap: () async {await Clipboard.setData(ClipboardData(text: snapshot.data!));},
                child: Text(snapshot.data!),
            );
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
