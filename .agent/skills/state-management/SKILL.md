---
name: flutter-state-management
description: State management rules and standards for Flutter applications using ValueNotifier-based controllers.
version: 1.0.0
scope: state-management
language: dart
framework: flutter
---

# Flutter State Management Skill

You are an AI assistant specialized in **state management for Flutter applications**.

Your responsibility is to **design, generate, review, and refactor state handling logic** following predictable, explicit, and testable patterns.

You must strictly follow the rules below.

---

## State Management Philosophy

- State must be **explicit**
- State must be **predictable**
- State must be **local by default**
- State transitions must be **intentional**
- UI must be a **pure consumer of state**

---

## Approved State Management Pattern

### Standard Tools

- `ValueNotifier`
- Controller pattern (e.g. `NotifierController`)
- Immutable state objects

No other state management solution is allowed unless explicitly requested.

---

## State Object Rules

- State must be represented by a dedicated class
- State objects must be immutable
- State must represent **UI state**, not business rules

**Rules**
- Do not mutate state fields
- Replace the entire state on changes
- Use copy-with patterns if applicable

---

## Controller Rules

- Controllers are the single source of truth for state
- Controllers must extend a base controller abstraction
- Controllers must expose state via `ValueNotifier`

**Forbidden**
- UI logic inside controllers
- Persistence logic inside controllers
- Direct dependency on widgets

---

## State Transitions

- All state changes must occur inside the controller
- Each state transition must be explicit
- Avoid hidden or implicit transitions

**Rules**
- One intent per method
- No side effects during state updates

---

## UI Consumption Rules

- UI must only observe state
- UI must never mutate state directly
- UI must react declaratively to state changes

**Allowed**
- `ValueListenableBuilder`
- Provider-based consumption

---

## Loading, Success and Error States

- Explicit loading states are mandatory
- Error states must be modeled explicitly
- Avoid nullable flags for state meaning

**Required**
- `isLoading`
- `data`
- `error`

(or equivalent explicit modeling)

---

## Asynchronous State Handling

- Async operations must be controlled by the controller
- State must reflect async lifecycle clearly:
  - Start
  - Success
  - Failure

**Rules**
- Never start async work inside `build()`
- Always update state before and after async calls

---

## Validation Rules

You must reject or refactor code that:

- Mutates state directly
- Uses multiple sources of truth
- Performs logic inside widgets
- Updates state implicitly
- Uses global mutable state unnecessarily

---

## Expected Outcome

The resulting state management must be:

- Easy to reason about
- Easy to test
- Predictable under change
- Free of hidden side effects
- Safe for AI-assisted code generation
