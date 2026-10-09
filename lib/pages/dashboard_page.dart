import 'package:flutter/material.dart';
import '../services/youtube_service.dart';
import '../services/ai_service.dart';
import '../widgets/glass_card.dart';
import '../widgets/bouncy_button.dart';
import '../widgets/animated_counter.dart';
import '../widgets/shimmer_loader.dart';
import '../theme/app_theme.dart';
class DashboardPage extends StatefulWidget {
  final YoutubeService youtubeService;
  final AiService aiService;

  const DashboardPage({
    super.key,
    required this.youtubeService,
    required this.aiService,
  });

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  bool _isLoading = false;
  bool _isSignedIn = false;

  Map<String, dynamic>? _channelStats;
  List<Map<String, dynamic>>? _recentVideos;
  List<Map<String, dynamic>>? _unrepliedComments;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _isSignedIn = widget.youtubeService.isSignedIn;
    if (_isSignedIn) {
      _loadDashboardData();
    }
  }

  Future<void> _handleSignIn() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final success = await widget.youtubeService.signIn();
    
    setState(() {
      _isSignedIn = success;
    });

    if (success) {
      await _loadDashboardData();
    } else {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to sign in. Check Client ID config.';
      });
    }
  }

  Future<void> _handleSignOut() async {
    await widget.youtubeService.signOut();
    setState(() {
      _isSignedIn = false;
      _channelStats = null;
      _recentVideos = null;
      _unrepliedComments = null;
    });
  }

  Future<void> _loadDashboardData() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final stats = await widget.youtubeService.fetchChannelStats();
      final videos = await widget.youtubeService.fetchRecentVideos();
      final comments = await widget.youtubeService.fetchUnrepliedComments();

      if (mounted) {
        setState(() {
          _channelStats = stats;
          _recentVideos = videos;
          _unrepliedComments = comments;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
        });
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _handleAiReply(Map<String, dynamic> comment) async {
    final videoId = comment['videoId'] as String;
    // Find video context
    final video = _recentVideos?.firstWhere((v) => v['id'] == videoId, orElse: () => {'title': 'Unknown Video'});
    final videoContext = 'Video Title: ${video?['title']}';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 24),
              Text('AI is generating a reply...'),
            ],
          ),
        );
      }
    );

    try {
      final replyText = await widget.aiService.generateCommentReply(
        comment['author'], 
        comment['text'], 
        videoContext,
      );
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog

      _showReplyApprovalDialog(comment, replyText);
    } catch (e) {
      if (!mounted) return;
      Navigator.of(context).pop(); // Close loading dialog
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('AI Error: $e'), backgroundColor: Colors.red));
    }
  }

  void _showReplyApprovalDialog(Map<String, dynamic> comment, String generatedReply) {
    final TextEditingController replyController = TextEditingController(text: generatedReply);

    showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Review AI Reply'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Comment by ${comment['author']}:', style: const TextStyle(fontWeight: FontWeight.bold)),
              Text(comment['text']),
              const SizedBox(height: 16),
              TextField(
                controller: replyController,
                maxLines: 4,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  labelText: 'Generated Reply',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                final text = replyController.text.trim();
                if (text.isEmpty) return;
                
                Navigator.of(dialogContext).pop(); // Close dialog
                final success = await widget.youtubeService.replyToComment(comment['id'], text);
                if (!mounted) return;
                
                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Reply posted successfully!'), backgroundColor: Colors.green));
                  _loadDashboardData(); // Refresh list
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to post reply'), backgroundColor: Colors.red));
                }
              },
              child: const Text('Post Reply'),
            ),
          ],
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!_isSignedIn) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.youtube_searched_for, size: 64, color: Colors.redAccent),
            const SizedBox(height: 16),
            const Text(
              'Connect your YouTube Channel',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            if (_errorMessage != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
              ),
            _isLoading 
              ? const CircularProgressIndicator()
              : ElevatedButton.icon(
                  onPressed: _handleSignIn,
                  icon: const Icon(Icons.login),
                  label: const Text('Sign in with Google'),
                ),
          ],
        ),
      );
    }

    if (_isLoading && _channelStats == null) {
      return Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const ShimmerLoader(width: 250, height: 40),
            const SizedBox(height: 32),
            Row(
              children: [
                Expanded(child: const ShimmerLoader(width: double.infinity, height: 120)),
                const SizedBox(width: 16),
                Expanded(child: const ShimmerLoader(width: double.infinity, height: 120)),
                const SizedBox(width: 16),
                Expanded(child: const ShimmerLoader(width: double.infinity, height: 120)),
              ],
            ),
            const SizedBox(height: 32),
            const ShimmerLoader(width: double.infinity, height: 200),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadDashboardData,
      child: ListView(
        padding: const EdgeInsets.all(24.0),
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Welcome, ${_channelStats?['title'] ?? 'Creator'}',
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              OutlinedButton.icon(
                onPressed: _handleSignOut,
                icon: const Icon(Icons.logout, size: 18),
                label: const Text('Sign Out'),
              ),
            ],
          ),
          if (_errorMessage != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text('Error: $_errorMessage', style: const TextStyle(color: Colors.red)),
            ),
          const SizedBox(height: 24),
          
          // Overall stats
          _buildStatsCards(),
          const SizedBox(height: 32),

          // Recent Videos
          const Text('Recent Videos (Last 10)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildRecentVideos(),
          const SizedBox(height: 32),

          // Unreplied Comments
          const Text('Unreplied Comments (Top 10)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),
          _buildUnrepliedComments(),
        ],
      ),
    );
  }

  Widget _buildStatsCards() {
    if (_channelStats == null) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final crossAxisCount = constraints.maxWidth > 800 ? 3 : (constraints.maxWidth > 500 ? 2 : 1);
        return GridView.count(
          crossAxisCount: crossAxisCount,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 2.5,
          children: [
            _buildStatCard('Total Subscribers', _channelStats!['subscribers'], Icons.people),
            _buildStatCard('Lifetime Views', _channelStats!['views'], Icons.remove_red_eye),
            _buildStatCard('Video Count', _channelStats!['videoCount'], Icons.video_library),
          ],
        );
      },
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    int numericValue = int.tryParse(value.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    
    return GlassCard(
      padding: const EdgeInsets.all(20.0),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.electricCyan.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 28, color: AppTheme.electricCyan),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(title, style: const TextStyle(color: Colors.white60, fontSize: 13, fontWeight: FontWeight.w500)),
                const SizedBox(height: 4),
                AnimatedCounter(
                  value: numericValue,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, letterSpacing: -0.5),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentVideos() {
    if (_recentVideos == null || _recentVideos!.isEmpty) {
      return const Text('No recent videos found.');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _recentVideos!.length,
      itemBuilder: (context, index) {
        final video = _recentVideos![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: BouncyButton(
            child: GlassCard(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: video['thumbnailUrl'] != '' 
                      ? Image.network(video['thumbnailUrl'], width: 120, height: 68, fit: BoxFit.cover)
                      : Container(width: 120, height: 68, color: Colors.grey[800], child: const Icon(Icons.video_file)),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(video['title'], maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            const Icon(Icons.remove_red_eye, size: 14, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text('${video['views']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(width: 16),
                            const Icon(Icons.thumb_up, size: 14, color: Colors.white54),
                            const SizedBox(width: 4),
                            Text('${video['likes']}', style: const TextStyle(color: Colors.white54, fontSize: 12)),
                            const SizedBox(width: 16),
                            const Icon(Icons.mouse, size: 14, color: AppTheme.neonAmethyst),
                            const SizedBox(width: 4),
                            Text('CTR: ${video['ctr']}', style: const TextStyle(color: AppTheme.neonAmethyst, fontSize: 12, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildUnrepliedComments() {
    if (_unrepliedComments == null || _unrepliedComments!.isEmpty) {
      return const Text('No unreplied comments! You\'re all caught up.');
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _unrepliedComments!.length,
      itemBuilder: (context, index) {
        final comment = _unrepliedComments![index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: AppTheme.electricCyan.withValues(alpha: 0.2),
                  child: const Icon(Icons.person, color: AppTheme.electricCyan),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(comment['author'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const SizedBox(height: 4),
                      Text(comment['text'], style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                BouncyButton(
                  onPressed: () => _handleAiReply(comment),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.neonAmethyst, AppTheme.neonAmethyst.withValues(alpha: 0.8)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.auto_awesome, size: 16, color: Colors.white),
                        SizedBox(width: 8),
                        Text('AI Reply', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
