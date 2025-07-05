/// Base model class for all data models
/// 
/// Provides a common interface for serialization and equality comparison
library;

import 'dart:convert';

abstract class BaseModel {
  final String? id;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const BaseModel({
    this.id,
    this.createdAt,
    this.updatedAt,
  });

  /// Convert the model to a Map
  Map<String, dynamic> toMap();

  /// Convert the model to JSON string
  String toJson() => jsonEncode(toMap());

  /// Create a model from JSON string
  static T fromJson<T extends BaseModel>(String json) {
    throw UnimplementedError('fromJson must be implemented by subclasses');
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseModel) return false;
    return runtimeType == other.runtimeType && id == other.id;
  }

  @override
  int get hashCode => Object.hash(runtimeType, id);
}

/// Mixin for models that need equality comparison based on properties
mixin EquatableMixin on BaseModel {
  /// Properties to use for equality comparison
  List<Object?> get props;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! BaseModel) return false;
    if (runtimeType != other.runtimeType) return false;
    
    if (other is EquatableMixin) {
      final otherProps = other.props;
      if (props.length != otherProps.length) return false;
      
      for (int i = 0; i < props.length; i++) {
        if (props[i] != otherProps[i]) return false;
      }
      return true;
    }
    
    return false;
  }

  @override
  int get hashCode {
    return Object.hashAll(props);
  }
}
