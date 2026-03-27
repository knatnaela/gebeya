// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'inventory_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$InventoryState {

 bool get isLoading; String? get errorMessage; InventorySummary? get summary; List<InventoryTransaction> get recentTransactions; List<InventoryTransaction> get allTransactions; PaginationDto? get pagination;// Filters for transactions
 String? get productIdFilter; InventoryTransactionType? get typeFilter; DateTime? get startDateFilter; DateTime? get endDateFilter;
/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$InventoryStateCopyWith<InventoryState> get copyWith => _$InventoryStateCopyWithImpl<InventoryState>(this as InventoryState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is InventoryState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other.recentTransactions, recentTransactions)&&const DeepCollectionEquality().equals(other.allTransactions, allTransactions)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.productIdFilter, productIdFilter) || other.productIdFilter == productIdFilter)&&(identical(other.typeFilter, typeFilter) || other.typeFilter == typeFilter)&&(identical(other.startDateFilter, startDateFilter) || other.startDateFilter == startDateFilter)&&(identical(other.endDateFilter, endDateFilter) || other.endDateFilter == endDateFilter));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,summary,const DeepCollectionEquality().hash(recentTransactions),const DeepCollectionEquality().hash(allTransactions),pagination,productIdFilter,typeFilter,startDateFilter,endDateFilter);

@override
String toString() {
  return 'InventoryState(isLoading: $isLoading, errorMessage: $errorMessage, summary: $summary, recentTransactions: $recentTransactions, allTransactions: $allTransactions, pagination: $pagination, productIdFilter: $productIdFilter, typeFilter: $typeFilter, startDateFilter: $startDateFilter, endDateFilter: $endDateFilter)';
}


}

/// @nodoc
abstract mixin class $InventoryStateCopyWith<$Res>  {
  factory $InventoryStateCopyWith(InventoryState value, $Res Function(InventoryState) _then) = _$InventoryStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? errorMessage, InventorySummary? summary, List<InventoryTransaction> recentTransactions, List<InventoryTransaction> allTransactions, PaginationDto? pagination, String? productIdFilter, InventoryTransactionType? typeFilter, DateTime? startDateFilter, DateTime? endDateFilter
});


$InventorySummaryCopyWith<$Res>? get summary;

}
/// @nodoc
class _$InventoryStateCopyWithImpl<$Res>
    implements $InventoryStateCopyWith<$Res> {
  _$InventoryStateCopyWithImpl(this._self, this._then);

  final InventoryState _self;
  final $Res Function(InventoryState) _then;

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? summary = freezed,Object? recentTransactions = null,Object? allTransactions = null,Object? pagination = freezed,Object? productIdFilter = freezed,Object? typeFilter = freezed,Object? startDateFilter = freezed,Object? endDateFilter = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as InventorySummary?,recentTransactions: null == recentTransactions ? _self.recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<InventoryTransaction>,allTransactions: null == allTransactions ? _self.allTransactions : allTransactions // ignore: cast_nullable_to_non_nullable
as List<InventoryTransaction>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,productIdFilter: freezed == productIdFilter ? _self.productIdFilter : productIdFilter // ignore: cast_nullable_to_non_nullable
as String?,typeFilter: freezed == typeFilter ? _self.typeFilter : typeFilter // ignore: cast_nullable_to_non_nullable
as InventoryTransactionType?,startDateFilter: freezed == startDateFilter ? _self.startDateFilter : startDateFilter // ignore: cast_nullable_to_non_nullable
as DateTime?,endDateFilter: freezed == endDateFilter ? _self.endDateFilter : endDateFilter // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}
/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InventorySummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $InventorySummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}


/// Adds pattern-matching-related methods to [InventoryState].
extension InventoryStatePatterns on InventoryState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _InventoryState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _InventoryState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _InventoryState value)  $default,){
final _that = this;
switch (_that) {
case _InventoryState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _InventoryState value)?  $default,){
final _that = this;
switch (_that) {
case _InventoryState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  InventorySummary? summary,  List<InventoryTransaction> recentTransactions,  List<InventoryTransaction> allTransactions,  PaginationDto? pagination,  String? productIdFilter,  InventoryTransactionType? typeFilter,  DateTime? startDateFilter,  DateTime? endDateFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _InventoryState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.summary,_that.recentTransactions,_that.allTransactions,_that.pagination,_that.productIdFilter,_that.typeFilter,_that.startDateFilter,_that.endDateFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  InventorySummary? summary,  List<InventoryTransaction> recentTransactions,  List<InventoryTransaction> allTransactions,  PaginationDto? pagination,  String? productIdFilter,  InventoryTransactionType? typeFilter,  DateTime? startDateFilter,  DateTime? endDateFilter)  $default,) {final _that = this;
switch (_that) {
case _InventoryState():
return $default(_that.isLoading,_that.errorMessage,_that.summary,_that.recentTransactions,_that.allTransactions,_that.pagination,_that.productIdFilter,_that.typeFilter,_that.startDateFilter,_that.endDateFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? errorMessage,  InventorySummary? summary,  List<InventoryTransaction> recentTransactions,  List<InventoryTransaction> allTransactions,  PaginationDto? pagination,  String? productIdFilter,  InventoryTransactionType? typeFilter,  DateTime? startDateFilter,  DateTime? endDateFilter)?  $default,) {final _that = this;
switch (_that) {
case _InventoryState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.summary,_that.recentTransactions,_that.allTransactions,_that.pagination,_that.productIdFilter,_that.typeFilter,_that.startDateFilter,_that.endDateFilter);case _:
  return null;

}
}

}

/// @nodoc


class _InventoryState implements InventoryState {
  const _InventoryState({required this.isLoading, this.errorMessage, this.summary, final  List<InventoryTransaction> recentTransactions = const <InventoryTransaction>[], final  List<InventoryTransaction> allTransactions = const <InventoryTransaction>[], this.pagination, this.productIdFilter, this.typeFilter, this.startDateFilter, this.endDateFilter}): _recentTransactions = recentTransactions,_allTransactions = allTransactions;
  

@override final  bool isLoading;
@override final  String? errorMessage;
@override final  InventorySummary? summary;
 final  List<InventoryTransaction> _recentTransactions;
@override@JsonKey() List<InventoryTransaction> get recentTransactions {
  if (_recentTransactions is EqualUnmodifiableListView) return _recentTransactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_recentTransactions);
}

 final  List<InventoryTransaction> _allTransactions;
@override@JsonKey() List<InventoryTransaction> get allTransactions {
  if (_allTransactions is EqualUnmodifiableListView) return _allTransactions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_allTransactions);
}

@override final  PaginationDto? pagination;
// Filters for transactions
@override final  String? productIdFilter;
@override final  InventoryTransactionType? typeFilter;
@override final  DateTime? startDateFilter;
@override final  DateTime? endDateFilter;

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$InventoryStateCopyWith<_InventoryState> get copyWith => __$InventoryStateCopyWithImpl<_InventoryState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _InventoryState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.summary, summary) || other.summary == summary)&&const DeepCollectionEquality().equals(other._recentTransactions, _recentTransactions)&&const DeepCollectionEquality().equals(other._allTransactions, _allTransactions)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.productIdFilter, productIdFilter) || other.productIdFilter == productIdFilter)&&(identical(other.typeFilter, typeFilter) || other.typeFilter == typeFilter)&&(identical(other.startDateFilter, startDateFilter) || other.startDateFilter == startDateFilter)&&(identical(other.endDateFilter, endDateFilter) || other.endDateFilter == endDateFilter));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,summary,const DeepCollectionEquality().hash(_recentTransactions),const DeepCollectionEquality().hash(_allTransactions),pagination,productIdFilter,typeFilter,startDateFilter,endDateFilter);

@override
String toString() {
  return 'InventoryState(isLoading: $isLoading, errorMessage: $errorMessage, summary: $summary, recentTransactions: $recentTransactions, allTransactions: $allTransactions, pagination: $pagination, productIdFilter: $productIdFilter, typeFilter: $typeFilter, startDateFilter: $startDateFilter, endDateFilter: $endDateFilter)';
}


}

/// @nodoc
abstract mixin class _$InventoryStateCopyWith<$Res> implements $InventoryStateCopyWith<$Res> {
  factory _$InventoryStateCopyWith(_InventoryState value, $Res Function(_InventoryState) _then) = __$InventoryStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? errorMessage, InventorySummary? summary, List<InventoryTransaction> recentTransactions, List<InventoryTransaction> allTransactions, PaginationDto? pagination, String? productIdFilter, InventoryTransactionType? typeFilter, DateTime? startDateFilter, DateTime? endDateFilter
});


@override $InventorySummaryCopyWith<$Res>? get summary;

}
/// @nodoc
class __$InventoryStateCopyWithImpl<$Res>
    implements _$InventoryStateCopyWith<$Res> {
  __$InventoryStateCopyWithImpl(this._self, this._then);

  final _InventoryState _self;
  final $Res Function(_InventoryState) _then;

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? summary = freezed,Object? recentTransactions = null,Object? allTransactions = null,Object? pagination = freezed,Object? productIdFilter = freezed,Object? typeFilter = freezed,Object? startDateFilter = freezed,Object? endDateFilter = freezed,}) {
  return _then(_InventoryState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,summary: freezed == summary ? _self.summary : summary // ignore: cast_nullable_to_non_nullable
as InventorySummary?,recentTransactions: null == recentTransactions ? _self._recentTransactions : recentTransactions // ignore: cast_nullable_to_non_nullable
as List<InventoryTransaction>,allTransactions: null == allTransactions ? _self._allTransactions : allTransactions // ignore: cast_nullable_to_non_nullable
as List<InventoryTransaction>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,productIdFilter: freezed == productIdFilter ? _self.productIdFilter : productIdFilter // ignore: cast_nullable_to_non_nullable
as String?,typeFilter: freezed == typeFilter ? _self.typeFilter : typeFilter // ignore: cast_nullable_to_non_nullable
as InventoryTransactionType?,startDateFilter: freezed == startDateFilter ? _self.startDateFilter : startDateFilter // ignore: cast_nullable_to_non_nullable
as DateTime?,endDateFilter: freezed == endDateFilter ? _self.endDateFilter : endDateFilter // ignore: cast_nullable_to_non_nullable
as DateTime?,
  ));
}

/// Create a copy of InventoryState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InventorySummaryCopyWith<$Res>? get summary {
    if (_self.summary == null) {
    return null;
  }

  return $InventorySummaryCopyWith<$Res>(_self.summary!, (value) {
    return _then(_self.copyWith(summary: value));
  });
}
}

// dart format on
