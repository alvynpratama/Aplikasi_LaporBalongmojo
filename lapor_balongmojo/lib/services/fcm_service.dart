import 'package:firebase_messaging/firebase_messaging.dart';

// Handler background (tetap sama)
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class FcmService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  static const String _topicName = 'emergency_alerts';

  Future<void> initialize() async {
    try {
      // 1. Minta Izin
      NotificationSettings settings = await _firebaseMessaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      if (settings.authorizationStatus == AuthorizationStatus.authorized) {
        print('Izin notifikasi diberikan!');

        // 2. Listener Foreground
        FirebaseMessaging.onMessage.listen((RemoteMessage message) {
          print('Notifikasi Foreground: ${message.notification?.title}');
        });

        // 3. Listener Background
        FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

        // --- BAGIAN PENTING: Bungkus Subscribe dengan Try-Catch ---
        // Agar jika gagal (SERVICE_NOT_AVAILABLE), aplikasi TIDAK MACET.
        try {
          await _firebaseMessaging.subscribeToTopic(_topicName);
          print('Berhasil berlangganan topik $_topicName');
        } catch (topicError) {
          // Kita hanya print error, tapi biarkan fungsi initialize selesai
          print('PERINGATAN: Gagal subscribe topik (Mungkin masalah emulator): $topicError');
        }
        // ----------------------------------------------------------
      }
    } catch (e) {
      print('Error inisialisasi FCM: $e');
    }
  }

  Future<void> unsubscribeFromTopic() async {
    try {
      await _firebaseMessaging.unsubscribeFromTopic(_topicName);
      print('Berhenti berlangganan topik $_topicName.');
    } catch (e) {
      print('Gagal berhenti berlangganan: $e');
    }
  }
}