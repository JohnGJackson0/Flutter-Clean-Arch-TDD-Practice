// @dart=2.9

// TODO ^

import 'dart:convert';
import 'package:clean/core/error/exceptions.dart';
import 'package:clean/features/number_trivia/data/datasources/number_trivia_remote_datasource.dart';
import 'package:clean/features/number_trivia/data/models/number_trivia_model.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import '../../../../fixtures/fixture_reader.dart';
import 'package:http/http.dart' as http;

class MockHttpClient extends Mock implements http.Client {}

void main() {
  NumberTriviaRemoteDataSourceImpl datasource;
  MockHttpClient mockHttpClient;

  setUp(() {
    mockHttpClient = MockHttpClient();
    datasource = NumberTriviaRemoteDataSourceImpl(client: mockHttpClient);
  });

  void setUpMockHTTPSuccess200() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response(fixture('trivia.json'), 200));
  }

  void setUpMockHTTPClientFailure404() {
    when(mockHttpClient.get(any, headers: anyNamed('headers')))
        .thenAnswer((_) async => http.Response('Something went wrong', 404));
  }

  group('getConcreteNumberTrivia', () {
    const tNumber = 1;
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a get request on a URL with number
      being an endpoint and with application/json header''', () async {
      setUpMockHTTPSuccess200();
      datasource.getConcreteNumberTrivia(tNumber);
      verify(mockHttpClient.get('http://numbersapi.com/$tNumber',
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return numberTrivia when the response code is 200', () async {
      setUpMockHTTPSuccess200();
      final result = await datasource.getConcreteNumberTrivia(tNumber);
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other error',
        () async {
      setUpMockHTTPClientFailure404();
      final call = datasource.getConcreteNumberTrivia;

      expect(
          () => call(tNumber), throwsA(const TypeMatcher<ServerException>()));
    });
  });

  group('getRandomNumberTrivia', () {
    final tNumberTriviaModel =
        NumberTriviaModel.fromJson(json.decode(fixture('trivia.json')));

    test('''should perform a get request on a URL with number
      being an endpoint and with application/json header''', () async {
      setUpMockHTTPSuccess200();
      datasource.getRandomNumberTrivia();
      verify(mockHttpClient.get('http://numbersapi.com/random',
          headers: {'Content-Type': 'application/json'}));
    });

    test('should return numberTrivia when the response code is 200', () async {
      setUpMockHTTPSuccess200();
      final result = await datasource.getRandomNumberTrivia();
      expect(result, equals(tNumberTriviaModel));
    });

    test(
        'should throw a ServerException when the response code is 404 or other error',
        () async {
      setUpMockHTTPClientFailure404();
      final call = datasource.getRandomNumberTrivia;

      expect(() => call(), throwsA(const TypeMatcher<ServerException>()));
    });
  });
}
