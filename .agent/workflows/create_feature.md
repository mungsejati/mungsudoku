---
description: Create a new Feature (View, Controller, State) following project architecture
---
# Create Feature Workflow

1. **Identify Feature Information**
   - **Feature Name**: PascalCase (e.g., `Login`) -> `[FeatureName]`
   - **Feature Directory**: snake_case (e.g., `login`) -> `[feature_name]`
   - **Base Path**: `lib/src/presentation/[feature_name]/`

2. **Create State File**
   - File Path: `lib/src/presentation/[feature_name]/[feature_name]_state.dart`
   - **Rules**:
     - Sealed class `[FeatureName]State` extends `BaseState`.
     - `[FeatureName]Initial` class.
     - `[FeatureName]Loading` class.
     - `[FeatureName]Success` class.
     - `[FeatureName]Error` class with `message` field.
   
   **Template**:
   ```dart
   import '../../infra/controller/base_state.dart';

   sealed class [FeatureName]State extends BaseState {}

   class [FeatureName]Initial extends [FeatureName]State {}

   class [FeatureName]Loading extends [FeatureName]State {}

   class [FeatureName]Success extends [FeatureName]State {
     // Add necessary fields
   }

   class [FeatureName]Error extends [FeatureName]State {
     final String message;
     
     [FeatureName]Error({required this.message});
   }
   ```

3. **Create Controller File**
   - File Path: `lib/src/presentation/[feature_name]/[feature_name]_controller.dart`
   - **Rules**:
     - Class `[FeatureName]Controller` extends `NotifierController<[FeatureName]State>`.
     - Constructor calls `super([FeatureName]Initial())`.
     - `loadData()` method (or main action method) handles `update(Loading)`, `try-catch` with `update(Success)` and `update(Error)`.
   
   **Template**:
   ```dart
   import '../../infra/controller/notifier_controller.dart';
   import '[feature_name]_state.dart';

   class [FeatureName]Controller extends NotifierController<[FeatureName]State> {
     [FeatureName]Controller() : super([FeatureName]Initial());

     Future<void> loadData() async {
       update([FeatureName]Loading());
       try {
         // TODO: Implement logic / usecase call
         update([FeatureName]Success());
       } catch (e) {
         update([FeatureName]Error(message: e.toString()));
       }
     }
   }
   ```

4. **Create View File**
   - File Path: `lib/src/presentation/[feature_name]/[feature_name]_page.dart`
   - **Rules**:
     - `StatefulWidget` named `[FeatureName]Page`.
     - Accepts `[FeatureName]Controller` in constructor.
     - `initState` calls `widget.controller.loadData()`.
     - `build` uses `ValueListenableBuilder` with `widget.controller.stateNotifier`.
     - Uses `CustomProgressIndicator` for loading state.
     - Handles `Success` and `Error` states.

   **Template**:
   ```dart
   import 'package:flutter/material.dart';
   import '../../core/ui/widgets/custom_progress_indicator.dart';
   import '[feature_name]_controller.dart';
   import '[feature_name]_state.dart';

   class [FeatureName]Page extends StatefulWidget {
     final [FeatureName]Controller controller;

     const [FeatureName]Page({
       super.key,
       required this.controller,
     });

     @override
     State<[FeatureName]Page> createState() => _[FeatureName]PageState();
   }

   class _[FeatureName]PageState extends State<[FeatureName]Page> {
     @override
     void initState() {
       super.initState();
       widget.controller.loadData();
     }

     @override
     Widget build(BuildContext context) {
       return Scaffold(
         appBar: AppBar(title: const Text("[FeatureName]")),
         body: ValueListenableBuilder(
           valueListenable: widget.controller.stateNotifier,
           builder: (context, state, child) {
             if (state is [FeatureName]Loading) {
               return const CustomProgressIndicator();
             }
             if (state is [FeatureName]Success) {
               return const Center(child: Text("Success"));
             }
             if (state is [FeatureName]Error) {
               return Center(child: Text("Error: ${state.message}"));
             }
             return const SizedBox.shrink();
           },
         ),
       );
     }
   }
   ```

5. **Verify Implementation**
   - Check all 3 files exist in the correct directory.
   - Check State extends `BaseState`.
   - Check Controller extends `NotifierController`.
   - Check View uses `ValueListenableBuilder` and `CustomProgressIndicator`.
