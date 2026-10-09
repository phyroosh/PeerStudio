import 'package:googleapis/youtube/v3.dart' as yt;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:extension_google_sign_in_as_googleapis_auth/extension_google_sign_in_as_googleapis_auth.dart';
import '../models/ai_models.dart';

class YoutubeService {
  GoogleSignIn get _googleSignIn => GoogleSignIn.instance;
  yt.YouTubeApi? _youtubeApi;

  Future<void> init(UserSettings settings) async {
    // Only initialize if we have a clientId
    if (settings.youtubeClientId.isNotEmpty) {
      await _googleSignIn.initialize(
        clientId: settings.youtubeClientId,
      );
    }
  }

  Future<bool> signIn() async {
    try {
      final account = await _googleSignIn.authenticate(
        scopeHint: [yt.YouTubeApi.youtubeReadonlyScope],
      );
      
      final authClient = account.authorizationClient;
      final authz = await authClient.authorizeScopes(
        [yt.YouTubeApi.youtubeReadonlyScope],
      );
      
      final gapisClient = authz.authClient(
        scopes: [yt.YouTubeApi.youtubeReadonlyScope],
      );

      _youtubeApi = yt.YouTubeApi(gapisClient);
      return true;
    } catch (e) {
      return false;
    }
  }
  
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    _youtubeApi = null;
  }

  bool get isSignedIn => _youtubeApi != null;

  Future<Map<String, dynamic>> fetchChannelStats() async {
    if (_youtubeApi == null) throw Exception('Not authenticated');

    final channels = await _youtubeApi!.channels.list(
      ['snippet', 'statistics'],
      mine: true,
    );

    if (channels.items == null || channels.items!.isEmpty) {
      throw Exception('No channel found');
    }

    final channel = channels.items!.first;
    return {
      'title': channel.snippet?.title ?? 'Unknown Channel',
      'subscribers': channel.statistics?.subscriberCount ?? '0',
      'views': channel.statistics?.viewCount ?? '0',
      'videoCount': channel.statistics?.videoCount ?? '0',
    };
  }

  Future<List<Map<String, dynamic>>> fetchRecentVideos() async {
    if (_youtubeApi == null) throw Exception('Not authenticated');

    final channels = await _youtubeApi!.channels.list(
      ['contentDetails'],
      mine: true,
    );

    if (channels.items == null || channels.items!.isEmpty) {
      throw Exception('No channel found');
    }

    final uploadsPlaylistId = channels.items!.first.contentDetails?.relatedPlaylists?.uploads;
    if (uploadsPlaylistId == null) throw Exception('No uploads playlist found');

    final playlistItems = await _youtubeApi!.playlistItems.list(
      ['snippet'],
      playlistId: uploadsPlaylistId,
      maxResults: 10,
    );

    if (playlistItems.items == null || playlistItems.items!.isEmpty) {
      return [];
    }

    final videoIds = playlistItems.items!
        .map((item) => item.snippet?.resourceId?.videoId)
        .whereType<String>()
        .toList();

    if (videoIds.isEmpty) return [];

    final videos = await _youtubeApi!.videos.list(
      ['snippet', 'statistics'],
      id: videoIds,
    );

    if (videos.items == null) return [];

    return videos.items!.map((video) {
      final views = int.tryParse(video.statistics?.viewCount ?? '0') ?? 0;
      final likes = int.tryParse(video.statistics?.likeCount ?? '0') ?? 0;
      // Note: Dislikes are no longer available via the API for public, but for authenticated owner, maybe?
      // Actually YouTube removed dislikeCount from the API entirely, even for owners, via the standard videos.list. 
      // It might be in YouTube Analytics API, but we'll return what we have.
      
      return {
        'id': video.id,
        'title': video.snippet?.title ?? 'No title',
        'thumbnailUrl': video.snippet?.thumbnails?.high?.url ?? video.snippet?.thumbnails?.default_?.url ?? '',
        'views': views.toString(),
        'likes': likes.toString(),
        'comments': video.statistics?.commentCount ?? '0',
        // 'ctr' and 'dislikes' require YouTube Analytics API, so we'll leave placeholders or N/A
        'ctr': 'N/A', 
        'likeToDislikeRatio': 'N/A', 
      };
    }).toList();
  }

  Future<List<Map<String, dynamic>>> fetchUnrepliedComments() async {
    if (_youtubeApi == null) throw Exception('Not authenticated');

    final commentThreads = await _youtubeApi!.commentThreads.list(
      ['snippet', 'replies'],
      allThreadsRelatedToChannelId: 'mine',
      maxResults: 50,
    );

    if (commentThreads.items == null || commentThreads.items!.isEmpty) {
      return [];
    }

    // Filter comments where the channel owner hasn't replied.
    // This is a simplified logic: if totalReplyCount is 0, it's definitely unreplied.
    final unreplied = commentThreads.items!.where((thread) {
      final topComment = thread.snippet?.topLevelComment;
      if (topComment == null) return false;
      
      // If no replies, it's unreplied
      if ((thread.snippet?.totalReplyCount ?? 0) == 0) return true;
      
      // We could check if we replied in `thread.replies`, but for simplicity, 
      // just returning top comments with 0 replies to prepare for AI layer.
      return false;
    }).take(10).toList();

    return unreplied.map((thread) {
      final comment = thread.snippet?.topLevelComment?.snippet;
      return {
        'id': thread.id,
        'author': comment?.authorDisplayName ?? 'Unknown',
        'text': comment?.textDisplay ?? '',
        'videoId': comment?.videoId ?? '',
        'publishedAt': comment?.publishedAt?.toIso8601String() ?? '',
      };
    }).toList();
  }

  Future<bool> replyToComment(String parentId, String replyText) async {
    if (_youtubeApi == null) throw Exception('Not authenticated');
    try {
      final commentThreadReply = yt.Comment(
        snippet: yt.CommentSnippet(
          parentId: parentId,
          textOriginal: replyText,
        ),
      );
      await _youtubeApi!.comments.insert(
        commentThreadReply,
        ['snippet'],
      );
      return true;
    } catch (e) {
      // debugPrint('Error posting reply: $e');
      return false;
    }
  }
}
