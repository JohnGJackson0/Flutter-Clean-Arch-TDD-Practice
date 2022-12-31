import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';

class NumberTrivia extends Equatable {
  final String text;
  final int number;

  // if there is any logic in entity, write the test for entity

  /*
    Either: catch error as early as possible
    and return a failure object rather than
    catching them later, needing to be remembered

    but how to return number trivia or failure from the
    same method? Use Either type from Dartz
  */

  NumberTrivia({required this.text, required this.number})
      : super([text, number]);
}
