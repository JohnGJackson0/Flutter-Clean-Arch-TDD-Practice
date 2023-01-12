// @dart=2.9

// TODO ^

import 'package:clean/core/error/failures.dart';
import 'package:clean/core/util/input_converter.dart';
import 'package:clean/features/number_trivia/domain/entities/number_trivia.dart';
import 'package:clean/features/number_trivia/domain/usecases/get_concrete_number_trivia.dart';
import 'package:clean/features/number_trivia/domain/usecases/get_random_number_trivia.dart';
import 'package:clean/features/number_trivia/presentation/bloc/number_trivia_bloc.dart';
import 'package:mockito/mockito.dart';
import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';

class MockGetConcreteNumberTrivia extends Mock
    implements GetConcreteNumberTrivia {}

class MockGetRandomNumberTrivia extends Mock implements GetRandomNumberTrivia {}

class MockInputConverter extends Mock implements InputConverter {}

void main() {
  NumberTriviaBloc bloc;
  MockGetConcreteNumberTrivia mockGetConcreteNumberTrivia;
  MockGetRandomNumberTrivia mockGetRandomNumberTrivia;
  MockInputConverter mockInputConverter;

  setUp(() {
    mockGetConcreteNumberTrivia = MockGetConcreteNumberTrivia();
    mockGetRandomNumberTrivia = MockGetRandomNumberTrivia();
    mockInputConverter = MockInputConverter();

    bloc = NumberTriviaBloc(
        concrete: mockGetConcreteNumberTrivia,
        random: mockGetRandomNumberTrivia,
        inputConverter: mockInputConverter);
  });

  test('initial state should be empty', () {
    expect(bloc.initialState, equals(Empty()));
  });

  group('GetTriviaForConcreteNumber', () {
    final tNumberString = '1';
    final tNumberParsed = 1;
    final tNumberTrivia = NumberTrivia(number: 1, text: 'test trivia');

    void setupMockInputConverterSuccess() =>
        when(mockInputConverter.stringToUnsignedInt(any))
            .thenReturn(Right(tNumberParsed));

    test(
        'should call the InputConverter to validate and convert the string to an unsigned integer',
        () async {
      setupMockInputConverterSuccess();
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockInputConverter.stringToUnsignedInt(any));
      verify(mockInputConverter.stringToUnsignedInt(tNumberString));
    });

    test('should emit [Error] when the input is invalid', () {
      when(mockInputConverter.stringToUnsignedInt(any))
          .thenReturn(Left(InvalidInputFailure()));
      final expected = [Empty(), Error(message: INVALID_INPUT_FAILURE_MESSAGE)];
      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should get data from the usecase', () async {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
      await untilCalled(mockGetConcreteNumberTrivia(any));
      verify(mockGetConcreteNumberTrivia(Params(number: tNumberParsed)));
    });

    test('should emit [loading, loaded] when data is gotten successfully', () {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Right(tNumberTrivia));
      // when testing with streams we do assert later before
      // acting on the code
      final expected = [Empty(), Loading(), Loaded(trivia: tNumberTrivia)];

      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test('should emit [loading, error] when getting data fails', () {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(ServerFailure()));
      final expected = [
        Empty(),
        Loading(),
        Error(message: SERVER_FAILURE_MESSAGE)
      ];

      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });

    test(
        'should emit [loading, error] with a proper message for the error when getting data fails',
        () {
      setupMockInputConverterSuccess();
      when(mockGetConcreteNumberTrivia(any))
          .thenAnswer((_) async => Left(CacheFailure()));
      final expected = [
        Empty(),
        Loading(),
        Error(message: CACHE_FAILURE_MESSAGE)
      ];

      expectLater(bloc.state, emitsInOrder(expected));
      bloc.dispatch(GetTriviaForConcreteNumber(tNumberString));
    });
  });
  
}
