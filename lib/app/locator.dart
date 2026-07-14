import 'package:get_it/get_it.dart';
import 'package:hive/hive.dart';
import 'package:zendora_app/core/constants/datasource/achievements/achievements_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/achievements/achievements_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/datasource/auth/auth_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/auth/auth_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/datasource/best/best_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/best/best_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/datasource/gtq/gtq_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/gtq/gtq_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/datasource/hub/hub_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/hub/hub_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/datasource/learn/learn_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/learn/learn_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/datasource/profile/profile_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/profile/profile_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/datasource/sports/sports_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/sports/sports_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/datasource/stats/stats_remote_data_source.dart';
import 'package:zendora_app/core/constants/datasource/stats/stats_remote_data_source_impl.dart';
import 'package:zendora_app/core/constants/services/api/api_service.dart';
import 'package:zendora_app/core/constants/services/storage_service/storage_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  //---------------- SERVICES ----------------//
  locator.registerLazySingleton<HiveInterface>(() => Hive);

  locator.registerLazySingleton<ApiService>(() => ApiService());

  locator.registerLazySingleton<StorageService>(() => StorageService());
  // locator.registerLazySingleton<UtilityService>(() => UtilityService());

  //data sources
  locator.registerLazySingleton<AuthRemoteDataSource>(
    () => AuthRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<SportsRemoteDataSource>(
    () => SportsRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<LearnRemoteDataSource>(
    () => LearnRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<GtqRemoteDataSource>(
    () => GtqRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<StatsRemoteDataSource>(
    () => StatsRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<HubRemoteDataSource>(
    () => HubRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<BestRemoteDataSource>(
    () => BestRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<AchievementsRemoteDataSource>(
    () => AchievementsRemoteDataSourceImpl(locator<ApiService>()),
  );

  locator.registerLazySingleton<ProfileRemoteDataSource>(
    () => ProfileRemoteDataSourceImpl(locator<ApiService>()),
  );

  await locator<StorageService>().init();
}
