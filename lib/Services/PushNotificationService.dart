import 'dart:async';
import 'dart:io';

import 'package:mozaconnect/DataModels/NotificationMessage.dart';
import 'package:mozaconnect/locator.dart';
import 'package:mozaconnect/Services/LocalStorageService.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class PushNotificationService {
  final LocalStorageService _localStorageService =
      locator<LocalStorageService>();

  final FirebaseMessaging _fcm = FirebaseMessaging();
  StreamSubscription _iosSubscription;

  void initialise() {
    debugPrint('PushNotificationService | initialise');
    if (Platform.isIOS) {
      _iosSubscription = _fcm.onIosSettingsRegistered.listen((data) {
        // save the token  OR subscribe to a topic here
      });

      _fcm.requestNotificationPermissions(IosNotificationSettings());
    }

    _fcm.configure(
      onMessage: (Map<String, dynamic> message) async {
        debugPrint("PushNotificationService | onMessage: $message");
        _serializeAndSave(message);
      },
      onLaunch: (Map<String, dynamic> message) async {
        debugPrint("PushNotificationService | onLaunch: $message");
        _serializeAndSave(message);
      },
      onResume: (Map<String, dynamic> message) async {
        debugPrint("PushNotificationService | onResume: $message");
        _serializeAndSave(message);
      },
    );
  }

  void _serializeAndSave(Map<String, dynamic> message) {
    debugPrint('PushNotificationService | _serializeAndSave');
    var notificationData = message['data'];

    debugPrint('_serializeAndSave | notificationData:$notificationData');

    var notification = NotificationMessage.fromMap(notificationData);

    debugPrint('_serializeAndSave | $notification');

    saveNotification(notification);
  }

  void saveNotification(NotificationMessage notification) {
    var hasNotificationBeenOpened = _localStorageService.openedNotifications
        .contains(notification.mobileAppNotificationId);

    if (!_localStorageService.hasStoredNotification &&
        !hasNotificationBeenOpened) {
      print(
          'No notification on disk. And not in opened notifications: ${_localStorageService.openedNotifications} Save $notification');
      _localStorageService.savedNotification = notification;
    } else if (_localStorageService.hasStoredNotification) {
      // TODO: Of the notification id is not equal to the one on disk and it's not in the pervious notifications
      var savedNotification = _localStorageService.savedNotification;
      var isNotificationOnDisk = notification.mobileAppNotificationId ==
          savedNotification.mobileAppNotificationId;

      if (!isNotificationOnDisk) {
        print(
            'Notification does not match one on disk. Saved notification: $savedNotification, new notification: $notification');
        if (!hasNotificationBeenOpened) {
          print(
              'Notification has not been opened yet. Id not found in ${_localStorageService.openedNotifications}');
          _localStorageService.savedNotification = notification;
        }
      }
    }
  }

  void subscribeToTopic(String topic) {
    debugPrint('PushNotificationService | subscribeToTopic - $topic');
    _fcm.subscribeToTopic(topic);
  }

  void dispose() {
     _iosSubscription?.cancel();
  }
}
