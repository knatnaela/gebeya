// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_analytics.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$SalesAnalytics {

 int get totalSales; num get totalRevenue; num get totalCostOfGoodsSold; num get grossProfit; num get totalExpenses; num get netProfit; num get profitMargin; num get averageSaleAmount; List<TopProduct> get topProducts; List<DailySalesPoint> get dailySales;
/// Create a copy of SalesAnalytics
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesAnalyticsCopyWith<SalesAnalytics> get copyWith => _$SalesAnalyticsCopyWithImpl<SalesAnalytics>(this as SalesAnalytics, _$identity);

  /// Serializes this SalesAnalytics to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesAnalytics&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalCostOfGoodsSold, totalCostOfGoodsSold) || other.totalCostOfGoodsSold == totalCostOfGoodsSold)&&(identical(other.grossProfit, grossProfit) || other.grossProfit == grossProfit)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.profitMargin, profitMargin) || other.profitMargin == profitMargin)&&(identical(other.averageSaleAmount, averageSaleAmount) || other.averageSaleAmount == averageSaleAmount)&&const DeepCollectionEquality().equals(other.topProducts, topProducts)&&const DeepCollectionEquality().equals(other.dailySales, dailySales));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSales,totalRevenue,totalCostOfGoodsSold,grossProfit,totalExpenses,netProfit,profitMargin,averageSaleAmount,const DeepCollectionEquality().hash(topProducts),const DeepCollectionEquality().hash(dailySales));

@override
String toString() {
  return 'SalesAnalytics(totalSales: $totalSales, totalRevenue: $totalRevenue, totalCostOfGoodsSold: $totalCostOfGoodsSold, grossProfit: $grossProfit, totalExpenses: $totalExpenses, netProfit: $netProfit, profitMargin: $profitMargin, averageSaleAmount: $averageSaleAmount, topProducts: $topProducts, dailySales: $dailySales)';
}


}

/// @nodoc
abstract mixin class $SalesAnalyticsCopyWith<$Res>  {
  factory $SalesAnalyticsCopyWith(SalesAnalytics value, $Res Function(SalesAnalytics) _then) = _$SalesAnalyticsCopyWithImpl;
@useResult
$Res call({
 int totalSales, num totalRevenue, num totalCostOfGoodsSold, num grossProfit, num totalExpenses, num netProfit, num profitMargin, num averageSaleAmount, List<TopProduct> topProducts, List<DailySalesPoint> dailySales
});




}
/// @nodoc
class _$SalesAnalyticsCopyWithImpl<$Res>
    implements $SalesAnalyticsCopyWith<$Res> {
  _$SalesAnalyticsCopyWithImpl(this._self, this._then);

  final SalesAnalytics _self;
  final $Res Function(SalesAnalytics) _then;

/// Create a copy of SalesAnalytics
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? totalSales = null,Object? totalRevenue = null,Object? totalCostOfGoodsSold = null,Object? grossProfit = null,Object? totalExpenses = null,Object? netProfit = null,Object? profitMargin = null,Object? averageSaleAmount = null,Object? topProducts = null,Object? dailySales = null,}) {
  return _then(_self.copyWith(
totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as num,totalCostOfGoodsSold: null == totalCostOfGoodsSold ? _self.totalCostOfGoodsSold : totalCostOfGoodsSold // ignore: cast_nullable_to_non_nullable
as num,grossProfit: null == grossProfit ? _self.grossProfit : grossProfit // ignore: cast_nullable_to_non_nullable
as num,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as num,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as num,profitMargin: null == profitMargin ? _self.profitMargin : profitMargin // ignore: cast_nullable_to_non_nullable
as num,averageSaleAmount: null == averageSaleAmount ? _self.averageSaleAmount : averageSaleAmount // ignore: cast_nullable_to_non_nullable
as num,topProducts: null == topProducts ? _self.topProducts : topProducts // ignore: cast_nullable_to_non_nullable
as List<TopProduct>,dailySales: null == dailySales ? _self.dailySales : dailySales // ignore: cast_nullable_to_non_nullable
as List<DailySalesPoint>,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesAnalytics].
extension SalesAnalyticsPatterns on SalesAnalytics {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesAnalytics value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesAnalytics() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesAnalytics value)  $default,){
final _that = this;
switch (_that) {
case _SalesAnalytics():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesAnalytics value)?  $default,){
final _that = this;
switch (_that) {
case _SalesAnalytics() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int totalSales,  num totalRevenue,  num totalCostOfGoodsSold,  num grossProfit,  num totalExpenses,  num netProfit,  num profitMargin,  num averageSaleAmount,  List<TopProduct> topProducts,  List<DailySalesPoint> dailySales)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesAnalytics() when $default != null:
return $default(_that.totalSales,_that.totalRevenue,_that.totalCostOfGoodsSold,_that.grossProfit,_that.totalExpenses,_that.netProfit,_that.profitMargin,_that.averageSaleAmount,_that.topProducts,_that.dailySales);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int totalSales,  num totalRevenue,  num totalCostOfGoodsSold,  num grossProfit,  num totalExpenses,  num netProfit,  num profitMargin,  num averageSaleAmount,  List<TopProduct> topProducts,  List<DailySalesPoint> dailySales)  $default,) {final _that = this;
switch (_that) {
case _SalesAnalytics():
return $default(_that.totalSales,_that.totalRevenue,_that.totalCostOfGoodsSold,_that.grossProfit,_that.totalExpenses,_that.netProfit,_that.profitMargin,_that.averageSaleAmount,_that.topProducts,_that.dailySales);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int totalSales,  num totalRevenue,  num totalCostOfGoodsSold,  num grossProfit,  num totalExpenses,  num netProfit,  num profitMargin,  num averageSaleAmount,  List<TopProduct> topProducts,  List<DailySalesPoint> dailySales)?  $default,) {final _that = this;
switch (_that) {
case _SalesAnalytics() when $default != null:
return $default(_that.totalSales,_that.totalRevenue,_that.totalCostOfGoodsSold,_that.grossProfit,_that.totalExpenses,_that.netProfit,_that.profitMargin,_that.averageSaleAmount,_that.topProducts,_that.dailySales);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _SalesAnalytics implements SalesAnalytics {
  const _SalesAnalytics({required this.totalSales, required this.totalRevenue, required this.totalCostOfGoodsSold, required this.grossProfit, required this.totalExpenses, required this.netProfit, required this.profitMargin, required this.averageSaleAmount, final  List<TopProduct> topProducts = const <TopProduct>[], final  List<DailySalesPoint> dailySales = const <DailySalesPoint>[]}): _topProducts = topProducts,_dailySales = dailySales;
  factory _SalesAnalytics.fromJson(Map<String, dynamic> json) => _$SalesAnalyticsFromJson(json);

@override final  int totalSales;
@override final  num totalRevenue;
@override final  num totalCostOfGoodsSold;
@override final  num grossProfit;
@override final  num totalExpenses;
@override final  num netProfit;
@override final  num profitMargin;
@override final  num averageSaleAmount;
 final  List<TopProduct> _topProducts;
@override@JsonKey() List<TopProduct> get topProducts {
  if (_topProducts is EqualUnmodifiableListView) return _topProducts;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_topProducts);
}

 final  List<DailySalesPoint> _dailySales;
@override@JsonKey() List<DailySalesPoint> get dailySales {
  if (_dailySales is EqualUnmodifiableListView) return _dailySales;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_dailySales);
}


/// Create a copy of SalesAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesAnalyticsCopyWith<_SalesAnalytics> get copyWith => __$SalesAnalyticsCopyWithImpl<_SalesAnalytics>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$SalesAnalyticsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesAnalytics&&(identical(other.totalSales, totalSales) || other.totalSales == totalSales)&&(identical(other.totalRevenue, totalRevenue) || other.totalRevenue == totalRevenue)&&(identical(other.totalCostOfGoodsSold, totalCostOfGoodsSold) || other.totalCostOfGoodsSold == totalCostOfGoodsSold)&&(identical(other.grossProfit, grossProfit) || other.grossProfit == grossProfit)&&(identical(other.totalExpenses, totalExpenses) || other.totalExpenses == totalExpenses)&&(identical(other.netProfit, netProfit) || other.netProfit == netProfit)&&(identical(other.profitMargin, profitMargin) || other.profitMargin == profitMargin)&&(identical(other.averageSaleAmount, averageSaleAmount) || other.averageSaleAmount == averageSaleAmount)&&const DeepCollectionEquality().equals(other._topProducts, _topProducts)&&const DeepCollectionEquality().equals(other._dailySales, _dailySales));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,totalSales,totalRevenue,totalCostOfGoodsSold,grossProfit,totalExpenses,netProfit,profitMargin,averageSaleAmount,const DeepCollectionEquality().hash(_topProducts),const DeepCollectionEquality().hash(_dailySales));

@override
String toString() {
  return 'SalesAnalytics(totalSales: $totalSales, totalRevenue: $totalRevenue, totalCostOfGoodsSold: $totalCostOfGoodsSold, grossProfit: $grossProfit, totalExpenses: $totalExpenses, netProfit: $netProfit, profitMargin: $profitMargin, averageSaleAmount: $averageSaleAmount, topProducts: $topProducts, dailySales: $dailySales)';
}


}

/// @nodoc
abstract mixin class _$SalesAnalyticsCopyWith<$Res> implements $SalesAnalyticsCopyWith<$Res> {
  factory _$SalesAnalyticsCopyWith(_SalesAnalytics value, $Res Function(_SalesAnalytics) _then) = __$SalesAnalyticsCopyWithImpl;
@override @useResult
$Res call({
 int totalSales, num totalRevenue, num totalCostOfGoodsSold, num grossProfit, num totalExpenses, num netProfit, num profitMargin, num averageSaleAmount, List<TopProduct> topProducts, List<DailySalesPoint> dailySales
});




}
/// @nodoc
class __$SalesAnalyticsCopyWithImpl<$Res>
    implements _$SalesAnalyticsCopyWith<$Res> {
  __$SalesAnalyticsCopyWithImpl(this._self, this._then);

  final _SalesAnalytics _self;
  final $Res Function(_SalesAnalytics) _then;

/// Create a copy of SalesAnalytics
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? totalSales = null,Object? totalRevenue = null,Object? totalCostOfGoodsSold = null,Object? grossProfit = null,Object? totalExpenses = null,Object? netProfit = null,Object? profitMargin = null,Object? averageSaleAmount = null,Object? topProducts = null,Object? dailySales = null,}) {
  return _then(_SalesAnalytics(
totalSales: null == totalSales ? _self.totalSales : totalSales // ignore: cast_nullable_to_non_nullable
as int,totalRevenue: null == totalRevenue ? _self.totalRevenue : totalRevenue // ignore: cast_nullable_to_non_nullable
as num,totalCostOfGoodsSold: null == totalCostOfGoodsSold ? _self.totalCostOfGoodsSold : totalCostOfGoodsSold // ignore: cast_nullable_to_non_nullable
as num,grossProfit: null == grossProfit ? _self.grossProfit : grossProfit // ignore: cast_nullable_to_non_nullable
as num,totalExpenses: null == totalExpenses ? _self.totalExpenses : totalExpenses // ignore: cast_nullable_to_non_nullable
as num,netProfit: null == netProfit ? _self.netProfit : netProfit // ignore: cast_nullable_to_non_nullable
as num,profitMargin: null == profitMargin ? _self.profitMargin : profitMargin // ignore: cast_nullable_to_non_nullable
as num,averageSaleAmount: null == averageSaleAmount ? _self.averageSaleAmount : averageSaleAmount // ignore: cast_nullable_to_non_nullable
as num,topProducts: null == topProducts ? _self._topProducts : topProducts // ignore: cast_nullable_to_non_nullable
as List<TopProduct>,dailySales: null == dailySales ? _self._dailySales : dailySales // ignore: cast_nullable_to_non_nullable
as List<DailySalesPoint>,
  ));
}


}


/// @nodoc
mixin _$TopProduct {

 String get name; int get quantity; num get revenue;
/// Create a copy of TopProduct
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$TopProductCopyWith<TopProduct> get copyWith => _$TopProductCopyWithImpl<TopProduct>(this as TopProduct, _$identity);

  /// Serializes this TopProduct to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is TopProduct&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,quantity,revenue);

@override
String toString() {
  return 'TopProduct(name: $name, quantity: $quantity, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class $TopProductCopyWith<$Res>  {
  factory $TopProductCopyWith(TopProduct value, $Res Function(TopProduct) _then) = _$TopProductCopyWithImpl;
@useResult
$Res call({
 String name, int quantity, num revenue
});




}
/// @nodoc
class _$TopProductCopyWithImpl<$Res>
    implements $TopProductCopyWith<$Res> {
  _$TopProductCopyWithImpl(this._self, this._then);

  final TopProduct _self;
  final $Res Function(TopProduct) _then;

/// Create a copy of TopProduct
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? name = null,Object? quantity = null,Object? revenue = null,}) {
  return _then(_self.copyWith(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [TopProduct].
extension TopProductPatterns on TopProduct {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _TopProduct value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _TopProduct() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _TopProduct value)  $default,){
final _that = this;
switch (_that) {
case _TopProduct():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _TopProduct value)?  $default,){
final _that = this;
switch (_that) {
case _TopProduct() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String name,  int quantity,  num revenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _TopProduct() when $default != null:
return $default(_that.name,_that.quantity,_that.revenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String name,  int quantity,  num revenue)  $default,) {final _that = this;
switch (_that) {
case _TopProduct():
return $default(_that.name,_that.quantity,_that.revenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String name,  int quantity,  num revenue)?  $default,) {final _that = this;
switch (_that) {
case _TopProduct() when $default != null:
return $default(_that.name,_that.quantity,_that.revenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _TopProduct implements TopProduct {
  const _TopProduct({required this.name, required this.quantity, required this.revenue});
  factory _TopProduct.fromJson(Map<String, dynamic> json) => _$TopProductFromJson(json);

@override final  String name;
@override final  int quantity;
@override final  num revenue;

/// Create a copy of TopProduct
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$TopProductCopyWith<_TopProduct> get copyWith => __$TopProductCopyWithImpl<_TopProduct>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$TopProductToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _TopProduct&&(identical(other.name, name) || other.name == name)&&(identical(other.quantity, quantity) || other.quantity == quantity)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,name,quantity,revenue);

@override
String toString() {
  return 'TopProduct(name: $name, quantity: $quantity, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class _$TopProductCopyWith<$Res> implements $TopProductCopyWith<$Res> {
  factory _$TopProductCopyWith(_TopProduct value, $Res Function(_TopProduct) _then) = __$TopProductCopyWithImpl;
@override @useResult
$Res call({
 String name, int quantity, num revenue
});




}
/// @nodoc
class __$TopProductCopyWithImpl<$Res>
    implements _$TopProductCopyWith<$Res> {
  __$TopProductCopyWithImpl(this._self, this._then);

  final _TopProduct _self;
  final $Res Function(_TopProduct) _then;

/// Create a copy of TopProduct
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? name = null,Object? quantity = null,Object? revenue = null,}) {
  return _then(_TopProduct(
name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,quantity: null == quantity ? _self.quantity : quantity // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}


/// @nodoc
mixin _$DailySalesPoint {

 String get date;// yyyy-mm-dd
 int get count; num get revenue;
/// Create a copy of DailySalesPoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DailySalesPointCopyWith<DailySalesPoint> get copyWith => _$DailySalesPointCopyWithImpl<DailySalesPoint>(this as DailySalesPoint, _$identity);

  /// Serializes this DailySalesPoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DailySalesPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,count,revenue);

@override
String toString() {
  return 'DailySalesPoint(date: $date, count: $count, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class $DailySalesPointCopyWith<$Res>  {
  factory $DailySalesPointCopyWith(DailySalesPoint value, $Res Function(DailySalesPoint) _then) = _$DailySalesPointCopyWithImpl;
@useResult
$Res call({
 String date, int count, num revenue
});




}
/// @nodoc
class _$DailySalesPointCopyWithImpl<$Res>
    implements $DailySalesPointCopyWith<$Res> {
  _$DailySalesPointCopyWithImpl(this._self, this._then);

  final DailySalesPoint _self;
  final $Res Function(DailySalesPoint) _then;

/// Create a copy of DailySalesPoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? date = null,Object? count = null,Object? revenue = null,}) {
  return _then(_self.copyWith(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}

}


/// Adds pattern-matching-related methods to [DailySalesPoint].
extension DailySalesPointPatterns on DailySalesPoint {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DailySalesPoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DailySalesPoint() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DailySalesPoint value)  $default,){
final _that = this;
switch (_that) {
case _DailySalesPoint():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DailySalesPoint value)?  $default,){
final _that = this;
switch (_that) {
case _DailySalesPoint() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String date,  int count,  num revenue)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DailySalesPoint() when $default != null:
return $default(_that.date,_that.count,_that.revenue);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String date,  int count,  num revenue)  $default,) {final _that = this;
switch (_that) {
case _DailySalesPoint():
return $default(_that.date,_that.count,_that.revenue);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String date,  int count,  num revenue)?  $default,) {final _that = this;
switch (_that) {
case _DailySalesPoint() when $default != null:
return $default(_that.date,_that.count,_that.revenue);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _DailySalesPoint implements DailySalesPoint {
  const _DailySalesPoint({required this.date, required this.count, required this.revenue});
  factory _DailySalesPoint.fromJson(Map<String, dynamic> json) => _$DailySalesPointFromJson(json);

@override final  String date;
// yyyy-mm-dd
@override final  int count;
@override final  num revenue;

/// Create a copy of DailySalesPoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DailySalesPointCopyWith<_DailySalesPoint> get copyWith => __$DailySalesPointCopyWithImpl<_DailySalesPoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$DailySalesPointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DailySalesPoint&&(identical(other.date, date) || other.date == date)&&(identical(other.count, count) || other.count == count)&&(identical(other.revenue, revenue) || other.revenue == revenue));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,date,count,revenue);

@override
String toString() {
  return 'DailySalesPoint(date: $date, count: $count, revenue: $revenue)';
}


}

/// @nodoc
abstract mixin class _$DailySalesPointCopyWith<$Res> implements $DailySalesPointCopyWith<$Res> {
  factory _$DailySalesPointCopyWith(_DailySalesPoint value, $Res Function(_DailySalesPoint) _then) = __$DailySalesPointCopyWithImpl;
@override @useResult
$Res call({
 String date, int count, num revenue
});




}
/// @nodoc
class __$DailySalesPointCopyWithImpl<$Res>
    implements _$DailySalesPointCopyWith<$Res> {
  __$DailySalesPointCopyWithImpl(this._self, this._then);

  final _DailySalesPoint _self;
  final $Res Function(_DailySalesPoint) _then;

/// Create a copy of DailySalesPoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? date = null,Object? count = null,Object? revenue = null,}) {
  return _then(_DailySalesPoint(
date: null == date ? _self.date : date // ignore: cast_nullable_to_non_nullable
as String,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,revenue: null == revenue ? _self.revenue : revenue // ignore: cast_nullable_to_non_nullable
as num,
  ));
}


}

// dart format on
