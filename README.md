# Clean Architecture in flutter

## Understaing DI and DIAP

If the creation of an object is tied to implementation logic, then relying solely on the abstract type and defining the logic for its creation does not fully decouple the implementation from that code.

Therefore, it should not be responsible for creating the objects themselves. Instead, it should have a passed in pre-constructed object. Violating this principle would be any object that creates another object within the code.

Dependency injection requires configuration details to be provided by the construction code itself, which can be challenging when clear default options are not available.

The challenge is well worth the effort though because it completes the software boundary on code where the implementation may change often. It helps define how code will work for testing without dealing with implementation logic that the test does not care about. Lastly, it makes the code base easier to reason about by seperating the app into maintainable chucks of logic that loosly depends on each other.
