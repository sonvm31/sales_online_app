class AuthSession {
  final int? userId;
  final String accessToken;
  final String firebaseUid;
  final String? fullName;
  final String email;
  final String? phone;
  final String role;

  const AuthSession({
    this.userId,
    required this.accessToken,
    required this.firebaseUid,
    required this.email,
    this.fullName,
    this.phone,
    required this.role,
  });

  AuthSession copyWith({String? fullName, String? phone}) {
    return AuthSession(
      userId: userId,
      accessToken: accessToken,
      firebaseUid: firebaseUid,
      fullName: fullName ?? this.fullName,
      email: email,
      phone: phone ?? this.phone,
      role: role,
    );
  }
}
