// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expenses_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$ExpensesState {

 bool get isLoading; bool get isLoadingMore; String? get errorMessage; List<Expense> get expenses; PaginationDto? get pagination; DateTime? get startDate; DateTime? get endDate;/// `null` means all categories.
 ExpenseCategory? get categoryFilter;
/// Create a copy of ExpensesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpensesStateCopyWith<ExpensesState> get copyWith => _$ExpensesStateCopyWithImpl<ExpensesState>(this as ExpensesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ExpensesState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other.expenses, expenses)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.categoryFilter, categoryFilter) || other.categoryFilter == categoryFilter));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isLoadingMore,errorMessage,const DeepCollectionEquality().hash(expenses),pagination,startDate,endDate,categoryFilter);

@override
String toString() {
  return 'ExpensesState(isLoading: $isLoading, isLoadingMore: $isLoadingMore, errorMessage: $errorMessage, expenses: $expenses, pagination: $pagination, startDate: $startDate, endDate: $endDate, categoryFilter: $categoryFilter)';
}


}

/// @nodoc
abstract mixin class $ExpensesStateCopyWith<$Res>  {
  factory $ExpensesStateCopyWith(ExpensesState value, $Res Function(ExpensesState) _then) = _$ExpensesStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, bool isLoadingMore, String? errorMessage, List<Expense> expenses, PaginationDto? pagination, DateTime? startDate, DateTime? endDate, ExpenseCategory? categoryFilter
});




}
/// @nodoc
class _$ExpensesStateCopyWithImpl<$Res>
    implements $ExpensesStateCopyWith<$Res> {
  _$ExpensesStateCopyWithImpl(this._self, this._then);

  final ExpensesState _self;
  final $Res Function(ExpensesState) _then;

/// Create a copy of ExpensesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? isLoadingMore = null,Object? errorMessage = freezed,Object? expenses = null,Object? pagination = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? categoryFilter = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,expenses: null == expenses ? _self.expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<Expense>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryFilter: freezed == categoryFilter ? _self.categoryFilter : categoryFilter // ignore: cast_nullable_to_non_nullable
as ExpenseCategory?,
  ));
}

}


/// Adds pattern-matching-related methods to [ExpensesState].
extension ExpensesStatePatterns on ExpensesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ExpensesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ExpensesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ExpensesState value)  $default,){
final _that = this;
switch (_that) {
case _ExpensesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ExpensesState value)?  $default,){
final _that = this;
switch (_that) {
case _ExpensesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  bool isLoadingMore,  String? errorMessage,  List<Expense> expenses,  PaginationDto? pagination,  DateTime? startDate,  DateTime? endDate,  ExpenseCategory? categoryFilter)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ExpensesState() when $default != null:
return $default(_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.expenses,_that.pagination,_that.startDate,_that.endDate,_that.categoryFilter);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  bool isLoadingMore,  String? errorMessage,  List<Expense> expenses,  PaginationDto? pagination,  DateTime? startDate,  DateTime? endDate,  ExpenseCategory? categoryFilter)  $default,) {final _that = this;
switch (_that) {
case _ExpensesState():
return $default(_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.expenses,_that.pagination,_that.startDate,_that.endDate,_that.categoryFilter);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  bool isLoadingMore,  String? errorMessage,  List<Expense> expenses,  PaginationDto? pagination,  DateTime? startDate,  DateTime? endDate,  ExpenseCategory? categoryFilter)?  $default,) {final _that = this;
switch (_that) {
case _ExpensesState() when $default != null:
return $default(_that.isLoading,_that.isLoadingMore,_that.errorMessage,_that.expenses,_that.pagination,_that.startDate,_that.endDate,_that.categoryFilter);case _:
  return null;

}
}

}

/// @nodoc


class _ExpensesState implements ExpensesState {
  const _ExpensesState({required this.isLoading, this.isLoadingMore = false, this.errorMessage, final  List<Expense> expenses = const <Expense>[], this.pagination, this.startDate, this.endDate, this.categoryFilter}): _expenses = expenses;
  

@override final  bool isLoading;
@override@JsonKey() final  bool isLoadingMore;
@override final  String? errorMessage;
 final  List<Expense> _expenses;
@override@JsonKey() List<Expense> get expenses {
  if (_expenses is EqualUnmodifiableListView) return _expenses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_expenses);
}

@override final  PaginationDto? pagination;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
/// `null` means all categories.
@override final  ExpenseCategory? categoryFilter;

/// Create a copy of ExpensesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpensesStateCopyWith<_ExpensesState> get copyWith => __$ExpensesStateCopyWithImpl<_ExpensesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ExpensesState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.isLoadingMore, isLoadingMore) || other.isLoadingMore == isLoadingMore)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&const DeepCollectionEquality().equals(other._expenses, _expenses)&&(identical(other.pagination, pagination) || other.pagination == pagination)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.categoryFilter, categoryFilter) || other.categoryFilter == categoryFilter));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,isLoadingMore,errorMessage,const DeepCollectionEquality().hash(_expenses),pagination,startDate,endDate,categoryFilter);

@override
String toString() {
  return 'ExpensesState(isLoading: $isLoading, isLoadingMore: $isLoadingMore, errorMessage: $errorMessage, expenses: $expenses, pagination: $pagination, startDate: $startDate, endDate: $endDate, categoryFilter: $categoryFilter)';
}


}

/// @nodoc
abstract mixin class _$ExpensesStateCopyWith<$Res> implements $ExpensesStateCopyWith<$Res> {
  factory _$ExpensesStateCopyWith(_ExpensesState value, $Res Function(_ExpensesState) _then) = __$ExpensesStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, bool isLoadingMore, String? errorMessage, List<Expense> expenses, PaginationDto? pagination, DateTime? startDate, DateTime? endDate, ExpenseCategory? categoryFilter
});




}
/// @nodoc
class __$ExpensesStateCopyWithImpl<$Res>
    implements _$ExpensesStateCopyWith<$Res> {
  __$ExpensesStateCopyWithImpl(this._self, this._then);

  final _ExpensesState _self;
  final $Res Function(_ExpensesState) _then;

/// Create a copy of ExpensesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? isLoadingMore = null,Object? errorMessage = freezed,Object? expenses = null,Object? pagination = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? categoryFilter = freezed,}) {
  return _then(_ExpensesState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,isLoadingMore: null == isLoadingMore ? _self.isLoadingMore : isLoadingMore // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,expenses: null == expenses ? _self._expenses : expenses // ignore: cast_nullable_to_non_nullable
as List<Expense>,pagination: freezed == pagination ? _self.pagination : pagination // ignore: cast_nullable_to_non_nullable
as PaginationDto?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,categoryFilter: freezed == categoryFilter ? _self.categoryFilter : categoryFilter // ignore: cast_nullable_to_non_nullable
as ExpenseCategory?,
  ));
}


}

// dart format on
