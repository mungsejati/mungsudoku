---
description: Create a new Domain Entity and its corresponding Data Model following project rules
---
# Create Entity and Model Workflow

1. **Identify Names**
   - **Entity**:
     - Class Name: PascalCase (e.g., `ProductItem`)
     - File Name: snake_case (e.g., `product_item.dart`)
   - **Model**:
     - Class Name: `[EntityName]Model` (e.g., `ProductItemModel`)
     - File Name: snake_case (e.g., `product_item_model.dart`)

2. **Create the Entity File**
   - Target Directory: `lib/src/domain/entities/`
   - File Path: `lib/src/domain/entities/[file_name].dart`
   - **Rules**:
     - The class MUST extend `Equatable` (from `package:equatable/equatable.dart`).
     - All fields MUST be `final`.
     - The constructor MUST be `const` and use named parameters.
     - You MUST override `props` getter to include all fields for value comparison.

   **Template**:
   ```dart
   import 'package:equatable/equatable.dart';

   class [EntityName] extends Equatable {
     final [Type] [fieldName];

     const [EntityName]({
       required this.[fieldName],
     });

     @override
     List<Object?> get props => [
       [fieldName],
     ];
   }
   ```

3. **Create the Model File**
   - Target Directory: `lib/src/data/models/`
   - File Path: `lib/src/data/models/[model_file_name].dart`
   - **Rules**:
     - The class MUST extend the Entity created in step 2.
     - The constructor MUST be `const` and call `super` with necessary fields.
     - You MUST implement `fromMap(Map<String, dynamic> map)` factory.
     - You MUST implement `toMap()` method.
     - You MUST implement `toJson()` method (using `json.encode`).
     - Import `dart:convert` and the entity file.

   **Template**:
   ```dart
   import 'dart:convert';
   import '../../domain/entities/[entity_file_name].dart';

   class [EntityName]Model extends [EntityName] {
     const [EntityName]Model({
       required super.[fieldName],
     });

     factory [EntityName]Model.fromMap(Map<String, dynamic> map) {
       return [EntityName]Model(
         [fieldName]: map['[json_key]'] ?? [default_value],
       );
     }

     Map<String, dynamic> toMap() {
       return {
         '[json_key]': [fieldName],
       };
     }

     String toJson() => json.encode(toMap());
   }
   ```

4. **Verify Implementation**
   - **Entity**:
     - Check file location `lib/src/domain/entities/`.
     - Check `Equatable` extension and `const` constructor.
   - **Model**:
     - Check file location `lib/src/data/models/`.
     - Check it extends the Entity.
     - Check `fromMap`, `toMap`, `toJson`.
     - Check `super` call in constructor.
