import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../auth_state.dart';
import '../theme.dart';
import '../widgets/post_card.dart';
import '../widgets/widgets.dart';

class BookmarksScreen extends StatelessWidget {
  const BookmarksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthState>();
    final userId = auth.user?.id ?? '';
    final saved = app.posts.where((p) => p.bookmarkedBy.contains(userId)).toList();

    return Scaffold(
      backgroundColor: BColor.bg,
      appBar: AppBar(
        backgroundColor: BColor.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Saved'),
        actions: [
          if (saved.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Center(
                child: Text(
                  '${saved.length} posts',
                  style: const TextStyle(color: BColor.muted, fontSize: 13),
                ),
              ),
            ),
        ],
      ),
      body: saved.isEmpty
          ? const BEmptyState(
              icon: '🔖',
              title: 'Nothing saved yet',
              subtitle: 'Tap the bookmark icon on any post to save it here.',
            )
          : ListView.builder(
              itemCount: saved.length,
              itemBuilder: (_, i) => PostCard(post: saved[i]),
            ),
    );
  }
}
