import 'package:bloc/bloc.dart';
import 'package:clean/core/error/failures.dart';
import 'package:clean/core/usecase/usecase.dart';
import 'package:clean/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';

import '../../../../core/util/input_converter.dart';
import '../../domain/entities/number_trivia.dart';
import '../../domain/usecases/get_random_number_trivia.dart';

part 'number_trivia_event.dart';
part 'number_trivia_state.dart';

// presentation logic only
// business logic goes to domain
// reactive state manager, only flows in a single
// direction

// bloc recieves event > useCase > data recieved >
//  state emitted > updated

// notice localization
const String SERVER_FAILURE_MESSAGE = 'Server Failure';
const String CACHE_FAILURE_MESSAGE = 'Cache Failure';
const String INVALID_INPUT_FAILURE_MESSAGE =
    'Invalid Input - The number must be a positive integer or zero';

class NumberTriviaBloc extends Bloc<NumberTriviaEvent, NumberTriviaState> {
  final GetConcreteNumberTrivia getConcreteNumberTrivia;
  final GetRandomNumberTrivia getRandomNumberTrivia;
  final InputConverter inputConverter;
  @override
  NumberTriviaState get initialState => Empty();

  NumberTriviaBloc(
      {required GetConcreteNumberTrivia concrete,
      required GetRandomNumberTrivia random,
      required this.inputConverter})
      :
        // needed before non-null conversion
        // all we should do now is
        // {.., required this.getConcreteNumberTrivia}
        // adding this anyway
        // ignore: unnecessary_null_comparison
        assert(concrete != null),
        getConcreteNumberTrivia = concrete,
        getRandomNumberTrivia = random;

  @override
  Stream<NumberTriviaState> mapEventToState(NumberTriviaEvent event) async* {
    if (event is GetTriviaForConcreteNumber) {
      final inputEither =
          inputConverter.stringToUnsignedInt(event.numberString);

      // cannot simply return, must also yield the fold when emitting
      // since there is a nested Higher Order Function
      yield* inputEither.fold((failure) async* {
        yield Error(message: INVALID_INPUT_FAILURE_MESSAGE);
      }, (integer) async* {
        yield Loading();
        final failureOrTrivia =
            await getConcreteNumberTrivia(Params(number: integer));

        yield* _handleTriviaLoadedOrError(failureOrTrivia);
      });
    } else if (event is GetTriviaForRandomNumber) {
      yield Loading();
      final failureOrTrivia = await getRandomNumberTrivia(NoParams());
      yield* _handleTriviaLoadedOrError(failureOrTrivia);
    }
  }

  Stream<NumberTriviaState> _handleTriviaLoadedOrError(
      Either<Failure, NumberTrivia> failureOrTrivia) async* {
    // if return type is either, use FOLD, it
    // makes it so you have to handle error side
    yield failureOrTrivia.fold(
        (failure) => Error(message: _mapFailureToMessage(failure)),
        (trivia) => Loaded(trivia: trivia));
  }

  // should use extension method but not currently
  // implemented in flutter
  String _mapFailureToMessage(Failure failure) {
    switch (failure.runtimeType) {
      case ServerFailure:
        return SERVER_FAILURE_MESSAGE;
      case CacheFailure:
        return CACHE_FAILURE_MESSAGE;
      default:
        return 'Unexpected Error';
    }
  }
}
