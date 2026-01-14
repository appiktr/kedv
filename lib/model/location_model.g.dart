// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'location_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

City _$CityFromJson(Map<String, dynamic> json) =>
    City(id: (json['id'] as num).toInt(), name: json['name'] as String);

Map<String, dynamic> _$CityToJson(City instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
};

District _$DistrictFromJson(Map<String, dynamic> json) => District(
  id: (json['id'] as num).toInt(),
  name: json['name'] as String,
  cityId: (json['city_id'] as num).toInt(),
);

Map<String, dynamic> _$DistrictToJson(District instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'city_id': instance.cityId,
};

Neighbourhood _$NeighbourhoodFromJson(Map<String, dynamic> json) =>
    Neighbourhood(
      id: (json['id'] as num).toInt(),
      name: json['neighbourhood'] as String,
      districtId: (json['district_id'] as num).toInt(),
      cityId: (json['city_id'] as num).toInt(),
    );

Map<String, dynamic> _$NeighbourhoodToJson(Neighbourhood instance) =>
    <String, dynamic>{
      'id': instance.id,
      'neighbourhood': instance.name,
      'district_id': instance.districtId,
      'city_id': instance.cityId,
    };
