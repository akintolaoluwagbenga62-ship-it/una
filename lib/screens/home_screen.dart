import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../auth_state.dart';
import '../theme.dart';
import '../widgets/bondly_logo.dart';
import '../widgets/widgets.dart';
import '../widgets/post_card.dart';
import 'ai_hub_screen.dart';
import 'notifications_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with AutomaticKeepAliveClientMixin {
  static const _moods = ['all', 'hype', 'chill', 'deep', 'funny'];
  bool _showSearchBar = false;
  final _searchCtrl = TextEditingController();

  @override
  bool get wantKeepAlive => true;

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final app = context.watch<AppState>();
    final posts = app.filteredPosts;

    return Scaffold(
      backgroundColor: BColor.bg,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (ctx, _) => [
            SliverToBoxAdapter(
              child: Column(children: [
                // ── Top bar ──────────────────────────────────────────────
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Row(children: [
                    const BondlyLogo(size: 32, showText: true),
                    const Spacer(),
                    _IconBtn(
                      icon: Icons.search_rounded,
                      onTap: () => setState(() {
                        _showSearchBar = !_showSearchBar;
                        if (!_showSearchBar) {
                          _searchCtrl.clear();
                          app.setSearchQuery('');
                        }
                      }),
                      active: _showSearchBar,
                    ),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: Icons.notifications_none_rounded,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const NotificationsScreen())),
                      badge: app.unreadNotifications > 0 ? app.unreadNotifications : null,
                    ),
                    const SizedBox(width: 8),
                    _GhostButton(ghostMode: app.ghostMode, onTap: app.toggleGhost),
                    const SizedBox(width: 8),
                    _IconBtn(
                      icon: Icons.psychology_outlined,
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const AiHubScreen())),
                    ),
                  ]),
                ),

                // ── Search bar ────────────────────────────────────────────
                if (_showSearchBar)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: TextField(
                      controller: _searchCtrl,
                      autofocus: true,
                      style: const TextStyle(color: BColor.text),
                      decoration: InputDecoration(
                        hintText: 'Search posts...',
                        prefixIcon: const Icon(Icons.search_rounded, color: BColor.muted, size: 18),
                        suffixIcon: _searchCtrl.text.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.close_rounded, color: BColor.muted, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  app.setSearchQuery('');
                                },
                              )
                            : null,
                      ),
                      onChanged: (val) {
                        setState(() {});
                        app.setSearchQuery(val);
                      },
                    ),
                  ),

                // ── Ghost banner ──────────────────────────────────────────
                GhostModeBanner(
                  ghostMode: app.ghostMode,
                  timeLeft: app.ghostTimeLeft,
                  onTap: app.toggleGhost,
                ),

                // ── Stories ───────────────────────────────────────────────
                StoryBar(users: app.seedUsers),
                const BDivider(),

                // ── Mood filter ───────────────────────────────────────────
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  child: Row(children: _moods.map((m) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: MoodChip(
                      mood: m,
                      selected: app.moodFilter == m,
                      onTap: () => app.setMood(m),
                    ),
                  )).toList()),
                ),

                // ── Trending topics ───────────────────────────────────────
                _TrendingTopics(topics: app.trendingTopics, onTap: (t) => app.setSearchQuery(t)),
                const BDivider(),
              ]),
            ),
          ],
          body: !app.postsLoaded
              ? const Center(child: CircularProgressIndicator(color: BColor.muted))
              : posts.isEmpty
                  ? const BEmptyState(icon: '🌬️', title: 'No posts yet', subtitle: 'Be the first to post something real.')
                  : RefreshIndicator(
                      color: BColor.green,
                      backgroundColor: BColor.bg1,
                      onRefresh: app.refreshPosts,
                      child: ListView.builder(
                        itemCount: posts.length + 1,
                        itemBuilder: (ctx, i) {
                          if (i == posts.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 24),
                              child: Center(child: Text("you've seen it all 👀", style: TextStyle(color: BColor.muted, fontSize: 13))),
                            );
                          }
                          return PostCard(post: posts[i]);
                        },
                      ),
                    ),
        ),
      ),
    );
  }
}

// ── Trending topics chip bar ──────────────────────────────────────────────────
class _TrendingTopics extends StatelessWidget {
  final List<String> topics;
  final void Function(String) onTap;
  const _TrendingTopics({required this.topics, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (topics.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Padding(
        padding: EdgeInsets.fromLTRB(16, 8, 16, 6),
        child: Text('Trending', style: TextStyle(color: BColor.muted, fontSize: 11, fontWeight: FontWeight.w600, letterSpacing: 0.8)),
      ),
      SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Row(children: topics.map((t) => Padding(
          padding: const EdgeInsets.only(right: 8),
          child: GestureDetector(
            onTap: () => onTap(t),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: BColor.bg2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: BColor.border),
              ),
              child: Text(t, style: const TextStyle(color: BColor.textSub, fontSize: 12)),
            ),
          ),
        )).toList()),
      ),
      const SizedBox(height: 8),
    ]);
  }
}

// ── Ghost button ─────────────────────────────────────────────────────────────
class _GhostButton extends StatelessWidget {
  final bool ghostMode;
  final VoidCallback onTap;
  const _GhostButton({required this.ghostMode, required this.onTap});

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
      child: Center(
        child: Text('👻', style: TextStyle(fontSize: ghostMode ? 18 : 16)),
      ),
    ),
  );
}

// ── Icon button ───────────────────────────────────────────────────────────────
class _IconBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  final int? badge;
  const _IconBtn({required this.icon, required this.onTap, this.active = false, this.badge});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 36, height: 36,
      child: Stack(children: [
        Container(
          width: 36, height: 36,
          decoration: BoxDecoration(
            color: active ? BColor.text.withAlpha(25) : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(color: active ? BColor.text : BColor.border),
          ),
          child: Center(child: Icon(icon, size: 18, color: active ? BColor.text : BColor.muted)),
        ),
        if (badge != null)
          Positioned(
            right: 0, top: 0,
            child: Container(
              width: 16, height: 16,
              decoration: const BoxDecoration(color: BColor.danger, shape: BoxShape.circle),
              child: Center(
                child: Text(
                  badge! > 9 ? '9+' : '$badge',
                  style: const TextStyle(color: Colors.white, fontSize: 9, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ),
      ]),
    ),
  );
}
