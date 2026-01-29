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
import 'chat_message.spider.dart' as _i2;
import 'chat_response.spider.dart' as _i3;
import 'chat_session.spider.dart' as _i4;
import 'greetings/greeting.dart' as _i5;
import 'task.spider.dart' as _i6;
import 'task_priority.spider.dart' as _i7;
import 'package:butlrapp_client/src/protocol/chat_session.spider.dart' as _i8;
import 'package:butlrapp_client/src/protocol/chat_message.spider.dart' as _i9;
import 'package:butlrapp_client/src/protocol/task.spider.dart' as _i10;
import 'package:serverpod_auth_idp_client/serverpod_auth_idp_client.dart'
    as _i11;
import 'package:serverpod_auth_core_client/serverpod_auth_core_client.dart'
    as _i12;
export 'chat_message.spider.dart';
export 'chat_response.spider.dart';
export 'chat_session.spider.dart';
export 'greetings/greeting.dart';
export 'task.spider.dart';
export 'task_priority.spider.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static String? getClassNameFromObjectJson(dynamic data) {
    if (data is! Map) return null;
    final className = data['__className__'] as String?;
    return className;
  }

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;

    final dataClassName = getClassNameFromObjectJson(data);
    if (dataClassName != null && dataClassName != getClassNameForType(t)) {
      try {
        return deserializeByClassName({
          'className': dataClassName,
          'data': data,
        });
      } on FormatException catch (_) {
        // If the className is not recognized (e.g., older client receiving
        // data with a new subtype), fall back to deserializing without the
        // className, using the expected type T.
      }
    }

    if (t == _i2.ChatMessage) {
      return _i2.ChatMessage.fromJson(data) as T;
    }
    if (t == _i3.ChatResponse) {
      return _i3.ChatResponse.fromJson(data) as T;
    }
    if (t == _i4.ChatSession) {
      return _i4.ChatSession.fromJson(data) as T;
    }
    if (t == _i5.Greeting) {
      return _i5.Greeting.fromJson(data) as T;
    }
    if (t == _i6.Task) {
      return _i6.Task.fromJson(data) as T;
    }
    if (t == _i7.TaskPriority) {
      return _i7.TaskPriority.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.ChatMessage?>()) {
      return (data != null ? _i2.ChatMessage.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.ChatResponse?>()) {
      return (data != null ? _i3.ChatResponse.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.ChatSession?>()) {
      return (data != null ? _i4.ChatSession.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Greeting?>()) {
      return (data != null ? _i5.Greeting.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.Task?>()) {
      return (data != null ? _i6.Task.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.TaskPriority?>()) {
      return (data != null ? _i7.TaskPriority.fromJson(data) : null) as T;
    }
    if (t == List<_i6.Task>) {
      return (data as List).map((e) => deserialize<_i6.Task>(e)).toList() as T;
    }
    if (t == _i1.getType<List<_i6.Task>?>()) {
      return (data != null
              ? (data as List).map((e) => deserialize<_i6.Task>(e)).toList()
              : null)
          as T;
    }
    if (t == List<_i8.ChatSession>) {
      return (data as List).map((e) => deserialize<_i8.ChatSession>(e)).toList()
          as T;
    }
    if (t == List<_i9.ChatMessage>) {
      return (data as List).map((e) => deserialize<_i9.ChatMessage>(e)).toList()
          as T;
    }
    if (t == List<_i10.Task>) {
      return (data as List).map((e) => deserialize<_i10.Task>(e)).toList() as T;
    }
    try {
      return _i11.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    try {
      return _i12.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  static String? getClassNameForType(Type type) {
    return switch (type) {
      _i2.ChatMessage => 'ChatMessage',
      _i3.ChatResponse => 'ChatResponse',
      _i4.ChatSession => 'ChatSession',
      _i5.Greeting => 'Greeting',
      _i6.Task => 'Task',
      _i7.TaskPriority => 'TaskPriority',
      _ => null,
    };
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;

    if (data is Map<String, dynamic> && data['__className__'] is String) {
      return (data['__className__'] as String).replaceFirst('butlrapp.', '');
    }

    switch (data) {
      case _i2.ChatMessage():
        return 'ChatMessage';
      case _i3.ChatResponse():
        return 'ChatResponse';
      case _i4.ChatSession():
        return 'ChatSession';
      case _i5.Greeting():
        return 'Greeting';
      case _i6.Task():
        return 'Task';
      case _i7.TaskPriority():
        return 'TaskPriority';
    }
    className = _i11.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_idp.$className';
    }
    className = _i12.Protocol().getClassNameForObject(data);
    if (className != null) {
      return 'serverpod_auth_core.$className';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'ChatMessage') {
      return deserialize<_i2.ChatMessage>(data['data']);
    }
    if (dataClassName == 'ChatResponse') {
      return deserialize<_i3.ChatResponse>(data['data']);
    }
    if (dataClassName == 'ChatSession') {
      return deserialize<_i4.ChatSession>(data['data']);
    }
    if (dataClassName == 'Greeting') {
      return deserialize<_i5.Greeting>(data['data']);
    }
    if (dataClassName == 'Task') {
      return deserialize<_i6.Task>(data['data']);
    }
    if (dataClassName == 'TaskPriority') {
      return deserialize<_i7.TaskPriority>(data['data']);
    }
    if (dataClassName.startsWith('serverpod_auth_idp.')) {
      data['className'] = dataClassName.substring(19);
      return _i11.Protocol().deserializeByClassName(data);
    }
    if (dataClassName.startsWith('serverpod_auth_core.')) {
      data['className'] = dataClassName.substring(20);
      return _i12.Protocol().deserializeByClassName(data);
    }
    return super.deserializeByClassName(data);
  }

  /// Maps any `Record`s known to this [Protocol] to their JSON representation
  ///
  /// Throws in case the record type is not known.
  ///
  /// This method will return `null` (only) for `null` inputs.
  Map<String, dynamic>? mapRecordToJson(Record? record) {
    if (record == null) {
      return null;
    }
    try {
      return _i11.Protocol().mapRecordToJson(record);
    } catch (_) {}
    try {
      return _i12.Protocol().mapRecordToJson(record);
    } catch (_) {}
    throw Exception('Unsupported record type ${record.runtimeType}');
  }
}
