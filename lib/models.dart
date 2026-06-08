// ── USER ─────────────────────────────────────────────────────────────────────
class BUser {
  final String id, name, handle, bio, role, location;
  final List<String> tags;
  final int followers, following;
  final bool faceVerified;
  final String joinedAt;
  final String? email;

  BUser({
    required this.id, required this.name, required this.handle,
    this.bio = '', this.role = 'Creator', this.location = '',
    this.tags = const [], this.followers = 0, this.following = 0,
    this.faceVerified = false, required this.joinedAt, this.email,
  });

  factory BUser.fromMap(Map<String, dynamic> m) => BUser(
    id: m['id'] ?? '', name: m['name'] ?? '', handle: m['handle'] ?? '',
    bio: m['bio'] ?? '', role: m['role'] ?? 'Creator',
    location: m['location'] ?? '',
    tags: List<String>.from(m['tags'] ?? []),
    followers: m['followers'] ?? 0, following: m['following'] ?? 0,
    faceVerified: m['faceVerified'] ?? false,
    joinedAt: m['joinedAt'] ?? '', email: m['email'],
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'name': name, 'handle': handle, 'bio': bio, 'role': role,
    'location': location, 'tags': tags, 'followers': followers,
    'following': following, 'faceVerified': faceVerified,
    'joinedAt': joinedAt, 'email': email,
  };

  BUser copyWith({String? name, String? bio, String? role, String? location, List<String>? tags, bool? faceVerified, String? email}) => BUser(
    id: id, name: name ?? this.name, handle: handle, bio: bio ?? this.bio,
    role: role ?? this.role, location: location ?? this.location,
    tags: tags ?? this.tags, followers: followers, following: following,
    faceVerified: faceVerified ?? this.faceVerified, joinedAt: joinedAt, email: email ?? this.email,
  );
}

// ── POST ─────────────────────────────────────────────────────────────────────
class BPost {
  final String id, userId, text, mood;
  final bool isAnonymous, isTimeCapsule;
  final List<String> tags, likedBy, repostedBy, bookmarkedBy;
  final int views;
  final int? vibeScore;
  final String? vibeLabel;
  final String createdAt;

  BPost({
    required this.id, required this.userId, required this.text,
    this.mood = 'chill', this.isAnonymous = false, this.isTimeCapsule = false,
    this.tags = const [], this.likedBy = const [], this.repostedBy = const [],
    this.bookmarkedBy = const [], this.views = 0, this.vibeScore,
    this.vibeLabel, required this.createdAt,
  });

  int get likes => likedBy.length;
  int get reposts => repostedBy.length;

  factory BPost.fromMap(Map<String, dynamic> m) => BPost(
    id: m['id'] ?? '', userId: m['userId'] ?? '', text: m['text'] ?? '',
    mood: m['mood'] ?? 'chill', isAnonymous: m['isAnonymous'] ?? false,
    isTimeCapsule: m['isTimeCapsule'] ?? false,
    tags: List<String>.from(m['tags'] ?? []),
    likedBy: List<String>.from(m['likedBy'] ?? []),
    repostedBy: List<String>.from(m['repostedBy'] ?? []),
    bookmarkedBy: List<String>.from(m['bookmarkedBy'] ?? []),
    views: m['views'] ?? 0, vibeScore: m['vibeScore'],
    vibeLabel: m['vibeLabel'], createdAt: m['createdAt'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'userId': userId, 'text': text, 'mood': mood,
    'isAnonymous': isAnonymous, 'isTimeCapsule': isTimeCapsule,
    'tags': tags, 'likedBy': likedBy, 'repostedBy': repostedBy,
    'bookmarkedBy': bookmarkedBy, 'views': views,
    'vibeScore': vibeScore, 'vibeLabel': vibeLabel, 'createdAt': createdAt,
  };
}

// ── MESSAGE ───────────────────────────────────────────────────────────────────
class BMessage {
  final String id, senderId, text;
  final bool isAnonymous;
  final String? voiceNote;
  final String type; // 'text' | 'voice' | 'image' | 'poll' | 'ai'
  final List<String> reactions; // emoji reactions
  final Map<String, dynamic>? poll;
  final bool isPinned;
  final String createdAt;

  BMessage({
    required this.id, required this.senderId, required this.text,
    this.isAnonymous = false, this.voiceNote, this.type = 'text',
    this.reactions = const [], this.poll, this.isPinned = false,
    required this.createdAt,
  });

  factory BMessage.fromMap(Map<String, dynamic> m) => BMessage(
    id: m['id'] ?? '', senderId: m['senderId'] ?? '', text: m['text'] ?? '',
    isAnonymous: m['isAnonymous'] ?? false, voiceNote: m['voiceNote'],
    type: m['type'] ?? 'text',
    reactions: List<String>.from(m['reactions'] ?? []),
    poll: m['poll'] != null ? Map<String, dynamic>.from(m['poll']) : null,
    isPinned: m['isPinned'] ?? false, createdAt: m['createdAt'] ?? '',
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'senderId': senderId, 'text': text,
    'isAnonymous': isAnonymous, 'voiceNote': voiceNote, 'type': type,
    'reactions': reactions, 'poll': poll, 'isPinned': isPinned, 'createdAt': createdAt,
  };

  BMessage copyWith({List<String>? reactions, bool? isPinned}) => BMessage(
    id: id, senderId: senderId, text: text, isAnonymous: isAnonymous,
    voiceNote: voiceNote, type: type, reactions: reactions ?? this.reactions,
    poll: poll, isPinned: isPinned ?? this.isPinned, createdAt: createdAt,
  );
}

// ── CHAT ─────────────────────────────────────────────────────────────────────
class BChat {
  final String id, type, lastMessage, lastMessageAt, topic;
  final String? name;
  final List<String> participants;
  final int unread, memberCount;
  final bool isAiModerated;

  BChat({
    required this.id, required this.type, this.name, required this.lastMessage,
    required this.lastMessageAt, this.topic = '', this.participants = const [],
    this.unread = 0, this.memberCount = 0, this.isAiModerated = false,
  });

  factory BChat.fromMap(Map<String, dynamic> m) => BChat(
    id: m['id'] ?? '', type: m['type'] ?? 'dm', name: m['name'],
    lastMessage: m['lastMessage'] ?? '', lastMessageAt: m['lastMessageAt'] ?? '',
    topic: m['topic'] ?? '', participants: List<String>.from(m['participants'] ?? []),
    unread: m['unread'] ?? 0, memberCount: m['memberCount'] ?? 0,
    isAiModerated: m['isAiModerated'] ?? false,
  );

  Map<String, dynamic> toMap() => {
    'id': id, 'type': type, 'name': name, 'lastMessage': lastMessage,
    'lastMessageAt': lastMessageAt, 'topic': topic, 'participants': participants,
    'unread': unread, 'memberCount': memberCount, 'isAiModerated': isAiModerated,
  };

  BChat copyWith({String? lastMessage, String? lastMessageAt, int? unread}) => BChat(
    id: id, type: type, name: name, lastMessage: lastMessage ?? this.lastMessage,
    lastMessageAt: lastMessageAt ?? this.lastMessageAt, topic: topic,
    participants: participants, unread: unread ?? this.unread,
    memberCount: memberCount, isAiModerated: isAiModerated,
  );
}

// ── STORY ─────────────────────────────────────────────────────────────────────
class BStory {
  final String id, userId, mood;
  final String createdAt;
  BStory({required this.id, required this.userId, required this.mood, required this.createdAt});
}

// ── HELPERS ──────────────────────────────────────────────────────────────────
String formatTime(String iso) {
  try {
    final diff = DateTime.now().difference(DateTime.parse(iso));
    if (diff.inMinutes < 1) return 'now';
    if (diff.inHours < 1) return '${diff.inMinutes}m';
    if (diff.inDays < 1) return '${diff.inHours}h';
    return '${diff.inDays}d';
  } catch (_) {
    return '';
  }
}

String formatCount(int n) {
  if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
  if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}K';
  return '$n';
}
