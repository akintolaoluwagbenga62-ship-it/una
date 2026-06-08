import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import '../widgets/post_card.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});
  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  final _ctrl = TextEditingController();
  bool _focused = false;
  String _query = '';

  static const _trending = [
    {'tag': '#MentalHealth', 'posts': '42.1K', 'mood': 'deep'},
    {'tag': '#Photography', 'posts': '128K', 'mood': 'chill'},
    {'tag': '#NightShots', 'posts': '31.4K', 'mood': 'chill'},
    {'tag': '#PoetryCorner', 'posts': '18.7K', 'mood': 'deep'},
    {'tag': '#MusicProducer', 'posts': '67.2K', 'mood': 'hype'},
    {'tag': '#FilmCommunity', 'posts': '22.9K', 'mood': 'chill'},
    {'tag': '#SilentMinds', 'posts': '9.3K', 'mood': 'deep'},
    {'tag': '#GenZArt', 'posts': '54.8K', 'mood': 'hype'},
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final users = _query.isEmpty ? [] : app.seedUsers.where((u) =>
      u.name.toLowerCase().contains(_query.toLowerCase()) ||
      u.handle.toLowerCase().contains(_query.toLowerCase())).toList();
    final posts = _query.isEmpty ? [] : app.posts.where((p) =>
      p.text.toLowerCase().contains(_query.toLowerCase()) ||
      p.tags.any((t) => t.toLowerCase().contains(_query.toLowerCase()))).toList();

    return Scaffold(
      backgroundColor: BColor.bg,
      body: SafeArea(
        child: Column(children: [
          // Search bar
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: Container(
              height: 42,
              decoration: BoxDecoration(
                color: BColor.bg2,
                borderRadius: BorderRadius.circular(21),
                border: Border.all(color: _focused ? BColor.text : BColor.border),
              ),
              child: Row(children: [
                const SizedBox(width: 14),
                const Icon(Icons.search, color: BColor.muted, size: 18),
                const SizedBox(width: 8),
                Expanded(child: TextField(
                  controller: _ctrl,
                  style: const TextStyle(color: BColor.text, fontSize: 14),
                  decoration: const InputDecoration(hintText: 'Search Bondly', hintStyle: TextStyle(color: BColor.muted, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                  onFocusChange: (v) => setState(() => _focused = v),
                  onChanged: (v) => setState(() => _query = v),
                  autocorrect: false,
                )),
                if (_query.isNotEmpty) GestureDetector(
                  onTap: () { _ctrl.clear(); setState(() => _query = ''); },
                  child: const Padding(padding: EdgeInsets.all(12), child: Icon(Icons.close, size: 16, color: BColor.muted)),
                ),
              ]),
            ),
          ),

          Expanded(child: _query.isEmpty ? _buildBrowse(context, app) : _buildResults(context, app, users, posts)),
        ]),
      ),
    );
  }

  Widget _buildBrowse(BuildContext context, AppState app) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Trending', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: BColor.text)),
        const SizedBox(height: 14),
        ..._trending.asMap().entries.map((e) {
          final t = e.value;
          final col = BColor.mood(t['mood']!);
          return Container(
            margin: const EdgeInsets.only(bottom: 2),
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 42, height: 42,
                decoration: BoxDecoration(color: col.withAlpha(30), borderRadius: BorderRadius.circular(10)),
                child: Center(child: Text(_moodEmoji(t['mood']!), style: const TextStyle(fontSize: 20))),
              ),
              title: Text(t['tag']!, style: const TextStyle(color: BColor.text, fontWeight: FontWeight.w700, fontSize: 14)),
              subtitle: Text('${t['posts']} posts · ${t['mood']}', style: const TextStyle(color: BColor.muted, fontSize: 12)),
              trailing: Text('#${e.key + 1}', style: const TextStyle(color: BColor.muted, fontSize: 14, fontWeight: FontWeight.w800)),
              onTap: () { setState(() { _ctrl.text = t['tag']!; _query = t['tag']!; }); },
            ),
          );
        }),
        const SizedBox(height: 24),
        const Text('People to Follow', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: BColor.text)),
        const SizedBox(height: 14),
        ...app.seedUsers.take(4).map((u) => Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: BColor.bg1, borderRadius: BorderRadius.circular(14), border: Border.all(color: BColor.border)),
          child: Row(children: [
            BAvatar(name: u.name, size: 44, faceVerified: u.faceVerified),
            const SizedBox(width: 12),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(u.name, style: const TextStyle(fontWeight: FontWeight.w700, color: BColor.text, fontSize: 14)),
                if (u.faceVerified) ...[const SizedBox(width: 4), const Icon(Icons.verified, color: BColor.green, size: 13)],
              ]),
              Text(u.handle, style: const TextStyle(fontSize: 12, color: BColor.muted)),
              const SizedBox(height: 4),
              Text(u.bio, style: const TextStyle(fontSize: 12, color: BColor.textSub), maxLines: 1, overflow: TextOverflow.ellipsis),
            ])),
            const SizedBox(width: 8),
            OutlinedButton(
              onPressed: () {},
              style: OutlinedButton.styleFrom(
                foregroundColor: BColor.text, side: const BorderSide(color: BColor.border),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                minimumSize: Size.zero, tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
              ),
              child: const Text('Follow'),
            ),
          ]),
        )),
      ]),
    );
  }

  Widget _buildResults(BuildContext context, AppState app, List users, List posts) {
    return ListView(children: [
      if (users.isNotEmpty) ...[
        const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8), child: Text('People', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BColor.muted))),
        ...users.map((u) => ListTile(
          leading: BAvatar(name: u.name, size: 40, faceVerified: u.faceVerified),
          title: Text(u.name, style: const TextStyle(color: BColor.text, fontWeight: FontWeight.w700, fontSize: 14)),
          subtitle: Text('${u.handle} · ${formatCount(u.followers)} followers', style: const TextStyle(color: BColor.muted, fontSize: 12)),
          trailing: const Icon(Icons.chevron_right, color: BColor.muted, size: 18),
        )),
        const BDivider(),
      ],
      if (posts.isNotEmpty) ...[
        const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 8), child: Text('Posts', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BColor.muted))),
        ...posts.map((p) => PostCard(post: p)),
      ],
      if (users.isEmpty && posts.isEmpty)
        Padding(padding: const EdgeInsets.only(top: 60), child: BEmptyState(icon: '🔍', title: 'No results for "$_query"', subtitle: 'Try a different search term or hashtag')),
    ]);
  }

  String _moodEmoji(String mood) {
    switch (mood) {
      case 'hype': return '🔥';
      case 'chill': return '🌊';
      case 'deep': return '🌙';
      case 'funny': return '😂';
      default: return '✨';
    }
  }
}
