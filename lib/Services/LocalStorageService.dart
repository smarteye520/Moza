import 'dart:async';

import 'package:mozaconnect/DataModels/NotificationMessage.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class LocalStorageService {
  static const String _appCodeKey = 'app_code';
  static const String _notificationMessageKey = 'notification_message';
  static const String _openedNotificationsKey = 'opened_notifications';

  static LocalStorageService _instance;
  static SharedPreferences _preferences;

  final StreamController<dynamic> _valueUpdateController =
      StreamController<dynamic>.broadcast();

  static Future<LocalStorageService> getInstance() async {
    if (_instance == null) {
      _instance = LocalStorageService();
    }

    if (_preferences == null) {
      _preferences = await SharedPreferences.getInstance();
    }

    return _instance;
  }

  Stream get valueUpdated => _valueUpdateController.stream;

  String get appCode => _preferences.getString(_appCodeKey);

  set appCode(String appCode) => _preferences.setString(_appCodeKey, appCode);

  bool get hasAppCode => _preferences.containsKey(_appCodeKey);

  List<String> get openedNotifications {
    var notificationList =
        _preferences.getStringList(_openedNotificationsKey) ?? List<String>();
    return notificationList;
  }

  set openedNotifications(List<String> ids) =>
      _preferences.setStringList(_openedNotificationsKey, ids);

  bool get hasStoredNotification =>
      _preferences.containsKey(_notificationMessageKey);

  NotificationMessage get savedNotification {
    var notificationPacket = _preferences.getString(_notificationMessageKey);
    try {
      if (notificationPacket != null) {
        var notificationData = json.decode(notificationPacket);
        return NotificationMessage.fromMap(notificationData);
      }

      return null;
    } catch (e) {
      print(
          'LocalStorageService - Could not parse $notificationPacket\nError::: $e');
      return null;
    }
  }

  set savedNotification(NotificationMessage notification) {
    debugPrint('LocalStorageService | SET savedNotification $notification');
    try {
      var packet = json.encode(notification.toMap());
      _preferences.setString(_notificationMessageKey, packet).then((value) {
        debugPrint('LocalStorageService | notification saved: $value');
        _valueUpdateController.add(value);
      });
    } catch (e) {
      print(
          'LocalStorageService | Could not save notification: $notification\nERROR:::$e');
    }
  }

  Future clearStoredNotification() async {
    debugPrint('LocalStorageService ~ clearStoredNotification');
    await _preferences.remove(_notificationMessageKey);
    _valueUpdateController.add(null);
  }
}
