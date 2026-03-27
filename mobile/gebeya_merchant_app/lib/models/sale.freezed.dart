// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sale.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SaleSeller {

 String get id; String? get firstName; String? get lastName; String? get email;
/// Create a copy of SaleSeller
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleSellerCopyWith<SaleSeller> get copyWith => _$SaleSellerCopyWithImpl<SaleSeller>(this as SaleSeller, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleSeller&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email);

@override
String toString() {
  return 'SaleSeller(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
}


}

/// @nodoc
abstract mixin class $SaleSellerCopyWith<$Res>  {
  factory $SaleSellerCopyWith(SaleSeller value, $Res Function(SaleSeller) _then) = _$SaleSellerCopyWithImpl;
@useResult
$Res call({
 String id, String? firstName, String? lastName, String? email
});




}
/// @nodoc
class _$SaleSellerCopyWithImpl<$Res>
    implements $SaleSellerCopyWith<$Res> {
  _$SaleSellerCopyWithImpl(this._self, this._then);

  final SaleSeller _self;
  final $Res Function(SaleSeller) _then;

/// Create a copy of SaleSeller
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleSeller].
extension SaleSellerPatterns on SaleSeller {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleSeller value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleSeller() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleSeller value)  $default,){
final _that = this;
switch (_that) {
case _SaleSeller():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleSeller value)?  $default,){
final _that = this;
switch (_that) {
case _SaleSeller() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String? firstName,  String? lastName,  String? email)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleSeller() when $default != null:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String? firstName,  String? lastName,  String? email)  $default,) {final _that = this;
switch (_that) {
case _SaleSeller():
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String? firstName,  String? lastName,  String? email)?  $default,) {final _that = this;
switch (_that) {
case _SaleSeller() when $default != null:
return $default(_that.id,_that.firstName,_that.lastName,_that.email);case _:
  return null;

}
}

}

/// @nodoc


class _SaleSeller implements SaleSeller {
  const _SaleSeller({required this.id, this.firstName, this.lastName, this.email});
  

@override final  String id;
@override final  String? firstName;
@override final  String? lastName;
@override final  String? email;

/// Create a copy of SaleSeller
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleSellerCopyWith<_SaleSeller> get copyWith => __$SaleSellerCopyWithImpl<_SaleSeller>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleSeller&&(identical(other.id, id) || other.id == id)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.email, email) || other.email == email));
}


@override
int get hashCode => Object.hash(runtimeType,id,firstName,lastName,email);

@override
String toString() {
  return 'SaleSeller(id: $id, firstName: $firstName, lastName: $lastName, email: $email)';
}


}

/// @nodoc
abstract mixin class _$SaleSellerCopyWith<$Res> implements $SaleSellerCopyWith<$Res> {
  factory _$SaleSellerCopyWith(_SaleSeller value, $Res Function(_SaleSeller) _then) = __$SaleSellerCopyWithImpl;
@override @useResult
$Res call({
 String id, String? firstName, String? lastName, String? email
});




}
/// @nodoc
class __$SaleSellerCopyWithImpl<$Res>
    implements _$SaleSellerCopyWith<$Res> {
  __$SaleSellerCopyWithImpl(this._self, this._then);

  final _SaleSeller _self;
  final $Res Function(_SaleSeller) _then;

/// Create a copy of SaleSeller
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? firstName = freezed,Object? lastName = freezed,Object? email = freezed,}) {
  return _then(_SaleSeller(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

/// @nodoc
mixin _$SaleLineItem {

 String get id; String get productId; String get productName; String? get brand; String? get sku; String? get size; int get quantity; num get unitPrice; num get defaultPrice; num get totalPrice; num get costPrice;
/// Create a copy of SaleLineItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleLineItemCopyWith<SaleLineItem> get copyWith => _$SaleLineItemCopyWithImpl<SaleLineItem>(this as SaleLineItem, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SaleLineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.size, size) || other.size == size)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.defaultPrice, defaultPrice) || other.defaultPrice == defaultPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.costPrice, costPrice) || other.costPrice == costPrice));
}


@override
int get hashCode => Object.hash(runtimeType,id,productId,productName,brand,sku,size,quantity,unitPrice,defaultPrice,totalPrice,costPrice);

@override
String toString() {
  return 'SaleLineItem(id: $id, productId: $productId, productName: $productName, brand: $brand, sku: $sku, size: $size, quantity: $quantity, unitPrice: $unitPrice, defaultPrice: $defaultPrice, totalPrice: $totalPrice, costPrice: $costPrice)';
}


}

/// @nodoc
abstract mixin class $SaleLineItemCopyWith<$Res>  {
  factory $SaleLineItemCopyWith(SaleLineItem value, $Res Function(SaleLineItem) _then) = _$SaleLineItemCopyWithImpl;
@useResult
$Res call({
 String id, String productId, String productName, String? brand, String? sku, String? size, int quantity, num unitPrice, num defaultPrice, num totalPrice, num costPrice
});




}
/// @nodoc
class _$SaleLineItemCopyWithImpl<$Res>
    implements $SaleLineItemCopyWith<$Res> {
  _$SaleLineItemCopyWithImpl(this._self, this._then);

  final SaleLineItem _self;
  final $Res Function(SaleLineItem) _then;

/// Create a copy of SaleLineItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? productId = null,Object? productName = null,Object? brand = freezed,Object? sku = freezed,Object? size = freezed,Object? quantity = null,Object? unitPrice = null,Object? defaultPrice = null,Object? totalPrice = null,Object? costPrice = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as num,defaultPrice: null == defaultPrice ? _self.defaultPrice : defaultPrice // ignore: cast_nullable_to_non_nullable
as num,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as num,costPrice: null == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [SaleLineItem].
extension SaleLineItemPatterns on SaleLineItem {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SaleLineItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SaleLineItem() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SaleLineItem value)  $default,){
final _that = this;
switch (_that) {
case _SaleLineItem():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SaleLineItem value)?  $default,){
final _that = this;
switch (_that) {
case _SaleLineItem() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String productId,  String productName,  String? brand,  String? sku,  String? size,  int quantity,  num unitPrice,  num defaultPrice,  num totalPrice,  num costPrice)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SaleLineItem() when $default != null:
return $default(_that.id,_that.productId,_that.productName,_that.brand,_that.sku,_that.size,_that.quantity,_that.unitPrice,_that.defaultPrice,_that.totalPrice,_that.costPrice);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String productId,  String productName,  String? brand,  String? sku,  String? size,  int quantity,  num unitPrice,  num defaultPrice,  num totalPrice,  num costPrice)  $default,) {final _that = this;
switch (_that) {
case _SaleLineItem():
return $default(_that.id,_that.productId,_that.productName,_that.brand,_that.sku,_that.size,_that.quantity,_that.unitPrice,_that.defaultPrice,_that.totalPrice,_that.costPrice);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String productId,  String productName,  String? brand,  String? sku,  String? size,  int quantity,  num unitPrice,  num defaultPrice,  num totalPrice,  num costPrice)?  $default,) {final _that = this;
switch (_that) {
case _SaleLineItem() when $default != null:
return $default(_that.id,_that.productId,_that.productName,_that.brand,_that.sku,_that.size,_that.quantity,_that.unitPrice,_that.defaultPrice,_that.totalPrice,_that.costPrice);case _:
  return null;

}
}

}

/// @nodoc


class _SaleLineItem implements SaleLineItem {
  const _SaleLineItem({required this.id, required this.productId, required this.productName, this.brand, this.sku, this.size, required this.quantity, required this.unitPrice, required this.defaultPrice, required this.totalPrice, required this.costPrice});
  

@override final  String id;
@override final  String productId;
@override final  String productName;
@override final  String? brand;
@override final  String? sku;
@override final  String? size;
@override final  int quantity;
@override final  num unitPrice;
@override final  num defaultPrice;
@override final  num totalPrice;
@override final  num costPrice;

/// Create a copy of SaleLineItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleLineItemCopyWith<_SaleLineItem> get copyWith => __$SaleLineItemCopyWithImpl<_SaleLineItem>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SaleLineItem&&(identical(other.id, id) || other.id == id)&&(identical(other.productId, productId) || other.productId == productId)&&(identical(other.productName, productName) || other.productName == productName)&&(identical(other.brand, brand) || other.brand == brand)&&(identical(other.sku, sku) || other.sku == sku)&&(identical(other.size, size) || other.size == size)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.unitPrice, unitPrice) || other.unitPrice == unitPrice)&&(identical(other.defaultPrice, defaultPrice) || other.defaultPrice == defaultPrice)&&(identical(other.totalPrice, totalPrice) || other.totalPrice == totalPrice)&&(identical(other.costPrice, costPrice) || other.costPrice == costPrice));
}


@override
int get hashCode => Object.hash(runtimeType,id,productId,productName,brand,sku,size,quantity,unitPrice,defaultPrice,totalPrice,costPrice);

@override
String toString() {
  return 'SaleLineItem(id: $id, productId: $productId, productName: $productName, brand: $brand, sku: $sku, size: $size, quantity: $quantity, unitPrice: $unitPrice, defaultPrice: $defaultPrice, totalPrice: $totalPrice, costPrice: $costPrice)';
}


}

/// @nodoc
abstract mixin class _$SaleLineItemCopyWith<$Res> implements $SaleLineItemCopyWith<$Res> {
  factory _$SaleLineItemCopyWith(_SaleLineItem value, $Res Function(_SaleLineItem) _then) = __$SaleLineItemCopyWithImpl;
@override @useResult
$Res call({
 String id, String productId, String productName, String? brand, String? sku, String? size, int quantity, num unitPrice, num defaultPrice, num totalPrice, num costPrice
});




}
/// @nodoc
class __$SaleLineItemCopyWithImpl<$Res>
    implements _$SaleLineItemCopyWith<$Res> {
  __$SaleLineItemCopyWithImpl(this._self, this._then);

  final _SaleLineItem _self;
  final $Res Function(_SaleLineItem) _then;

/// Create a copy of SaleLineItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? productId = null,Object? productName = null,Object? brand = freezed,Object? sku = freezed,Object? size = freezed,Object? quantity = null,Object? unitPrice = null,Object? defaultPrice = null,Object? totalPrice = null,Object? costPrice = null,}) {
  return _then(_SaleLineItem(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,productId: null == productId ? _self.productId : productId // ignore: cast_nullable_to_non_nullable
as String,productName: null == productName ? _self.productName : productName // ignore: cast_nullable_to_non_nullable
as String,brand: freezed == brand ? _self.brand : brand // ignore: cast_nullable_to_non_nullable
as String?,sku: freezed == sku ? _self.sku : sku // ignore: cast_nullable_to_non_nullable
as String?,size: freezed == size ? _self.size : size // ignore: cast_nullable_to_non_nullable
as String?,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,unitPrice: null == unitPrice ? _self.unitPrice : unitPrice // ignore: cast_nullable_to_non_nullable
as num,defaultPrice: null == defaultPrice ? _self.defaultPrice : defaultPrice // ignore: cast_nullable_to_non_nullable
as num,totalPrice: null == totalPrice ? _self.totalPrice : totalPrice // ignore: cast_nullable_to_non_nullable
as num,costPrice: null == costPrice ? _self.costPrice : costPrice // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

/// @nodoc
mixin _$Sale {

 String get id; DateTime get saleDate; DateTime get createdAt; num get totalAmount; num? get platformFee; String? get customerName; String? get customerPhone; String? get notes; num get netIncome; num get profitMargin; num get costOfGoodsSold; List<SaleLineItem> get items; SaleSeller? get seller; String? get merchantName;
/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SaleCopyWith<Sale> get copyWith => _$SaleCopyWithImpl<Sale>(this as Sale, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Sale&&(identical(other.id, id) || other.id == id)&&(identical(other.saleDate, saleDate) || other.saleDate == saleDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.netIncome, netIncome) || other.netIncome == netIncome)&&(identical(other.profitMargin, profitMargin) || other.profitMargin == profitMargin)&&(identical(other.costOfGoodsSold, costOfGoodsSold) || other.costOfGoodsSold == costOfGoodsSold)&&const DeepCollectionEquality().equals(other.items, items)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.merchantName, merchantName) || other.merchantName == merchantName));
}


@override
int get hashCode => Object.hash(runtimeType,id,saleDate,createdAt,totalAmount,platformFee,customerName,customerPhone,notes,netIncome,profitMargin,costOfGoodsSold,const DeepCollectionEquality().hash(items),seller,merchantName);

@override
String toString() {
  return 'Sale(id: $id, saleDate: $saleDate, createdAt: $createdAt, totalAmount: $totalAmount, platformFee: $platformFee, customerName: $customerName, customerPhone: $customerPhone, notes: $notes, netIncome: $netIncome, profitMargin: $profitMargin, costOfGoodsSold: $costOfGoodsSold, items: $items, seller: $seller, merchantName: $merchantName)';
}


}

/// @nodoc
abstract mixin class $SaleCopyWith<$Res>  {
  factory $SaleCopyWith(Sale value, $Res Function(Sale) _then) = _$SaleCopyWithImpl;
@useResult
$Res call({
 String id, DateTime saleDate, DateTime createdAt, num totalAmount, num? platformFee, String? customerName, String? customerPhone, String? notes, num netIncome, num profitMargin, num costOfGoodsSold, List<SaleLineItem> items, SaleSeller? seller, String? merchantName
});


$SaleSellerCopyWith<$Res>? get seller;

}
/// @nodoc
class _$SaleCopyWithImpl<$Res>
    implements $SaleCopyWith<$Res> {
  _$SaleCopyWithImpl(this._self, this._then);

  final Sale _self;
  final $Res Function(Sale) _then;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? saleDate = null,Object? createdAt = null,Object? totalAmount = null,Object? platformFee = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? notes = freezed,Object? netIncome = null,Object? profitMargin = null,Object? costOfGoodsSold = null,Object? items = null,Object? seller = freezed,Object? merchantName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleDate: null == saleDate ? _self.saleDate : saleDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as num,platformFee: freezed == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as num?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,netIncome: null == netIncome ? _self.netIncome : netIncome // ignore: cast_nullable_to_non_nullable
as num,profitMargin: null == profitMargin ? _self.profitMargin : profitMargin // ignore: cast_nullable_to_non_nullable
as num,costOfGoodsSold: null == costOfGoodsSold ? _self.costOfGoodsSold : costOfGoodsSold // ignore: cast_nullable_to_non_nullable
as num,items: null == items ? _self.items : items // ignore: cast_nullable_to_non_nullable
as List<SaleLineItem>,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as SaleSeller?,merchantName: freezed == merchantName ? _self.merchantName : merchantName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}
/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaleSellerCopyWith<$Res>? get seller {
    if (_self.seller == null) {
    return null;
  }

  return $SaleSellerCopyWith<$Res>(_self.seller!, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}


/// Adds pattern-matching-related methods to [Sale].
extension SalePatterns on Sale {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Sale value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Sale() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Sale value)  $default,){
final _that = this;
switch (_that) {
case _Sale():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Sale value)?  $default,){
final _that = this;
switch (_that) {
case _Sale() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  DateTime saleDate,  DateTime createdAt,  num totalAmount,  num? platformFee,  String? customerName,  String? customerPhone,  String? notes,  num netIncome,  num profitMargin,  num costOfGoodsSold,  List<SaleLineItem> items,  SaleSeller? seller,  String? merchantName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Sale() when $default != null:
return $default(_that.id,_that.saleDate,_that.createdAt,_that.totalAmount,_that.platformFee,_that.customerName,_that.customerPhone,_that.notes,_that.netIncome,_that.profitMargin,_that.costOfGoodsSold,_that.items,_that.seller,_that.merchantName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  DateTime saleDate,  DateTime createdAt,  num totalAmount,  num? platformFee,  String? customerName,  String? customerPhone,  String? notes,  num netIncome,  num profitMargin,  num costOfGoodsSold,  List<SaleLineItem> items,  SaleSeller? seller,  String? merchantName)  $default,) {final _that = this;
switch (_that) {
case _Sale():
return $default(_that.id,_that.saleDate,_that.createdAt,_that.totalAmount,_that.platformFee,_that.customerName,_that.customerPhone,_that.notes,_that.netIncome,_that.profitMargin,_that.costOfGoodsSold,_that.items,_that.seller,_that.merchantName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  DateTime saleDate,  DateTime createdAt,  num totalAmount,  num? platformFee,  String? customerName,  String? customerPhone,  String? notes,  num netIncome,  num profitMargin,  num costOfGoodsSold,  List<SaleLineItem> items,  SaleSeller? seller,  String? merchantName)?  $default,) {final _that = this;
switch (_that) {
case _Sale() when $default != null:
return $default(_that.id,_that.saleDate,_that.createdAt,_that.totalAmount,_that.platformFee,_that.customerName,_that.customerPhone,_that.notes,_that.netIncome,_that.profitMargin,_that.costOfGoodsSold,_that.items,_that.seller,_that.merchantName);case _:
  return null;

}
}

}

/// @nodoc


class _Sale implements Sale {
  const _Sale({required this.id, required this.saleDate, required this.createdAt, required this.totalAmount, this.platformFee, this.customerName, this.customerPhone, this.notes, required this.netIncome, required this.profitMargin, required this.costOfGoodsSold, final  List<SaleLineItem> items = const <SaleLineItem>[], this.seller, this.merchantName}): _items = items;
  

@override final  String id;
@override final  DateTime saleDate;
@override final  DateTime createdAt;
@override final  num totalAmount;
@override final  num? platformFee;
@override final  String? customerName;
@override final  String? customerPhone;
@override final  String? notes;
@override final  num netIncome;
@override final  num profitMargin;
@override final  num costOfGoodsSold;
 final  List<SaleLineItem> _items;
@override@JsonKey() List<SaleLineItem> get items {
  if (_items is EqualUnmodifiableListView) return _items;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_items);
}

@override final  SaleSeller? seller;
@override final  String? merchantName;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SaleCopyWith<_Sale> get copyWith => __$SaleCopyWithImpl<_Sale>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Sale&&(identical(other.id, id) || other.id == id)&&(identical(other.saleDate, saleDate) || other.saleDate == saleDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.totalAmount, totalAmount) || other.totalAmount == totalAmount)&&(identical(other.platformFee, platformFee) || other.platformFee == platformFee)&&(identical(other.customerName, customerName) || other.customerName == customerName)&&(identical(other.customerPhone, customerPhone) || other.customerPhone == customerPhone)&&(identical(other.notes, notes) || other.notes == notes)&&(identical(other.netIncome, netIncome) || other.netIncome == netIncome)&&(identical(other.profitMargin, profitMargin) || other.profitMargin == profitMargin)&&(identical(other.costOfGoodsSold, costOfGoodsSold) || other.costOfGoodsSold == costOfGoodsSold)&&const DeepCollectionEquality().equals(other._items, _items)&&(identical(other.seller, seller) || other.seller == seller)&&(identical(other.merchantName, merchantName) || other.merchantName == merchantName));
}


@override
int get hashCode => Object.hash(runtimeType,id,saleDate,createdAt,totalAmount,platformFee,customerName,customerPhone,notes,netIncome,profitMargin,costOfGoodsSold,const DeepCollectionEquality().hash(_items),seller,merchantName);

@override
String toString() {
  return 'Sale(id: $id, saleDate: $saleDate, createdAt: $createdAt, totalAmount: $totalAmount, platformFee: $platformFee, customerName: $customerName, customerPhone: $customerPhone, notes: $notes, netIncome: $netIncome, profitMargin: $profitMargin, costOfGoodsSold: $costOfGoodsSold, items: $items, seller: $seller, merchantName: $merchantName)';
}


}

/// @nodoc
abstract mixin class _$SaleCopyWith<$Res> implements $SaleCopyWith<$Res> {
  factory _$SaleCopyWith(_Sale value, $Res Function(_Sale) _then) = __$SaleCopyWithImpl;
@override @useResult
$Res call({
 String id, DateTime saleDate, DateTime createdAt, num totalAmount, num? platformFee, String? customerName, String? customerPhone, String? notes, num netIncome, num profitMargin, num costOfGoodsSold, List<SaleLineItem> items, SaleSeller? seller, String? merchantName
});


@override $SaleSellerCopyWith<$Res>? get seller;

}
/// @nodoc
class __$SaleCopyWithImpl<$Res>
    implements _$SaleCopyWith<$Res> {
  __$SaleCopyWithImpl(this._self, this._then);

  final _Sale _self;
  final $Res Function(_Sale) _then;

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? saleDate = null,Object? createdAt = null,Object? totalAmount = null,Object? platformFee = freezed,Object? customerName = freezed,Object? customerPhone = freezed,Object? notes = freezed,Object? netIncome = null,Object? profitMargin = null,Object? costOfGoodsSold = null,Object? items = null,Object? seller = freezed,Object? merchantName = freezed,}) {
  return _then(_Sale(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,saleDate: null == saleDate ? _self.saleDate : saleDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,totalAmount: null == totalAmount ? _self.totalAmount : totalAmount // ignore: cast_nullable_to_non_nullable
as num,platformFee: freezed == platformFee ? _self.platformFee : platformFee // ignore: cast_nullable_to_non_nullable
as num?,customerName: freezed == customerName ? _self.customerName : customerName // ignore: cast_nullable_to_non_nullable
as String?,customerPhone: freezed == customerPhone ? _self.customerPhone : customerPhone // ignore: cast_nullable_to_non_nullable
as String?,notes: freezed == notes ? _self.notes : notes // ignore: cast_nullable_to_non_nullable
as String?,netIncome: null == netIncome ? _self.netIncome : netIncome // ignore: cast_nullable_to_non_nullable
as num,profitMargin: null == profitMargin ? _self.profitMargin : profitMargin // ignore: cast_nullable_to_non_nullable
as num,costOfGoodsSold: null == costOfGoodsSold ? _self.costOfGoodsSold : costOfGoodsSold // ignore: cast_nullable_to_non_nullable
as num,items: null == items ? _self._items : items // ignore: cast_nullable_to_non_nullable
as List<SaleLineItem>,seller: freezed == seller ? _self.seller : seller // ignore: cast_nullable_to_non_nullable
as SaleSeller?,merchantName: freezed == merchantName ? _self.merchantName : merchantName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

/// Create a copy of Sale
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SaleSellerCopyWith<$Res>? get seller {
    if (_self.seller == null) {
    return null;
  }

  return $SaleSellerCopyWith<$Res>(_self.seller!, (value) {
    return _then(_self.copyWith(seller: value));
  });
}
}

// dart format on
