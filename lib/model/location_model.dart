import 'package:json_annotation/json_annotation.dart';

part 'location_model.g.dart';

@JsonSerializable()
class City {
  final int id;
  final String name;

  City({required this.id, required this.name});

  factory City.fromJson(Map<String, dynamic> json) => _$CityFromJson(json);
  Map<String, dynamic> toJson() => _$CityToJson(this);

  @override
  String toString() => name;
}

@JsonSerializable()
class District {
  final int id;
  final String name;
  @JsonKey(name: 'city_id')
  final int cityId;

  District({required this.id, required this.name, required this.cityId});

  factory District.fromJson(Map<String, dynamic> json) => _$DistrictFromJson(json);
  Map<String, dynamic> toJson() => _$DistrictToJson(this);

  @override
  String toString() => name;
}

@JsonSerializable()
class Neighbourhood {
  final int id;
  @JsonKey(name: 'neighbourhood')
  final String name;
  @JsonKey(name: 'district_id')
  final int districtId;
  @JsonKey(name: 'city_id')
  final int cityId;

  Neighbourhood({required this.id, required this.name, required this.districtId, required this.cityId});

  factory Neighbourhood.fromJson(Map<String, dynamic> json) => _$NeighbourhoodFromJson(json);
  Map<String, dynamic> toJson() => _$NeighbourhoodToJson(this);

  @override
  String toString() => name;
}
