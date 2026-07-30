# Flutter State Management – Example (NotifierController + BaseState)

This example demonstrates the **correct and expected implementation** of the `flutter-state-management` skill using:

- `BaseState`
- `NotifierController`
- `ValueNotifier`
- Explicit state classes (sealed states)

This is the **only approved pattern** for state management.

---

## State Implementation

**File:** `lib/src/presentation/example/example_state.dart`

```dart
import '../../infra/controller/base_state.dart';

sealed class FooState extends BaseState {}

class FooInitial extends FooState {}

class FooLoading extends FooState {}

class FooSuccess extends FooState {
  final String data;

  FooSuccess(this.data);
}

class FooError extends FooState {
  final String message;

  FooError({required this.message});
}
```

---

## Controller Implementation

**File:** `lib/src/presentation/example/example_controller.dart`

```dart
import '../../infra/controller/notifier_controller.dart';
import 'example_state.dart';

class FooController extends NotifierController<FooState> {
  FooController() : super(FooInitial());

  Future<void> loadData() async {
    update(FooLoading());

    try {
      // Call use case here
      await Future.delayed(const Duration(seconds: 2));

      update(FooSuccess("Dados"));
    } catch (e) {
      update(
        FooError(
          message: e.toString(),
        ),
      );
    }
  }
}
```

---

## View (UI Consumption)

**File** `lib/src/presentation/example/example_page.dart`

```dart
import 'package:flutter/material.dart';

import 'example_controller.dart';
import 'example_state.dart';

class FooPage extends StatefulWidget {
  final FooController controller;

  const FooPage({
    super.key,
    required this.controller,
  });

  @override
  State<FooPage> createState() => _FooPageState();
}

class _FooPageState extends State<FooPage> {
  @override
  void initState() {
    super.initState();
    // Start loading when page is initialized
    widget.controller.loadData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Foo'),
      ),
      body: ValueListenableBuilder<FooState>(
        valueListenable: widget.controller.stateNotifier,
        builder: (context, state, child) {
          if (state is FooLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is FooSuccess) {
            return Center(
              child: Text(state.data),
            );
          }

          if (state is FooError) {
            return Center(
              child: Text(state.message),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
```
