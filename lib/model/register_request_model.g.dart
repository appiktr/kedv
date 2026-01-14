// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'register_request_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

RegisterRequestModel _$RegisterRequestModelFromJson(
  Map<String, dynamic> json,
) => RegisterRequestModel(
  name: json['name'] as String,
  email: json['email'] as String,
  phone: json['phone'] as String,
  password: json['password'] as String,
  passwordConfirmation: json['password_confirmation'] as String,
  gender: json['gender'] as String,
  birthdate: json['birthdate'] as String,
  cityId: (json['city_id'] as num).toInt(),
  districtId: (json['district_id'] as num).toInt(),
  neighbourhoodId: (json['neighbourhood_id'] as num).toInt(),
);

Map<String, dynamic> _$RegisterRequestModelToJson(
  RegisterRequestModel instance,
) => <String, dynamic>{
  'name': instance.name,
  'email': instance.email,
  'phone': instance.phone,
  'password': instance.password,
  'password_confirmation': instance.passwordConfirmation,
  'gender': instance.gender,
  'birthdate': instance.birthdate,
  'city_id': instance.cityId,
  'district_id': instance.districtId,
  'neighbourhood_id': instance.neighbourhoodId,
};
