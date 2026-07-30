---
trigger: always_on
---

**Related Skills:** 
- [Flutter Architecture](../skills/architecture/SKILL.md)
**Related Workflows:**
- [Create Entity Model](../workflows/create_entity_model.md)

## Application Architecture
* **Separation of Concerns:** Aim for separation of concerns similar to MVC/MVVM, with defined Model, View, and ViewModel/Controller roles.
* **Logical Layers:** Organize the project into logical layers:
    * Presentation (widgets, screens)
    * Domain (business logic classes)
    * Data (model classes, Repositories Interfaces)
    * Infra (Repositories Implementations, External dependencies adapters)
    * Core (shared classes, utilities, and extension types, app configs, themes, constants, etc)
* **Layer-based Organization:** Organize code by layer, as defined above.

## Project Structure
* **Standard Structure:** Assumes a standard Flutter project structure with `lib/main.dart` as the primary application entry point.

## Data Flow
* **Data Structures:** Define data structures (classes) to represent the data used in the application.
* **Data Abstraction:** Abstract data sources (e.g., API calls, database operations) using Repositories/Services to promote testability.
