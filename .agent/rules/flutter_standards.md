---
trigger: always_on
---

**Related Skills:**
- [Clean Code](../skills/clean-code/SKILL.md)
- [App Builder](../skills/app-builder/SKILL.md)

## Flutter Style Guide
* **SOLID Principles:** Apply SOLID principles throughout the codebase.
* **Concise and Declarative:** Write concise, modern, technical Dart code. Prefer functional and declarative patterns.
* **Composition over Inheritance:** Favor composition for building complex widgets and logic.
* **Immutability:** Prefer immutable data structures. Widgets (especially `StatelessWidget`) should be immutable.
* **Widgets are for UI:** Everything in Flutter's UI is a widget. Compose complex UIs from smaller, reusable widgets.

## Flutter Best Practices
* **Immutability:** Widgets (especially `StatelessWidget`) are immutable; when the UI needs to change, Flutter rebuilds the widget tree.
* **Composition:** Prefer composing smaller widgets over extending existing ones. Use this to avoid deep widget nesting.
* **Private Widgets:** Use small, private `Widget` classes instead of private helper methods that return a `Widget`.
* **Build Methods:** Break down large `build()` methods into smaller, reusable private Widget classes.
* **List Performance:** Use `ListView.builder` or `SliverList` for long lists to create lazy-loaded lists for performance.
* **Isolates:** Use `compute()` to run expensive calculations in a separate isolate to avoid blocking the UI thread, such as JSON parsing.
* **Const Constructors:** Use `const` constructors for widgets and in `build()` methods whenever possible to reduce rebuilds.
* **Build Method Performance:** Avoid performing expensive operations, like network calls or complex computations, directly within `build()` methods.
