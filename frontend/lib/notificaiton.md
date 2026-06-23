import 'package:firebase_messaging/firebase_messaging.dart';

class NotificationService {
static Future<void> subscribeToBrakeAlerts() async {
FirebaseMessaging messaging = FirebaseMessaging.instance;

    // Permission maangein (iOS ke liye zaroori hai)
    await messaging.requestPermission();

    // Backend par jo topic name diya tha wahi yahan use karein
    await messaging.subscribeToTopic('brake_alerts');
    print("✅ Subscribed to Brake Alerts Topic");
}
}


class AppNotification {
final int id;
final String title;
final String body;
final bool isRead;
final String type;

AppNotification({required this.id, required this.title, required this.body, required this.isRead, required this.type});

factory AppNotification.fromJson(Map<String, dynamic> json) {
return AppNotification(
id: json['id'],
title: json['title'],
body: json['body'],
isRead: json['is_read'] == 1 || json['is_read'] == true,
type: json['type'],
);
}
}



<<<<<<<<<<<<<<<<<


FirebaseMessaging.onMessage.listen((RemoteMessage message) {
print("Got a message in foreground!");
if (message.notification != null) {
// Yahan aap ek SnackBar ya Local Notification pop-up dikha sakte hain
print("Title: ${message.notification!.title}");
}
});


<<<<<<<<<<<<<<<<<<<<<<


Future<List<AppNotification>> fetchNotifications() async {
final response = await http.get(
Uri.parse('https://aapka-railway-url.com/smart_coach_api/api/notifications'),
headers: {
'Authorization': 'Bearer $yourStoredToken', // Login waala token yahan jayega
},
);

if (response.statusCode == 200) {
List data = json.decode(response.body)['data'];
return data.map((n) => AppNotification.fromJson(n)).toList();
} else {
throw Exception('Failed to load notifications');
}
}


