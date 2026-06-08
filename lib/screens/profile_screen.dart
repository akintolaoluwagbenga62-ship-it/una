import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../auth_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/bondly_logo.dart';
import '../widgets/widgets.dart';
import '../widgets/post_card.dart';
import 'auth/welcome_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String _tab = 'POSTS';
  static const _tabs = ['POSTS', 'SAVED', 'TAGGED'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthState>();
    final user = auth.user;
    if (user == null) return const SizedBox.shrink();

    final myPosts = app.posts.where((p) => p.userId == user.id || p.userId == 'me').toList();
    final savedPosts = app.posts.where((p) => p.bookmarkedBy.contains(user.id)).toList();
    final displayPosts = _tab == 'POSTS' ? myPosts : _tab == 'SAVED' ? savedPosts : myPosts.take(2).toList();

    return Scaffold(
      backgroundColor: BColor.bg,
      body: CustomScrollView(
        slivers: [
          // Top actions bar
          SliverToBoxAdapter(child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(children: [
                const Spacer(),
                _GhostBtn(ghostMode: app.ghostMode, onTap: app.toggleGhost),
                const SizedBox(width: 8),
                _IconBtn(icon: Icons.logout_outlined, onTap: () async {
                  await auth.logout();
                  if (context.mounted) Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const WelcomeScreen()), (_) => false);
                }),
              ]),
            ),
          )),

          SliverToBoxAdapter(child: Column(children: [
            GhostModeBanner(ghostMode: app.ghostMode, timeLeft: app.ghostTimeLeft, onTap: app.toggleGhost),

            // Cover
            Container(height: 120, decoration: const BoxDecoration(color: Color(0xFF111111))),

            // Profile info
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, crossAxisAlignment: CrossAxisAlignment.end, children: [
                  Transform.translate(
                    offset: const Offset(0, -24),
                    child: Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(color: BColor.bg, borderRadius: BorderRadius.circular(46)),
                      child: BAvatar(name: user.name, size: 80, faceVerified: user.faceVerified),
                    ),
                  ),
                  Row(children: [
                    OutlinedButton(
                      onPressed: () => _showEditProfile(context, auth),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: BColor.text, side: const BorderSide(color: BColor.border),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                      child: const Text('Edit profile'),
                    ),
                  ]),
                ]),

                // Name + verified
                Row(children: [
                  Text(user.name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: BColor.text)),
                  if (user.faceVerified) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(8), border: Border.all(color: BColor.border)),
                      child: const Row(mainAxisSize: MainAxisSize.min, children: [
                        Icon(Icons.shield, size: 12, color: BColor.green),
                        SizedBox(width: 4),
                        Text('Verified', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: BColor.green)),
                      ]),
                    ),
                  ],
                ]),
                Text(user.handle, style: const TextStyle(fontSize: 14, color: BColor.muted)),
                if (user.role.isNotEmpty || user.location.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text('${user.role.toUpperCase()}${user.location.isNotEmpty ? " · ${user.location.toUpperCase()}" : ""}', style: const TextStyle(fontSize: 12, color: BColor.muted, letterSpacing: 0.5)),
                ],
                if (user.bio.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(user.bio, style: const TextStyle(fontSize: 14, color: BColor.text, height: 1.5)),
                ],
                if (user.tags.isNotEmpty) ...[
                  const SizedBox(height: 10),
                  Wrap(spacing: 8, runSpacing: 6, children: user.tags.map((t) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(14), border: Border.all(color: BColor.border)),
                    child: Text(t, style: const TextStyle(fontSize: 12, color: BColor.text, fontWeight: FontWeight.w600)),
                  )).toList()),
                ],
                const SizedBox(height: 12),
                Row(children: [
                  GestureDetector(
                    onTap: () {},
                    child: RichText(text: TextSpan(children: [
                      TextSpan(text: formatCount(user.following), style: const TextStyle(color: BColor.text, fontWeight: FontWeight.w900, fontSize: 16)),
                      const TextSpan(text: ' FOLLOWING', style: TextStyle(color: BColor.muted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    ])),
                  ),
                  const SizedBox(width: 20),
                  GestureDetector(
                    onTap: () {},
                    child: RichText(text: TextSpan(children: [
                      TextSpan(text: formatCount(user.followers), style: const TextStyle(color: BColor.text, fontWeight: FontWeight.w900, fontSize: 16)),
                      const TextSpan(text: ' FOLLOWERS', style: TextStyle(color: BColor.muted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.5)),
                    ])),
                  ),
                ]),
                const SizedBox(height: 16),
              ]),
            ),

            // Tabs
            Container(
              decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: BColor.border, width: 0.5))),
              child: Row(children: [
                ..._tabs.map((t) => Expanded(child: GestureDetector(
                  onTap: () => setState(() => _tab = t),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(border: Border(bottom: BorderSide(color: _tab == t ? BColor.text : Colors.transparent, width: 2))),
                    child: Text(t, textAlign: TextAlign.center, style: TextStyle(fontSize: 13, fontWeight: _tab == t ? FontWeight.w800 : FontWeight.w400, color: _tab == t ? BColor.text : BColor.muted, letterSpacing: 0.5)),
                  ),
                ))),
                Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Icon(Icons.grid_view_rounded, color: BColor.muted, size: 20),
                ),
              ]),
            ),
          ])),

          // Grid
          displayPosts.isEmpty
              ? SliverFillRemaining(child: BEmptyState(icon: _tab == 'SAVED' ? '🔖' : '📸', title: _tab == 'SAVED' ? 'No saved posts' : 'No posts yet', subtitle: _tab == 'SAVED' ? 'Bookmark posts to see them here' : 'Share something on the feed'))
              : SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3, crossAxisSpacing: 1, mainAxisSpacing: 1),
                  delegate: SliverChildBuilderDelegate(
                    (ctx, i) => GestureDetector(
                      onTap: () => _showPostDetail(context, displayPosts[i]),
                      child: Container(
                        color: BColor.bg1,
                        child: displayPosts[i].isAnonymous
                            ? const Center(child: Text('👻', style: TextStyle(fontSize: 30)))
                            : Stack(fit: StackFit.expand, children: [
                                const ColoredBox(color: BColor.bg2),
                                Center(child: Icon(Icons.article_outlined, color: BColor.muted, size: 28)),
                                if (displayPosts[i].isTimeCapsule) Positioned(top: 6, right: 6, child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(color: BColor.bg.withAlpha(179), shape: BoxShape.circle),
                                  child: const Text('⏳', style: TextStyle(fontSize: 12)),
                                )),
                                Positioned(bottom: 6, left: 6, child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                  decoration: BoxDecoration(color: BColor.bg.withAlpha(153), borderRadius: BorderRadius.circular(4)),
                                  child: Text(displayPosts[i].mood, style: TextStyle(fontSize: 10, color: BColor.mood(displayPosts[i].mood), fontWeight: FontWeight.w700)),
                                )),
                              ]),
                      ),
                    ),
                    childCount: displayPosts.length,
                  ),
                ),
        ],
      ),
    );
  }

  void _showPostDetail(BuildContext context, BPost post) {
    showModalBottomSheet(
      context: context, isScrollControlled: true,
      backgroundColor: BColor.bg, useSafeArea: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7, minChildSize: 0.5, maxChildSize: 0.95, expand: false,
        builder: (_, scrollCtrl) => SingleChildScrollView(controller: scrollCtrl, child: PostCard(post: post)),
      ),
    );
  }

  void _showEditProfile(BuildContext context, AuthState auth) {
    final nameCtrl = TextEditingController(text: auth.user?.name);
    final bioCtrl = TextEditingController(text: auth.user?.bio);
    showModalBottomSheet(
      context: context, isScrollControlled: true, backgroundColor: BColor.bg1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('Edit Profile', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: BColor.text)),
              const Spacer(),
              TextButton(
                onPressed: () {
                  auth.updateUser(auth.user!.copyWith(name: nameCtrl.text.trim(), bio: bioCtrl.text.trim()));
                  Navigator.pop(context);
                },
                child: const Text('Save', style: TextStyle(color: BColor.text, fontWeight: FontWeight.w800)),
              ),
            ]),
            const SizedBox(height: 16),
            TextField(controller: nameCtrl, style: const TextStyle(color: BColor.text), decoration: const InputDecoration(labelText: 'Display Name', labelStyle: TextStyle(color: BColor.muted))),
            const SizedBox(height: 12),
            TextField(controller: bioCtrl, maxLines: 3, style: const TextStyle(color: BColor.text), decoration: const InputDecoration(labelText: 'Bio', labelStyle: TextStyle(color: BColor.muted))),
            const SizedBox(height: 20),
          ]),
        ),
      ),
    );
  }
}

class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final Widget? customWidget;
  const _IconBtn({required this.icon, required this.onTap, this.active = false, this.customWidget});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(color: active ? BColor.text.withAlpha(25) : Colors.transparent, shape: BoxShape.circle, border: Border.all(color: active ? BColor.text : BColor.border)),
      child: Center(child: customWidget ?? Icon(icon, size: 18, color: active ? BColor.text : BColor.muted)),
    ),
  );
}

class _GhostBtn extends StatelessWidget {
  final bool ghostMode;
  final VoidCallback onTap;
  const _GhostBtn({required this.ghostMode, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 36, height: 36,
      decoration: BoxDecoration(
        color: ghostMode ? BColor.text.withAlpha(25) : Colors.transparent,
        shape: BoxShape.circle,
        border: Border.all(color: ghostMode ? BColor.text : BColor.border),
      ),
      child: Center(child: Text('👻', style: TextStyle(fontSize: ghostMode ? 18 : 16))),
    ),
  );
}
