import 'package:get_it/get_it.dart';
import '../services/analytics_service.dart';

GetIt locator = GetIt.instance;


Future<void> setupLocator() async {
  if (!locator.isRegistered<AnalyticsService>()) {
    locator.registerLazySingleton(() => AnalyticsService());
  }
}