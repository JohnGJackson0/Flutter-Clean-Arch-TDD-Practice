// overkill to create abstract class for simple
// util class

// use class to help with mock
import 'package:dartz/dartz.dart';

import '../error/failures.dart';

class InputConverter {
  // shield the domain layer from influence of input
  // conversion, domain doesn't care about about
  // ui being a string first.

  Either<Failure, int> stringToUnsignedInt(String str) {
    try {
      final integer = int.parse(str);
      if (integer < 0) throw const FormatException();
      return Right(integer);
    } on FormatException {
      return Left(InvalidInputFailure());
    }
  }
}
