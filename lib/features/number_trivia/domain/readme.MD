# Domain Layer


## Core Layers

A layer is a core concern of an application. Major core concerns of most modern applications are fetching data, presenting data, and writing logic for the data. Clean architecture seperates these in a protected way so that changes to a core concern only influences the other core concerns as minimally as possible.

When core concerns of an application communicate with the least amount of details between them, then they don't care or are required to change when one layer changes or is replaced. This is what makes the core concern reusable where literally any other 'core concern' can be dropped in or changed dramatically, yet it will work and already be unit tested with the other core concerns. 

The "repo" layer can use new endpoints, cache data, use an ORM and the core logic inside of a domain would never care how it does it. It just says to repo to provide the data that it needs to work. If another repo can provide the same data for the useCase it can simply call that one instead and the whole application would work still.

Similarly, the Presentation layer can be completely replaced or you can use multiple presentation layers and the maximum logic not tied to presentation would be reusable.

When details are minimal between a concern it is refered to as loose coupling. 

High cohesion is something else to think about in application architecture. This is how much core concern supports a central purpose. If the concern of a layer is fetching data and doing the business logic, it is lower cohesion with the same coupling to presentation. This defines that it is probably a good idea that clean architecture would seperate them.

Clean architecture is an example of constructing loose coupling and high cohesion for the concerns that match of most modern applications. 

## Domain

Domain is the "safe center" of an application. It is the center since the the call structure starts with presentation, the presentation calls on the domain and the domain calls on the repo to get the data. 

For it to be "safe" we have to
define what it actually needs minimally to work for what it calls (the repo), then we use this minimal contract to depend on. When we build the repo, the understanding is that we must support the contract in the useCase. Any repo that supports that contract can now work with the useCase. 

This is a known as a software boundary. It is the best possible way to call on something we expect to change even dramatically but need to depend on it for other code. We are trying to "protect" the domain, core logic of the application from changes to the repo layer as much as possible. 

A contract can be set by an interface or in the case of dart since they don't have interfaces, is an abstract class. This defines a type for the minimal communication required between core concerns. Remember that limiting the data between communication layers is what allows loose coupling.

Business logic is anything that can be extracted from imports of the view library or framework. If you must have the view library or framework as a part of the logic you are writing, then it is presentation logic and not apart of the domain. 

This presentation logic should be highly specific to the platform, view library or framework that the presentation is concerned about. To maximize reusability extract any logic that instead could be shared between platforms while never importing any view specific libray to domain.


