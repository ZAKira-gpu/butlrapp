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

abstract class ChatSession implements _i1.SerializableModel {
  ChatSession._({
    this.id,
    required this.title,
    required this.createdAt,
    this.userId,
  });

  factory ChatSession({
    int? id,
    required String title,
    required DateTime createdAt,
    int? userId,
  }) = _ChatSessionImpl;

  factory ChatSession.fromJson(Map<String, dynamic> jsonSerialization) {
    return ChatSession(
      id: jsonSerialization['id'] as int?,
      title: jsonSerialization['title'] as String,
      createdAt: _i1.DateTimeJsonExtension.fromJson(
        jsonSerialization['createdAt'],
      ),
      userId: jsonSerialization['userId'] as int?,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String title;

  DateTime createdAt;

  int? userId;

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  ChatSession copyWith({
    int? id,
    String? title,
    DateTime? createdAt,
    int? userId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      '__className__': 'ChatSession',
      if (id != null) 'id': id,
      'title': title,
      'createdAt': createdAt.toJson(),
      if (userId != null) 'userId': userId,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ChatSessionImpl extends ChatSession {
  _ChatSessionImpl({
    int? id,
    required String title,
    required DateTime createdAt,
    int? userId,
  }) : super._(
         id: id,
         title: title,
         createdAt: createdAt,
         userId: userId,
       );

  /// Returns a shallow copy of this [ChatSession]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  ChatSession copyWith({
    Object? id = _Undefined,
    String? title,
    DateTime? createdAt,
    Object? userId = _Undefined,
  }) {
    return ChatSession(
      id: id is int? ? id : this.id,
      title: title ?? this.title,
      createdAt: createdAt ?? this.createdAt,
      userId: userId is int? ? userId : this.userId,
    );
  }
}
