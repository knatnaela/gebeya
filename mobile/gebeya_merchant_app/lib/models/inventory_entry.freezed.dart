// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_entry.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventoryEntry {

 String get id; String get productId; String get locationId; int get quantity; String? get batchNumber; DateTime? get expirationDate; DateTime get receivedDate; String? get notes; String get addedBy; PaymentStatus get paymentStatus; String? get supplierName; String? get supplierContact;/// Unsold units in this batch (FIFO).
 int? get remainingQuantity;/// Unit cost frozen at receipt.
 double? get unitCost; double? get totalCost; double? get paidAmount; DateTime? get paymentDueDate; DateTime? get paidAt;// Nested objects (populated from DTO)
 EntryProduct? get product; Location? get location; EntryUser? get user;
/// Create a copy of InventoryEntry
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryEntryCopyWith<InventoryEntry> get copyWith => _$InventoryEntryCopyWithImpl<InventoryEntry>(this as InventoryEntry, _$identity);

  /// Serializes this InventoryEntry to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.batchNumber, batchNumber) || other.batchNumber == batchNumber)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.receivedDate, receivedDate) || other.receivedDate == receivedDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.addedBy, addedBy) || other.addedBy == addedBy)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.supplierContact, supplierContact) || other.supplierContact == supplierContact)&&(identical(other.remainingQuantity, remainingQuantity) || other.remainingQuantity == remainingQuantity)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.paymentDueDate, paymentDueDate) || other.paymentDueDate == paymentDueDate)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.product, product) || other.product == product)&&(identical(other.location, location) || other.location == location)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,productId,locationId,quantity,batchNumber,expirationDate,receivedDate,notes,addedBy,paymentStatus,supplierName,supplierContact,remainingQuantity,unitCost,totalCost,paidAmount,paymentDueDate,paidAt,product,location,user]);

@override
String toString() {
  return 'InventoryEntry(id: $id, productId: $productId, locationId: $locationId, quantity: $quantity, batchNumber: $batchNumber, expirationDate: $expirationDate, receivedDate: $receivedDate, notes: $notes, addedBy: $addedBy, paymentStatus: $paymentStatus, supplierName: $supplierName, supplierContact: $supplierContact, remainingQuantity: $remainingQuantity, unitCost: $unitCost, totalCost: $totalCost, paidAmount: $paidAmount, paymentDueDate: $paymentDueDate, paidAt: $paidAt, product: $product, location: $location, user: $user)';
}


}

/// @nodoc
abstract mixin class $InventoryEntryCopyWith<$Res>  {
  factory $InventoryEntryCopyWith(InventoryEntry value, $Res Function(InventoryEntry) _then) = _$InventoryEntryCopyWithImpl;
@useResult
$Res call({
 String id, String productId, String locationId, int quantity, String? batchNumber, DateTime? expirationDate, DateTime receivedDate, String? notes, String addedBy, PaymentStatus paymentStatus, String? supplierName, String? supplierContact, int? remainingQuantity, double? unitCost, double? totalCost, double? paidAmount, DateTime? paymentDueDate, DateTime? paidAt, EntryProduct? product, Location? location, EntryUser? user
});


$EntryProductCopyWith<$Res>? get product;$LocationCopyWith<$Res>? get location;$EntryUserCopyWith<$Res>? get user;

}
/// @nodoc
class _$InventoryEntryCopyWithImpl<$Res>
    implements $InventoryEntryCopyWith<$Res> {
  _$InventoryEntryCopyWithImpl(this._self, this._then);

  final InventoryEntry _self;
  final $Res Function(InventoryEntry) _then;

/// Create a copy of InventoryEntry
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? locationId = null,Object? quantity = null,Object? batchNumber = freezed,Object? expirationDate = freezed,Object? receivedDate = null,Object? notes = freezed,Object? addedBy = null,Object? paymentStatus = null,Object? supplierName = freezed,Object? supplierContact = freezed,Object? remainingQuantity = freezed,Object? unitCost = freezed,Object? totalCost = freezed,Object? paidAmount = freezed,Object? paymentDueDate = freezed,Object? paidAt = freezed,Object? product = freezed,Object? location = freezed,Object? user = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,batchNumber: freezed == batchNumber ? _self.batchNumber : batchNumber // ignore: cast_nullable_to_non_nullable
as String?,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedDate: null == receivedDate ? _self.receivedDate : receivedDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,addedBy: null == addedBy ? _self.addedBy : addedBy // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,supplierContact: freezed == supplierContact ? _self.supplierContact : supplierContact // ignore: cast_nullable_to_non_nullable
as String?,remainingQuantity: freezed == remainingQuantity ? _self.remainingQuantity : remainingQuantity // ignore: cast_nullable_to_non_nullable
as int?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as double?,totalCost: freezed == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double?,paidAmount: freezed == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double?,paymentDueDate: freezed == paymentDueDate ? _self.paymentDueDate : paymentDueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as EntryProduct?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as EntryUser?,
  ));
}
/// Create a copy of InventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryProductCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $EntryProductCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of InventoryEntry
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
}/// Create a copy of InventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $EntryUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// Adds pattern-matching-related methods to [InventoryEntry].
extension InventoryEntryPatterns on InventoryEntry {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryEntry value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryEntry() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryEntry value)  $default,){
final _that = this;
switch (_that) {
case _InventoryEntry():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryEntry value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryEntry() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  String locationId,  int quantity,  String? batchNumber,  DateTime? expirationDate,  DateTime receivedDate,  String? notes,  String addedBy,  PaymentStatus paymentStatus,  String? supplierName,  String? supplierContact,  int? remainingQuantity,  double? unitCost,  double? totalCost,  double? paidAmount,  DateTime? paymentDueDate,  DateTime? paidAt,  EntryProduct? product,  Location? location,  EntryUser? user)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryEntry() when $default != null:
return $default(_that.id,_that.productId,_that.locationId,_that.quantity,_that.batchNumber,_that.expirationDate,_that.receivedDate,_that.notes,_that.addedBy,_that.paymentStatus,_that.supplierName,_that.supplierContact,_that.remainingQuantity,_that.unitCost,_that.totalCost,_that.paidAmount,_that.paymentDueDate,_that.paidAt,_that.product,_that.location,_that.user);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  String locationId,  int quantity,  String? batchNumber,  DateTime? expirationDate,  DateTime receivedDate,  String? notes,  String addedBy,  PaymentStatus paymentStatus,  String? supplierName,  String? supplierContact,  int? remainingQuantity,  double? unitCost,  double? totalCost,  double? paidAmount,  DateTime? paymentDueDate,  DateTime? paidAt,  EntryProduct? product,  Location? location,  EntryUser? user)  $default,) {final _that = this;
switch (_that) {
case _InventoryEntry():
return $default(_that.id,_that.productId,_that.locationId,_that.quantity,_that.batchNumber,_that.expirationDate,_that.receivedDate,_that.notes,_that.addedBy,_that.paymentStatus,_that.supplierName,_that.supplierContact,_that.remainingQuantity,_that.unitCost,_that.totalCost,_that.paidAmount,_that.paymentDueDate,_that.paidAt,_that.product,_that.location,_that.user);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  String locationId,  int quantity,  String? batchNumber,  DateTime? expirationDate,  DateTime receivedDate,  String? notes,  String addedBy,  PaymentStatus paymentStatus,  String? supplierName,  String? supplierContact,  int? remainingQuantity,  double? unitCost,  double? totalCost,  double? paidAmount,  DateTime? paymentDueDate,  DateTime? paidAt,  EntryProduct? product,  Location? location,  EntryUser? user)?  $default,) {final _that = this;
switch (_that) {
case _InventoryEntry() when $default != null:
return $default(_that.id,_that.productId,_that.locationId,_that.quantity,_that.batchNumber,_that.expirationDate,_that.receivedDate,_that.notes,_that.addedBy,_that.paymentStatus,_that.supplierName,_that.supplierContact,_that.remainingQuantity,_that.unitCost,_that.totalCost,_that.paidAmount,_that.paymentDueDate,_that.paidAt,_that.product,_that.location,_that.user);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventoryEntry implements InventoryEntry {
  const _InventoryEntry({required this.id, required this.productId, required this.locationId, required this.quantity, this.batchNumber, this.expirationDate, required this.receivedDate, this.notes, required this.addedBy, this.paymentStatus = PaymentStatus.paid, this.supplierName, this.supplierContact, this.remainingQuantity, this.unitCost, this.totalCost, this.paidAmount, this.paymentDueDate, this.paidAt, this.product, this.location, this.user});
  factory _InventoryEntry.fromJson(Map<String, dynamic> json) => _$InventoryEntryFromJson(json);

@override final  String id;
@override final  String productId;
@override final  String locationId;
@override final  int quantity;
@override final  String? batchNumber;
@override final  DateTime? expirationDate;
@override final  DateTime receivedDate;
@override final  String? notes;
@override final  String addedBy;
@override@JsonKey() final  PaymentStatus paymentStatus;
@override final  String? supplierName;
@override final  String? supplierContact;
/// Unsold units in this batch (FIFO).
@override final  int? remainingQuantity;
/// Unit cost frozen at receipt.
@override final  double? unitCost;
@override final  double? totalCost;
@override final  double? paidAmount;
@override final  DateTime? paymentDueDate;
@override final  DateTime? paidAt;
// Nested objects (populated from DTO)
@override final  EntryProduct? product;
@override final  Location? location;
@override final  EntryUser? user;

/// Create a copy of InventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryEntryCopyWith<_InventoryEntry> get copyWith => __$InventoryEntryCopyWithImpl<_InventoryEntry>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventoryEntryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryEntry&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.locationId, locationId) || other.locationId == locationId)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.batchNumber, batchNumber) || other.batchNumber == batchNumber)&&(identical(other.expirationDate, expirationDate) || other.expirationDate == expirationDate)&&(identical(other.receivedDate, receivedDate) || other.receivedDate == receivedDate)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.addedBy, addedBy) || other.addedBy == addedBy)&&(identical(other.paymentStatus, paymentStatus) || other.paymentStatus == paymentStatus)&&(identical(other.supplierName, supplierName) || other.supplierName == supplierName)&&(identical(other.supplierContact, supplierContact) || other.supplierContact == supplierContact)&&(identical(other.remainingQuantity, remainingQuantity) || other.remainingQuantity == remainingQuantity)&&(identical(other.unitCost, unitCost) || other.unitCost == unitCost)&&(identical(other.totalCost, totalCost) || other.totalCost == totalCost)&&(identical(other.paidAmount, paidAmount) || other.paidAmount == paidAmount)&&(identical(other.paymentDueDate, paymentDueDate) || other.paymentDueDate == paymentDueDate)&&(identical(other.paidAt, paidAt) || other.paidAt == paidAt)&&(identical(other.product, product) || other.product == product)&&(identical(other.location, location) || other.location == location)&&(identical(other.user, user) || other.user == user));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,productId,locationId,quantity,batchNumber,expirationDate,receivedDate,notes,addedBy,paymentStatus,supplierName,supplierContact,remainingQuantity,unitCost,totalCost,paidAmount,paymentDueDate,paidAt,product,location,user]);

@override
String toString() {
  return 'InventoryEntry(id: $id, productId: $productId, locationId: $locationId, quantity: $quantity, batchNumber: $batchNumber, expirationDate: $expirationDate, receivedDate: $receivedDate, notes: $notes, addedBy: $addedBy, paymentStatus: $paymentStatus, supplierName: $supplierName, supplierContact: $supplierContact, remainingQuantity: $remainingQuantity, unitCost: $unitCost, totalCost: $totalCost, paidAmount: $paidAmount, paymentDueDate: $paymentDueDate, paidAt: $paidAt, product: $product, location: $location, user: $user)';
}


}

/// @nodoc
abstract mixin class _$InventoryEntryCopyWith<$Res> implements $InventoryEntryCopyWith<$Res> {
  factory _$InventoryEntryCopyWith(_InventoryEntry value, $Res Function(_InventoryEntry) _then) = __$InventoryEntryCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, String locationId, int quantity, String? batchNumber, DateTime? expirationDate, DateTime receivedDate, String? notes, String addedBy, PaymentStatus paymentStatus, String? supplierName, String? supplierContact, int? remainingQuantity, double? unitCost, double? totalCost, double? paidAmount, DateTime? paymentDueDate, DateTime? paidAt, EntryProduct? product, Location? location, EntryUser? user
});


@override $EntryProductCopyWith<$Res>? get product;@override $LocationCopyWith<$Res>? get location;@override $EntryUserCopyWith<$Res>? get user;

}
/// @nodoc
class __$InventoryEntryCopyWithImpl<$Res>
    implements _$InventoryEntryCopyWith<$Res> {
  __$InventoryEntryCopyWithImpl(this._self, this._then);

  final _InventoryEntry _self;
  final $Res Function(_InventoryEntry) _then;

/// Create a copy of InventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? locationId = null,Object? quantity = null,Object? batchNumber = freezed,Object? expirationDate = freezed,Object? receivedDate = null,Object? notes = freezed,Object? addedBy = null,Object? paymentStatus = null,Object? supplierName = freezed,Object? supplierContact = freezed,Object? remainingQuantity = freezed,Object? unitCost = freezed,Object? totalCost = freezed,Object? paidAmount = freezed,Object? paymentDueDate = freezed,Object? paidAt = freezed,Object? product = freezed,Object? location = freezed,Object? user = freezed,}) {
  return _then(_InventoryEntry(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,locationId: null == locationId ? _self.locationId : locationId // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,batchNumber: freezed == batchNumber ? _self.batchNumber : batchNumber // ignore: cast_nullable_to_non_nullable
as String?,expirationDate: freezed == expirationDate ? _self.expirationDate : expirationDate // ignore: cast_nullable_to_non_nullable
as DateTime?,receivedDate: null == receivedDate ? _self.receivedDate : receivedDate // ignore: cast_nullable_to_non_nullable
as DateTime,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,addedBy: null == addedBy ? _self.addedBy : addedBy // ignore: cast_nullable_to_non_nullable
as String,paymentStatus: null == paymentStatus ? _self.paymentStatus : paymentStatus // ignore: cast_nullable_to_non_nullable
as PaymentStatus,supplierName: freezed == supplierName ? _self.supplierName : supplierName // ignore: cast_nullable_to_non_nullable
as String?,supplierContact: freezed == supplierContact ? _self.supplierContact : supplierContact // ignore: cast_nullable_to_non_nullable
as String?,remainingQuantity: freezed == remainingQuantity ? _self.remainingQuantity : remainingQuantity // ignore: cast_nullable_to_non_nullable
as int?,unitCost: freezed == unitCost ? _self.unitCost : unitCost // ignore: cast_nullable_to_non_nullable
as double?,totalCost: freezed == totalCost ? _self.totalCost : totalCost // ignore: cast_nullable_to_non_nullable
as double?,paidAmount: freezed == paidAmount ? _self.paidAmount : paidAmount // ignore: cast_nullable_to_non_nullable
as double?,paymentDueDate: freezed == paymentDueDate ? _self.paymentDueDate : paymentDueDate // ignore: cast_nullable_to_non_nullable
as DateTime?,paidAt: freezed == paidAt ? _self.paidAt : paidAt // ignore: cast_nullable_to_non_nullable
as DateTime?,product: freezed == product ? _self.product : product // ignore: cast_nullable_to_non_nullable
as EntryProduct?,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as Location?,user: freezed == user ? _self.user : user // ignore: cast_nullable_to_non_nullable
as EntryUser?,
  ));
}

/// Create a copy of InventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryProductCopyWith<$Res>? get product {
    if (_self.product == null) {
    return null;
  }

  return $EntryProductCopyWith<$Res>(_self.product!, (value) {
    return _then(_self.copyWith(product: value));
  });
}/// Create a copy of InventoryEntry
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
}/// Create a copy of InventoryEntry
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$EntryUserCopyWith<$Res>? get user {
    if (_self.user == null) {
    return null;
  }

  return $EntryUserCopyWith<$Res>(_self.user!, (value) {
    return _then(_self.copyWith(user: value));
  });
}
}


/// @nodoc
mixin _$EntryProduct {

 String get id; String get name; String? get brand; String? get sku;
/// Create a copy of EntryProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryProductCopyWith<EntryProduct> get copyWith => _$EntryProductCopyWithImpl<EntryProduct>(this as EntryProduct, _$identity);

  /// Serializes this EntryProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.sku, sku) || other.sku == sku));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,sku);

@override
String toString() {
  return 'EntryProduct(id: $id, name: $name, brand: $brand, sku: $sku)';
}


}

/// @nodoc
abstract mixin class $EntryProductCopyWith<$Res>  {
  factory $EntryProductCopyWith(EntryProduct value, $Res Function(EntryProduct) _then) = _$EntryProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, String? brand, String? sku
});




}
/// @nodoc
class _$EntryProductCopyWithImpl<$Res>
    implements $EntryProductCopyWith<$Res> {
  _$EntryProductCopyWithImpl(this._self, this._then);

  final EntryProduct _self;
  final $Res Function(EntryProduct) _then;

/// Create a copy of EntryProduct
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


/// Adds pattern-matching-related methods to [EntryProduct].
extension EntryProductPatterns on EntryProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryProduct value)  $default,){
final _that = this;
switch (_that) {
case _EntryProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryProduct value)?  $default,){
final _that = this;
switch (_that) {
case _EntryProduct() when $default != null:
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
case _EntryProduct() when $default != null:
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
case _EntryProduct():
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
case _EntryProduct() when $default != null:
return $default(_that.id,_that.name,_that.brand,_that.sku);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntryProduct implements EntryProduct {
  const _EntryProduct({required this.id, required this.name, this.brand, this.sku});
  factory _EntryProduct.fromJson(Map<String, dynamic> json) => _$EntryProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  String? brand;
@override final  String? sku;

/// Create a copy of EntryProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryProductCopyWith<_EntryProduct> get copyWith => __$EntryProductCopyWithImpl<_EntryProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntryProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.sku, sku) || other.sku == sku));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,brand,sku);

@override
String toString() {
  return 'EntryProduct(id: $id, name: $name, brand: $brand, sku: $sku)';
}


}

/// @nodoc
abstract mixin class _$EntryProductCopyWith<$Res> implements $EntryProductCopyWith<$Res> {
  factory _$EntryProductCopyWith(_EntryProduct value, $Res Function(_EntryProduct) _then) = __$EntryProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, String? brand, String? sku
});




}
/// @nodoc
class __$EntryProductCopyWithImpl<$Res>
    implements _$EntryProductCopyWith<$Res> {
  __$EntryProductCopyWithImpl(this._self, this._then);

  final _EntryProduct _self;
  final $Res Function(_EntryProduct) _then;

/// Create a copy of EntryProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? brand = freezed,Object? sku = freezed,}) {
  return _then(_EntryProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$EntryUser {

 String get id; String get firstName; String? get lastName; String? get email;
/// Create a copy of EntryUser
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$EntryUserCopyWith<EntryUser> get copyWith => _$EntryUserCopyWithImpl<EntryUser>(this as EntryUser, _$identity);

  /// Serializes this EntryUser to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is EntryUser&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email);

@override
String toString() {
  return 'EntryUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
}


}

/// @nodoc
abstract mixin class $EntryUserCopyWith<$Res>  {
  factory $EntryUserCopyWith(EntryUser value, $Res Function(EntryUser) _then) = _$EntryUserCopyWithImpl;
@useResult
$Res call({
 String id, String firstName, String? lastName, String? email
});




}
/// @nodoc
class _$EntryUserCopyWithImpl<$Res>
    implements $EntryUserCopyWith<$Res> {
  _$EntryUserCopyWithImpl(this._self, this._then);

  final EntryUser _self;
  final $Res Function(EntryUser) _then;

/// Create a copy of EntryUser
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


/// Adds pattern-matching-related methods to [EntryUser].
extension EntryUserPatterns on EntryUser {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _EntryUser value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _EntryUser() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _EntryUser value)  $default,){
final _that = this;
switch (_that) {
case _EntryUser():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _EntryUser value)?  $default,){
final _that = this;
switch (_that) {
case _EntryUser() when $default != null:
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
case _EntryUser() when $default != null:
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
case _EntryUser():
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
case _EntryUser() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _EntryUser implements EntryUser {
  const _EntryUser({required this.id, required this.firstName, this.lastName, this.email});
  factory _EntryUser.fromJson(Map<String, dynamic> json) => _$EntryUserFromJson(json);

@override final  String id;
@override final  String firstName;
@override final  String? lastName;
@override final  String? email;

/// Create a copy of EntryUser
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$EntryUserCopyWith<_EntryUser> get copyWith => __$EntryUserCopyWithImpl<_EntryUser>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$EntryUserToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _EntryUser&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email);

@override
String toString() {
  return 'EntryUser(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
}


}

/// @nodoc
abstract mixin class _$EntryUserCopyWith<$Res> implements $EntryUserCopyWith<$Res> {
  factory _$EntryUserCopyWith(_EntryUser value, $Res Function(_EntryUser) _then) = __$EntryUserCopyWithImpl;
@override @useResult
$Res call({
 String id, String firstName, String? lastName, String? email
});




}
/// @nodoc
class __$EntryUserCopyWithImpl<$Res>
    implements _$EntryUserCopyWith<$Res> {
  __$EntryUserCopyWithImpl(this._self, this._then);

  final _EntryUser _self;
  final $Res Function(_EntryUser) _then;

/// Create a copy of EntryUser
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = null,Object? lastName = freezed,Object? email = freezed,}) {
  return _then(_EntryUser(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: null == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
