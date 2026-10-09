import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/ai_models.dart';

class AiService {
  final UserSettings settings;

  AiService({required this.settings});

  AIModel get _effectiveModel {
    if (!settings.autoSelectBestModel && settings.selectedModel != null) {
      return settings.selectedModel!;
    }
    // Auto-Select routing logic based on available keys
    if (settings.anthropicApiKey.isNotEmpty) {
      return AIModelData.getBestModelForProvider('Anthropic'); // Claude 3.5 Sonnet
    } else if (settings.openaiApiKey.isNotEmpty) {
      return AIModelData.getBestModelForProvider('OpenAI'); // GPT-4o
    } else if (settings.nvidiaApiKey.isNotEmpty) {
      // NIM doesn't have a single best in our list, but let's assume Llama 3.1 405B from Meta on NIM
      return AIModelData.getBestModelForProvider('Meta'); 
    }
    // Fallback if no keys (will fail later when calling API without key)
    return AIModelData.getGlobalBestModel();
  }

  String _getApiKeyForModel(AIModel model) {
    switch (model.provider) {
      case 'Anthropic':
        return settings.anthropicApiKey;
      case 'OpenAI':
        return settings.openaiApiKey;
      case 'NVIDIA': // Assuming Meta/Mistral models might be served via NIM if user selected NIM, but we structured by original provider.
      case 'Meta':
      case 'Mistral':
      case 'Google': // If we mapped Google to NIM or if we just want to fall back
        // If the user selected a model that is hosted on NVIDIA NIM, we use nvidiaApiKey
        if (settings.nvidiaApiKey.isNotEmpty) return settings.nvidiaApiKey;
        // Fallback to OpenAI if they are using an OpenAI-compatible endpoint
        return settings.openaiApiKey;
      default:
        return settings.openaiApiKey.isNotEmpty ? settings.openaiApiKey : settings.anthropicApiKey;
    }
  }

  Future<String> generateText(String prompt, {String systemPrompt = ''}) async {
    final model = _effectiveModel;
    final apiKey = _getApiKeyForModel(model);

    if (apiKey.isEmpty) {
      throw Exception('API Key for ${model.provider} is missing in Vault.');
    }

    if (model.provider == 'Anthropic') {
      return _callAnthropic(model.id, apiKey, prompt, systemPrompt);
    } else if (model.provider == 'OpenAI') {
      return _callOpenAI(model.id, apiKey, prompt, systemPrompt, 'https://api.openai.com/v1/chat/completions');
    } else {
      // Assume OpenAI-compatible endpoint for NVIDIA NIM (Meta, Mistral etc hosted on build.nvidia.com)
      final endpoint = model.provider == 'Meta' || model.provider == 'Mistral' || model.provider == 'NVIDIA' 
        ? 'https://integrate.api.nvidia.com/v1/chat/completions'
        : 'https://api.openai.com/v1/chat/completions'; // Fallback
      
      // NVIDIA NIM requires model names to be specific, we might need a mapping but we'll send the ID
      String nimModelId = model.id;
      if (endpoint.contains('nvidia')) {
        if (model.id == 'llama-3.1-405b') nimModelId = 'meta/llama-3.1-405b-instruct';
        if (model.id == 'llama-3.1-70b') nimModelId = 'meta/llama-3.1-70b-instruct';
        if (model.id == 'llama-3.1-8b') nimModelId = 'meta/llama-3.1-8b-instruct';
        if (model.id == 'mistral-large') nimModelId = 'mistralai/mistral-large';
        // Add meta/ prefix for generic llamas if not already handled
      }
      return _callOpenAI(nimModelId, apiKey, prompt, systemPrompt, endpoint);
    }
  }

  Future<String> _callAnthropic(String modelId, String apiKey, String prompt, String systemPrompt) async {
    final response = await http.post(
      Uri.parse('https://api.anthropic.com/v1/messages'),
      headers: {
        'x-api-key': apiKey,
        'anthropic-version': '2023-06-01',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'model': modelId,
        'max_tokens': 1024,
        if (systemPrompt.isNotEmpty) 'system': systemPrompt,
        'messages': [
          {'role': 'user', 'content': prompt}
        ]
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['content'][0]['text'] as String;
    } else {
      throw Exception('Anthropic API Error: ${response.statusCode} - ${response.body}');
    }
  }

  Future<String> _callOpenAI(String modelId, String apiKey, String prompt, String systemPrompt, String endpoint) async {
    final messages = [];
    if (systemPrompt.isNotEmpty) {
      messages.add({'role': 'system', 'content': systemPrompt});
    }
    messages.add({'role': 'user', 'content': prompt});

    final response = await http.post(
      Uri.parse(endpoint),
      headers: {
        'Authorization': 'Bearer $apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'model': modelId,
        'messages': messages,
        'max_tokens': 1024,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['choices'][0]['message']['content'] as String;
    } else {
      throw Exception('API Error ($endpoint): ${response.statusCode} - ${response.body}');
    }
  }

  // --- Specialized features --- //

  Future<String> generateCommentReply(String commentAuthor, String commentText, String videoContext) async {
    final systemPrompt = 'You are the creator of a YouTube channel. Reply to the subscriber comment naturally, engagingly, and concisely (under 2 sentences). Maintain a warm, appreciative tone.';
    final prompt = 'Video Context: $videoContext\nSubscriber ($commentAuthor): $commentText\nYour reply:';
    
    return generateText(prompt, systemPrompt: systemPrompt);
  }

  Future<String> generateTitleAndThumbnailIdeas(String currentTitle, String metrics) async {
    final systemPrompt = 'You are an expert YouTube strategist. Given a video title and its metrics, output exactly 3 higher-converting, click-inducing alternative titles. After the titles, provide 2 bullet points describing structural visual suggestions for the thumbnail to increase CTR.';
    final prompt = 'Current Title: $currentTitle\nMetrics: $metrics\n\nProvide 3 titles and visual suggestions:';
    
    return generateText(prompt, systemPrompt: systemPrompt);
  }
}
