import 'package:flutter/material.dart';
import '../services/ai_service.dart';
import '../services/youtube_service.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';
import '../widgets/bouncy_button.dart';

class VideoOptimizerPage extends StatefulWidget {
  final AiService aiService;
  final YoutubeService youtubeService;

  const VideoOptimizerPage({
    super.key,
    required this.aiService,
    required this.youtubeService,
  });

  @override
  State<VideoOptimizerPage> createState() => _VideoOptimizerPageState();
}

class _VideoOptimizerPageState extends State<VideoOptimizerPage> {
  final _titleController = TextEditingController();
  final _metricsController = TextEditingController();
  
  bool _isLoading = false;
  String? _result;
  String? _selectedVideoId;

  // Let's optionally load recent videos so user can pick one easily
  List<dynamic> _recentVideos = [];
  bool _isLoadingVideos = false;

  @override
  void initState() {
    super.initState();
    _fetchRecentVideos();
  }

  Future<void> _fetchRecentVideos() async {
    if (!widget.youtubeService.isSignedIn) return;
    
    setState(() {
      _isLoadingVideos = true;
    });

    try {
      final videos = await widget.youtubeService.fetchRecentVideos();
      setState(() {
        _recentVideos = videos;
      });
    } catch (e) {
      debugPrint('Error fetching videos for optimizer: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingVideos = false;
        });
      }
    }
  }

  void _onVideoSelected(dynamic video) {
    if (video == null) return;
    
    final title = video['title'] ?? '';
    final viewCount = video['views'] ?? 'N/A';
    final likeCount = video['likes'] ?? 'N/A';
    final commentCount = video['comments'] ?? 'N/A';

    setState(() {
      _selectedVideoId = video['id'];
      _titleController.text = title;
      _metricsController.text = 'Views: $viewCount, Likes: $likeCount, Comments: $commentCount';
      _result = null; // Clear previous result
    });
  }

  Future<void> _generateIdeas() async {
    if (_titleController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a video title')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
      _result = null;
    });

    try {
      final result = await widget.aiService.generateTitleAndThumbnailIdeas(
        _titleController.text,
        _metricsController.text,
      );
      
      setState(() {
        _result = result;
      });
    } catch (e) {
      setState(() {
        _result = 'Error generating ideas: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _metricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Title & Thumbnail Optimizer', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: -0.5)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            GlassCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (_isLoadingVideos)
                    const Center(child: CircularProgressIndicator())
                  else if (_recentVideos.isNotEmpty) ...[
                    const Text('Select Video Context', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white70)),
                    const SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: AppTheme.background.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTheme.border),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<dynamic>(
                          dropdownColor: AppTheme.surface,
                          items: _recentVideos.map((video) {
                            return DropdownMenuItem<dynamic>(
                              value: video,
                              child: Text(
                                video['title'] ?? 'Unknown',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          }).toList(),
                          onChanged: _onVideoSelected,
                          value: _recentVideos.any((v) => v['id'] == _selectedVideoId) 
                              ? _recentVideos.firstWhere((v) => v['id'] == _selectedVideoId)
                              : null,
                          isExpanded: true,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                  ],
                  
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Current Video Title',
                      labelStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.electricCyan)),
                      filled: true,
                      fillColor: AppTheme.background.withValues(alpha: 0.5),
                    ),
                    maxLines: null,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _metricsController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      labelText: 'Current Metrics (e.g. Views: 1000, CTR: 5%)',
                      labelStyle: const TextStyle(color: Colors.white54),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.border)),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: AppTheme.electricCyan)),
                      filled: true,
                      fillColor: AppTheme.background.withValues(alpha: 0.5),
                    ),
                    maxLines: null,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            BouncyButton(
              onPressed: _isLoading ? null : _generateIdeas,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.neonAmethyst, Color(0xFFB5179E)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.neonAmethyst.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    )
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (_isLoading)
                      const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)))
                    else
                      const Icon(Icons.auto_awesome, color: Colors.white),
                    const SizedBox(width: 12),
                    const Text('Optimize Title & Thumbnail', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            if (_result != null) ...[
              const Text(
                'AI Suggestions:',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: -0.5),
              ),
              const SizedBox(height: 16),
              GlassCard(
                child: Text(
                  _result!,
                  style: const TextStyle(height: 1.6, fontSize: 16),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
