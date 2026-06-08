import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme.dart';
import '../models.dart';
import '../app_state.dart';
import '../auth_state.dart';
import 'widgets.dart';

class PostCard extends StatefulWidget {
  final BPost post;
  const PostCard({super.key, required this.post});

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> with SingleTickerProviderStateMixin {
  late AnimationController _likeCtrl;
  late Animation<double> _likeScale;

  @override
  void initState() {
    super.initState();
    _likeCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 300));
    _likeScale = Tween<double>(begin: 1, end: 1.4)
        .chain(CurveTween(curve: Curves.elasticOut))
        .animate(_likeCtrl);
  }

  @override
  void dispose() { _likeCtrl.dispose(); super.dispose(); }

  void _onLike(AppState app, String userId) {
    app.toggleLike(widget.post.id, userId);
    _likeCtrl.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    final app    = context.watch<AppState>();
    final auth   = context.watch<AuthState>();
    final post   = widget.post;
    final userId = auth.user?.id ?? 'guest';
    final isLiked= post.likedBy.contains(userId);
    final isBm   = post.bookmarkedBy.contains(userId);

    BUser? author;
    if (!post.isAnonymous) author = app.getUserById(post.userId);
    final name   = post.isAnonymous ? 'Anonymous' : (author?.name ?? post.userId);
    final handle = post.isAnonymous ? '' : (author?.handle ?? '');

    return Column(children: [
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          BAvatar(
            name: name, size: 42,
            faceVerified: !post.isAnonymous && (author?.faceVerified ?? false),
            isAnonymous: post.isAnonymous,
          ),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(children: [
              Expanded(child: Row(children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.w700, color: BColor.text, fontSize: 14)),
                if (!post.isAnonymous && (author?.faceVerified ?? false)) ...[
                  const SizedBox(width: 4),
                  const Icon(Icons.check_circle, color: BColor.green, size: 13),
                ],
                if (handle.isNotEmpty) ...[
                  const SizedBox(width: 4),
                  Text(handle, style: const TextStyle(fontSize: 12, color: BColor.muted)),
                ],
              ])),
              Text('·', style: const TextStyle(color: BColor.muted)),
              const SizedBox(width: 4),
              Text(formatTime(post.createdAt), style: const TextStyle(fontSize: 12, color: BColor.muted)),
            ]),
            const SizedBox(height: 2),

            // Vibe pill
            if (post.vibeLabel != null) Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: BColor.bg2,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: BColor.border),
                ),
                child: Text(
                  '✦ ${post.vibeLabel}  ${post.vibeScore ?? ''}',
                  style: const TextStyle(fontSize: 10, color: BColor.green, fontWeight: FontWeight.w600),
                ),
              ),
            ),

            // Text
            Text(post.text, style: const TextStyle(fontSize: 15, color: BColor.text, height: 1.5)),

            // Tags
            if (post.tags.isNotEmpty) Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Wrap(spacing: 6, children: post.tags
                  .map((t) => Text(t, style: const TextStyle(fontSize: 13, color: BColor.green, fontWeight: FontWeight.w600)))
                  .toList()),
            ),

            // Anonymous badge
            if (post.isAnonymous) Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(6), border: Border.all(color: BColor.border)),
                child: const Text('posted anonymously', style: TextStyle(fontSize: 11, color: BColor.muted)),
              ),
            ),

            // Time capsule badge
            if (post.isTimeCapsule) Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: BColor.bg1,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: BColor.border),
                ),
                child: const Text('Time Capsule', style: TextStyle(fontSize: 11, color: BColor.muted, fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 10),

            // Actions
            Row(children: [
              _Action(icon: Icons.chat_bubble_outline_rounded, count: 0, onTap: () {}),
              const SizedBox(width: 20),
              _Action(icon: Icons.repeat_rounded, count: post.reposts, onTap: () => app.toggleLike(post.id, userId), activeColor: BColor.green),
              const SizedBox(width: 20),
              ScaleTransition(
                scale: _likeScale,
                child: _Action(
                  icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  count: post.likes,
                  active: isLiked,
                  onTap: () => _onLike(app, userId),
                  activeColor: BColor.danger,
                ),
              ),
              const SizedBox(width: 20),
              _Action(icon: Icons.bar_chart_rounded, count: post.views, onTap: () {}),
              const Spacer(),
              GestureDetector(
                onTap: () => app.toggleBookmark(post.id, userId),
                child: Icon(
                  isBm ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                  size: 18,
                  color: isBm ? BColor.green : BColor.muted,
                ),
              ),
            ]),
          ])),
        ]),
      ),
      const BDivider(),
    ]);
  }
}

class _Action extends StatelessWidget {
  final IconData icon;
  final int count;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  const _Action({required this.icon, required this.count, this.active = false, this.activeColor = BColor.muted, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Row(children: [
      Icon(icon, size: 17, color: active ? activeColor : BColor.muted),
      if (count > 0) ...[
        const SizedBox(width: 4),
        Text(formatCount(count), style: TextStyle(fontSize: 12, color: active ? activeColor : BColor.muted)),
      ],
    ]),
  );
}
