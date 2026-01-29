/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters
// ignore_for_file: invalid_use_of_internal_member

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'task_priority.spider.dart' as _i2;

abstract class Task implements _i1.SerializableModel {
  Task._({
    this.id,
    required this.title,
    this.description,
    required this.priority,
    this.dueAt,
    this.recurrence,
    this.recurrenceInterval,
    required this.completed,
    required this.createdAt,
  });

  factory Task({
    int? id,
    required String title,
    String? description,
    required _i2.TaskPriority priority,
    DateTime? dueAt,
    String? recurrence,
    int? recurrenceInterval,
    required bool completed,
    required DateTime createdAt,
  }) = _TaskImpl;

  factory Task.fromJson(Map<String, dynamic> jsonSerialization) {
    return Task(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      description: jsonSerialization['description'] as String?,
      priority: _i2.TaskPriority.fromJson(
        (jsonSerialization['priority'] as String),
      ),
      dueAt: jsonSerialization['dueAt'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['dueAt']),
      recurrence: jsonSerialization['recurrence'] as String?,
      recurrenceInterval: jsonSerialization['recurrenceInterval'] as int?,
      completed: jsonSerialization['completed'] as bool,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String title;

  String? description;

  _i2.TaskPriority priority;

  DateTime? dueAt;

  String? recurrence;

  int? recurrenceInterval;

  bool completed;

  DateTime createdAt;

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Task copyWith({
    int? id,
    String? title,
    String? description,
    _i2.TaskPriority? priority,
    DateTime? dueAt,
    String? recurrence,
    int? recurrenceInterval,
    bool? completed,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'Task',
      if (id != null) 'id': id,
      'title': title,
      if (description != null) 'description': description,
      'priority': priority.toJson(),
      if (dueAt != null) 'dueAt': dueAt?.toJson(),
      if (recurrence != null) 'recurrence': recurrence,
      if (recurrenceInterval != null) 'recurrenceInterval': recurrenceInterval,
      'completed': completed,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _TaskImpl extends Task {
  _TaskImpl({
    int? id,
    required String title,
    String? description,
    required _i2.TaskPriority priority,
    DateTime? dueAt,
    String? recurrence,
    int? recurrenceInterval,
    required bool completed,
    required DateTime createdAt,
  }) : super._(
         id: id,
         title: title,
         description: description,
         priority: priority,
         dueAt: dueAt,
         recurrence: recurrence,
         recurrenceInterval: recurrenceInterval,
         completed: completed,
         createdAt: createdAt,
       );

  /// Returns a shallow copy of this [Task]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Task copyWith({
    Object? id = _Undefined,
    String? title,
    Object? description = _Undefined,
    _i2.TaskPriority? priority,
    Object? dueAt = _Undefined,
    Object? recurrence = _Undefined,
    Object? recurrenceInterval = _Undefined,
    bool? completed,
    DateTime? createdAt,
  }) {
    return Task(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      description: description is String? ? description : this.description,
      priority: priority ?? this.priority,
      dueAt: dueAt is DateTime? ? dueAt : this.dueAt,
      recurrence: recurrence is String? ? recurrence : this.recurrence,
      recurrenceInterval: recurrenceInterval is int?
          ? recurrenceInterval
          : this.recurrenceInterval,
      completed: completed ?? this.completed,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
