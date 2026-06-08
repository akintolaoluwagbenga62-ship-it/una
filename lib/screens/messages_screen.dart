import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../auth_state.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'group_chat_screen.dart';
import 'dm_chat_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});
  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> with SingleTickerProviderStateMixin {
  late TabController _tab;
  @override
  void initState() { super.initState(); _tab = TabController(length: 3, vsync: this); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthState>();
    final allChats = app.chats;
    final totalUnread = allChats.fold(0, (s, c) => s + c.unread);

    return Scaffold(
      backgroundColor: BColor.bg,
      body: SafeArea(
        child: Column(children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              const Text('Messages', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: BColor.text)),
              if (totalUnread > 0) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: BColor.text, borderRadius: BorderRadius.circular(10)),
                  child: Text('$totalUnread', style: const TextStyle(color: BColor.bg, fontSize: 11, fontWeight: FontWeight.w800)),
                ),
              ],
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.add_comment_outlined, color: BColor.muted),
                onPressed: () {},
              ),
            ]),
          ),

          GhostModeBanner(ghostMode: app.ghostMode, timeLeft: app.ghostTimeLeft, onTap: app.toggleGhost),

          // Tab bar
          Container(
            decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: BColor.border, width: 0.5))),
            child: TabBar(
              controller: _tab,
              indicatorColor: BColor.text,
              indicatorWeight: 2,
              labelColor: BColor.text,
              unselectedLabelColor: BColor.muted,
              labelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
              unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
              tabs: const [Tab(text: 'All'), Tab(text: 'DMs'), Tab(text: 'Groups')],
            ),
          ),

          Expanded(child: TabBarView(
            controller: _tab,
            children: [
              _ChatList(chats: allChats, app: app, onTap: (c) => _open(context, c)),
              _ChatList(chats: allChats.where((c) => c.type == 'dm').toList(), app: app, onTap: (c) => _open(context, c)),
              _ChatList(chats: allChats.where((c) => c.type == 'group').toList(), app: app, onTap: (c) => _open(context, c), showNewGroupBtn: true),
            ],
          )),
        ]),
      ),
    );
  }

  void _open(BuildContext context, dynamic chat) {
    final c = chat;
    if (c.type == 'group') {
      Navigator.push(context, MaterialPageRoute(builder: (_) => GroupChatScreen(chat: c)));
    } else {
      Navigator.push(context, MaterialPageRoute(builder: (_) => DmChatScreen(chat: c)));
    }
  }
}

class _ChatList extends StatelessWidget {
  final List chats;
  final AppState app;
  final void Function(dynamic) onTap;
  final bool showNewGroupBtn;
  const _ChatList({required this.chats, required this.app, required this.onTap, this.showNewGroupBtn = false});

  @override
  Widget build(BuildContext context) {
    if (chats.isEmpty) return const BEmptyState(icon: '📭', title: 'No messages yet', subtitle: 'Start a conversation or join a group');
    return ListView(children: [
      if (showNewGroupBtn) Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
        child: OutlinedButton.icon(
          icon: const Icon(Icons.group_add_outlined, size: 16),
          label: const Text('Create new group', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
          style: OutlinedButton.styleFrom(
            foregroundColor: BColor.muted, side: const BorderSide(color: BColor.border),
            padding: const EdgeInsets.symmetric(vertical: 10),
          ),
          onPressed: () {},
        ),
      ),
      ...chats.map((c) {
        final otherUser = c.type == 'dm' ? app.getUserById(c.participants.firstWhere((p) => p != 'me', orElse: () => c.participants.first)) : null;
        return Column(children: [
          BChatListItem(chat: c, otherUser: otherUser, onTap: () => onTap(c)),
          const BDivider(),
        ]);
      }),
    ]);
  }
}
