// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'expense.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$Expense {

 String get id; String get merchantId; String get userId; ExpenseCategory get category; double get amount; String? get description; DateTime get expenseDate; DateTime get createdAt; DateTime get updatedAt; String? get recordedByName;
/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ExpenseCopyWith<Expense> get copyWith => _$ExpenseCopyWithImpl<Expense>(this as Expense, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description)&&(identical(other.expenseDate, expenseDate) || other.expenseDate == expenseDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.recordedByName, recordedByName) || other.recordedByName == recordedByName));
}


@override
int get hashCode => Object.hash(runtimeType,id,merchantId,userId,category,amount,description,expenseDate,createdAt,updatedAt,recordedByName);

@override
String toString() {
  return 'Expense(id: $id, merchantId: $merchantId, userId: $userId, category: $category, amount: $amount, description: $description, expenseDate: $expenseDate, createdAt: $createdAt, updatedAt: $updatedAt, recordedByName: $recordedByName)';
}


}

/// @nodoc
abstract mixin class $ExpenseCopyWith<$Res>  {
  factory $ExpenseCopyWith(Expense value, $Res Function(Expense) _then) = _$ExpenseCopyWithImpl;
@useResult
$Res call({
 String id, String merchantId, String userId, ExpenseCategory category, double amount, String? description, DateTime expenseDate, DateTime createdAt, DateTime updatedAt, String? recordedByName
});




}
/// @nodoc
class _$ExpenseCopyWithImpl<$Res>
    implements $ExpenseCopyWith<$Res> {
  _$ExpenseCopyWithImpl(this._self, this._then);

  final Expense _self;
  final $Res Function(Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? merchantId = null,Object? userId = null,Object? category = null,Object? amount = null,Object? description = freezed,Object? expenseDate = null,Object? createdAt = null,Object? updatedAt = null,Object? recordedByName = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,merchantId: null == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expenseDate: null == expenseDate ? _self.expenseDate : expenseDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,recordedByName: freezed == recordedByName ? _self.recordedByName : recordedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [Expense].
extension ExpensePatterns on Expense {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Expense value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Expense value)  $default,){
final _that = this;
switch (_that) {
case _Expense():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Expense value)?  $default,){
final _that = this;
switch (_that) {
case _Expense() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String merchantId,  String userId,  ExpenseCategory category,  double amount,  String? description,  DateTime expenseDate,  DateTime createdAt,  DateTime updatedAt,  String? recordedByName)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.merchantId,_that.userId,_that.category,_that.amount,_that.description,_that.expenseDate,_that.createdAt,_that.updatedAt,_that.recordedByName);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String merchantId,  String userId,  ExpenseCategory category,  double amount,  String? description,  DateTime expenseDate,  DateTime createdAt,  DateTime updatedAt,  String? recordedByName)  $default,) {final _that = this;
switch (_that) {
case _Expense():
return $default(_that.id,_that.merchantId,_that.userId,_that.category,_that.amount,_that.description,_that.expenseDate,_that.createdAt,_that.updatedAt,_that.recordedByName);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String merchantId,  String userId,  ExpenseCategory category,  double amount,  String? description,  DateTime expenseDate,  DateTime createdAt,  DateTime updatedAt,  String? recordedByName)?  $default,) {final _that = this;
switch (_that) {
case _Expense() when $default != null:
return $default(_that.id,_that.merchantId,_that.userId,_that.category,_that.amount,_that.description,_that.expenseDate,_that.createdAt,_that.updatedAt,_that.recordedByName);case _:
  return null;

}
}

}

/// @nodoc


class _Expense implements Expense {
  const _Expense({required this.id, required this.merchantId, required this.userId, required this.category, required this.amount, this.description, required this.expenseDate, required this.createdAt, required this.updatedAt, this.recordedByName});
  

@override final  String id;
@override final  String merchantId;
@override final  String userId;
@override final  ExpenseCategory category;
@override final  double amount;
@override final  String? description;
@override final  DateTime expenseDate;
@override final  DateTime createdAt;
@override final  DateTime updatedAt;
@override final  String? recordedByName;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ExpenseCopyWith<_Expense> get copyWith => __$ExpenseCopyWithImpl<_Expense>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Expense&&(identical(other.id, id) || other.id == id)&&(identical(other.merchantId, merchantId) || other.merchantId == merchantId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.amount, amount) || other.amount == amount)&&(identical(other.description, description) || other.description == description)&&(identical(other.expenseDate, expenseDate) || other.expenseDate == expenseDate)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.recordedByName, recordedByName) || other.recordedByName == recordedByName));
}


@override
int get hashCode => Object.hash(runtimeType,id,merchantId,userId,category,amount,description,expenseDate,createdAt,updatedAt,recordedByName);

@override
String toString() {
  return 'Expense(id: $id, merchantId: $merchantId, userId: $userId, category: $category, amount: $amount, description: $description, expenseDate: $expenseDate, createdAt: $createdAt, updatedAt: $updatedAt, recordedByName: $recordedByName)';
}


}

/// @nodoc
abstract mixin class _$ExpenseCopyWith<$Res> implements $ExpenseCopyWith<$Res> {
  factory _$ExpenseCopyWith(_Expense value, $Res Function(_Expense) _then) = __$ExpenseCopyWithImpl;
@override @useResult
$Res call({
 String id, String merchantId, String userId, ExpenseCategory category, double amount, String? description, DateTime expenseDate, DateTime createdAt, DateTime updatedAt, String? recordedByName
});




}
/// @nodoc
class __$ExpenseCopyWithImpl<$Res>
    implements _$ExpenseCopyWith<$Res> {
  __$ExpenseCopyWithImpl(this._self, this._then);

  final _Expense _self;
  final $Res Function(_Expense) _then;

/// Create a copy of Expense
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? merchantId = null,Object? userId = null,Object? category = null,Object? amount = null,Object? description = freezed,Object? expenseDate = null,Object? createdAt = null,Object? updatedAt = null,Object? recordedByName = freezed,}) {
  return _then(_Expense(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,merchantId: null == merchantId ? _self.merchantId : merchantId // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,category: null == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as ExpenseCategory,amount: null == amount ? _self.amount : amount // ignore: cast_nullable_to_non_nullable
as double,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,expenseDate: null == expenseDate ? _self.expenseDate : expenseDate // ignore: cast_nullable_to_non_nullable
as DateTime,createdAt: null == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as DateTime,updatedAt: null == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as DateTime,recordedByName: freezed == recordedByName ? _self.recordedByName : recordedByName // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on
