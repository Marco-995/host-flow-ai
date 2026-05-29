/// Response body for GET /api/v1/health.
class HealthResponse {
  const HealthResponse({
    required this.status,
    required this.version,
  });

  final String status;
  final String version;

  factory HealthResponse.fromJson(Map<String, dynamic> json) {
    return HealthResponse(
      status: json['status'] as String,
      version: json['version'] as String,
    );
  }
}
