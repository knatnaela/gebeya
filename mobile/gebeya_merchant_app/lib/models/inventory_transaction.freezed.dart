// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_transaction.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryTransaction {

 String get id; String get productId; String get locationId; String get userId; InventoryTransactionType get type; int get quantity; String? get reason; String? get referenceId; String? get referenceType; DateTime get createdAt;// Nested objects (populated from DTO)
 TransactionProduct? get product; Location? get location; TransactionUser? get user;
/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryTransactionCopyWith<InventoryTransaction> get copyWith => _$InventoryTransactionCopyWithImpl<InventoryTransaction>(this as InventoryTransaction, _$identity);

  /// Serializes this InventoryTransaction to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.product, product) || other.product == product)&&(identical(other.location, location) || other.location == location)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,locationId,userId,type,quantity,reason,referenceId,referenceType,createdAt,product,location,user);

@override
String toString() {
  return 'InventoryTransaction(id: $id, productId: $productId, locationId: $locationId, userId: $userId, type: $type, quantity: $quantity, reason: $reason, referenceId: $referenceId, referenceType: $referenceType, createdAt: $createdAt, product: $product, location: $location, user: $user)';
}


}

/// @nodoc
abstract mixin class $InventoryTransactionCopyWith<$Res>  {
  factory $InventoryTransactionCopyWith(InventoryTransaction value, $Res Function(InventoryTransaction) _then) = _$InventoryTransactionCopyWithImpl;
@useResult
$Res call({
 String id, String productId, String locationId, String userId, InventoryTransactionType type, int quantity, String? reason, String? referenceId, String? referenceType, DateTime createdAt, TransactionProduct? product, Location? location, TransactionUser? user
});


$TransactionProductCopyWith<$Res>? get product;$LocationCopyWith<$Res>? get location;$TransactionUserCopyWith<$Res>? get user;

}
/// @nodoc
class _$InventoryTransactionCopyWithImpl<$Res>
    implements $InventoryTransactionCopyWith<$Res> {
  _$InventoryTransactionCopyWithImpl(this._self, this._then);

  final InventoryTransaction _self;
  final $Res Function(InventoryTransaction) _then;

/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? locationId = null,Object? userId = null,Object? type = null,Object? quantity = null,Object? reason = freezed,Object? referenceId = freezed,Object? referenceType = freezed,Object? createdAt = null,Object? product = freezed,Object? location = freezed,Object? user = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InventoryTransactionType,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as TransactionProduct?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as TransactionUser?,
  ));
}
/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionProductCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $TransactionProductCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $TransactionUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [InventoryTransaction].
extension InventoryTransactionPatterns on InventoryTransaction {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryTransaction value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryTransaction() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryTransaction value)  $default,){
final _that = this;
switch (_that) {
case _InventoryTransaction():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryTransaction value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryTransaction() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  String locationId,  String userId,  InventoryTransactionType type,  int quantity,  String? reason,  String? referenceId,  String? referenceType,  DateTime createdAt,  TransactionProduct? product,  Location? location,  TransactionUser? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryTransaction() when $default != null:
return $default(_that.id,_that.productId,_that.locationId,_that.userId,_that.type,_that.quantity,_that.reason,_that.referenceId,_that.referenceType,_that.createdAt,_that.product,_that.location,_that.user);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  String locationId,  String userId,  InventoryTransactionType type,  int quantity,  String? reason,  String? referenceId,  String? referenceType,  DateTime createdAt,  TransactionProduct? product,  Location? location,  TransactionUser? user)  $default,) {final _that = this;
switch (_that) {
case _InventoryTransaction():
return $default(_that.id,_that.productId,_that.locationId,_that.userId,_that.type,_that.quantity,_that.reason,_that.referenceId,_that.referenceType,_that.createdAt,_that.product,_that.location,_that.user);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  String locationId,  String userId,  InventoryTransactionType type,  int quantity,  String? reason,  String? referenceId,  String? referenceType,  DateTime createdAt,  TransactionProduct? product,  Location? location,  TransactionUser? user)?  $default,) {final _that = this;
switch (_that) {
case _InventoryTransaction() when $default != null:
return $default(_that.id,_that.productId,_that.locationId,_that.userId,_that.type,_that.quantity,_that.reason,_that.referenceId,_that.referenceType,_that.createdAt,_that.product,_that.location,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryTransaction implements InventoryTransaction {
  const _InventoryTransaction({required this.id, required this.productId, required this.locationId, required this.userId, required this.type, required this.quantity, this.reason, this.referenceId, this.referenceType, required this.createdAt, this.product, this.location, this.user});
  factory _InventoryTransaction.fromJson(Map<String, dynamic> json) => _$InventoryTransactionFromJson(json);

@override final  String id;
@override final  String productId;
@override final  String locationId;
@override final  String userId;
@override final  InventoryTransactionType type;
@override final  int quantity;
@override final  String? reason;
@override final  String? referenceId;
@override final  String? referenceType;
@override final  DateTime createdAt;
// Nested objects (populated from DTO)
@override final  TransactionProduct? product;
@override final  Location? location;
@override final  TransactionUser? user;

/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryTransactionCopyWith<_InventoryTransaction> get copyWith => __$InventoryTransactionCopyWithImpl<_InventoryTransaction>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryTransactionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryTransaction&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.type, type) || other.type == type)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.reason, reason) || other.reason == reason)&&(identical(other.referenceId, referenceId) || other.referenceId == referenceId)&&(identical(other.referenceType, referenceType) || other.referenceType == referenceType)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.product, product) || other.product == product)&&(identical(other.location, location) || other.location == location)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,productId,locationId,userId,type,quantity,reason,referenceId,referenceType,createdAt,product,location,user);

@override
String toString() {
  return 'InventoryTransaction(id: $id, productId: $productId, locationId: $locationId, userId: $userId, type: $type, quantity: $quantity, reason: $reason, referenceId: $referenceId, referenceType: $referenceType, createdAt: $createdAt, product: $product, location: $location, user: $user)';
}


}

/// @nodoc
abstract mixin class _$InventoryTransactionCopyWith<$Res> implements $InventoryTransactionCopyWith<$Res> {
  factory _$InventoryTransactionCopyWith(_InventoryTransaction value, $Res Function(_InventoryTransaction) _then) = __$InventoryTransactionCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, String locationId, String userId, InventoryTransactionType type, int quantity, String? reason, String? referenceId, String? referenceType, DateTime createdAt, TransactionProduct? product, Location? location, TransactionUser? user
});


@override $TransactionProductCopyWith<$Res>? get product;@override $LocationCopyWith<$Res>? get location;@override $TransactionUserCopyWith<$Res>? get user;

}
/// @nodoc
class __$InventoryTransactionCopyWithImpl<$Res>
    implements _$InventoryTransactionCopyWith<$Res> {
  __$InventoryTransactionCopyWithImpl(this._self, this._then);

  final _InventoryTransaction _self;
  final $Res Function(_InventoryTransaction) _then;

/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? locationId = null,Object? userId = null,Object? type = null,Object? quantity = null,Object? reason = freezed,Object? referenceId = freezed,Object? referenceType = freezed,Object? createdAt = null,Object? product = freezed,Object? location = freezed,Object? user = freezed,}) {
  return _then(_InventoryTransaction(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as InventoryTransactionType,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,reason: freezed == reason ? _self.reason : reason // ignore: cast_nullable_to_non_nullable
as String?,referenceId: freezed == referenceId ? _self.referenceId : referenceId // ignore: cast_nullable_to_non_nullable
as String?,referenceType: freezed == referenceType ? _self.referenceType : referenceType // ignore: cast_nullable_to_non_nullable
as String?,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as TransactionProduct?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as TransactionUser?,
  ));
}

/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionProductCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $TransactionProductCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$LocationCopyWith<$Res>? get location {
    if (_self.location == null) {
    return null;
  }

  return $LocationCopyWith<$Res>(_self.location!, (value) {
    return _then(_self.copyWith(location: value));
  });
}/// Create a copy of InventoryTransaction
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$TransactionUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $TransactionUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$TransactionProduct {

 String get id; String get name; String? get brand; String? get sku;
/// Create a copy of TransactionProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionProductCopyWith<TransactionProduct> get copyWith => _$TransactionProductCopyWithImpl<TransactionProduct>(this as TransactionProduct, _$identity);

  /// Serializes this TransactionProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.sku, sku) || other.sku == sku));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,sku);

@override
String toString() {
  return 'TransactionProduct(id: $id, name: $name, brand: $brand, sku: $sku)';
}


}

/// @nodoc
abstract mixin class $TransactionProductCopyWith<$Res>  {
  factory $TransactionProductCopyWith(TransactionProduct value, $Res Function(TransactionProduct) _then) = _$TransactionProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? brand, String? sku
});




}
/// @nodoc
class _$TransactionProductCopyWithImpl<$Res>
    implements $TransactionProductCopyWith<$Res> {
  _$TransactionProductCopyWithImpl(this._self, this._then);

  final TransactionProduct _self;
  final $Res Function(TransactionProduct) _then;

/// Create a copy of TransactionProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? brand = freezed,Object? sku = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionProduct].
extension TransactionProductPatterns on TransactionProduct {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionProduct() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionProduct value)  $default,){
final _that = this;
switch (_that) {
case _TransactionProduct():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionProduct value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionProduct() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  String? brand,  String? sku)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.sku);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  String? brand,  String? sku)  $default,) {final _that = this;
switch (_that) {
case _TransactionProduct():
return $default(_that.id,_that.name,_that.brand,_that.sku);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  String? brand,  String? sku)?  $default,) {final _that = this;
switch (_that) {
case _TransactionProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.sku);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionProduct implements TransactionProduct {
  const _TransactionProduct({required this.id, required this.name, this.brand, this.sku});
  factory _TransactionProduct.fromJson(Map<String, dynamic> json) => _$TransactionProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? brand;
@override final  String? sku;

/// Create a copy of TransactionProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionProductCopyWith<_TransactionProduct> get copyWith => __$TransactionProductCopyWithImpl<_TransactionProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.sku, sku) || other.sku == sku));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,sku);

@override
String toString() {
  return 'TransactionProduct(id: $id, name: $name, brand: $brand, sku: $sku)';
}


}

/// @nodoc
abstract mixin class _$TransactionProductCopyWith<$Res> implements $TransactionProductCopyWith<$Res> {
  factory _$TransactionProductCopyWith(_TransactionProduct value, $Res Function(_TransactionProduct) _then) = __$TransactionProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? brand, String? sku
});




}
/// @nodoc
class __$TransactionProductCopyWithImpl<$Res>
    implements _$TransactionProductCopyWith<$Res> {
  __$TransactionProductCopyWithImpl(this._self, this._then);

  final _TransactionProduct _self;
  final $Res Function(_TransactionProduct) _then;

/// Create a copy of TransactionProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = freezed,Object? sku = freezed,}) {
  return _then(_TransactionProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$TransactionUser {

 String get id; String get firstName; String? get lastName; String? get email;
/// Create a copy of TransactionUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TransactionUserCopyWith<TransactionUser> get copyWith => _$TransactionUserCopyWithImpl<TransactionUser>(this as TransactionUser, _$identity);

  /// Serializes this TransactionUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TransactionUser&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email);

@override
String toString() {
  return 'TransactionUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
}


}

/// @nodoc
abstract mixin class $TransactionUserCopyWith<$Res>  {
  factory $TransactionUserCopyWith(TransactionUser value, $Res Function(TransactionUser) _then) = _$TransactionUserCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String? lastName, String? email
});




}
/// @nodoc
class _$TransactionUserCopyWithImpl<$Res>
    implements $TransactionUserCopyWith<$Res> {
  _$TransactionUserCopyWithImpl(this._self, this._then);

  final TransactionUser _self;
  final $Res Function(TransactionUser) _then;

/// Create a copy of TransactionUser
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = null,Object? lastName = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [TransactionUser].
extension TransactionUserPatterns on TransactionUser {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TransactionUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TransactionUser() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TransactionUser value)  $default,){
final _that = this;
switch (_that) {
case _TransactionUser():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TransactionUser value)?  $default,){
final _that = this;
switch (_that) {
case _TransactionUser() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String firstName,  String? lastName,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TransactionUser() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String firstName,  String? lastName,  String? email)  $default,) {final _that = this;
switch (_that) {
case _TransactionUser():
return $default(_that.id,_that.firstName,_that.lastName,_that.email);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String firstName,  String? lastName,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _TransactionUser() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TransactionUser implements TransactionUser {
  const _TransactionUser({required this.id, required this.firstName, this.lastName, this.email});
  factory _TransactionUser.fromJson(Map<String, dynamic> json) => _$TransactionUserFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String? lastName;
@override final  String? email;

/// Create a copy of TransactionUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TransactionUserCopyWith<_TransactionUser> get copyWith => __$TransactionUserCopyWithImpl<_TransactionUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TransactionUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TransactionUser&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email);

@override
String toString() {
  return 'TransactionUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
}


}

/// @nodoc
abstract mixin class _$TransactionUserCopyWith<$Res> implements $TransactionUserCopyWith<$Res> {
  factory _$TransactionUserCopyWith(_TransactionUser value, $Res Function(_TransactionUser) _then) = __$TransactionUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String? lastName, String? email
});




}
/// @nodoc
class __$TransactionUserCopyWithImpl<$Res>
    implements _$TransactionUserCopyWith<$Res> {
  __$TransactionUserCopyWithImpl(this._self, this._then);

  final _TransactionUser _self;
  final $Res Function(_TransactionUser) _then;

/// Create a copy of TransactionUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = freezed,Object? email = freezed,}) {
  return _then(_TransactionUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
