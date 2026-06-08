import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../auth_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'call_screen.dart';

class DmChatScreen extends StatefulWidget {
  final BChat chat;
  const DmChatScreen({super.key, required this.chat});
  @override
  State<DmChatScreen> createState() => _DmChatScreenState();
}

class _DmChatScreenState extends State<DmChatScreen> {
  final _ctrl = TextEditingController();
  bool _showBeams = false;

  static const _beams = ['❤️', '🔥', '😂', '😭', '🫂', '💯', '🙏', '✨'];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  BUser? get _otherUser {
    final app = context.read<AppState>();
    final otherId = widget.chat.participants.firstWhere((p) => p != 'me' && p != (context.read<AuthState>().user?.id ?? 'me'), orElse: () => widget.chat.participants.first);
    return app.getUserById(otherId);
  }

  void _send(AppState app, AuthState auth) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final msg = BMessage(id: '${DateTime.now().millisecondsSinceEpoch}', senderId: auth.user?.id ?? 'me', text: text, createdAt: DateTime.now().toIso8601String());
    app.sendMessage(widget.chat.id, msg);
    _ctrl.clear();
    setState(() {});
  }

  void _sendBeam(AppState app, AuthState auth, String beam) {
    final msg = BMessage(id: '${DateTime.now().millisecondsSinceEpoch}', senderId: auth.user?.id ?? 'me', text: beam, createdAt: DateTime.now().toIso8601String());
    app.sendMessage(widget.chat.id, msg);
    setState(() => _showBeams = false);
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthState>();
    final messages = app.getMessages(widget.chat.id);
    final other = _otherUser;

    return Scaffold(
      backgroundColor: BColor.bg,
      appBar: AppBar(
        backgroundColor: BColor.bg,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: BColor.text), onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: Row(children: [
          BAvatar(name: other?.name ?? 'User', size: 34, faceVerified: other?.faceVerified ?? false),
          const SizedBox(width: 10),
          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(other?.name ?? 'User', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: BColor.text)),
            Text(other?.handle ?? '', style: const TextStyle(fontSize: 11, color: BColor.muted)),
          ]),
        ]),
        actions: [
          IconButton(icon: const Icon(Icons.call_outlined, color: BColor.text, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(name: other?.name ?? 'User', isVideo: false)))),
          IconButton(icon: const Icon(Icons.videocam_outlined, color: BColor.text, size: 20), onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(name: other?.name ?? 'User', isVideo: true)))),
          IconButton(icon: const Icon(Icons.more_vert, color: BColor.muted), onPressed: () {}),
        ],
      ),
      body: Column(children: [
        Expanded(
          child: messages.isEmpty
              ? const BEmptyState(icon: '💬', title: 'Start the conversation', subtitle: 'Say something real')
              : ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) {
                    final msg = messages[i];
                    final isMe = msg.senderId == (auth.user?.id ?? 'me') || msg.senderId == 'me';
                    return _DmBubble(msg: msg, isMe: isMe, other: other);
                  },
                ),
        ),

        // Beams
        if (_showBeams) Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: BColor.bg1, borderRadius: BorderRadius.circular(14), border: Border.all(color: BColor.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send a Beam ⚡', style: TextStyle(fontSize: 12, color: BColor.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Wrap(spacing: 8, runSpacing: 8, children: _beams.map((b) => GestureDetector(
              onTap: () => _sendBeam(app, auth, b),
              child: Container(width: 40, height: 40, decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(20)), child: Center(child: Text(b, style: const TextStyle(fontSize: 22)))),
            )).toList()),
          ]),
        ),

        // Input
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 20),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: BColor.border, width: 0.5))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            GestureDetector(
              onTap: () => setState(() => _showBeams = !_showBeams),
              child: Container(width: 36, height: 36, child: Center(child: Icon(Icons.bolt, size: 22, color: _showBeams ? BColor.gold : BColor.muted))),
            ),
            Expanded(child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              margin: const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: BColor.border)),
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                style: const TextStyle(color: BColor.text, fontSize: 14),
                decoration: InputDecoration(hintText: 'Message ${other?.name ?? ""}...', hintStyle: const TextStyle(color: BColor.muted, fontSize: 14), border: InputBorder.none, isDense: true, contentPadding: EdgeInsets.zero),
                onChanged: (_) => setState(() {}),
              ),
            )),
            GestureDetector(
              onTap: _ctrl.text.trim().isEmpty ? null : () => _send(app, auth),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: _ctrl.text.trim().isEmpty ? Colors.transparent : BColor.text, shape: BoxShape.circle, border: Border.all(color: _ctrl.text.trim().isEmpty ? BColor.border : Colors.transparent)),
                child: Center(child: Icon(_ctrl.text.trim().isEmpty ? Icons.mic_outlined : Icons.send_rounded, size: 17, color: _ctrl.text.trim().isEmpty ? BColor.muted : BColor.bg)),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}

class _DmBubble extends StatelessWidget {
  final BMessage msg;
  final bool isMe;
  final BUser? other;
  const _DmBubble({required this.msg, required this.isMe, this.other});

  @override
  Widget build(BuildContext context) {
    final isEmoji = msg.text.runes.length == 1 || (msg.text.runes.length <= 2 && msg.text.length <= 4);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
      child: Row(
        mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isMe) ...[BAvatar(name: other?.name ?? '?', size: 28, faceVerified: other?.faceVerified ?? false), const SizedBox(width: 8)],
          if (isEmoji) Text(msg.text, style: const TextStyle(fontSize: 40))
          else Container(
            constraints: const BoxConstraints(maxWidth: 260),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isMe ? BColor.text : BColor.bg1,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18), topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : 4), bottomRight: Radius.circular(isMe ? 4 : 18),
              ),
              border: isMe ? null : Border.all(color: BColor.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text(msg.text, style: TextStyle(fontSize: 14.5, color: isMe ? BColor.bg : BColor.text, height: 1.4)),
              const SizedBox(height: 2),
              Text(formatTime(msg.createdAt), style: TextStyle(fontSize: 10, color: isMe ? BColor.bg.withAlpha(128) : BColor.muted)),
            ]),
          ),
          if (isMe) const SizedBox(width: 8),
        ],
      ),
    );
  }
}
