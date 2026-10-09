import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/ai_models.dart';

class SettingsService {
  static const _keyAnthropic = 'anthropicApiKey';
  static const _keyOpenAI = 'openaiApiKey';
  static const _keyNvidia = 'nvidiaApiKey';
  static const _keyYtClientId = 'ytClientId';
  static const _keyYtClientSecret = 'ytClientSecret';
  static const _keyYtRedirectUri = 'ytRedirectUri';
  static const _keyAutoSelect = 'autoSelectBestModel';
  static const _keyProvider = 'selectedProvider';
  static const _keyModelId = 'selectedModelId';

  late SharedPreferences _prefs;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  UserSettings loadSettings() {
    final provider = _prefs.getString(_keyProvider) ?? 'OpenAI';
    final modelId = _prefs.getString(_keyModelId);
    AIModel? selectedModel;
    if (modelId != null) {
      selectedModel = AIModelData.allModels.firstWhere(
        (m) => m.id == modelId,
        orElse: () => AIModelData.getBestModelForProvider(provider),
      );
    }

    return UserSettings(
      autoSelectBestModel: _prefs.getBool(_keyAutoSelect) ?? true,
      selectedModel: selectedModel,
      apiKey: '', // kept for backwards compatibility in UI if needed, but we now use specific keys
      anthropicApiKey: _prefs.getString(_keyAnthropic) ?? '',
      openaiApiKey: _prefs.getString(_keyOpenAI) ?? '',
      nvidiaApiKey: _prefs.getString(_keyNvidia) ?? '',
      youtubeClientId: _prefs.getString(_keyYtClientId) ?? '',
      youtubeClientSecret: _prefs.getString(_keyYtClientSecret) ?? '',
      youtubeRedirectUri: _prefs.getString(_keyYtRedirectUri) ?? '',
    );
  }

  Future<void> saveSettings(UserSettings settings) async {
    await _prefs.setBool(_keyAutoSelect, settings.autoSelectBestModel);
    if (settings.selectedModel != null) {
      await _prefs.setString(_keyProvider, settings.selectedModel!.provider);
      await _prefs.setString(_keyModelId, settings.selectedModel!.id);
    }
    await _prefs.setString(_keyAnthropic, settings.anthropicApiKey);
    await _prefs.setString(_keyOpenAI, settings.openaiApiKey);
    await _prefs.setString(_keyNvidia, settings.nvidiaApiKey);
    await _prefs.setString(_keyYtClientId, settings.youtubeClientId);
    await _prefs.setString(_keyYtClientSecret, settings.youtubeClientSecret);
    await _prefs.setString(_keyYtRedirectUri, settings.youtubeRedirectUri);
  }

  Future<Map<String, String>> parseClientSecret(String filePath) async {
    try {
      final file = File(filePath);
      final content = await file.readAsString();
      final json = jsonDecode(content) as Map<String, dynamic>;

      final clientType = json.containsKey('installed') ? 'installed' : (json.containsKey('web') ? 'web' : null);
      if (clientType == null) {
        throw Exception('Invalid client_secret.json format. Missing "installed" or "web" key.');
      }

      final data = json[clientType] as Map<String, dynamic>;
      final clientId = data['client_id'] as String?;
      final clientSecret = data['client_secret'] as String?;
      final redirectUris = data['redirect_uris'] as List<dynamic>?;
      
      if (clientId == null || clientSecret == null) {
        throw Exception('Missing client_id or client_secret.');
      }

      final redirectUri = (redirectUris != null && redirectUris.isNotEmpty) ? redirectUris.first.toString() : '';

      return {
        'clientId': clientId,
        'clientSecret': clientSecret,
        'redirectUri': redirectUri,
      };
    } catch (e) {
      throw Exception('Failed to parse file: $e');
    }
  }
}
