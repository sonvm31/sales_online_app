class UpdateProfileRequest {
  final String? fullName;
  final String? phone;
  final String? address;
  final String? shopName;
  final String? shopDescription;
  final String? shopAddress;
  final String? shopAvatarUrl;
  final double? latitude;
  final double? longitude;

  const UpdateProfileRequest({
    this.fullName,
    this.phone,
    this.address,
    this.shopName,
    this.shopDescription,
    this.shopAddress,
    this.shopAvatarUrl,
    this.latitude,
    this.longitude,
  });

  bool get hasChanges => toJson().isNotEmpty;

  Map<String, dynamic> toJson() {
    return <String, dynamic>{
      if (fullName != null) 'fullName': fullName,
      if (phone != null) 'phone': phone,
      if (address != null) 'address': address,
      if (shopName != null) 'shopName': shopName,
      if (shopDescription != null) 'shopDescription': shopDescription,
      if (shopAddress != null) 'shopAddress': shopAddress,
      if (shopAvatarUrl != null) 'shopAvatarUrl': shopAvatarUrl,
      if (latitude != null) 'latitude': latitude,
      if (longitude != null) 'longitude': longitude,
    };
  }
}
