import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models.dart';
import 'screens/notifications_screen.dart';

// ── MOCK SEED DATA ────────────────────────────────────────────────────────────
final kSeedUsers = [
  BUser(id: 'u1', name: 'alex rivers', handle: '@alex_rivers', bio: 'Capturing the silence between the noise. 19. Film student.', role: 'DIGITAL CREATOR', location: 'LONDON', tags: ['#Photography', '#Film', '#MentalHealth'], followers: 12400, following: 842, faceVerified: true, joinedAt: '2024-01-15'),
  BUser(id: 'u2', name: 'maya wild', handle: '@maya.wild', bio: 'Art is the only honest language. 18. NYC.', role: 'VISUAL ARTIST', location: 'NEW YORK', tags: ['#Art', '#AnalogFilm', '#NoFilter'], followers: 8900, following: 402, faceVerified: true, joinedAt: '2024-02-20'),
  BUser(id: 'u3', name: 'zack doe', handle: '@zackdoe', bio: 'light chaser. 20. street photographer.', role: 'STREET PHOTOGRAPHER', location: 'LOS ANGELES', tags: ['#Streets', '#Urban', '#Night'], followers: 21000, following: 310, faceVerified: true, joinedAt: '2023-11-05'),
  BUser(id: 'u4', name: 'luna chen', handle: '@luna_chen', bio: 'tokyo dreams in grayscale. 17. film studies.', role: 'FILM STUDENT', location: 'TOKYO', tags: ['#Film', '#Japan', '#Quiet'], followers: 5600, following: 890, faceVerified: true, joinedAt: '2024-03-12'),
  BUser(id: 'u5', name: 'jay storm', handle: '@jaystorm', bio: 'producer. 19. words and beats. atlanta born.', role: 'MUSIC PRODUCER', location: 'ATLANTA', tags: ['#Music', '#Beats', '#HipHop'], followers: 34000, following: 204, faceVerified: true, joinedAt: '2023-09-01'),
  BUser(id: 'u6', name: 'nova blake', handle: '@novablake', bio: 'poet. 18. words that land like stones in still water.', role: 'POET', location: 'BERLIN', tags: ['#Poetry', '#Words', '#Lit'], followers: 7200, following: 540, faceVerified: true, joinedAt: '2024-01-28'),
];

List<BPost> _buildSeedPosts() {
  final now = DateTime.now();
  return [
    BPost(id: 'p1', userId: 'u1', text: "there's something about shooting at 3am when the city forgets you exist. the shadows feel honest then.", mood: 'deep', tags: ['#NightPhotography', '#Solitude'], likedBy: List.generate(2847, (i) => 'u$i'), views: 89000, vibeScore: 91, vibeLabel: 'Genuine', createdAt: now.subtract(const Duration(minutes: 23)).toIso8601String()),
    BPost(id: 'p2', userId: 'u2', text: "finished my first roll of HP5 in months. every frame is a conversation with myself i never finished.", mood: 'chill', tags: ['#HP5', '#FilmPhotography'], likedBy: List.generate(1200, (i) => 'u$i'), views: 34000, vibeScore: 88, vibeLabel: 'Reflective', createdAt: now.subtract(const Duration(hours: 1, minutes: 7)).toIso8601String()),
    BPost(id: 'p3', userId: 'u5', text: "dropped a new beat at 2am and it somehow slapped harder in the silence. some things only live in the dark.", mood: 'hype', tags: ['#NewMusic', '#ProducerLife'], likedBy: List.generate(8900, (i) => 'u$i'), views: 210000, vibeScore: 95, vibeLabel: 'Energetic', createdAt: now.subtract(const Duration(hours: 3)).toIso8601String()),
    BPost(id: 'p4', userId: 'u6', text: "a poem for the ones who text 'im fine' and mean the opposite\n\nyou carry it so quietly\nno one hears the weight", mood: 'deep', tags: ['#Poetry', '#MentalHealth'], likedBy: List.generate(4300, (i) => 'u$i'), views: 67000, vibeScore: 87, vibeLabel: 'Emotional', createdAt: now.subtract(const Duration(hours: 5, minutes: 10)).toIso8601String()),
    BPost(id: 'p5', userId: 'u3', text: "this alley in downtown LA at 4am. no one was there. then this guy just walked through the frame. that's it. that's the shot.", mood: 'chill', tags: ['#StreetPhotography', '#LA'], likedBy: List.generate(12000, (i) => 'u$i'), views: 440000, vibeScore: 92, vibeLabel: 'Iconic', createdAt: now.subtract(const Duration(hours: 18)).toIso8601String()),
    BPost(id: 'p6', userId: 'u4', text: "tokyo's train stations at 11pm are somehow the loneliest and most alive places on earth simultaneously.", mood: 'deep', tags: ['#Tokyo', '#TrainStation', '#Japan'], likedBy: List.generate(3400, (i) => 'u$i'), views: 78000, vibeScore: 89, vibeLabel: 'Contemplative', createdAt: now.subtract(const Duration(hours: 26)).toIso8601String()),
    BPost(id: 'p7', userId: 'anonymous', text: "sometimes i wonder if my friends actually like me or just tolerate me. ghost posting bc i need to say it somewhere.", mood: 'deep', tags: ['#Anonymous', '#MentalHealth'], isAnonymous: true, likedBy: List.generate(5400, (i) => 'u$i'), views: 134000, vibeScore: 84, vibeLabel: 'Vulnerable', createdAt: now.subtract(const Duration(hours: 30)).toIso8601String()),
    BPost(id: 'p8', userId: 'u1', text: "reminder: not every thought needs an audience. some things are just for you.", mood: 'deep', tags: ['#MentalHealth', '#Boundaries'], likedBy: List.generate(19800, (i) => 'u$i'), views: 890000, vibeScore: 96, vibeLabel: 'Empowering', createdAt: now.subtract(const Duration(hours: 48)).toIso8601String()),
  ];
}

List<BChat> _buildSeedChats() {
  final now = DateTime.now();
  return [
    BChat(id: 'c1', type: 'group', name: 'Photography Crew', participants: ['u1','u2','u3','u4'], lastMessage: 'anyone shooting tonight?', lastMessageAt: now.subtract(const Duration(minutes: 4)).toIso8601String(), unread: 3, topic: 'Photography', memberCount: 28),
    BChat(id: 'c2', type: 'group', name: 'Late Night Vibes', participants: ['u5','u6','u1'], lastMessage: 'new beat just dropped in files', lastMessageAt: now.subtract(const Duration(minutes: 31)).toIso8601String(), unread: 7, topic: 'Music', memberCount: 64),
    BChat(id: 'c3', type: 'group', name: 'Safe Space', participants: ['u2','u4','u6'], lastMessage: 'thank you for listening everyone', lastMessageAt: now.subtract(const Duration(hours: 2)).toIso8601String(), unread: 0, topic: 'Mental Health', memberCount: 112, isAiModerated: true),
    BChat(id: 'c4', type: 'dm', participants: ['u2'], lastMessage: 'loved your last post btw', lastMessageAt: now.subtract(const Duration(minutes: 12)).toIso8601String(), unread: 1),
    BChat(id: 'c5', type: 'dm', participants: ['u5'], lastMessage: 'we should collab sometime', lastMessageAt: now.subtract(const Duration(hours: 5)).toIso8601String(), unread: 0),
  ];
}

Map<String, List<BMessage>> _buildSeedMessages() {
  final now = DateTime.now();
  return {
    'c1': [
      BMessage(id: 'm1', senderId: 'u3', text: 'just got back from downtown, incredible shots tonight', createdAt: now.subtract(const Duration(hours: 1)).toIso8601String()),
      BMessage(id: 'm2', senderId: 'u1', text: 'how was the light?', createdAt: now.subtract(const Duration(minutes: 55)).toIso8601String()),
      BMessage(id: 'm3', senderId: 'u3', text: 'perfect. overcast but not flat. that in-between grey', createdAt: now.subtract(const Duration(minutes: 52)).toIso8601String()),
      BMessage(id: 'm4', senderId: 'u4', text: "that's the best light honestly", createdAt: now.subtract(const Duration(minutes: 30)).toIso8601String()),
      BMessage(id: 'm5', senderId: 'u2', text: 'anyone shooting tonight?', createdAt: now.subtract(const Duration(minutes: 4)).toIso8601String()),
      BMessage(id: 'm6', senderId: 'anonymous', text: 'i want to come but i have social anxiety rn', isAnonymous: true, createdAt: now.subtract(const Duration(minutes: 2)).toIso8601String(), reactions: ['❤️', '🤝']),
    ],
    'c2': [
      BMessage(id: 'm1', senderId: 'u5', text: 'ok guys the beat is almost done', createdAt: now.subtract(const Duration(hours: 2)).toIso8601String()),
      BMessage(id: 'm2', senderId: 'u6', text: 'excited to hear it', createdAt: now.subtract(const Duration(hours: 1, minutes: 30)).toIso8601String()),
      BMessage(id: 'm3', senderId: 'u1', text: 'same, drop it when ready', createdAt: now.subtract(const Duration(hours: 1)).toIso8601String()),
      BMessage(id: 'm4', senderId: 'u5', text: 'new beat just dropped in files', createdAt: now.subtract(const Duration(minutes: 31)).toIso8601String(), type: 'voice', voiceNote: '0:42'),
    ],
    'c3': [
      BMessage(id: 'm1', senderId: 'u4', text: 'been having a rough week. glad this space exists', createdAt: now.subtract(const Duration(hours: 3)).toIso8601String()),
      BMessage(id: 'm2', senderId: 'u2', text: "we're here. always.", createdAt: now.subtract(const Duration(hours: 2, minutes: 55)).toIso8601String(), reactions: ['❤️', '🫂']),
      BMessage(id: 'm3', senderId: 'ai', text: 'Bondly AI: This is a safe space. Everything shared here stays here. 💙', createdAt: now.subtract(const Duration(hours: 2, minutes: 50)).toIso8601String(), type: 'ai'),
      BMessage(id: 'm4', senderId: 'u6', text: 'same, this community is actually real', createdAt: now.subtract(const Duration(hours: 2, minutes: 40)).toIso8601String()),
      BMessage(id: 'm5', senderId: 'u4', text: 'thank you for listening everyone', isPinned: true, createdAt: now.subtract(const Duration(hours: 2)).toIso8601String()),
      BMessage(id: 'm6', senderId: 'anonymous', text: 'does anyone else feel like theyre performing happiness?', isAnonymous: true, createdAt: now.subtract(const Duration(hours: 1)).toIso8601String(), reactions: ['🫂', '❤️', '🙏']),
    ],
    'c4': [
      BMessage(id: 'm1', senderId: 'u2', text: 'hey! saw your post from yesterday', createdAt: now.subtract(const Duration(hours: 3)).toIso8601String()),
      BMessage(id: 'm2', senderId: 'me', text: 'thanks! took forever to get that angle right', createdAt: now.subtract(const Duration(hours: 2, minutes: 30)).toIso8601String()),
      BMessage(id: 'm3', senderId: 'u2', text: 'loved your last post btw', createdAt: now.subtract(const Duration(minutes: 12)).toIso8601String()),
    ],
    'c5': [
      BMessage(id: 'm1', senderId: 'u5', text: 'yo your photography is different', createdAt: now.subtract(const Duration(hours: 8)).toIso8601String()),
      BMessage(id: 'm2', senderId: 'me', text: 'thanks man that means a lot from you', createdAt: now.subtract(const Duration(hours: 7)).toIso8601String()),
      BMessage(id: 'm3', senderId: 'u5', text: 'we should collab sometime', createdAt: now.subtract(const Duration(hours: 5)).toIso8601String()),
    ],
  };
}

// ── STATE ─────────────────────────────────────────────────────────────────────
class AppState extends ChangeNotifier {
  // Ghost mode
  bool ghostMode = false;
  int ghostTimeLeft = 0;

  // Feed
  String moodFilter = 'all';
  bool aiVibeEnabled = true;
  List<BPost> posts = [];
  bool postsLoaded = false;

  // Chats
  List<BChat> chats = [];
  Map<String, List<BMessage>> messages = {};

  // Users (seed)
  final List<BUser> seedUsers = kSeedUsers;

  bool _loaded = false;

  // Search
  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  // Notifications
  List<BNotification> _notifications = [];
  List<BNotification> get notifications => _notifications;
  int get unreadNotifications => _notifications.where((n) => !n.read).length;

  // Trending topics
  final List<String> trendingTopics = [
    '#NightPhotography', '#FilmPhotography', '#MentalHealth', '#StreetStyle', '#Poetry',
  ];

  Future<void> load() async {
    if (_loaded) return;
    _loaded = true;
    final prefs = await SharedPreferences.getInstance();

    // Load user-created posts
    final postJson = prefs.getString('bondly_user_posts');
    final userPosts = postJson != null ? (jsonDecode(postJson) as List).map((m) => BPost.fromMap(Map<String, dynamic>.from(m))).toList() : <BPost>[];
    posts = [...userPosts, ..._buildSeedPosts()];
    postsLoaded = true;

    // Load chats
    chats = _buildSeedChats();
    messages = _buildSeedMessages();

    // Load ghost mode
    ghostMode = prefs.getBool('bondly_ghost') ?? false;
    ghostTimeLeft = prefs.getInt('bondly_ghost_time') ?? 0;
    if (ghostMode && ghostTimeLeft <= 0) ghostMode = false;

    _seedNotifications();
    notifyListeners();
  }

  // ── GHOST MODE ──────────────────────────────────────────────────────────────
  void toggleGhost() {
    ghostMode = !ghostMode;
    ghostTimeLeft = ghostMode ? 1800 : 0;
    _saveGhost();
    notifyListeners();
    if (ghostMode) _startGhostTimer();
  }

  void _startGhostTimer() async {
    while (ghostMode && ghostTimeLeft > 0) {
      await Future.delayed(const Duration(seconds: 1));
      ghostTimeLeft--;
      if (ghostTimeLeft <= 0) {
        ghostMode = false;
        ghostTimeLeft = 0;
      }
      _saveGhost();
      notifyListeners();
    }
  }

  void _saveGhost() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('bondly_ghost', ghostMode);
    prefs.setInt('bondly_ghost_time', ghostTimeLeft);
  }

  // ── POSTS ──────────────────────────────────────────────────────────────────
  List<BPost> get filteredPosts {
    var result = posts.where((p) {
      if (moodFilter != 'all' && p.mood != moodFilter) return false;
      if (_searchQuery.isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return p.text.toLowerCase().contains(q) ||
               p.tags.any((t) => t.toLowerCase().contains(q));
      }
      return true;
    }).toList();
    return result;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Future<void> refreshPosts() async {
    await Future.delayed(const Duration(milliseconds: 800));
    // In a real app, fetch from server. Here we just shuffle.
    final rng = Random();
    posts = [...posts]..sort((_,__) => rng.nextInt(3) - 1);
    notifyListeners();
  }

  void markNotificationsRead() {
    _notifications = _notifications.map((n) => n.copyWith(read: true)).toList();
    notifyListeners();
  }

  void _seedNotifications() {
    final now = DateTime.now();
    _notifications = [
      BNotification(id: 'n1', type: 'like', title: 'alex rivers liked your post', body: '"reminder: not every thought needs an audience"', createdAt: now.subtract(const Duration(minutes: 5)).toIso8601String()),
      BNotification(id: 'n2', type: 'comment', title: 'maya wild commented', body: '"this hit different at 2am"', createdAt: now.subtract(const Duration(minutes: 22)).toIso8601String()),
      BNotification(id: 'n3', type: 'follow', title: 'jay storm started following you', body: 'Music Producer from Atlanta', createdAt: now.subtract(const Duration(hours: 1)).toIso8601String()),
      BNotification(id: 'n4', type: 'vibe', title: 'Your post hit 90+ vibe score!', body: 'The algorithm loves your energy. Keep posting.', createdAt: now.subtract(const Duration(hours: 3)).toIso8601String()),
      BNotification(id: 'n5', type: 'mention', title: 'zack doe mentioned you', body: 'in Photography Crew chat', createdAt: now.subtract(const Duration(hours: 6)).toIso8601String()),
    ];
  }

  Future<void> addPost(BPost post) async {
    posts = [post, ...posts];
    final prefs = await SharedPreferences.getInstance();
    final userPosts = posts.where((p) => !kSeedPosts.any((s) => s.id == p.id)).toList();
    prefs.setString('bondly_user_posts', jsonEncode(userPosts.map((p) => p.toMap()).toList()));
    notifyListeners();
  }

  void toggleLike(String postId, String userId) {
    posts = posts.map((p) {
      if (p.id != postId) return p;
      final liked = p.likedBy.contains(userId)
          ? p.likedBy.where((id) => id != userId).toList()
          : [...p.likedBy, userId];
      return BPost(id: p.id, userId: p.userId, text: p.text, mood: p.mood,
        isAnonymous: p.isAnonymous, isTimeCapsule: p.isTimeCapsule, tags: p.tags,
        likedBy: liked, repostedBy: p.repostedBy, bookmarkedBy: p.bookmarkedBy,
        views: p.views, vibeScore: p.vibeScore, vibeLabel: p.vibeLabel, createdAt: p.createdAt);
    }).toList();
    notifyListeners();
  }

  void toggleBookmark(String postId, String userId) {
    posts = posts.map((p) {
      if (p.id != postId) return p;
      final bm = p.bookmarkedBy.contains(userId)
          ? p.bookmarkedBy.where((id) => id != userId).toList()
          : [...p.bookmarkedBy, userId];
      return BPost(id: p.id, userId: p.userId, text: p.text, mood: p.mood,
        isAnonymous: p.isAnonymous, isTimeCapsule: p.isTimeCapsule, tags: p.tags,
        likedBy: p.likedBy, repostedBy: p.repostedBy, bookmarkedBy: bm,
        views: p.views, vibeScore: p.vibeScore, vibeLabel: p.vibeLabel, createdAt: p.createdAt);
    }).toList();
    notifyListeners();
  }

  // ── MESSAGES ───────────────────────────────────────────────────────────────
  List<BMessage> getMessages(String chatId) => messages[chatId] ?? [];

  void sendMessage(String chatId, BMessage msg) {
    messages[chatId] = [msg, ...(messages[chatId] ?? [])];
    chats = chats.map((c) => c.id == chatId ? c.copyWith(lastMessage: msg.type == 'voice' ? '🎤 Voice note' : msg.isAnonymous ? '👻 Anonymous message' : msg.text, lastMessageAt: msg.createdAt, unread: 0) : c).toList();
    notifyListeners();

    // Auto-reply for groups
    final chat = chats.firstWhere((c) => c.id == chatId, orElse: () => BChat(id: '', type: 'dm', lastMessage: '', lastMessageAt: ''));
    if (chat.type == 'group') {
      Future.delayed(const Duration(milliseconds: 1800), () {
        final rng = Random();
        if (chat.isAiModerated && rng.nextDouble() > 0.5) {
          const aiReplies = ['Reminder: this is a safe space. Keep it kind. 💙', 'That sounds really tough. Does anyone want to share support?', 'Great energy in here. Keep it real.', 'Bondly AI: everything shared here stays here.'];
          final aiMsg = BMessage(id: '${DateTime.now().millisecondsSinceEpoch}', senderId: 'ai', text: aiReplies[rng.nextInt(aiReplies.length)], type: 'ai', createdAt: DateTime.now().toIso8601String());
          messages[chatId] = [aiMsg, ...(messages[chatId] ?? [])];
        } else if (chat.participants.isNotEmpty) {
          final senderId = chat.participants[rng.nextInt(chat.participants.length)];
          const replies = ['same 100%', 'this is it 🔥', 'real talk', 'needed this', 'ong', '💯', 'fr fr', 'say less'];
          final reply = BMessage(id: '${DateTime.now().millisecondsSinceEpoch}', senderId: senderId, text: replies[rng.nextInt(replies.length)], createdAt: DateTime.now().toIso8601String());
          messages[chatId] = [reply, ...(messages[chatId] ?? [])];
        }
        notifyListeners();
      });
    }
  }

  void reactToMessage(String chatId, String msgId, String emoji) {
    messages[chatId] = (messages[chatId] ?? []).map((m) {
      if (m.id != msgId) return m;
      final reactions = m.reactions.contains(emoji)
          ? m.reactions.where((e) => e != emoji).toList()
          : [...m.reactions, emoji];
      return m.copyWith(reactions: reactions);
    }).toList();
    notifyListeners();
  }

  void pinMessage(String chatId, String msgId) {
    messages[chatId] = (messages[chatId] ?? []).map((m) => m.copyWith(isPinned: m.id == msgId ? !m.isPinned : false)).toList();
    notifyListeners();
  }

  void setMood(String mood) { moodFilter = mood; notifyListeners(); }
  void toggleAiVibe() { aiVibeEnabled = !aiVibeEnabled; notifyListeners(); }

  BUser? getUserById(String id) {
    try { return seedUsers.firstWhere((u) => u.id == id); } catch (_) { return null; }
  }

  // AI Vibe Check
  Map<String, dynamic> vibeCheck(String text) {
    final rng = Random();
    final lower = text.toLowerCase();
    if (RegExp(r'excited|amazing|love|fire|🔥|hype|energy|drop').hasMatch(lower)) {
      return {'score': 90 + rng.nextInt(8), 'label': 'Energetic', 'desc': 'High vibration. People will feel this.'};
    } else if (RegExp(r'sad|lonely|tired|struggle|dark|lost|anxiety').hasMatch(lower)) {
      return {'score': 75 + rng.nextInt(10), 'label': 'Vulnerable', 'desc': 'Raw and real. The quiet ones will resonate.'};
    } else if (RegExp(r'remember|quiet|silence|feel|moment|honest').hasMatch(lower)) {
      return {'score': 85 + rng.nextInt(8), 'label': 'Reflective', 'desc': 'Thoughtful and layered. This has depth.'};
    } else if (RegExp(r'lol|funny|joke|haha|😂|crazy').hasMatch(lower)) {
      return {'score': 88 + rng.nextInt(8), 'label': 'Levity', 'desc': "You're lightening the room. Keep it."};
    }
    return {'score': 80 + rng.nextInt(15), 'label': 'Genuine', 'desc': 'Authentic. Post it.'};
  }
}

// static reference for checking seed posts
final kSeedPosts = _buildSeedPosts();
