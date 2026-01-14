import 'package:json_annotation/json_annotation.dart';
import 'package:kedv/model/location_model.dart';
import 'package:kedv/model/register_response_model.dart';

part 'profile_model.g.dart';

@JsonSerializable()
class ProfileModel {
  final int id;
  @JsonKey(name: 'user_id')
  final int userId;
  final User user;
  @JsonKey(name: 'city_id')
  final int cityId;
  final City city;
  @JsonKey(name: 'district_id')
  final int districtId;
  final District district;
  @JsonKey(name: 'neighbourhood_id')
  final int neighbourhoodId;
  final Neighbourhood neighbourhood;
  final String gender;
  @JsonKey(name: 'gender_label')
  final String genderLabel;
  final String birthdate;

  ProfileModel({
    required this.id,
    required this.userId,
    required this.user,
    required this.cityId,
    required this.city,
    required this.districtId,
    required this.district,
    required this.neighbourhoodId,
    required this.neighbourhood,
    required this.gender,
    required this.genderLabel,
    required this.birthdate,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) => _$ProfileModelFromJson(json);
  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);
}
