import 'package:summer2022/services/cache_service.dart';
import 'package:workmanager/workmanager.dart';

const fetchMail = "fetch-mail";

const _fetchFrequency = Duration(minutes: 30);

class BackgroundService {
  static void init() {
    Workmanager().initialize(callbackDispatcher);
  }

  static void registerBackgroundUpdates() {
    Workmanager().registerPeriodicTask("fetch-mail", fetchMail,
        frequency: _fetchFrequency);
  }
}

void callbackDispatcher() {
  Workmanager().executeTask((task, data) async {
    switch (task) {
      case fetchMail:
        await CacheService.updateMail(displayNotification: true);
        break;
    }

    //Return true when the task executed successfully or not
    return Future.value(true);
  });
}
