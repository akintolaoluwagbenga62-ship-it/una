import 'package:flutter/material.dart';
import '../theme.dart';
import '../models.dart';

// ── AVATAR ────────────────────────────────────────────────────────────────────
class BAvatar extends StatelessWidget {
  final String name;
  final double size;
  final bool faceVerified;
  final bool isAnonymous;
  const BAvatar({super.key, required this.name, this.size = 40, this.faceVerified = false, this.isAnonymous = false});

  Color get _color {
    final colors = [BColor.green, BColor.bg2, const Color(0xFF333333), const Color(0xFF222222), BColor.bg1];
    return colors[name.isEmpty ? 0 : name.codeUnitAt(0) % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    if (isAnonymous) {
      return Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: BColor.bg2,
          shape: BoxShape.circle,
          border: Border.all(color: BColor.border),
        ),
        child: Center(child: Icon(Icons.person_outline, color: BColor.muted, size: size * 0.45)),
      );
    }
    return Stack(children: [
      Container(
        width: size, height: size,
        decoration: BoxDecoration(color: _color, shape: BoxShape.circle),
        child: Center(child: Text(
          name.isEmpty ? '?' : name[0].toUpperCase(),
          style: TextStyle(color: BColor.text, fontWeight: FontWeight.w800, fontSize: size * 0.4),
        )),
      ),
      if (faceVerified) Positioned(
        bottom: 0, right: 0,
        child: Container(
          width: size * 0.32, height: size * 0.32,
          decoration: BoxDecoration(
            color: BColor.green,
            shape: BoxShape.circle,
            border: Border.all(color: BColor.bg, width: 1.5),
          ),
          child: Center(child: Icon(Icons.check, color: BColor.bg, size: size * 0.18)),
        ),
      ),
    ]);
  }
}

// ── GHOST MODE BANNER ──────────────────────────────────────────────────────────
class GhostModeBanner extends StatelessWidget {
  final bool ghostMode;
  final int timeLeft;
  final VoidCallback onTap;
  const GhostModeBanner({super.key, required this.ghostMode, required this.timeLeft, required this.onTap});

  String _fmt(int secs) {
    final m = secs ~/ 60;
    final s = secs % 60;
    return '${m}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    if (!ghostMode) return const SizedBox.shrink();
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.all(12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: BColor.bg1,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: BColor.border),
        ),
        child: Row(children: [
          const Icon(Icons.visibility_off_outlined, color: BColor.muted, size: 16),
          const SizedBox(width: 8),
          Expanded(child: Text(
            'Ghost Mode active — you\'re invisible  •  ${_fmt(timeLeft)} left',
            style: const TextStyle(color: BColor.textSub, fontSize: 12),
          )),
          const Icon(Icons.close, color: BColor.muted, size: 14),
        ]),
      ),
    );
  }
}

// ── MOOD CHIP ─────────────────────────────────────────────────────────────────
class MoodChip extends StatelessWidget {
  final String mood;
  final bool selected;
  final VoidCallback onTap;
  const MoodChip({super.key, required this.mood, required this.selected, required this.onTap});

  static const _labels = {'all': 'All', 'hype': 'Hype', 'chill': 'Chill', 'deep': 'Deep', 'funny': 'Funny'};

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? BColor.green : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: selected ? BColor.green : BColor.border),
        ),
        child: Text(
          _labels[mood] ?? mood,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: selected ? BColor.bg : BColor.muted,
          ),
        ),
      ),
    );
  }
}

// ── CHAT LIST ITEM ────────────────────────────────────────────────────────────
class BChatListItem extends StatelessWidget {
  final BChat chat;
  final BUser? otherUser;
  final VoidCallback onTap;
  const BChatListItem({super.key, required this.chat, this.otherUser, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isGroup = chat.type == 'group';
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(children: [
          isGroup
              ? Container(
                  width: 48, height: 48,
                  decoration: BoxDecoration(
                    color: BColor.bg2,
                    shape: BoxShape.circle,
                    border: Border.all(color: BColor.border),
                  ),
                  child: Center(child: Icon(_groupIcon(chat.topic), color: BColor.green, size: 22)),
                )
              : BAvatar(name: otherUser?.name ?? '?', size: 48, faceVerified: otherUser?.faceVerified ?? false),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Expanded(child: Row(children: [
                Text(
                  isGroup ? (chat.name ?? 'Group') : (otherUser?.name ?? 'User'),
                  style: const TextStyle(fontWeight: FontWeight.w700, color: BColor.text, fontSize: 15),
                  overflow: TextOverflow.ellipsis,
                ),
                if (chat.isAiModerated) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.smart_toy, color: BColor.green, size: 13),
                ],
                if (isGroup) ...[
                  const SizedBox(width: 4),
                  Text('${formatCount(chat.memberCount)}', style: const TextStyle(fontSize: 11, color: BColor.muted)),
                ],
              ])),
              Text(formatTime(chat.lastMessageAt), style: const TextStyle(fontSize: 11, color: BColor.muted)),
            ]),
            const SizedBox(height: 3),
            Row(children: [
              Expanded(child: Text(
                chat.lastMessage,
                style: const TextStyle(fontSize: 13, color: BColor.muted),
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              )),
              if (chat.unread > 0) Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                decoration: BoxDecoration(color: BColor.green, borderRadius: BorderRadius.circular(10)),
                child: Text('${chat.unread}', style: const TextStyle(color: BColor.bg, fontSize: 11, fontWeight: FontWeight.w800)),
              ),
            ]),
          ])),
        ]),
      ),
    );
  }

  IconData _groupIcon(String topic) {
    switch (topic.toLowerCase()) {
      case 'photography': return Icons.camera_alt_outlined;
      case 'music':       return Icons.music_note_outlined;
      case 'mental health': return Icons.favorite_border_outlined;
      case 'art':         return Icons.palette_outlined;
      default:            return Icons.forum_outlined;
    }
  }
}

// ── STORY BAR ─────────────────────────────────────────────────────────────────
class StoryBar extends StatelessWidget {
  final List<BUser> users;
  const StoryBar({super.key, required this.users});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 90,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        itemCount: users.length + 1,
        itemBuilder: (ctx, i) {
          if (i == 0) {
            return Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(children: [
                Stack(children: [
                  Container(
                    width: 54, height: 54,
                    decoration: BoxDecoration(
                      color: BColor.bg2,
                      shape: BoxShape.circle,
                      border: Border.all(color: BColor.border),
                    ),
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: Container(
                      width: 18, height: 18,
                      decoration: const BoxDecoration(color: BColor.green, shape: BoxShape.circle),
                      child: const Icon(Icons.add, color: BColor.bg, size: 12),
                    ),
                  ),
                ]),
                const SizedBox(height: 4),
                const Text('Your story', style: TextStyle(fontSize: 10, color: BColor.muted)),
              ]),
            );
          }
          final u = users[i - 1];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(children: [
              Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(color: BColor.green, shape: BoxShape.circle),
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(color: BColor.bg, shape: BoxShape.circle),
                  child: BAvatar(name: u.name, size: 46, faceVerified: u.faceVerified),
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 54,
                child: Text(
                  u.name.split(' ').first,
                  style: const TextStyle(fontSize: 10, color: BColor.muted),
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ]),
          );
        },
      ),
    );
  }
}

// ── SECTION DIVIDER ───────────────────────────────────────────────────────────
class BDivider extends StatelessWidget {
  const BDivider({super.key});
  @override
  Widget build(BuildContext context) => Container(height: 0.5, color: BColor.border);
}

// ── EMPTY STATE ───────────────────────────────────────────────────────────────
class BEmptyState extends StatelessWidget {
  final String icon, title, subtitle;
  const BEmptyState({super.key, required this.icon, required this.title, required this.subtitle});
  @override
  Widget build(BuildContext context) => Center(
    child: Padding(
      padding: const EdgeInsets.all(40),
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        Text(icon, style: const TextStyle(fontSize: 40)),
        const SizedBox(height: 16),
        Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: BColor.text)),
        const SizedBox(height: 6),
        Text(subtitle, style: const TextStyle(fontSize: 14, color: BColor.muted), textAlign: TextAlign.center),
      ]),
    ),
  );
}

// ── PASSWORD STRENGTH ─────────────────────────────────────────────────────────
class PasswordStrengthBar extends StatelessWidget {
  final String password;
  const PasswordStrengthBar({super.key, required this.password});

  int get strength {
    int s = 0;
    if (password.length >= 8) s++;
    if (RegExp(r'[A-Z]').hasMatch(password)) s++;
    if (RegExp(r'[a-z]').hasMatch(password)) s++;
    if (RegExp(r'[0-9]').hasMatch(password)) s++;
    if (RegExp(r'[!@#\$&*~^%]').hasMatch(password)) s++;
    return s;
  }

  Color get color {
    if (strength <= 1) return BColor.danger;
    if (strength == 2) return const Color(0xFFFF6B00);
    if (strength == 3) return BColor.gold;
    if (strength == 4) return BColor.green;
    return BColor.green;
  }

  String get label {
    if (strength <= 1) return 'Weak';
    if (strength == 2) return 'Fair';
    if (strength == 3) return 'Good';
    if (strength == 4) return 'Strong';
    return 'Very Strong';
  }

  @override
  Widget build(BuildContext context) {
    if (password.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Row(children: List.generate(5, (i) => Expanded(child: Container(
        height: 4,
        margin: const EdgeInsets.only(right: 4),
        decoration: BoxDecoration(
          color: i < strength ? color : BColor.bg2,
          borderRadius: BorderRadius.circular(2),
        ),
      )))),
      const SizedBox(height: 4),
      Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600)),
    ]);
  }
}
