// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'dashboard_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$DashboardState {

 bool get isLoading; String? get errorMessage; DateTime? get startDate; DateTime? get endDate; InventorySummary? get inventorySummary; SalesAnalytics? get salesAnalytics;
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$DashboardStateCopyWith<DashboardState> get copyWith => _$DashboardStateCopyWithImpl<DashboardState>(this as DashboardState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is DashboardState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.inventorySummary, inventorySummary) || other.inventorySummary == inventorySummary)&&(identical(other.salesAnalytics, salesAnalytics) || other.salesAnalytics == salesAnalytics));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,startDate,endDate,inventorySummary,salesAnalytics);

@override
String toString() {
  return 'DashboardState(isLoading: $isLoading, errorMessage: $errorMessage, startDate: $startDate, endDate: $endDate, inventorySummary: $inventorySummary, salesAnalytics: $salesAnalytics)';
}


}

/// @nodoc
abstract mixin class $DashboardStateCopyWith<$Res>  {
  factory $DashboardStateCopyWith(DashboardState value, $Res Function(DashboardState) _then) = _$DashboardStateCopyWithImpl;
@useResult
$Res call({
 bool isLoading, String? errorMessage, DateTime? startDate, DateTime? endDate, InventorySummary? inventorySummary, SalesAnalytics? salesAnalytics
});


$InventorySummaryCopyWith<$Res>? get inventorySummary;$SalesAnalyticsCopyWith<$Res>? get salesAnalytics;

}
/// @nodoc
class _$DashboardStateCopyWithImpl<$Res>
    implements $DashboardStateCopyWith<$Res> {
  _$DashboardStateCopyWithImpl(this._self, this._then);

  final DashboardState _self;
  final $Res Function(DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? inventorySummary = freezed,Object? salesAnalytics = freezed,}) {
  return _then(_self.copyWith(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,inventorySummary: freezed == inventorySummary ? _self.inventorySummary : inventorySummary // ignore: cast_nullable_to_non_nullable
as InventorySummary?,salesAnalytics: freezed == salesAnalytics ? _self.salesAnalytics : salesAnalytics // ignore: cast_nullable_to_non_nullable
as SalesAnalytics?,
  ));
}
/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InventorySummaryCopyWith<$Res>? get inventorySummary {
    if (_self.inventorySummary == null) {
    return null;
  }

  return $InventorySummaryCopyWith<$Res>(_self.inventorySummary!, (value) {
    return _then(_self.copyWith(inventorySummary: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesAnalyticsCopyWith<$Res>? get salesAnalytics {
    if (_self.salesAnalytics == null) {
    return null;
  }

  return $SalesAnalyticsCopyWith<$Res>(_self.salesAnalytics!, (value) {
    return _then(_self.copyWith(salesAnalytics: value));
  });
}
}


/// Adds pattern-matching-related methods to [DashboardState].
extension DashboardStatePatterns on DashboardState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _DashboardState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _DashboardState value)  $default,){
final _that = this;
switch (_that) {
case _DashboardState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _DashboardState value)?  $default,){
final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  DateTime? startDate,  DateTime? endDate,  InventorySummary? inventorySummary,  SalesAnalytics? salesAnalytics)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.startDate,_that.endDate,_that.inventorySummary,_that.salesAnalytics);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( bool isLoading,  String? errorMessage,  DateTime? startDate,  DateTime? endDate,  InventorySummary? inventorySummary,  SalesAnalytics? salesAnalytics)  $default,) {final _that = this;
switch (_that) {
case _DashboardState():
return $default(_that.isLoading,_that.errorMessage,_that.startDate,_that.endDate,_that.inventorySummary,_that.salesAnalytics);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( bool isLoading,  String? errorMessage,  DateTime? startDate,  DateTime? endDate,  InventorySummary? inventorySummary,  SalesAnalytics? salesAnalytics)?  $default,) {final _that = this;
switch (_that) {
case _DashboardState() when $default != null:
return $default(_that.isLoading,_that.errorMessage,_that.startDate,_that.endDate,_that.inventorySummary,_that.salesAnalytics);case _:
  return null;

}
}

}

/// @nodoc


class _DashboardState implements DashboardState {
  const _DashboardState({required this.isLoading, this.errorMessage, this.startDate, this.endDate, this.inventorySummary, this.salesAnalytics});
  

@override final  bool isLoading;
@override final  String? errorMessage;
@override final  DateTime? startDate;
@override final  DateTime? endDate;
@override final  InventorySummary? inventorySummary;
@override final  SalesAnalytics? salesAnalytics;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$DashboardStateCopyWith<_DashboardState> get copyWith => __$DashboardStateCopyWithImpl<_DashboardState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _DashboardState&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.errorMessage, errorMessage) || other.errorMessage == errorMessage)&&(identical(other.startDate, startDate) || other.startDate == startDate)&&(identical(other.endDate, endDate) || other.endDate == endDate)&&(identical(other.inventorySummary, inventorySummary) || other.inventorySummary == inventorySummary)&&(identical(other.salesAnalytics, salesAnalytics) || other.salesAnalytics == salesAnalytics));
}


@override
int get hashCode => Object.hash(runtimeType,isLoading,errorMessage,startDate,endDate,inventorySummary,salesAnalytics);

@override
String toString() {
  return 'DashboardState(isLoading: $isLoading, errorMessage: $errorMessage, startDate: $startDate, endDate: $endDate, inventorySummary: $inventorySummary, salesAnalytics: $salesAnalytics)';
}


}

/// @nodoc
abstract mixin class _$DashboardStateCopyWith<$Res> implements $DashboardStateCopyWith<$Res> {
  factory _$DashboardStateCopyWith(_DashboardState value, $Res Function(_DashboardState) _then) = __$DashboardStateCopyWithImpl;
@override @useResult
$Res call({
 bool isLoading, String? errorMessage, DateTime? startDate, DateTime? endDate, InventorySummary? inventorySummary, SalesAnalytics? salesAnalytics
});


@override $InventorySummaryCopyWith<$Res>? get inventorySummary;@override $SalesAnalyticsCopyWith<$Res>? get salesAnalytics;

}
/// @nodoc
class __$DashboardStateCopyWithImpl<$Res>
    implements _$DashboardStateCopyWith<$Res> {
  __$DashboardStateCopyWithImpl(this._self, this._then);

  final _DashboardState _self;
  final $Res Function(_DashboardState) _then;

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? isLoading = null,Object? errorMessage = freezed,Object? startDate = freezed,Object? endDate = freezed,Object? inventorySummary = freezed,Object? salesAnalytics = freezed,}) {
  return _then(_DashboardState(
isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,errorMessage: freezed == errorMessage ? _self.errorMessage : errorMessage // ignore: cast_nullable_to_non_nullable
as String?,startDate: freezed == startDate ? _self.startDate : startDate // ignore: cast_nullable_to_non_nullable
as DateTime?,endDate: freezed == endDate ? _self.endDate : endDate // ignore: cast_nullable_to_non_nullable
as DateTime?,inventorySummary: freezed == inventorySummary ? _self.inventorySummary : inventorySummary // ignore: cast_nullable_to_non_nullable
as InventorySummary?,salesAnalytics: freezed == salesAnalytics ? _self.salesAnalytics : salesAnalytics // ignore: cast_nullable_to_non_nullable
as SalesAnalytics?,
  ));
}

/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$InventorySummaryCopyWith<$Res>? get inventorySummary {
    if (_self.inventorySummary == null) {
    return null;
  }

  return $InventorySummaryCopyWith<$Res>(_self.inventorySummary!, (value) {
    return _then(_self.copyWith(inventorySummary: value));
  });
}/// Create a copy of DashboardState
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$SalesAnalyticsCopyWith<$Res>? get salesAnalytics {
    if (_self.salesAnalytics == null) {
    return null;
  }

  return $SalesAnalyticsCopyWith<$Res>(_self.salesAnalytics!, (value) {
    return _then(_self.copyWith(salesAnalytics: value));
  });
}
}

// dart format on
