import 'package:json_annotation/json_annotation.dart';

part 'register_request_model.g.dart';

@JsonSerializable()
class RegisterRequestModel {
  final String name;
  final String email;
  final String phone;
  final String password;
  @JsonKey(name: 'password_confirmation')
  final String passwordConfirmation;
  final String gender;
  final String birthdate;
  @JsonKey(name: 'city_id')
  final int cityId;
  @JsonKey(name: 'district_id')
  final int districtId;
  @JsonKey(name: 'neighbourhood_id')
  final int neighbourhoodId;

  RegisterRequestModel({
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.passwordConfirmation,
    required this.gender,
    required this.birthdate,
    required this.cityId,
    required this.districtId,
    required this.neighbourhoodId,
  });

  factory RegisterRequestModel.fromJson(Map<String, dynamic> json) => _$RegisterRequestModelFromJson(json);
  Map<String, dynamic> toJson() => _$RegisterRequestModelToJson(this);
}
