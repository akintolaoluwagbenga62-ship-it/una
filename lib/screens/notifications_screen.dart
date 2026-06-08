import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().markNotificationsRead();
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final notifs = app.notifications;

    return Scaffold(
      backgroundColor: BColor.bg,
      appBar: AppBar(
        backgroundColor: BColor.bg,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Notifications'),
        bottom: TabBar(
          controller: _tabs,
          labelColor: BColor.text,
          unselectedLabelColor: BColor.muted,
          indicatorColor: BColor.green,
          indicatorSize: TabBarIndicatorSize.label,
          tabs: const [
            Tab(text: 'All'),
            Tab(text: 'Mentions'),
            Tab(text: 'Activity'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _NotifList(notifications: notifs),
          _NotifList(notifications: notifs.where((n) => n.type == 'mention').toList()),
          _NotifList(notifications: notifs.where((n) => n.type != 'mention').toList()),
        ],
      ),
    );
  }
}

class _NotifList extends StatelessWidget {
  final List<BNotification> notifications;
  const _NotifList({required this.notifications});

  @override
  Widget build(BuildContext context) {
    if (notifications.isEmpty) {
      return const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('🔔', style: TextStyle(fontSize: 40)),
          SizedBox(height: 12),
          Text('Nothing here yet', style: TextStyle(color: BColor.muted, fontSize: 15)),
        ]),
      );
    }
    return ListView.separated(
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const Divider(color: BColor.border, height: 0.5),
      itemBuilder: (_, i) => _NotifTile(n: notifications[i]),
    );
  }
}

class _NotifTile extends StatelessWidget {
  final BNotification n;
  const _NotifTile({required this.n});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: n.read ? Colors.transparent : BColor.green.withAlpha(13),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 40, height: 40,
          decoration: BoxDecoration(
            color: _iconColor(n.type).withAlpha(38),
            shape: BoxShape.circle,
          ),
          child: Center(child: Text(_iconEmoji(n.type), style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(n.title, style: const TextStyle(color: BColor.text, fontSize: 14, fontWeight: FontWeight.w600)),
          const SizedBox(height: 2),
          Text(n.body, style: const TextStyle(color: BColor.textSub, fontSize: 13)),
          const SizedBox(height: 4),
          Text(_timeAgo(n.createdAt), style: const TextStyle(color: BColor.muted, fontSize: 11)),
        ])),
      ]),
    );
  }

  String _iconEmoji(String type) {
    switch (type) {
      case 'like': return '❤️';
      case 'comment': return '💬';
      case 'follow': return '👋';
      case 'mention': return '@';
      case 'vibe': return '✨';
      default: return '🔔';
    }
  }

  Color _iconColor(String type) {
    switch (type) {
      case 'like': return BColor.danger;
      case 'comment': return BColor.green;
      case 'follow': return BColor.green;
      case 'mention': return BColor.green;
      default: return BColor.muted;
    }
  }

  String _timeAgo(String iso) {
    final diff = DateTime.now().difference(DateTime.parse(iso));
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }
}

// ── Notification model ────────────────────────────────────────────────────────
class BNotification {
  final String id, type, title, body, createdAt;
  final bool read;
  const BNotification({
    required this.id, required this.type,
    required this.title, required this.body,
    required this.createdAt, this.read = false,
  });
  BNotification copyWith({bool? read}) => BNotification(
    id: id, type: type, title: title, body: body,
    createdAt: createdAt, read: read ?? this.read,
  );
}
