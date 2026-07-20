class AuthSession {
  final int? userId;
  final String accessToken;
  final String firebaseUid;
  final String? fullName;
  final String email;
  final String? phone;
  final String? address;
  final double? deliveryLatitude;
  final double? deliveryLongitude;
  final String role;

  const AuthSession({
    this.userId,
    required this.accessToken,
    required this.firebaseUid,
    required this.email,
    this.fullName,
    this.phone,
    this.address,
    this.deliveryLatitude,
    this.deliveryLongitude,
    required this.role,
  });

  AuthSession copyWith({
    String? fullName,
    String? phone,
    String? address,
    double? deliveryLatitude,
    double? deliveryLongitude,
  }) {
    return AuthSession(
      userId: userId,
      accessToken: accessToken,
      firebaseUid: firebaseUid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      deliveryLatitude: deliveryLatitude ?? this.deliveryLatitude,
      deliveryLongitude: deliveryLongitude ?? this.deliveryLongitude,
      role: role,
    );
  }
}
