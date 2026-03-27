// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'sales_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$SalesState {

 bool get isLoading; bool get isLoadingMore; String? get errorMessage; List<Sale> get sales; PaginationDto? get pagination; DateTime? get startDate; DateTime? get endDate; String get searchQuery;
/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$SalesStateCopyWith<SalesState> get copyWith => _$SalesStateCopyWithImpl<SalesState>(this as SalesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is SalesState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.sales, sales)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isLoadingMore,errorMessage,const DeepCollectionEquality().hash(sales),pagination,startDate,endDate,searchQuery);

@override
String toString() {
  return 'SalesState(isLoading: $isLoading, isLoadingMore: $isLoadingMore, errorMessage: $errorMessage, sales: $sales, pagination: $pagination, startDate: $startDate, endDate: $endDate, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class $SalesStateCopyWith<$Res>  {
  factory $SalesStateCopyWith(SalesState value, $Res Function(SalesState) _then) = _$SalesStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isLoadingMore, String? errorMessage, List<Sale> sales, PaginationDto? pagination, DateTime? startDate, DateTime? endDate, String searchQuery
});




}
/// @nodoc
class _$SalesStateCopyWithImpl<$Res>
    implements $SalesStateCopyWith<$Res> {
  _$SalesStateCopyWithImpl(this._self, this._then);

  final SalesState _self;
  final $Res Function(SalesState) _then;

/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isLoadingMore = null,Object? errorMessage = freezed,Object? sales = null,Object? pagination = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? searchQuery = null,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,sales: null == sales ? _self.sales : sales // ignore: cast_nullable_to_non_nullable
as List<Sale>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [SalesState].
extension SalesStatePatterns on SalesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _SalesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _SalesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _SalesState value)  $default,){
final _that = this;
switch (_that) {
case _SalesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _SalesState value)?  $default,){
final _that = this;
switch (_that) {
case _SalesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isLoadingMore,  String? errorMessage,  List<Sale> sales,  PaginationDto? pagination,  DateTime? startDate,  DateTime? endDate,  String searchQuery)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _SalesState() when $default != null:
return $default(_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.sales,_that.pagination,_that.startDate,_that.endDate,_that.searchQuery);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isLoadingMore,  String? errorMessage,  List<Sale> sales,  PaginationDto? pagination,  DateTime? startDate,  DateTime? endDate,  String searchQuery)  $default,) {final _that = this;
switch (_that) {
case _SalesState():
return $default(_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.sales,_that.pagination,_that.startDate,_that.endDate,_that.searchQuery);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isLoadingMore,  String? errorMessage,  List<Sale> sales,  PaginationDto? pagination,  DateTime? startDate,  DateTime? endDate,  String searchQuery)?  $default,) {final _that = this;
switch (_that) {
case _SalesState() when $default != null:
return $default(_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.sales,_that.pagination,_that.startDate,_that.endDate,_that.searchQuery);case _:
  return null;

}
}

}

/// @nodoc


class _SalesState implements SalesState {
  const _SalesState({required this.isLoading, this.isLoadingMore = false, this.errorMessage, final  List<Sale> sales = const <Sale>[], this.pagination, this.startDate, this.endDate, this.searchQuery = ''}): _sales = sales;
  

@override final  bool isLoading;
@override@JsonKey() final  bool isLoadingMore;
@override final  String? errorMessage;
 final  List<Sale> _sales;
@override@JsonKey() List<Sale> get sales {
  if (_sales is EqualUnmodifiableListView) return _sales;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sales);
}

@override final  PaginationDto? pagination;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override@JsonKey() final  String searchQuery;

/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$SalesStateCopyWith<_SalesState> get copyWith => __$SalesStateCopyWithImpl<_SalesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _SalesState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._sales, _sales)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.searchQuery, searchQuery) || other.searchQuery == searchQuery));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isLoadingMore,errorMessage,const DeepCollectionEquality().hash(_sales),pagination,startDate,endDate,searchQuery);

@override
String toString() {
  return 'SalesState(isLoading: $isLoading, isLoadingMore: $isLoadingMore, errorMessage: $errorMessage, sales: $sales, pagination: $pagination, startDate: $startDate, endDate: $endDate, searchQuery: $searchQuery)';
}


}

/// @nodoc
abstract mixin class _$SalesStateCopyWith<$Res> implements $SalesStateCopyWith<$Res> {
  factory _$SalesStateCopyWith(_SalesState value, $Res Function(_SalesState) _then) = __$SalesStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isLoadingMore, String? errorMessage, List<Sale> sales, PaginationDto? pagination, DateTime? startDate, DateTime? endDate, String searchQuery
});




}
/// @nodoc
class __$SalesStateCopyWithImpl<$Res>
    implements _$SalesStateCopyWith<$Res> {
  __$SalesStateCopyWithImpl(this._self, this._then);

  final _SalesState _self;
  final $Res Function(_SalesState) _then;

/// Create a copy of SalesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isLoadingMore = null,Object? errorMessage = freezed,Object? sales = null,Object? pagination = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? searchQuery = null,}) {
  return _then(_SalesState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,sales: null == sales ? _self._sales : sales // ignore: cast_nullable_to_non_nullable
as List<Sale>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,searchQuery: null == searchQuery ? _self.searchQuery : searchQuery // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on
