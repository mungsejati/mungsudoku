---
name: flutter-architecture
description: This skill is specialized in Flutter mobile application architecture, based on Clean Architecture, strict layer separation, low coupling, and high testability. Its purpose is to guide architectural decisions and validate architectural compliance across the codebase.
scope: architecture
language: dart
framework: flutter
---

# Flutter Architecture

## When to use

- When building a Flutter mobile application
- When following Clean Architecture principles
- When ensuring low coupling and high testability
- When isolating features for framework independence

## Principles

- Separation of Concerns
- Clean Architecture
- Dependency Inversion
- Testability First
- Feature Isolation
  - Framework Independence

## Layers

- Domain
  - Contain pure business rules
  - Must not depend on Flutter, packages or infrastructure
    allowed:
      - Entities
      - Domain Services
    forbidden:
      - Imports of Flutter
      - Dependência of external packages
      - UI or persistence logic

- Data
  - Define data access contracts
  - Implement unitary use cases
    allowed:
      - UseCases
      - Repository Interfaces
      - DTOs that extend Entities
    rules:
      - UseCases must be unique and focused classes
      - Must not contain UI or framework logic

- Infrastructure
  - Implement technical details
  - Adapt external packages to domain abstractions
    allowed:
      - HTTP adapters
      - Storage adapters
      - Network adapters
      - Logger adapters
      - Repository implementations
    rules:
      - Must depend on abstractions
      - Never expose external dependencies to upper layers

- Presentation
  - Render UI
  - Manage state
  - Orchestrate use cases
    allowed:
      - Pages
      - Widgets
      - Controllers
      - States
    rules:
      - Controllers must centralize state logic
      - UI must not contain business rules
      - Communication happens exclusively through UseCases

## State Management

- Standard
  - ValueNotifier
  - NotifierController
  rules:
    - State must be as local as possible
    - Controllers must not access infrastructure directly
    - States must be immutable whenever possible

## Dependency Injection

- Tool: provider
  rules:
    - Injection made in the infra/di layer
    - Presentation never instantiates concrete dependencies
    - Dependencies must be resolved by abstraction

## Routing

- Tool: go_router
  rules:
    - Routes defined outside the UI
    - Navigation must not contain business logic
    - Controllers must not know route details

## Directory Structure

- Rule: layer-first
  Constraints:
    - Each feature isolated in presentation
    - No cross-feature references
    - Domain and Data are shareable

## Validation Checks

- Domain must not import Flutter
- Presentation must not access infra directly
- Infra depends only on abstractions
- UseCases must not know UI
- Controllers must not contain persistence logic

## Output Expectations

- Modular and testable code
- Ease of architectural evolution
- Low coupling between layers
- Clarity of responsibilities
