import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import '../models/ai_models.dart';
import '../services/settings_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/model_accordion_item.dart';

class SettingsPage extends StatefulWidget {
  final UserSettings settings;
  final SettingsService settingsService;
  final ValueChanged<UserSettings> onSettingsChanged;

  const SettingsPage({
    super.key,
    required this.settings,
    required this.settingsService,
    required this.onSettingsChanged,
  });

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  late TextEditingController _anthropicController;
  late TextEditingController _openaiController;
  late TextEditingController _nvidiaController;
  
  late bool _autoSelectBestModel;
  AIModel? _selectedModel;
  String _selectedProvider = 'OpenAI'; 

  bool _obscureAnthropic = true;
  bool _obscureOpenAI = true;
  bool _obscureNvidia = true;

  @override
  void initState() {
    super.initState();
    _anthropicController = TextEditingController(text: widget.settings.anthropicApiKey);
    _openaiController = TextEditingController(text: widget.settings.openaiApiKey);
    _nvidiaController = TextEditingController(text: widget.settings.nvidiaApiKey);
    
    _autoSelectBestModel = widget.settings.autoSelectBestModel;
    _selectedModel = widget.settings.selectedModel;
    if (_selectedModel != null) {
      _selectedProvider = _selectedModel!.provider;
    }
  }

  @override
  void dispose() {
    _anthropicController.dispose();
    _openaiController.dispose();
    _nvidiaController.dispose();
    super.dispose();
  }

  void _updateSettings() {
    widget.onSettingsChanged(
      UserSettings(
        autoSelectBestModel: _autoSelectBestModel,
        selectedModel: _selectedModel,
        anthropicApiKey: _anthropicController.text.trim(),
        openaiApiKey: _openaiController.text.trim(),
        nvidiaApiKey: _nvidiaController.text.trim(),
        youtubeClientId: widget.settings.youtubeClientId,
        youtubeClientSecret: widget.settings.youtubeClientSecret,
        youtubeRedirectUri: widget.settings.youtubeRedirectUri,
      ),
    );
  }

  void _showToast(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade800 : AppTheme.electricCyan,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  bool _validateApiKeys() {
    if (_anthropicController.text.isNotEmpty && !_anthropicController.text.startsWith('sk-ant-')) {
      _showToast('Invalid Anthropic API Key format. Should start with sk-ant-', isError: true);
      return false;
    }
    if (_openaiController.text.isNotEmpty && !_openaiController.text.startsWith('sk-')) {
      _showToast('Invalid OpenAI API Key format. Should start with sk-', isError: true);
      return false;
    }
    if (_nvidiaController.text.isNotEmpty && _nvidiaController.text.length < 20) {
      _showToast('NVIDIA API Key seems too short.', isError: true);
      return false;
    }
    return true;
  }

  Future<void> _pickAndParseClientSecret() async {
    try {
      PlatformFile? result = await FilePicker.pickFile(
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result != null && result.path != null) {
        final filePath = result.path!;
        final parsed = await widget.settingsService.parseClientSecret(filePath);
        
        widget.onSettingsChanged(
          UserSettings(
            autoSelectBestModel: _autoSelectBestModel,
            selectedModel: _selectedModel,
            anthropicApiKey: _anthropicController.text.trim(),
            openaiApiKey: _openaiController.text.trim(),
            nvidiaApiKey: _nvidiaController.text.trim(),
            youtubeClientId: parsed['clientId'] ?? '',
            youtubeClientSecret: parsed['clientSecret'] ?? '',
            youtubeRedirectUri: parsed['redirectUri'] ?? '',
          ),
        );

        _showToast('YouTube Client Secret loaded successfully!');
      }
    } catch (e) {
      _showToast(e.toString(), isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final providers = AIModelData.getProviders();
    final effectiveModel = widget.settings.effectiveModel;

    return ListView(
      padding: const EdgeInsets.all(24.0),
      children: [
        const Text(
          'API Configuration',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 24),
        
        GlassCard(
          child: Column(
            children: [
              _buildApiKeyField(
                label: 'Anthropic API Key',
                controller: _anthropicController,
                obscureText: _obscureAnthropic,
                onToggleVisibility: () => setState(() => _obscureAnthropic = !_obscureAnthropic),
              ),
              const SizedBox(height: 16),
              _buildApiKeyField(
                label: 'OpenAI API Key',
                controller: _openaiController,
                obscureText: _obscureOpenAI,
                onToggleVisibility: () => setState(() => _obscureOpenAI = !_obscureOpenAI),
              ),
              const SizedBox(height: 16),
              _buildApiKeyField(
                label: 'NVIDIA NIM API Key',
                controller: _nvidiaController,
                obscureText: _obscureNvidia,
                onToggleVisibility: () => setState(() => _obscureNvidia = !_obscureNvidia),
              ),
              const SizedBox(height: 24),
              BouncyButton(
                onPressed: () {
                  if (_validateApiKeys()) {
                    _updateSettings();
                    _showToast('API Keys validated and saved.');
                  }
                },
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppTheme.electricCyan, Color(0xFF00B4D8)],
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Text('Save API Keys', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 48),

        const Text(
          'YouTube Local Vault',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 24),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              BouncyButton(
                onPressed: _pickAndParseClientSecret,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: AppTheme.border,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.file_upload, color: Colors.white),
                      SizedBox(width: 8),
                      Text('Load client_secret.json', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
              ),
              if (widget.settings.youtubeClientId.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.green.withValues(alpha: 0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.check_circle, color: Colors.green),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('YouTube Client ID Loaded', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                            Text(widget.settings.youtubeClientId, style: const TextStyle(color: Colors.white70, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),

        const SizedBox(height: 48),

        const Text(
          'Model Selection',
          style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, letterSpacing: -0.5),
        ),
        const SizedBox(height: 24),

        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SwitchListTile(
                title: const Text('Auto-Select Best Model', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                subtitle: Text(
                  'Currently effective model: ${effectiveModel.name} (${effectiveModel.provider})',
                  style: const TextStyle(color: AppTheme.electricCyan),
                ),
                value: _autoSelectBestModel,
                activeThumbColor: AppTheme.electricCyan,
                onChanged: (value) {
                  setState(() {
                    _autoSelectBestModel = value;
                    if (value) {
                      _selectedModel = null;
                    }
                  });
                  _updateSettings();
                },
              ),
              
              const SizedBox(height: 24),
              
              // Provider tabs
              Opacity(
                opacity: _autoSelectBestModel ? 0.5 : 1.0,
                child: IgnorePointer(
                  ignoring: _autoSelectBestModel,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: providers.map((provider) {
                            final isSelected = _selectedProvider == provider;
                            return Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: BouncyButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedProvider = provider;
                                    _selectedModel = AIModelData.getBestModelForProvider(provider);
                                  });
                                  _updateSettings();
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: isSelected ? AppTheme.neonAmethyst : AppTheme.border,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    provider,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isSelected ? Colors.white : Colors.white70,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 24),
                      // Accordion list of models for selected provider
                      ...AIModelData.getModelsByProvider(_selectedProvider).map((model) {
                        return ModelAccordionItem(
                          model: model,
                          isSelected: _selectedModel?.id == model.id,
                          onSelect: () {
                            setState(() {
                              _selectedModel = model;
                            });
                            _updateSettings();
                          },
                        );
                      }),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildApiKeyField({
    required String label,
    required TextEditingController controller,
    required bool obscureText,
    required VoidCallback onToggleVisibility,
  }) {
    return TextField(
      controller: controller,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppTheme.electricCyan),
        ),
        prefixIcon: const Icon(Icons.vpn_key, color: Colors.white54),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility : Icons.visibility_off, color: Colors.white54),
          onPressed: onToggleVisibility,
        ),
        filled: true,
        fillColor: AppTheme.background.withValues(alpha: 0.5),
      ),
      obscureText: obscureText,
    );
  }
}
