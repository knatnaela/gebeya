// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_summary.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$InventorySummary {

 int get totalProducts; num get totalStockValue; num get totalStockQuantity; int get lowStockCount; int get outOfStockCount; List<LowStockProduct> get lowStockProducts; List<OutOfStockProduct> get outOfStockProducts;
/// Create a copy of InventorySummary
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventorySummaryCopyWith<InventorySummary> get copyWith => _$InventorySummaryCopyWithImpl<InventorySummary>(this as InventorySummary, _$identity);

  /// Serializes this InventorySummary to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventorySummary&&(identical(other.totalProducts, totalProducts) || other.totalProducts == totalProducts)&&(identical(other.totalStockValue, totalStockValue) || other.totalStockValue == totalStockValue)&&(identical(other.totalStockQuantity, totalStockQuantity) || other.totalStockQuantity == totalStockQuantity)&&(identical(other.lowStockCount, lowStockCount) || other.lowStockCount == lowStockCount)&&(identical(other.outOfStockCount, outOfStockCount) || other.outOfStockCount == outOfStockCount)&&const DeepCollectionEquality().equals(other.lowStockProducts, lowStockProducts)&&const DeepCollectionEquality().equals(other.outOfStockProducts, outOfStockProducts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalProducts,totalStockValue,totalStockQuantity,lowStockCount,outOfStockCount,const DeepCollectionEquality().hash(lowStockProducts),const DeepCollectionEquality().hash(outOfStockProducts));

@override
String toString() {
  return 'InventorySummary(totalProducts: $totalProducts, totalStockValue: $totalStockValue, totalStockQuantity: $totalStockQuantity, lowStockCount: $lowStockCount, outOfStockCount: $outOfStockCount, lowStockProducts: $lowStockProducts, outOfStockProducts: $outOfStockProducts)';
}


}

/// @nodoc
abstract mixin class $InventorySummaryCopyWith<$Res>  {
  factory $InventorySummaryCopyWith(InventorySummary value, $Res Function(InventorySummary) _then) = _$InventorySummaryCopyWithImpl;
@useResult
$Res call({
 int totalProducts, num totalStockValue, num totalStockQuantity, int lowStockCount, int outOfStockCount, List<LowStockProduct> lowStockProducts, List<OutOfStockProduct> outOfStockProducts
});




}
/// @nodoc
class _$InventorySummaryCopyWithImpl<$Res>
    implements $InventorySummaryCopyWith<$Res> {
  _$InventorySummaryCopyWithImpl(this._self, this._then);

  final InventorySummary _self;
  final $Res Function(InventorySummary) _then;

/// Create a copy of InventorySummary
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalProducts = null,Object? totalStockValue = null,Object? totalStockQuantity = null,Object? lowStockCount = null,Object? outOfStockCount = null,Object? lowStockProducts = null,Object? outOfStockProducts = null,}) {
  return _then(_self.copyWith(
totalProducts: null == totalProducts ? _self.totalProducts : totalProducts // ignore: cast_nullable_to_non_nullable
as int,totalStockValue: null == totalStockValue ? _self.totalStockValue : totalStockValue // ignore: cast_nullable_to_non_nullable
as num,totalStockQuantity: null == totalStockQuantity ? _self.totalStockQuantity : totalStockQuantity // ignore: cast_nullable_to_non_nullable
as num,lowStockCount: null == lowStockCount ? _self.lowStockCount : lowStockCount // ignore: cast_nullable_to_non_nullable
as int,outOfStockCount: null == outOfStockCount ? _self.outOfStockCount : outOfStockCount // ignore: cast_nullable_to_non_nullable
as int,lowStockProducts: null == lowStockProducts ? _self.lowStockProducts : lowStockProducts // ignore: cast_nullable_to_non_nullable
as List<LowStockProduct>,outOfStockProducts: null == outOfStockProducts ? _self.outOfStockProducts : outOfStockProducts // ignore: cast_nullable_to_non_nullable
as List<OutOfStockProduct>,
  ));
}

}


/// Adds pattern-matching-related methods to [InventorySummary].
extension InventorySummaryPatterns on InventorySummary {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventorySummary value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventorySummary() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventorySummary value)  $default,){
final _that = this;
switch (_that) {
case _InventorySummary():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventorySummary value)?  $default,){
final _that = this;
switch (_that) {
case _InventorySummary() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalProducts,  num totalStockValue,  num totalStockQuantity,  int lowStockCount,  int outOfStockCount,  List<LowStockProduct> lowStockProducts,  List<OutOfStockProduct> outOfStockProducts)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventorySummary() when $default != null:
return $default(_that.totalProducts,_that.totalStockValue,_that.totalStockQuantity,_that.lowStockCount,_that.outOfStockCount,_that.lowStockProducts,_that.outOfStockProducts);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalProducts,  num totalStockValue,  num totalStockQuantity,  int lowStockCount,  int outOfStockCount,  List<LowStockProduct> lowStockProducts,  List<OutOfStockProduct> outOfStockProducts)  $default,) {final _that = this;
switch (_that) {
case _InventorySummary():
return $default(_that.totalProducts,_that.totalStockValue,_that.totalStockQuantity,_that.lowStockCount,_that.outOfStockCount,_that.lowStockProducts,_that.outOfStockProducts);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalProducts,  num totalStockValue,  num totalStockQuantity,  int lowStockCount,  int outOfStockCount,  List<LowStockProduct> lowStockProducts,  List<OutOfStockProduct> outOfStockProducts)?  $default,) {final _that = this;
switch (_that) {
case _InventorySummary() when $default != null:
return $default(_that.totalProducts,_that.totalStockValue,_that.totalStockQuantity,_that.lowStockCount,_that.outOfStockCount,_that.lowStockProducts,_that.outOfStockProducts);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _InventorySummary implements InventorySummary {
  const _InventorySummary({required this.totalProducts, required this.totalStockValue, required this.totalStockQuantity, required this.lowStockCount, required this.outOfStockCount, final  List<LowStockProduct> lowStockProducts = const <LowStockProduct>[], final  List<OutOfStockProduct> outOfStockProducts = const <OutOfStockProduct>[]}): _lowStockProducts = lowStockProducts,_outOfStockProducts = outOfStockProducts;
  factory _InventorySummary.fromJson(Map<String, dynamic> json) => _$InventorySummaryFromJson(json);

@override final  int totalProducts;
@override final  num totalStockValue;
@override final  num totalStockQuantity;
@override final  int lowStockCount;
@override final  int outOfStockCount;
 final  List<LowStockProduct> _lowStockProducts;
@override@JsonKey() List<LowStockProduct> get lowStockProducts {
  if (_lowStockProducts is EqualUnmodifiableListView) return _lowStockProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_lowStockProducts);
}

 final  List<OutOfStockProduct> _outOfStockProducts;
@override@JsonKey() List<OutOfStockProduct> get outOfStockProducts {
  if (_outOfStockProducts is EqualUnmodifiableListView) return _outOfStockProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_outOfStockProducts);
}


/// Create a copy of InventorySummary
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventorySummaryCopyWith<_InventorySummary> get copyWith => __$InventorySummaryCopyWithImpl<_InventorySummary>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$InventorySummaryToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventorySummary&&(identical(other.totalProducts, totalProducts) || other.totalProducts == totalProducts)&&(identical(other.totalStockValue, totalStockValue) || other.totalStockValue == totalStockValue)&&(identical(other.totalStockQuantity, totalStockQuantity) || other.totalStockQuantity == totalStockQuantity)&&(identical(other.lowStockCount, lowStockCount) || other.lowStockCount == lowStockCount)&&(identical(other.outOfStockCount, outOfStockCount) || other.outOfStockCount == outOfStockCount)&&const DeepCollectionEquality().equals(other._lowStockProducts, _lowStockProducts)&&const DeepCollectionEquality().equals(other._outOfStockProducts, _outOfStockProducts));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalProducts,totalStockValue,totalStockQuantity,lowStockCount,outOfStockCount,const DeepCollectionEquality().hash(_lowStockProducts),const DeepCollectionEquality().hash(_outOfStockProducts));

@override
String toString() {
  return 'InventorySummary(totalProducts: $totalProducts, totalStockValue: $totalStockValue, totalStockQuantity: $totalStockQuantity, lowStockCount: $lowStockCount, outOfStockCount: $outOfStockCount, lowStockProducts: $lowStockProducts, outOfStockProducts: $outOfStockProducts)';
}


}

/// @nodoc
abstract mixin class _$InventorySummaryCopyWith<$Res> implements $InventorySummaryCopyWith<$Res> {
  factory _$InventorySummaryCopyWith(_InventorySummary value, $Res Function(_InventorySummary) _then) = __$InventorySummaryCopyWithImpl;
@override @useResult
$Res call({
 int totalProducts, num totalStockValue, num totalStockQuantity, int lowStockCount, int outOfStockCount, List<LowStockProduct> lowStockProducts, List<OutOfStockProduct> outOfStockProducts
});




}
/// @nodoc
class __$InventorySummaryCopyWithImpl<$Res>
    implements _$InventorySummaryCopyWith<$Res> {
  __$InventorySummaryCopyWithImpl(this._self, this._then);

  final _InventorySummary _self;
  final $Res Function(_InventorySummary) _then;

/// Create a copy of InventorySummary
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalProducts = null,Object? totalStockValue = null,Object? totalStockQuantity = null,Object? lowStockCount = null,Object? outOfStockCount = null,Object? lowStockProducts = null,Object? outOfStockProducts = null,}) {
  return _then(_InventorySummary(
totalProducts: null == totalProducts ? _self.totalProducts : totalProducts // ignore: cast_nullable_to_non_nullable
as int,totalStockValue: null == totalStockValue ? _self.totalStockValue : totalStockValue // ignore: cast_nullable_to_non_nullable
as num,totalStockQuantity: null == totalStockQuantity ? _self.totalStockQuantity : totalStockQuantity // ignore: cast_nullable_to_non_nullable
as num,lowStockCount: null == lowStockCount ? _self.lowStockCount : lowStockCount // ignore: cast_nullable_to_non_nullable
as int,outOfStockCount: null == outOfStockCount ? _self.outOfStockCount : outOfStockCount // ignore: cast_nullable_to_non_nullable
as int,lowStockProducts: null == lowStockProducts ? _self._lowStockProducts : lowStockProducts // ignore: cast_nullable_to_non_nullable
as List<LowStockProduct>,outOfStockProducts: null == outOfStockProducts ? _self._outOfStockProducts : outOfStockProducts // ignore: cast_nullable_to_non_nullable
as List<OutOfStockProduct>,
  ));
}


}


/// @nodoc
mixin _$LowStockProduct {

 String get id; String get name; num get stockQuantity; num get threshold;
/// Create a copy of LowStockProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$LowStockProductCopyWith<LowStockProduct> get copyWith => _$LowStockProductCopyWithImpl<LowStockProduct>(this as LowStockProduct, _$identity);

  /// Serializes this LowStockProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is LowStockProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.threshold, threshold) || other.threshold == threshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,stockQuantity,threshold);

@override
String toString() {
  return 'LowStockProduct(id: $id, name: $name, stockQuantity: $stockQuantity, threshold: $threshold)';
}


}

/// @nodoc
abstract mixin class $LowStockProductCopyWith<$Res>  {
  factory $LowStockProductCopyWith(LowStockProduct value, $Res Function(LowStockProduct) _then) = _$LowStockProductCopyWithImpl;
@useResult
$Res call({
 String id, String name, num stockQuantity, num threshold
});




}
/// @nodoc
class _$LowStockProductCopyWithImpl<$Res>
    implements $LowStockProductCopyWith<$Res> {
  _$LowStockProductCopyWithImpl(this._self, this._then);

  final LowStockProduct _self;
  final $Res Function(LowStockProduct) _then;

/// Create a copy of LowStockProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? stockQuantity = null,Object? threshold = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as num,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [LowStockProduct].
extension LowStockProductPatterns on LowStockProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _LowStockProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _LowStockProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _LowStockProduct value)  $default,){
final _that = this;
switch (_that) {
case _LowStockProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _LowStockProduct value)?  $default,){
final _that = this;
switch (_that) {
case _LowStockProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  num stockQuantity,  num threshold)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _LowStockProduct() when $default != null:
return $default(_that.id,_that.name,_that.stockQuantity,_that.threshold);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  num stockQuantity,  num threshold)  $default,) {final _that = this;
switch (_that) {
case _LowStockProduct():
return $default(_that.id,_that.name,_that.stockQuantity,_that.threshold);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  num stockQuantity,  num threshold)?  $default,) {final _that = this;
switch (_that) {
case _LowStockProduct() when $default != null:
return $default(_that.id,_that.name,_that.stockQuantity,_that.threshold);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _LowStockProduct implements LowStockProduct {
  const _LowStockProduct({required this.id, required this.name, required this.stockQuantity, required this.threshold});
  factory _LowStockProduct.fromJson(Map<String, dynamic> json) => _$LowStockProductFromJson(json);

@override final  String id;
@override final  String name;
@override final  num stockQuantity;
@override final  num threshold;

/// Create a copy of LowStockProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$LowStockProductCopyWith<_LowStockProduct> get copyWith => __$LowStockProductCopyWithImpl<_LowStockProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$LowStockProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _LowStockProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.stockQuantity, stockQuantity) || other.stockQuantity == stockQuantity)&&(identical(other.threshold, threshold) || other.threshold == threshold));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,stockQuantity,threshold);

@override
String toString() {
  return 'LowStockProduct(id: $id, name: $name, stockQuantity: $stockQuantity, threshold: $threshold)';
}


}

/// @nodoc
abstract mixin class _$LowStockProductCopyWith<$Res> implements $LowStockProductCopyWith<$Res> {
  factory _$LowStockProductCopyWith(_LowStockProduct value, $Res Function(_LowStockProduct) _then) = __$LowStockProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, num stockQuantity, num threshold
});




}
/// @nodoc
class __$LowStockProductCopyWithImpl<$Res>
    implements _$LowStockProductCopyWith<$Res> {
  __$LowStockProductCopyWithImpl(this._self, this._then);

  final _LowStockProduct _self;
  final $Res Function(_LowStockProduct) _then;

/// Create a copy of LowStockProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? stockQuantity = null,Object? threshold = null,}) {
  return _then(_LowStockProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,stockQuantity: null == stockQuantity ? _self.stockQuantity : stockQuantity // ignore: cast_nullable_to_non_nullable
as num,threshold: null == threshold ? _self.threshold : threshold // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$OutOfStockProduct {

 String get id; String get name;
/// Create a copy of OutOfStockProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OutOfStockProductCopyWith<OutOfStockProduct> get copyWith => _$OutOfStockProductCopyWithImpl<OutOfStockProduct>(this as OutOfStockProduct, _$identity);

  /// Serializes this OutOfStockProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OutOfStockProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'OutOfStockProduct(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class $OutOfStockProductCopyWith<$Res>  {
  factory $OutOfStockProductCopyWith(OutOfStockProduct value, $Res Function(OutOfStockProduct) _then) = _$OutOfStockProductCopyWithImpl;
@useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class _$OutOfStockProductCopyWithImpl<$Res>
    implements $OutOfStockProductCopyWith<$Res> {
  _$OutOfStockProductCopyWithImpl(this._self, this._then);

  final OutOfStockProduct _self;
  final $Res Function(OutOfStockProduct) _then;

/// Create a copy of OutOfStockProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [OutOfStockProduct].
extension OutOfStockProductPatterns on OutOfStockProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OutOfStockProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OutOfStockProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OutOfStockProduct value)  $default,){
final _that = this;
switch (_that) {
case _OutOfStockProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OutOfStockProduct value)?  $default,){
final _that = this;
switch (_that) {
case _OutOfStockProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OutOfStockProduct() when $default != null:
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name)  $default,) {final _that = this;
switch (_that) {
case _OutOfStockProduct():
return $default(_that.id,_that.name);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name)?  $default,) {final _that = this;
switch (_that) {
case _OutOfStockProduct() when $default != null:
return $default(_that.id,_that.name);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _OutOfStockProduct implements OutOfStockProduct {
  const _OutOfStockProduct({required this.id, required this.name});
  factory _OutOfStockProduct.fromJson(Map<String, dynamic> json) => _$OutOfStockProductFromJson(json);

@override final  String id;
@override final  String name;

/// Create a copy of OutOfStockProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OutOfStockProductCopyWith<_OutOfStockProduct> get copyWith => __$OutOfStockProductCopyWithImpl<_OutOfStockProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$OutOfStockProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OutOfStockProduct&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name);

@override
String toString() {
  return 'OutOfStockProduct(id: $id, name: $name)';
}


}

/// @nodoc
abstract mixin class _$OutOfStockProductCopyWith<$Res> implements $OutOfStockProductCopyWith<$Res> {
  factory _$OutOfStockProductCopyWith(_OutOfStockProduct value, $Res Function(_OutOfStockProduct) _then) = __$OutOfStockProductCopyWithImpl;
@override @useResult
$Res call({
 String id, String name
});




}
/// @nodoc
class __$OutOfStockProductCopyWithImpl<$Res>
    implements _$OutOfStockProductCopyWith<$Res> {
  __$OutOfStockProductCopyWithImpl(this._self, this._then);

  final _OutOfStockProduct _self;
  final $Res Function(_OutOfStockProduct) _then;

/// Create a copy of OutOfStockProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,}) {
  return _then(_OutOfStockProduct(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
