// apps/merchant/lib/core/services/sound_service.dart
import 'package:audioplayers/audioplayers.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SoundService {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final FlutterLocalNotificationsPlugin _notificationsPlugin = FlutterLocalNotificationsPlugin();

  SoundService() {
    _initNotifications();
  }

  void _initNotifications() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings),
    );
  }

  /// [CRITICAL ALERTS SYSTEM]: Trigger arpeggio mp3 sounds + screen wake-locks + vibration patterns
  Future<void> triggerIncomingAlert({required String type}) async {
    // 1. Force Wake Lock so Merchant tablet screens stay lit during alert modal display (Rule 28 & 29)
    await WakelockPlus.enable();

    // 2. Play matching arpeggio audio file from android res/raw/ (normalized high urgency) (Section 8)
    String soundFile = 'order_alert.mp3';
    if (type == 'booking') soundFile = 'booking_alert.mp3';
    if (type == 'delivery') soundFile = 'delivery_alert.mp3';

    await _audioPlayer.play(AssetSource('raw/$soundFile'));

    // 3. Dispatch high-importance Android notification channel with vibration patterns (Rule 10)
    const androidDetails = AndroidNotificationDetails(
      'critical_alerts_channel',
      'Critical Merchant Alerts',
      channelDescription: 'Incoming orders, bookings, and delivery assignments',
      importance: Importance.max,
      priority: Priority.high,
      playSound: true,
      sound: RawResourceAndroidNotificationSound('order_alert'),
      enableVibration: true,
      vibrationPattern: Int64List.fromList([500, 1000, 500, 1000]),
      fullScreenIntent: true, // android 12+ overlay intents
    );

    await _notificationsPlugin.show(
      1001,
      'NEW URGENT REQUEST',
      'Check tablet immediately to accept prep assignment!',
      const NotificationDetails(android: androidDetails),
    );
  }

  /// Stops alarms and releases wake locks on request validation accept/reject
  Future<void> stopAlert() async {
    await _audioPlayer.stop();
    await WakelockPlus.disable();
  }
}
