// @dart=2.9

// TODO ^

import 'package:clean/core/error/failures.dart';
import 'package:clean/core/util/input_converter.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dartz/dartz.dart';

void main() {
  InputConverter inputConverter;

  setUp(() {
    inputConverter = InputConverter();
  });

  group('stringToUnsignedInt', () {
    test(
        'should return an integer when the string represents an unsigned integer',
        () async {
      const str = '123';
      final result = inputConverter.stringToUnsignedInt(str);
      expect(result, Right(123));
    });
  });

  test('should return a failure when the string is not an integer', () async {
    const str = 'abc';
    final result = inputConverter.stringToUnsignedInt(str);
    expect(result, Left(InvalidInputFailure()));
  });

  test('should return a failure when the string is a negative integer', () {
    const str = '-125';
    final result = inputConverter.stringToUnsignedInt(str);
    expect(result, Left(InvalidInputFailure()));
  });
}
