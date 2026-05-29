/// Models for GET /api/v1/bot-config/.
class BotConfiguration {
  const BotConfiguration({
    required this.systemPrompt,
    required this.welcomeMessage,
  });

  final String systemPrompt;
  final String welcomeMessage;

  factory BotConfiguration.fromJson(Map<String, dynamic> json) {
    return BotConfiguration(
      systemPrompt: json['system_prompt'] as String? ?? '',
      welcomeMessage: json['welcome_message'] as String? ?? '',
    );
  }
}
