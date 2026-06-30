// Request
class ParentSendOtpRequest {
  final String email;
  ParentSendOtpRequest({required this.email});

  Map<String, dynamic> toJson() => {'email': email};
}

// Response
class ParentSendOtpResponse {
  final bool status;
  final String message;

  ParentSendOtpResponse({required this.status, required this.message});

  factory ParentSendOtpResponse.fromJson(Map<String, dynamic> json) {
    return ParentSendOtpResponse(
      status: json['status'] ?? false,
      message: json['message'] ?? '',
    );
  }
}