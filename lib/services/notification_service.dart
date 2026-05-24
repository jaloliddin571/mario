import 'dart:io';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// ── BACKGROUND HANDLER — top level bo'lishi shart ────────
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  print('BG bildiruv: ${message.notification?.title}');
  await NotificationService.showLocalNotification(message);
}

class NotificationService {
  static final _messaging = FirebaseMessaging.instance;
  static final _local = FlutterLocalNotificationsPlugin();
  static final _db = FirebaseFirestore.instance;

  // Android notification channel
  static const _channel = AndroidNotificationChannel(
    'mario_shifts',
    'Smena bildirishnomalari',
    description: 'Mario fabrika smena yangiliklari',
    importance: Importance.max,
    playSound: true,
    enableVibration: true,
  );

  // ── INITIALIZE ─────────────────────────────────────────
  static Future<void> initialize() async {
    // Background handler
    FirebaseMessaging.onBackgroundMessage(
        _firebaseMessagingBackgroundHandler);

    // Ruxsat so'rash
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
    );

    print('FCM ruxsat: ${settings.authorizationStatus}');

    if (settings.authorizationStatus !=
        AuthorizationStatus.authorized) {
      print('FCM ruxsat berilmadi');
    }

    // Android channel yaratish
    await _local
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(_channel);

    // Local notifications init
    const androidSettings =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings =
    InitializationSettings(android: androidSettings);

    await _local.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (details) {
        print('Bildiruv bosildi: ${details.payload}');
      },
      onDidReceiveBackgroundNotificationResponse:
      _onBackgroundNotificationTapped,
    );

    // Foreground bildiruv — ilova ochiq bo'lganda
    FirebaseMessaging.onMessage.listen((message) {
      print('Foreground: ${message.notification?.title}');
      showLocalNotification(message);
    });

    // Background dan ilova ochilganda
    FirebaseMessaging.onMessageOpenedApp.listen((message) {
      print('Background tap: ${message.data}');
    });

    // Ilova o'chirilgan holda tap
    final initial = await _messaging.getInitialMessage();
    if (initial != null) {
      print('Initial tap: ${initial.data}');
    }

    // Foreground da bildiruv ko'rsatish
    await FirebaseMessaging.instance
        .setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );
  }

  // ── LOCAL BILDIRUV KO'RSATISH ──────────────────────────
  static Future<void> showLocalNotification(
      RemoteMessage message) async {
    final notification = message.notification;
    if (notification == null) return;

    await _local.show(
      message.hashCode,
      notification.title,
      notification.body,
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.max,
          priority: Priority.high,
          color: const Color(0xFFC0392B),
          icon: '@mipmap/ic_launcher',
          largeIcon: const DrawableResourceAndroidBitmap(
              '@mipmap/ic_launcher'),
          styleInformation: BigTextStyleInformation(
            notification.body ?? '',
            contentTitle: notification.title,
            summaryText: 'Mario Smena',
          ),
          ticker: notification.title,
        ),
      ),
      payload: message.data.toString(),
    );
  }

  // ── TOKEN SAQLASH ──────────────────────────────────────
  static Future<void> saveTokenForUser(
      String userId) async {
    try {
      final token = await _messaging.getToken();
      if (token == null) {
        print('FCM token null');
        return;
      }

      await _db.collection('users').doc(userId).update({
        'fcmToken': token,
        'platform': Platform.isAndroid ? 'android' : 'ios',
        'tokenUpdatedAt': FieldValue.serverTimestamp(),
      });

      print('FCM token saqlandi: ${token.substring(0, 20)}...');

      // Token yangilanganda avtomatik saqlash
      _messaging.onTokenRefresh.listen((newToken) async {
        await _db
            .collection('users')
            .doc(userId)
            .update({
          'fcmToken': newToken,
          'tokenUpdatedAt': FieldValue.serverTimestamp(),
        });
        print('FCM token yangilandi');
      });
    } catch (e) {
      print('Token saqlash xato: $e');
    }
  }

  // ── 1. YANGI SMENA BILDIRUVI ───────────────────────────
  static Future<void> sendNewShiftNotification({
    required String workerId,
    required String workerName,
    required String shiftType,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final typeLabel = _typeLabel(shiftType);
      final title = '📅 Yangi smena tayinlandi';
      final body = shiftType == 'off'
          ? '$date — Dam olish kuni 🌿'
          : '$date — $typeLabel: $startTime – $endTime';

      // Firestoreda bildiruv saqlash
      await _saveNotification(
        workerId: workerId,
        workerName: workerName,
        title: title,
        body: body,
        type: 'new_shift',
      );

      // FCM orqali yuborish
      await _sendFCM(
        workerId: workerId,
        title: title,
        body: body,
        data: {
          'type': 'new_shift',
          'shiftType': shiftType,
          'date': date,
        },
      );

      print('Yangi smena bildiruvi yuborildi: $workerName');
    } catch (e) {
      print('Yangi smena bildiruv xato: $e');
    }
  }

  // ── 2. ERTANGI SMENA ESLATMASI ─────────────────────────
  static Future<void> sendTomorrowReminder({
    required String workerId,
    required String workerName,
    required String shiftType,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final typeLabel = _typeLabel(shiftType);
      const title = '⏰ Ertangi smena eslatmasi';
      final body = shiftType == 'off'
          ? 'Ertaga dam olish kuni 🌿 Yaxshi dam oling!'
          : 'Ertaga $typeLabel smena: $startTime – $endTime\n'
          'Ish vaqtiga tayyor bo\'ling!';

      await _saveNotification(
        workerId: workerId,
        workerName: workerName,
        title: title,
        body: body,
        type: 'tomorrow_reminder',
      );

      await _sendFCM(
        workerId: workerId,
        title: title,
        body: body,
        data: {
          'type': 'tomorrow_reminder',
          'shiftType': shiftType,
        },
      );

      print('Ertangi eslatma yuborildi: $workerName');
    } catch (e) {
      print('Eslatma bildiruv xato: $e');
    }
  }

  // ── 3. SMENA O'ZGARISHI BILDIRUVI ──────────────────────
  static Future<void> sendShiftUpdatedNotification({
    required String workerId,
    required String workerName,
    required String shiftType,
    required String date,
    required String startTime,
    required String endTime,
  }) async {
    try {
      final typeLabel = _typeLabel(shiftType);
      const title = '✏️ Smena o\'zgartirildi';
      final body = shiftType == 'off'
          ? '$date — Dam olish kuniga o\'zgartirildi'
          : '$date — $typeLabel: $startTime – $endTime\n'
          'Jadvalingiz yangilandi';

      await _saveNotification(
        workerId: workerId,
        workerName: workerName,
        title: title,
        body: body,
        type: 'shift_updated',
      );

      await _sendFCM(
        workerId: workerId,
        title: title,
        body: body,
        data: {
          'type': 'shift_updated',
          'shiftType': shiftType,
          'date': date,
        },
      );

      print('O\'zgartirish bildiruvi yuborildi: $workerName');
    } catch (e) {
      print('O\'zgartirish bildiruv xato: $e');
    }
  }

  // ── ERTANGI ESLATMALARNI YUBORISH ──────────────────────
  // Bu funksiyani har kuni kechqurun 20:00 da chaqirish kerak
  static Future<void> sendAllTomorrowReminders() async {
    try {
      final tomorrow = DateTime.now().add(
          const Duration(days: 1));
      final tomorrowStr =
          '${tomorrow.year}-${tomorrow.month.toString().padLeft(2, '0')}-${tomorrow.day.toString().padLeft(2, '0')}';

      // Ertangi barcha smenalarni olish
      final shifts = await _db
          .collection('shifts')
          .where('date', isEqualTo: tomorrowStr)
          .get();

      for (final shift in shifts.docs) {
        final data = shift.data();
        final workerId = data['workerId'] ?? '';
        final workerName = data['workerName'] ?? '';
        final shiftType = data['type'] ?? '';
        final startTime = data['startTime'] ?? '';
        final endTime = data['endTime'] ?? '';

        if (workerId.isNotEmpty) {
          await sendTomorrowReminder(
            workerId: workerId,
            workerName: workerName,
            shiftType: shiftType,
            startTime: startTime,
            endTime: endTime,
          );
          // Rate limit uchun kichik kutish
          await Future.delayed(
              const Duration(milliseconds: 100));
        }
      }

      print('Barcha ertangi eslatmalar yuborildi: '
          '${shifts.docs.length} ta');
    } catch (e) {
      print('Ertangi eslatmalar xato: $e');
    }
  }

  // ── FCM YUBORISH ───────────────────────────────────────
  static Future<void> _sendFCM({
    required String workerId,
    required String title,
    required String body,
    required Map<String, String> data,
  }) async {
    try {
      // Ishchining FCM tokenini olish
      final userDoc = await _db
          .collection('users')
          .doc(workerId)
          .get();

      final token =
      userDoc.data()?['fcmToken'] as String?;
      if (token == null || token.isEmpty) {
        print('$workerId uchun FCM token topilmadi');
        return;
      }

      // FCM message Firestoreda saqlash
      // Firebase Cloud Functions bu ni o'qib yuboradi
      await _db.collection('fcm_queue').add({
        'token': token,
        'title': title,
        'body': body,
        'data': data,
        'workerId': workerId,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
      });

      print('FCM queue ga qo\'shildi: $workerId');
    } catch (e) {
      print('FCM yuborish xato: $e');
    }
  }

  // ── FIRESTORE GA BILDIRUV SAQLASH ─────────────────────
  static Future<void> _saveNotification({
    required String workerId,
    required String workerName,
    required String title,
    required String body,
    required String type,
  }) async {
    await _db.collection('notifications').add({
      'workerId': workerId,
      'workerName': workerName,
      'title': title,
      'body': body,
      'type': type,
      'read': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // ── ADMIN BILDIRUVI ────────────────────────────────────
  static Future<void> sendAdminNotification({
    required String title,
    required String body,
    required String type,
  }) async {
    // Barcha adminlarga bildiruv
    final admins = await _db
        .collection('users')
        .where('role', isEqualTo: 'admin')
        .get();

    for (final admin in admins.docs) {
      await _saveNotification(
        workerId: admin.id,
        workerName: 'Admin',
        title: title,
        body: body,
        type: type,
      );
    }
  }

  // ── YORDAMCHI ──────────────────────────────────────────
  static String _typeLabel(String type) {
    switch (type) {
      case 'morning': return 'Kunduzgi';
      case 'night': return 'Tungi';
      case 'half': return 'Yarim smena';
      case 'off': return 'Dam olish';
      default: return 'Smena';
    }
  }
}

@pragma('vm:entry-point')
void _onBackgroundNotificationTapped(
    NotificationResponse details) {
  print('BG tap: ${details.payload}');
}