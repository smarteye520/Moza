import 'package:mozaconnect/Services/LocalStorageService.dart';
import 'package:mozaconnect/Services/PushNotificationService.dart';
import 'package:get_it/get_it.dart';

GetIt locator = GetIt();

Future setupLocator() async {
  var instance = await LocalStorageService.getInstance();
  locator.registerSingleton<LocalStorageService>(instance);

  var pushNotificationService = PushNotificationService();
  pushNotificationService.initialise();
  locator.registerSingleton<PushNotificationService>(pushNotificationService);
}
