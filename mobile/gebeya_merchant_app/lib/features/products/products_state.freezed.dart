// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'products_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ProductsState {

 bool get isLoading; String? get errorMessage; List<Product> get products; PaginationDto? get pagination; Set<String> get selectedIds;// Filters
 String? get search; String? get brandFilter; String? get sizeFilter; num? get minPrice; num? get maxPrice; String? get stockFilter;// 'all', 'inStock', 'outOfStock', 'lowStock'
 bool? get isActiveFilter;// null = all, true = active, false = inactive
// Stock map (productId -> stock quantity)
 Map<String, num> get stockMap;
/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ProductsStateCopyWith<ProductsState> get copyWith => _$ProductsStateCopyWithImpl<ProductsState>(this as ProductsState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ProductsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.products, products)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&const DeepCollectionEquality().equals(other.selectedIds, selectedIds)&&(identical(other.search, search) || other.search == search)&&(identical(other.brandFilter, brandFilter) || other.brandFilter == brandFilter)&&(identical(other.sizeFilter, sizeFilter) || other.sizeFilter == sizeFilter)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.stockFilter, stockFilter) || other.stockFilter == stockFilter)&&(identical(other.isActiveFilter, isActiveFilter) || other.isActiveFilter == isActiveFilter)&&const DeepCollectionEquality().equals(other.stockMap, stockMap));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,const DeepCollectionEquality().hash(products),pagination,const DeepCollectionEquality().hash(selectedIds),search,brandFilter,sizeFilter,minPrice,maxPrice,stockFilter,isActiveFilter,const DeepCollectionEquality().hash(stockMap));

@override
String toString() {
  return 'ProductsState(isLoading: $isLoading, errorMessage: $errorMessage, products: $products, pagination: $pagination, selectedIds: $selectedIds, search: $search, brandFilter: $brandFilter, sizeFilter: $sizeFilter, minPrice: $minPrice, maxPrice: $maxPrice, stockFilter: $stockFilter, isActiveFilter: $isActiveFilter, stockMap: $stockMap)';
}


}

/// @nodoc
abstract mixin class $ProductsStateCopyWith<$Res>  {
  factory $ProductsStateCopyWith(ProductsState value, $Res Function(ProductsState) _then) = _$ProductsStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? errorMessage, List<Product> products, PaginationDto? pagination, Set<String> selectedIds, String? search, String? brandFilter, String? sizeFilter, num? minPrice, num? maxPrice, String? stockFilter, bool? isActiveFilter, Map<String, num> stockMap
});




}
/// @nodoc
class _$ProductsStateCopyWithImpl<$Res>
    implements $ProductsStateCopyWith<$Res> {
  _$ProductsStateCopyWithImpl(this._self, this._then);

  final ProductsState _self;
  final $Res Function(ProductsState) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? products = null,Object? pagination = freezed,Object? selectedIds = null,Object? search = freezed,Object? brandFilter = freezed,Object? sizeFilter = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? stockFilter = freezed,Object? isActiveFilter = freezed,Object? stockMap = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,products: null == products ? _self.products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,selectedIds: null == selectedIds ? _self.selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,brandFilter: freezed == brandFilter ? _self.brandFilter : brandFilter // ignore: cast_nullable_to_non_nullable
as String?,sizeFilter: freezed == sizeFilter ? _self.sizeFilter : sizeFilter // ignore: cast_nullable_to_non_nullable
as String?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as num?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as num?,stockFilter: freezed == stockFilter ? _self.stockFilter : stockFilter // ignore: cast_nullable_to_non_nullable
as String?,isActiveFilter: freezed == isActiveFilter ? _self.isActiveFilter : isActiveFilter // ignore: cast_nullable_to_non_nullable
as bool?,stockMap: null == stockMap ? _self.stockMap : stockMap // ignore: cast_nullable_to_non_nullable
as Map<String, num>,
  ));
}

}


/// Adds pattern-matching-related methods to [ProductsState].
extension ProductsStatePatterns on ProductsState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ProductsState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ProductsState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ProductsState value)  $default,){
final _that = this;
switch (_that) {
case _ProductsState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ProductsState value)?  $default,){
final _that = this;
switch (_that) {
case _ProductsState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  List<Product> products,  PaginationDto? pagination,  Set<String> selectedIds,  String? search,  String? brandFilter,  String? sizeFilter,  num? minPrice,  num? maxPrice,  String? stockFilter,  bool? isActiveFilter,  Map<String, num> stockMap)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ProductsState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.products,_that.pagination,_that.selectedIds,_that.search,_that.brandFilter,_that.sizeFilter,_that.minPrice,_that.maxPrice,_that.stockFilter,_that.isActiveFilter,_that.stockMap);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  List<Product> products,  PaginationDto? pagination,  Set<String> selectedIds,  String? search,  String? brandFilter,  String? sizeFilter,  num? minPrice,  num? maxPrice,  String? stockFilter,  bool? isActiveFilter,  Map<String, num> stockMap)  $default,) {final _that = this;
switch (_that) {
case _ProductsState():
return $default(_that.isLoading,_that.errorMessage,_that.products,_that.pagination,_that.selectedIds,_that.search,_that.brandFilter,_that.sizeFilter,_that.minPrice,_that.maxPrice,_that.stockFilter,_that.isActiveFilter,_that.stockMap);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? errorMessage,  List<Product> products,  PaginationDto? pagination,  Set<String> selectedIds,  String? search,  String? brandFilter,  String? sizeFilter,  num? minPrice,  num? maxPrice,  String? stockFilter,  bool? isActiveFilter,  Map<String, num> stockMap)?  $default,) {final _that = this;
switch (_that) {
case _ProductsState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.products,_that.pagination,_that.selectedIds,_that.search,_that.brandFilter,_that.sizeFilter,_that.minPrice,_that.maxPrice,_that.stockFilter,_that.isActiveFilter,_that.stockMap);case _:
  return null;

}
}

}

/// @nodoc


class _ProductsState implements ProductsState {
  const _ProductsState({required this.isLoading, this.errorMessage, final  List<Product> products = const <Product>[], this.pagination, final  Set<String> selectedIds = const <String>{}, this.search, this.brandFilter, this.sizeFilter, this.minPrice, this.maxPrice, this.stockFilter, this.isActiveFilter, final  Map<String, num> stockMap = const <String, num>{}}): _products = products,_selectedIds = selectedIds,_stockMap = stockMap;
  

@override final  bool isLoading;
@override final  String? errorMessage;
 final  List<Product> _products;
@override@JsonKey() List<Product> get products {
  if (_products is EqualUnmodifiableListView) return _products;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_products);
}

@override final  PaginationDto? pagination;
 final  Set<String> _selectedIds;
@override@JsonKey() Set<String> get selectedIds {
  if (_selectedIds is EqualUnmodifiableSetView) return _selectedIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableSetView(_selectedIds);
}

// Filters
@override final  String? search;
@override final  String? brandFilter;
@override final  String? sizeFilter;
@override final  num? minPrice;
@override final  num? maxPrice;
@override final  String? stockFilter;
// 'all', 'inStock', 'outOfStock', 'lowStock'
@override final  bool? isActiveFilter;
// null = all, true = active, false = inactive
// Stock map (productId -> stock quantity)
 final  Map<String, num> _stockMap;
// null = all, true = active, false = inactive
// Stock map (productId -> stock quantity)
@override@JsonKey() Map<String, num> get stockMap {
  if (_stockMap is EqualUnmodifiableMapView) return _stockMap;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_stockMap);
}


/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ProductsStateCopyWith<_ProductsState> get copyWith => __$ProductsStateCopyWithImpl<_ProductsState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ProductsState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._products, _products)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&const DeepCollectionEquality().equals(other._selectedIds, _selectedIds)&&(identical(other.search, search) || other.search == search)&&(identical(other.brandFilter, brandFilter) || other.brandFilter == brandFilter)&&(identical(other.sizeFilter, sizeFilter) || other.sizeFilter == sizeFilter)&&(identical(other.minPrice, minPrice) || other.minPrice == minPrice)&&(identical(other.maxPrice, maxPrice) || other.maxPrice == maxPrice)&&(identical(other.stockFilter, stockFilter) || other.stockFilter == stockFilter)&&(identical(other.isActiveFilter, isActiveFilter) || other.isActiveFilter == isActiveFilter)&&const DeepCollectionEquality().equals(other._stockMap, _stockMap));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,const DeepCollectionEquality().hash(_products),pagination,const DeepCollectionEquality().hash(_selectedIds),search,brandFilter,sizeFilter,minPrice,maxPrice,stockFilter,isActiveFilter,const DeepCollectionEquality().hash(_stockMap));

@override
String toString() {
  return 'ProductsState(isLoading: $isLoading, errorMessage: $errorMessage, products: $products, pagination: $pagination, selectedIds: $selectedIds, search: $search, brandFilter: $brandFilter, sizeFilter: $sizeFilter, minPrice: $minPrice, maxPrice: $maxPrice, stockFilter: $stockFilter, isActiveFilter: $isActiveFilter, stockMap: $stockMap)';
}


}

/// @nodoc
abstract mixin class _$ProductsStateCopyWith<$Res> implements $ProductsStateCopyWith<$Res> {
  factory _$ProductsStateCopyWith(_ProductsState value, $Res Function(_ProductsState) _then) = __$ProductsStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? errorMessage, List<Product> products, PaginationDto? pagination, Set<String> selectedIds, String? search, String? brandFilter, String? sizeFilter, num? minPrice, num? maxPrice, String? stockFilter, bool? isActiveFilter, Map<String, num> stockMap
});




}
/// @nodoc
class __$ProductsStateCopyWithImpl<$Res>
    implements _$ProductsStateCopyWith<$Res> {
  __$ProductsStateCopyWithImpl(this._self, this._then);

  final _ProductsState _self;
  final $Res Function(_ProductsState) _then;

/// Create a copy of ProductsState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? products = null,Object? pagination = freezed,Object? selectedIds = null,Object? search = freezed,Object? brandFilter = freezed,Object? sizeFilter = freezed,Object? minPrice = freezed,Object? maxPrice = freezed,Object? stockFilter = freezed,Object? isActiveFilter = freezed,Object? stockMap = null,}) {
  return _then(_ProductsState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,products: null == products ? _self._products : products // ignore: cast_nullable_to_non_nullable
as List<Product>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,selectedIds: null == selectedIds ? _self._selectedIds : selectedIds // ignore: cast_nullable_to_non_nullable
as Set<String>,search: freezed == search ? _self.search : search // ignore: cast_nullable_to_non_nullable
as String?,brandFilter: freezed == brandFilter ? _self.brandFilter : brandFilter // ignore: cast_nullable_to_non_nullable
as String?,sizeFilter: freezed == sizeFilter ? _self.sizeFilter : sizeFilter // ignore: cast_nullable_to_non_nullable
as String?,minPrice: freezed == minPrice ? _self.minPrice : minPrice // ignore: cast_nullable_to_non_nullable
as num?,maxPrice: freezed == maxPrice ? _self.maxPrice : maxPrice // ignore: cast_nullable_to_non_nullable
as num?,stockFilter: freezed == stockFilter ? _self.stockFilter : stockFilter // ignore: cast_nullable_to_non_nullable
as String?,isActiveFilter: freezed == isActiveFilter ? _self.isActiveFilter : isActiveFilter // ignore: cast_nullable_to_non_nullable
as bool?,stockMap: null == stockMap ? _self._stockMap : stockMap // ignore: cast_nullable_to_non_nullable
as Map<String, num>,
  ));
}


}

// dart format on
