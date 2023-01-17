import 'package:clean/core/network/network_info.dart';
import 'package:clean/core/util/input_converter.dart';
import 'package:clean/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean/features/number_trivia/data/repositories/number_trivia_repository_impl.dart';
import 'package:clean/features/number_trivia/domain/repositories/number_trivia_repository.dart';
import 'package:clean/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:data_connection_checker/data_connection_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'features/number_trivia/data/datasources/number_trivia_local_datasource.dart';
import 'features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:http/http.dart' as http;

/*
  Contract vs Impl allows us to test the units
  of code and mock via the contract and not impl

  Now, instanciate real implementation for the app
  using dependency injection architectural pattern DIAP

  It allows for the ability to switch out an entire
  implementation via instanciating another object here
  rather than in the code that actually uses it.

  i.e. changing this: NumberTriviaRepositoryImpl to 
  NumberTriviaRepositorySpecialImpl

  If we are to change to NumberTriviaRepositorySpecialImpl
  we know it should work because it would implement the same
  type i.e. abstract class which conforms to its contract

  if it doesn't fufill the contract it is a badly written
  class

  DIAP means we can have a seperated dependency for debug 
  or prod, also we can change dependency easily. 

  It provides even more decoupled code from implementation
  as object creation is 'a part of' the specific impl and
  not 'a part of' the generic contract it completes. So 
  it keeps it away from where it is depended on and placed
  here. 

  Instanciated via DIAP via singletons may reduce the number
  of times objects are created as well.

*/

// service locator
// sl.call() => sl()
final sl = GetIt.instance;

Future<void> init() async {
  //! Features - Number Trivia

  /*
    bloc  - as it is at the top of the callchain
    in clean architecture
  */

  /*
    sl() will find and return a instantiated type by
    taking the type we know we want and returning it

    registerFactory returns a new instance each time
    it is called. If you only want a single instance
    then use registerLazySingleton. We don't use it on bloc 
    instance as is tied to streams. If you close stream
    in singleton then the the instanciated object has
    a closed stream.
  */
  sl.registerFactory(() =>
      NumberTriviaBloc(concrete: sl(), random: sl(), inputConverter: sl()));

  /*
    The dependency of bloc however will have recycled 
    singleton. 
    The Lazy singletons are on demand only, as in they
    are not created on app start, only when they are needed
  */

  sl.registerLazySingleton(() => GetConcreteNumberTrivia(sl()));
  sl.registerLazySingleton(() => GetRandomNumberTrivia(sl()));

  sl.registerLazySingleton<NumberTriviaRemoteDataSource>(
    () => NumberTriviaRemoteDataSourceImpl(client: sl()),
  );

  sl.registerLazySingleton<NumberTriviaLocalDataSource>(
    () => NumberTriviaLocalDataSourceImpl(sharedPreferences: sl()),
  );

  //! Core
  sl.registerLazySingleton(() => InputConverter());

  sl.registerLazySingleton<NumberTriviaRepository>(() =>
      NumberTriviaRepositoryImpl(
          remoteDataSource: sl(), localDataSource: sl(), networkInfo: sl()));
  sl.registerLazySingleton<NetworkInfo>(() => NetworkInfoImpl(sl()));
  //! External
  final sharedPreferences = await SharedPreferences.getInstance();
  sl.registerLazySingleton<SharedPreferences>(() => sharedPreferences);

  sl.registerLazySingleton(() => http.Client());
  sl.registerLazySingleton(() => DataConnectionChecker());
}
