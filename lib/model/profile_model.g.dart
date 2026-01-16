// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ProfileModel _$ProfileModelFromJson(Map<String, dynamic> json) => ProfileModel(
  id: (json['id'] as num).toInt(),
  userId: (json['user_id'] as num).toInt(),
  user: User.fromJson(json['user'] as Map<String, dynamic>),
  cityId: (json['city_id'] as num).toInt(),
  city: City.fromJson(json['city'] as Map<String, dynamic>),
  districtId: (json['district_id'] as num).toInt(),
  district: District.fromJson(json['district'] as Map<String, dynamic>),
  neighbourhoodId: (json['neighbourhood_id'] as num).toInt(),
  neighbourhood: Neighbourhood.fromJson(
    json['neighbourhood'] as Map<String, dynamic>,
  ),
  gender: json['gender'] as String,
  genderLabel: json['gender_label'] as String,
  birthdate: json['birthdate'] as String,
  address: json['address'] as String?,
);

Map<String, dynamic> _$ProfileModelToJson(ProfileModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'user': instance.user,
      'city_id': instance.cityId,
      'city': instance.city,
      'district_id': instance.districtId,
      'district': instance.district,
      'neighbourhood_id': instance.neighbourhoodId,
      'neighbourhood': instance.neighbourhood,
      'gender': instance.gender,
      'gender_label': instance.genderLabel,
      'birthdate': instance.birthdate,
      'address': instance.address,
    };
