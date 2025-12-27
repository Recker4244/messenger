import 'package:get_it/get_it.dart';
import 'package:sivi_chat/services/api_service.dart';
import 'package:sivi_chat/services/chat_service.dart';
import 'package:sivi_chat/services/uuid_service.dart';
import 'package:stacked_services/stacked_services.dart';

final GetIt locator = GetIt.instance;

void setupLocator() {
  locator.registerLazySingleton(() => NavigationService());
  locator.registerLazySingleton(() => DialogService());
  locator.registerLazySingleton(() => SnackbarService());
  locator.registerSingleton<ChatService>(ChatService());
  locator.registerLazySingleton(() => ApiService());
  locator.registerSingleton<UuidService>(UuidService());
}
