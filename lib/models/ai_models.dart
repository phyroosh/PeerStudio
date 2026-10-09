class AIModel {
  final String id;
  final String name;
  final String provider;
  final bool isBestInClass;

  const AIModel({
    required this.id,
    required this.name,
    required this.provider,
    this.isBestInClass = false,
  });
}

class AIModelData {
  static const List<AIModel> allModels = [
    // OpenAI
    AIModel(id: 'gpt-4o', name: 'GPT-4o', provider: 'OpenAI', isBestInClass: true),
    AIModel(id: 'gpt-4o-mini', name: 'GPT-4o mini', provider: 'OpenAI'),
    AIModel(id: 'o1-preview', name: 'o1-preview', provider: 'OpenAI'),
    AIModel(id: 'o1-mini', name: 'o1-mini', provider: 'OpenAI'),
    AIModel(id: 'gpt-4-turbo', name: 'GPT-4 Turbo', provider: 'OpenAI'),
    AIModel(id: 'gpt-4', name: 'GPT-4', provider: 'OpenAI'),
    AIModel(id: 'gpt-3.5-turbo', name: 'GPT-3.5 Turbo', provider: 'OpenAI'),

    // Anthropic
    AIModel(id: 'claude-3-5-sonnet', name: 'Claude 3.5 Sonnet', provider: 'Anthropic', isBestInClass: true),
    AIModel(id: 'claude-3-opus', name: 'Claude 3 Opus', provider: 'Anthropic'),
    AIModel(id: 'claude-3-sonnet', name: 'Claude 3 Sonnet', provider: 'Anthropic'),
    AIModel(id: 'claude-3-haiku', name: 'Claude 3 Haiku', provider: 'Anthropic'),
    AIModel(id: 'claude-2.1', name: 'Claude 2.1', provider: 'Anthropic'),
    AIModel(id: 'claude-2.0', name: 'Claude 2.0', provider: 'Anthropic'),

    // Google
    AIModel(id: 'gemini-1.5-pro', name: 'Gemini 1.5 Pro', provider: 'Google', isBestInClass: true),
    AIModel(id: 'gemini-1.5-flash', name: 'Gemini 1.5 Flash', provider: 'Google'),
    AIModel(id: 'gemini-1.0-pro', name: 'Gemini 1.0 Pro', provider: 'Google'),
    AIModel(id: 'palm-2', name: 'PaLM 2', provider: 'Google'),

    // Meta
    AIModel(id: 'llama-3.1-405b', name: 'Llama 3.1 405B', provider: 'Meta', isBestInClass: true),
    AIModel(id: 'llama-3.1-70b', name: 'Llama 3.1 70B', provider: 'Meta'),
    AIModel(id: 'llama-3.1-8b', name: 'Llama 3.1 8B', provider: 'Meta'),
    AIModel(id: 'llama-3-70b', name: 'Llama 3 70B', provider: 'Meta'),
    AIModel(id: 'llama-3-8b', name: 'Llama 3 8B', provider: 'Meta'),
    AIModel(id: 'llama-2-70b', name: 'Llama 2 70B', provider: 'Meta'),
    AIModel(id: 'llama-2-13b', name: 'Llama 2 13B', provider: 'Meta'),
    AIModel(id: 'llama-2-7b', name: 'Llama 2 7B', provider: 'Meta'),

    // Mistral
    AIModel(id: 'mistral-large-2', name: 'Mistral Large 2', provider: 'Mistral', isBestInClass: true),
    AIModel(id: 'mistral-large', name: 'Mistral Large', provider: 'Mistral'),
    AIModel(id: 'mistral-medium', name: 'Mistral Medium', provider: 'Mistral'),
    AIModel(id: 'mistral-small', name: 'Mistral Small', provider: 'Mistral'),
    AIModel(id: 'mixtral-8x22b', name: 'Mixtral 8x22B', provider: 'Mistral'),
    AIModel(id: 'mixtral-8x7b', name: 'Mixtral 8x7B', provider: 'Mistral'),
    AIModel(id: 'mistral-nemo', name: 'Mistral Nemo', provider: 'Mistral'),
    AIModel(id: 'mistral-7b', name: 'Mistral 7B', provider: 'Mistral'),

    // Cohere
    AIModel(id: 'command-r-plus', name: 'Command R+', provider: 'Cohere', isBestInClass: true),
    AIModel(id: 'command-r', name: 'Command R', provider: 'Cohere'),
    AIModel(id: 'command', name: 'Command', provider: 'Cohere'),
    AIModel(id: 'command-light', name: 'Command Light', provider: 'Cohere'),

    // xAI
    AIModel(id: 'grok-2', name: 'Grok 2', provider: 'xAI', isBestInClass: true),
    AIModel(id: 'grok-2-mini', name: 'Grok 2 Mini', provider: 'xAI'),
    AIModel(id: 'grok-1.5', name: 'Grok 1.5', provider: 'xAI'),

    // AI21
    AIModel(id: 'jamba-1.5-large', name: 'Jamba 1.5 Large', provider: 'AI21', isBestInClass: true),
    AIModel(id: 'jamba-1.5-mini', name: 'Jamba 1.5 Mini', provider: 'AI21'),
    AIModel(id: 'j2-ultra', name: 'Jurassic-2 Ultra', provider: 'AI21'),

    // Amazon
    AIModel(id: 'titan-text-premier', name: 'Titan Text Premier', provider: 'Amazon', isBestInClass: true),
    AIModel(id: 'titan-text-express', name: 'Titan Text Express', provider: 'Amazon'),

    // Databricks
    AIModel(id: 'dbrx-instruct', name: 'DBRX Instruct', provider: 'Databricks', isBestInClass: true),

    // DeepSeek
    AIModel(id: 'deepseek-coder-v2', name: 'DeepSeek Coder V2', provider: 'DeepSeek', isBestInClass: true),
    AIModel(id: 'deepseek-llm-67b', name: 'DeepSeek LLM 67B', provider: 'DeepSeek'),
    
    // Qwen
    AIModel(id: 'qwen-2.5-72b', name: 'Qwen 2.5 72B', provider: 'Qwen', isBestInClass: true),
    AIModel(id: 'qwen-2.5-coder', name: 'Qwen 2.5 Coder', provider: 'Qwen'),
  ];

  static List<String> getProviders() {
    return allModels.map((m) => m.provider).toSet().toList();
  }

  static List<AIModel> getModelsByProvider(String provider) {
    return allModels.where((m) => m.provider == provider).toList();
  }

  static AIModel getBestModelForProvider(String provider) {
    return allModels.firstWhere(
      (m) => m.provider == provider && m.isBestInClass,
      orElse: () => allModels.firstWhere((m) => m.provider == provider),
    );
  }

  // Fallback to the overall best default (e.g. Claude 3.5 Sonnet)
  static AIModel getGlobalBestModel() {
    return allModels.firstWhere((m) => m.id == 'claude-3-5-sonnet');
  }
}

class UserSettings {
  bool autoSelectBestModel;
  AIModel? selectedModel;
  
  // Legacy general key if needed, or we just rely on specific ones
  String apiKey;

  String anthropicApiKey;
  String openaiApiKey;
  String nvidiaApiKey;

  String youtubeClientId;
  String youtubeClientSecret;
  String youtubeRedirectUri;

  UserSettings({
    this.autoSelectBestModel = true,
    this.selectedModel,
    this.apiKey = '',
    this.anthropicApiKey = '',
    this.openaiApiKey = '',
    this.nvidiaApiKey = '',
    this.youtubeClientId = '',
    this.youtubeClientSecret = '',
    this.youtubeRedirectUri = '',
  });

  AIModel get effectiveModel {
    if (autoSelectBestModel || selectedModel == null) {
      return AIModelData.getGlobalBestModel();
    }
    return selectedModel!;
  }
}
