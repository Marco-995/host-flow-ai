import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/data/models/bot_config_models.dart';

void main() {
  test('BotConfiguration parses backend JSON', () {
    final config = BotConfiguration.fromJson({
      'system_prompt': 'You are helpful.',
      'welcome_message': 'Hello guest!',
    });
    expect(config.systemPrompt, 'You are helpful.');
    expect(config.welcomeMessage, 'Hello guest!');
  });

  test('missing fields default to empty strings', () {
    final config = BotConfiguration.fromJson({});
    expect(config.systemPrompt, '');
    expect(config.welcomeMessage, '');
  });
}
