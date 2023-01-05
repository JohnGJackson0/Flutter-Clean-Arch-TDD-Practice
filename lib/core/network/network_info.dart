import 'package:data_connection_checker/data_connection_checker.dart';

/* 
  We are most likely to always depend on having
  a method that checks for internet connection. 

  We are less likely to always use the same method
  of determining if the internet connection is online
  or offline. 

  The abstract class defines the method we are depending 
  on rather than the implementaiton we are depending on in 
  all prod and test code in the whole application that needs
  it.

  It simply defers the implementation to another part that 
  models it and also defines a simple type that it promises 
  to do. 

  You can defer the implementation via a function/class, 
  but the abstract class is what 'hides' the implementation
  details and concrete implementations from bleading out.

  This is an 'abstract type.' In other places of the app
  you would want a simple type of which only represents the
  thing that is being accomplished. 

  Depending on the abstract class in other parts of the code
  is what stops unit tests from breaking through the whole 
  application simply because the concrete implementation has
  changed undesirably for the functionality required. 

  How?

  For tests that don't care how this is accomplished, you have
  a simple type of which can be mocked. This mock ignores all
  undesirable effects of how it's accomplished and just assumes
  the behavior of this module. Since it is ignoring the 
  implementation, it does not depend on the headaches 
  from testing this implementation. 

  What that means for testing, is that when undesirable or
  difficult to test change comes for network connection it
  does not even matter to any of the other tests. Only the 
  tests to this exact file. 

  In summation, it helps tests and maintainability in 
  production.   
*/

abstract class NetworkInfo {
  Future<bool> get isConnected;
}

class NetworkInfoImpl implements NetworkInfo {
  final DataConnectionChecker connectionChecker;

  NetworkInfoImpl(this.connectionChecker);

  @override
  Future<bool> get isConnected => connectionChecker.hasConnection;
}
