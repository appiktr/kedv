class ProfileUpdateRequestModel {
  final String name;
  final String phone;
  final String gender;
  final String birthdate;
  final int cityId;
  final int districtId;
  final int neighbourhoodId;
  final String address;
  final String? currentPassword;
  final String? password;
  final String? passwordConfirmation;

  ProfileUpdateRequestModel({
    required this.name,
    required this.phone,
    required this.gender,
    required this.birthdate,
    required this.cityId,
    required this.districtId,
    required this.neighbourhoodId,
    required this.address,
    this.currentPassword,
    this.password,
    this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': name,
      'phone': phone,
      'gender': gender,
      'birthdate': birthdate,
      'city_id': cityId,
      'district_id': districtId,
      'neighbourhood_id': neighbourhoodId,
      'address': address,
    };

    if (currentPassword != null && currentPassword!.isNotEmpty) {
      data['current_password'] = currentPassword;
    }
    if (password != null && password!.isNotEmpty) {
      data['password'] = password;
    }
    if (passwordConfirmation != null && passwordConfirmation!.isNotEmpty) {
      data['password_confirmation'] = passwordConfirmation;
    }

    return data;
  }
}
