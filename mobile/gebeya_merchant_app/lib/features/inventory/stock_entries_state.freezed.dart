// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'stock_entries_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$StockEntriesState {

 List<InventoryEntry> get entries; PaginationDto? get pagination; bool get isLoading; bool get isLoadingMore; String? get errorMessage; String? get productIdFilter; String? get locationIdFilter;
/// Create a copy of StockEntriesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$StockEntriesStateCopyWith<StockEntriesState> get copyWith => _$StockEntriesStateCopyWithImpl<StockEntriesState>(this as StockEntriesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is StockEntriesState&&const DeepCollectionEquality().equals(other.entries, entries)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.productIdFilter, productIdFilter) || other.productIdFilter == productIdFilter)&&(identical(other.locationIdFilter, locationIdFilter) || other.locationIdFilter == locationIdFilter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(entries),pagination,isLoading,isLoadingMore,errorMessage,productIdFilter,locationIdFilter);

@override
String toString() {
  return 'StockEntriesState(entries: $entries, pagination: $pagination, isLoading: $isLoading, isLoadingMore: $isLoadingMore, errorMessage: $errorMessage, productIdFilter: $productIdFilter, locationIdFilter: $locationIdFilter)';
}


}

/// @nodoc
abstract mixin class $StockEntriesStateCopyWith<$Res>  {
  factory $StockEntriesStateCopyWith(StockEntriesState value, $Res Function(StockEntriesState) _then) = _$StockEntriesStateCopyWithImpl;
@useResult
$Res call({
 List<InventoryEntry> entries, PaginationDto? pagination, bool isLoading, bool isLoadingMore, String? errorMessage, String? productIdFilter, String? locationIdFilter
});




}
/// @nodoc
class _$StockEntriesStateCopyWithImpl<$Res>
    implements $StockEntriesStateCopyWith<$Res> {
  _$StockEntriesStateCopyWithImpl(this._self, this._then);

  final StockEntriesState _self;
  final $Res Function(StockEntriesState) _then;

/// Create a copy of StockEntriesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? entries = null,Object? pagination = freezed,Object? isLoading = null,Object? isLoadingMore = null,Object? errorMessage = freezed,Object? productIdFilter = freezed,Object? locationIdFilter = freezed,}) {
  return _then(_self.copyWith(
entries: null == entries ? _self.entries : entries // ignore: cast_nullable_to_non_nullable
as List<InventoryEntry>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,productIdFilter: freezed == productIdFilter ? _self.productIdFilter : productIdFilter // ignore: cast_nullable_to_non_nullable
as String?,locationIdFilter: freezed == locationIdFilter ? _self.locationIdFilter : locationIdFilter // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [StockEntriesState].
extension StockEntriesStatePatterns on StockEntriesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _StockEntriesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _StockEntriesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _StockEntriesState value)  $default,){
final _that = this;
switch (_that) {
case _StockEntriesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _StockEntriesState value)?  $default,){
final _that = this;
switch (_that) {
case _StockEntriesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<InventoryEntry> entries,  PaginationDto? pagination,  bool isLoading,  bool isLoadingMore,  String? errorMessage,  String? productIdFilter,  String? locationIdFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _StockEntriesState() when $default != null:
return $default(_that.entries,_that.pagination,_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.productIdFilter,_that.locationIdFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<InventoryEntry> entries,  PaginationDto? pagination,  bool isLoading,  bool isLoadingMore,  String? errorMessage,  String? productIdFilter,  String? locationIdFilter)  $default,) {final _that = this;
switch (_that) {
case _StockEntriesState():
return $default(_that.entries,_that.pagination,_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.productIdFilter,_that.locationIdFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<InventoryEntry> entries,  PaginationDto? pagination,  bool isLoading,  bool isLoadingMore,  String? errorMessage,  String? productIdFilter,  String? locationIdFilter)?  $default,) {final _that = this;
switch (_that) {
case _StockEntriesState() when $default != null:
return $default(_that.entries,_that.pagination,_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.productIdFilter,_that.locationIdFilter);case _:
  return null;

}
}

}

/// @nodoc


class _StockEntriesState extends StockEntriesState {
  const _StockEntriesState({final  List<InventoryEntry> entries = const [], this.pagination, this.isLoading = false, this.isLoadingMore = false, this.errorMessage, this.productIdFilter, this.locationIdFilter}): _entries = entries,super._();
  

 final  List<InventoryEntry> _entries;
@override@JsonKey() List<InventoryEntry> get entries {
  if (_entries is EqualUnmodifiableListView) return _entries;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_entries);
}

@override final  PaginationDto? pagination;
@override@JsonKey() final  bool isLoading;
@override@JsonKey() final  bool isLoadingMore;
@override final  String? errorMessage;
@override final  String? productIdFilter;
@override final  String? locationIdFilter;

/// Create a copy of StockEntriesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$StockEntriesStateCopyWith<_StockEntriesState> get copyWith => __$StockEntriesStateCopyWithImpl<_StockEntriesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _StockEntriesState&&const DeepCollectionEquality().equals(other._entries, _entries)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.productIdFilter, productIdFilter) || other.productIdFilter == productIdFilter)&&(identical(other.locationIdFilter, locationIdFilter) || other.locationIdFilter == locationIdFilter));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_entries),pagination,isLoading,isLoadingMore,errorMessage,productIdFilter,locationIdFilter);

@override
String toString() {
  return 'StockEntriesState(entries: $entries, pagination: $pagination, isLoading: $isLoading, isLoadingMore: $isLoadingMore, errorMessage: $errorMessage, productIdFilter: $productIdFilter, locationIdFilter: $locationIdFilter)';
}


}

/// @nodoc
abstract mixin class _$StockEntriesStateCopyWith<$Res> implements $StockEntriesStateCopyWith<$Res> {
  factory _$StockEntriesStateCopyWith(_StockEntriesState value, $Res Function(_StockEntriesState) _then) = __$StockEntriesStateCopyWithImpl;
@override @useResult
$Res call({
 List<InventoryEntry> entries, PaginationDto? pagination, bool isLoading, bool isLoadingMore, String? errorMessage, String? productIdFilter, String? locationIdFilter
});




}
/// @nodoc
class __$StockEntriesStateCopyWithImpl<$Res>
    implements _$StockEntriesStateCopyWith<$Res> {
  __$StockEntriesStateCopyWithImpl(this._self, this._then);

  final _StockEntriesState _self;
  final $Res Function(_StockEntriesState) _then;

/// Create a copy of StockEntriesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? entries = null,Object? pagination = freezed,Object? isLoading = null,Object? isLoadingMore = null,Object? errorMessage = freezed,Object? productIdFilter = freezed,Object? locationIdFilter = freezed,}) {
  return _then(_StockEntriesState(
entries: null == entries ? _self._entries : entries // ignore: cast_nullable_to_non_nullable
as List<InventoryEntry>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,productIdFilter: freezed == productIdFilter ? _self.productIdFilter : productIdFilter // ignore: cast_nullable_to_non_nullable
as String?,locationIdFilter: freezed == locationIdFilter ? _self.locationIdFilter : locationIdFilter // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
