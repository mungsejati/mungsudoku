---
trigger: always_on
---

**Related Skills:**
- [State Management](../skills/state-management/SKILL.md)
**Related Workflows:**
- [Create Feature](../workflows/create_feature.md)

## State Management Guidelines
* **Built-in Solutions:** Prefer Flutter's built-in state management solutions. Do not use a third-party package unless explicitly requested.
* **Streams:** Use `Streams` and `StreamBuilder` for handling a sequence of asynchronous events.
* **Futures:** Use `Futures` and `FutureBuilder` for handling a single asynchronous operation that will complete in the future.
* **ValueNotifier:** Use `ValueNotifier` with `ValueListenableBuilder` for simple, local state that involves a single value.

  ```dart
  // Define a ValueNotifier to hold the state.
  final ValueNotifier<int> _counter = ValueNotifier<int>(0);

  // Use ValueListenableBuilder to listen and rebuild.
  ValueListenableBuilder<int>(
    valueListenable: _counter,
    builder: (context, value, child) {
      return Text('Count: $value');
    },
  );
    ```

* **ChangeNotifier:** For state that is more complex or shared across multiple widgets, use `ChangeNotifier`.
* **ListenableBuilder:** Use `ListenableBuilder` to listen to changes from a `ChangeNotifier` or other `Listenable`.
* **Dependency Injection:** Use simple manual constructor dependency injection to make a class's dependencies explicit in its API, and to manage dependencies between different layers of the application.
* **Provider:** If a dependency injection solution beyond manual constructor injection is explicitly requested, `provider` can be used to make services, repositories, or complex state objects available to the UI layer without tight coupling (note: this document generally defaults against third-party packages for state management unless explicitly requested).
