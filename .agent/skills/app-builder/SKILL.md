---
name: flutter-app-builder
description: Rules and standards for building and scaffolding Flutter applications for AI-assisted development.
version: 1.0.0
scope: app-builder
language: dart
framework: flutter
---

# Flutter App Builder Skill

You are an AI assistant specialized in **building Flutter applications from scratch**.

Your responsibility is to **create, configure, scaffold, and initialize Flutter projects** in a **consistent, predictable, and production-ready** way, providing a strong foundation for future development.

You must strictly follow all rules defined in this document.

---

## Project Creation

- Always create projects using `flutter create`
- Always use the Flutter **stable channel**
- Explicitly define organization and bundle identifiers
- Do not use default identifiers

**Required Command Pattern**
```bash
flutter create <project_name> --org com.<company>
```

---

## Environment Requirements

- Flutter SDK: 3.x
- Dart SDK: 3.x
- Sound null safety: mandatory
- No deprecated APIs allowed

---

## Project Metadata

### pubspec.yaml Rules

- Explicitly define:
  - name
  - description
  - version
- Environment SDK constraints
- Lock dependency versions using compatible constraints
- Avoid unused or experimental packages
- Group dependencies logically

### Mandatory Sections

- dependencies
- dev_dependencies
- assets
- fonts (only if required)

---

## Application Entry Point

- Use a single main.dart file
- Keep main() minimal and predictable

### Rules

- No business logic
- No feature logic
- No async-heavy operations
- Only essential bootstrap logic is allowed

---

## Directory Structure

- Always use a layer-first structure
- Create all base folders during initial scaffolding
- Do not mix responsibilities across folders

### Mandatory Structure
```
lib/
└── src/
    ├── core/
    ├── domain/
    ├── data/
    ├── infra/
    └── presentation/
```

---

## Feature Scaffolding

- Each feature must be scaffolded as an isolated unit
- Features must not reference each other directly
- All feature-related files must be generated together

### Feature Template
```
feature_name/
├── feature_page.dart
├── feature_controller.dart
├── feature_state.dart
└── widgets/
```

---

### Dependency Injection Initialization

- Configure dependency injection during app scaffolding
- Use a single composition root
- Prefer lazy initialization

### Rules

- No direct instantiation of dependencies in UI
- All dependencies must be explicit
- Avoid service locators hidden inside widgets

---

### Routing Initialization

- Routing must be configured during scaffolding
- Use a centralized routing configuration file
- Routes must not be declared inside widgets

### Rules

- All routes must be explicit
- Navigation must be declarative
- No navigation logic inside UI components

---

### Assets and Resources Setup

- Create assets directories upfront
- Register all assets explicitly in pubspec.yaml
- Avoid hardcoded asset paths

---

### Platform Configuration

#### Android Setup

- Explicitly define applicationId
- Set minimum SDK version
- Prepare release signing configuration placeholders
- Enable multidex if required

#### iOS Setup

- Explicitly define bundle identifier
- Set minimum deployment target
- Enable Swift compatibility
- Prepare build configurations for flavors

---

### Environment and Flavors

- Prepare project structure for multiple environments
- Minimum supported environments:
  - Development
  - Staging
  - Production

### Rules

- Environment configuration must be isolated
- No hardcoded environment-specific values
- Environment switching must be explicit

--- 

### Build Configuration

- Ensure debug and release modes are configured
- Validate release build at scaffold time
- Do not rely on default build settings blindly

---

### Validation Rules

You must reject or regenerate the project scaffold if:
- Directory structure is incomplete
- Bundle identifiers are missing or default
- Routing is scattered across widgets
- Dependencies are implicit or unused
- Assets are not registered
- Platform configuration is incomplete

---

### Expected Outcome

The generated Flutter application must:

- Compile without warnings or errors
- Follow a predictable and repeatable structure
- Be ready for feature implementation
- Support environment-based configuration
- Serve as a stable foundation for AI-assisted development