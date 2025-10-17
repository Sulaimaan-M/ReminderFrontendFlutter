class DeviceRegistrationResponse {
  final bool success;
  final int? deviceId;
  final String? errorMessage;

  DeviceRegistrationResponse({
    required this.success,
    this.deviceId,
    this.errorMessage,
  });

  factory DeviceRegistrationResponse.failure(String error) {
    return DeviceRegistrationResponse(
      success: false,
      errorMessage: error,
    );
  }

  factory DeviceRegistrationResponse.success(int id) {
    return DeviceRegistrationResponse(
      success: true,
      deviceId: id,
    );
  }
}