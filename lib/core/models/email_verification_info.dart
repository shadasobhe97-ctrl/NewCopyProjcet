class EmailVerificationInfo {
  final String status;
  final String? newEmail;

  EmailVerificationInfo({
    required this.status,
    this.newEmail,
  });

  factory EmailVerificationInfo.fromJson(Map<String, dynamic> json) {
    return EmailVerificationInfo(
      status: json['status']?.toString() ?? '',
      newEmail: json['new_email']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'new_email': newEmail,
    };
  }
}

class ProfileUpdateResult<T> {
  final T profile;
  final EmailVerificationInfo? emailVerification;
  final String message;

  ProfileUpdateResult({
    required this.profile,
    this.emailVerification,
    required this.message,
  });
}
