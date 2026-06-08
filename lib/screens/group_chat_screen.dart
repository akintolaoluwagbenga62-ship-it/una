import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../auth_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';
import 'call_screen.dart';

class GroupChatScreen extends StatefulWidget {
  final BChat chat;
  const GroupChatScreen({super.key, required this.chat});
  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final _ctrl = TextEditingController();
  final _scrollCtrl = ScrollController();
  bool _anon = false;
  bool _showBeams = false;
  bool _showPoll = false;
  bool _isRecording = false;
  int _recordSeconds = 0;
  BMessage? _pinnedMsg;
  final _pollCtrl = TextEditingController();
  final _pollOpt1 = TextEditingController();
  final _pollOpt2 = TextEditingController();

  static const _beams = ['❤️', '🔥', '😂', '😭', '🫂', '💯', '🙏', '✨', '👻', '💙'];
  static const _reactions = ['❤️', '🔥', '😂', '🫂', '💯', '✨'];

  @override
  void initState() {
    super.initState();
    final msgs = context.read<AppState>().getMessages(widget.chat.id);
    _pinnedMsg = msgs.where((m) => m.isPinned).isNotEmpty ? msgs.firstWhere((m) => m.isPinned) : null;
  }

  @override
  void dispose() {
    _ctrl.dispose(); _scrollCtrl.dispose(); _pollCtrl.dispose();
    _pollOpt1.dispose(); _pollOpt2.dispose();
    super.dispose();
  }

  void _send(AppState app, AuthState auth) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final msg = BMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      senderId: _anon ? 'anonymous' : (auth.user?.id ?? 'me'),
      text: text, isAnonymous: _anon,
      createdAt: DateTime.now().toIso8601String(),
    );
    app.sendMessage(widget.chat.id, msg);
    _ctrl.clear();
    setState(() => _showBeams = false);
  }

  void _sendBeam(AppState app, AuthState auth, String beam) {
    final msg = BMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      senderId: _anon ? 'anonymous' : (auth.user?.id ?? 'me'),
      text: beam, isAnonymous: _anon,
      createdAt: DateTime.now().toIso8601String(),
    );
    app.sendMessage(widget.chat.id, msg);
    setState(() => _showBeams = false);
  }

  void _sendVoiceNote(AppState app, AuthState auth) {
    if (_recordSeconds == 0) return;
    final duration = '0:${_recordSeconds.toString().padLeft(2, '0')}';
    final msg = BMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      senderId: _anon ? 'anonymous' : (auth.user?.id ?? 'me'),
      text: '🎤 Voice note ($duration)',
      isAnonymous: _anon, type: 'voice', voiceNote: duration,
      createdAt: DateTime.now().toIso8601String(),
    );
    app.sendMessage(widget.chat.id, msg);
    setState(() { _isRecording = false; _recordSeconds = 0; });
  }

  void _sendPoll(AppState app, AuthState auth) {
    if (_pollCtrl.text.trim().isEmpty || _pollOpt1.text.trim().isEmpty || _pollOpt2.text.trim().isEmpty) return;
    final msg = BMessage(
      id: '${DateTime.now().millisecondsSinceEpoch}',
      senderId: _anon ? 'anonymous' : (auth.user?.id ?? 'me'),
      text: '📊 Poll: ${_pollCtrl.text.trim()}',
      isAnonymous: _anon, type: 'poll',
      poll: {'question': _pollCtrl.text.trim(), 'options': [_pollOpt1.text.trim(), _pollOpt2.text.trim()], 'votes': [0, 0]},
      createdAt: DateTime.now().toIso8601String(),
    );
    app.sendMessage(widget.chat.id, msg);
    setState(() { _showPoll = false; _pollCtrl.clear(); _pollOpt1.clear(); _pollOpt2.clear(); });
  }

  void _startRecording() async {
    setState(() { _isRecording = true; _recordSeconds = 0; });
    while (_isRecording) {
      await Future.delayed(const Duration(seconds: 1));
      if (!_isRecording || !mounted) break;
      setState(() => _recordSeconds++);
    }
  }

  void _showMemberSheet(BuildContext context, AppState app) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BColor.bg1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _MemberSheet(chat: widget.chat, app: app),
    );
  }

  void _showInfoSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BColor.bg1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => _GroupInfoSheet(chat: widget.chat),
    );
  }

  void _showReactionPicker(BuildContext context, AppState app, String msgId) {
    showModalBottomSheet(
      context: context,
      backgroundColor: BColor.bg1,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('React to message', style: TextStyle(color: BColor.muted, fontSize: 13, fontWeight: FontWeight.w600)),
          const SizedBox(height: 16),
          Wrap(spacing: 16, children: _reactions.map((e) => GestureDetector(
            onTap: () { app.reactToMessage(widget.chat.id, msgId, e); Navigator.pop(context); },
            child: Text(e, style: const TextStyle(fontSize: 32)),
          )).toList()),
          const SizedBox(height: 12),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthState>();
    final messages = app.getMessages(widget.chat.id);
    final pinned = messages.where((m) => m.isPinned).toList();
    final currentPinned = pinned.isNotEmpty ? pinned.first : null;

    return Scaffold(
      backgroundColor: BColor.bg,
      appBar: AppBar(
        backgroundColor: BColor.bg,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: BColor.text), onPressed: () => Navigator.pop(context)),
        titleSpacing: 0,
        title: GestureDetector(
          onTap: () => _showInfoSheet(context),
          child: Row(children: [
            Container(width: 36, height: 36, decoration: BoxDecoration(color: BColor.bg2, shape: BoxShape.circle, border: Border.all(color: BColor.border)),
              child: Center(child: Text(_emoji(widget.chat.topic), style: const TextStyle(fontSize: 18)))),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Text(widget.chat.name ?? 'Group', style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: BColor.text)),
                if (widget.chat.isAiModerated) ...[const SizedBox(width: 4), const Icon(Icons.smart_toy, color: BColor.green, size: 13)],
              ]),
              Text('${formatCount(widget.chat.memberCount)} members', style: const TextStyle(fontSize: 11, color: BColor.muted)),
            ]),
          ]),
        ),
        actions: [
          // Voice call
          IconButton(
            icon: const Icon(Icons.call_outlined, color: BColor.text, size: 20),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(name: widget.chat.name ?? 'Group', isVideo: false))),
          ),
          // Video call
          IconButton(
            icon: const Icon(Icons.videocam_outlined, color: BColor.text, size: 20),
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => CallScreen(name: widget.chat.name ?? 'Group', isVideo: true))),
          ),
          // Members
          IconButton(
            icon: const Icon(Icons.group_outlined, color: BColor.muted, size: 20),
            onPressed: () => _showMemberSheet(context, app),
          ),
          IconButton(
            icon: const Icon(Icons.more_vert, color: BColor.muted, size: 20),
            onPressed: () => _showInfoSheet(context),
          ),
        ],
      ),
      body: Column(children: [
        // Pinned message
        if (currentPinned != null) Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          color: BColor.green.withAlpha(20),
          child: Row(children: [
            const Icon(Icons.push_pin, color: BColor.green, size: 14),
            const SizedBox(width: 8),
            Expanded(child: Text(currentPinned.text, style: const TextStyle(fontSize: 12, color: BColor.textSub), maxLines: 1, overflow: TextOverflow.ellipsis)),
            GestureDetector(onTap: () { app.pinMessage(widget.chat.id, currentPinned.id); }, child: const Icon(Icons.close, size: 14, color: BColor.muted)),
          ]),
        ),

        // Messages
        Expanded(
          child: messages.isEmpty
              ? const BEmptyState(icon: '💬', title: 'Start the conversation', subtitle: 'Be the first to say something')
              : ListView.builder(
                  controller: _scrollCtrl,
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: messages.length,
                  itemBuilder: (ctx, i) => _MessageBubble(
                    msg: messages[i],
                    app: app,
                    auth: auth,
                    chatId: widget.chat.id,
                    onReact: () => _showReactionPicker(context, app, messages[i].id),
                    onPin: () => app.pinMessage(widget.chat.id, messages[i].id),
                  ),
                ),
        ),

        // Poll composer
        if (_showPoll) Container(
          margin: const EdgeInsets.all(12),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: BColor.bg1, borderRadius: BorderRadius.circular(14), border: Border.all(color: BColor.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Text('📊 Create Poll', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: BColor.text)),
              const Spacer(),
              GestureDetector(onTap: () => setState(() => _showPoll = false), child: const Icon(Icons.close, size: 16, color: BColor.muted)),
            ]),
            const SizedBox(height: 10),
            TextField(controller: _pollCtrl, style: const TextStyle(color: BColor.text, fontSize: 13), decoration: const InputDecoration(hintText: 'Poll question...', isDense: true, contentPadding: EdgeInsets.all(8))),
            const SizedBox(height: 8),
            TextField(controller: _pollOpt1, style: const TextStyle(color: BColor.text, fontSize: 13), decoration: const InputDecoration(hintText: 'Option 1', isDense: true, contentPadding: EdgeInsets.all(8), prefixText: 'A  ')),
            const SizedBox(height: 6),
            TextField(controller: _pollOpt2, style: const TextStyle(color: BColor.text, fontSize: 13), decoration: const InputDecoration(hintText: 'Option 2', isDense: true, contentPadding: EdgeInsets.all(8), prefixText: 'B  ')),
            const SizedBox(height: 10),
            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: () => _sendPoll(app, auth),
              style: FilledButton.styleFrom(backgroundColor: BColor.text, foregroundColor: BColor.bg, textStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13), padding: const EdgeInsets.symmetric(vertical: 10)),
              child: const Text('Send Poll'),
            )),
          ]),
        ),

        // Beam picker
        if (_showBeams) Container(
          margin: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(color: BColor.bg1, borderRadius: BorderRadius.circular(14), border: Border.all(color: BColor.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('Send a Beam ⚡', style: TextStyle(fontSize: 12, color: BColor.muted, fontWeight: FontWeight.w600)),
            const SizedBox(height: 10),
            Wrap(spacing: 8, runSpacing: 8, children: _beams.map((b) => GestureDetector(
              onTap: () => _sendBeam(app, auth, b),
              child: Container(width: 42, height: 42, decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(21)), child: Center(child: Text(b, style: const TextStyle(fontSize: 22)))),
            )).toList()),
          ]),
        ),

        // Recording indicator
        if (_isRecording) Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          color: BColor.danger.withAlpha(20),
          child: Row(children: [
            Container(width: 10, height: 10, decoration: const BoxDecoration(color: BColor.danger, shape: BoxShape.circle)),
            const SizedBox(width: 8),
            Text('Recording${_anon ? " anonymously" : ""}...  0:${_recordSeconds.toString().padLeft(2, '0')}', style: const TextStyle(color: BColor.danger, fontSize: 13)),
            const Spacer(),
            GestureDetector(
              onTap: () => sendVoiceNote(app, auth),
              child: Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6), decoration: BoxDecoration(color: BColor.danger, borderRadius: BorderRadius.circular(14)), child: const Text('Send', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700))),
            ),
          ]),
        ),

        // Input bar
        Container(
          padding: const EdgeInsets.fromLTRB(10, 8, 10, 12),
          decoration: const BoxDecoration(border: Border(top: BorderSide(color: BColor.border, width: 0.5))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.end, children: [
            // Anon toggle
            GestureDetector(
              onTap: () => setState(() => _anon = !_anon),
              child: Container(
                width: 36, height: 36,
                decoration: BoxDecoration(
                  color: _anon ? BColor.green.withAlpha(51) : Colors.transparent,
                  shape: BoxShape.circle,
                  border: Border.all(color: _anon ? BColor.green : BColor.border),
                ),
                child: Center(child: Text('👻', style: TextStyle(fontSize: _anon ? 18 : 16))),
              ),
            ),
            const SizedBox(width: 6),

            // Attachment
            GestureDetector(
              onTap: () => setState(() => _showPoll = !_showPoll),
              child: Container(width: 34, height: 34, decoration: const BoxDecoration(shape: BoxShape.circle), child: Center(child: Icon(Icons.poll_outlined, size: 20, color: _showPoll ? BColor.text : BColor.muted))),
            ),

            // Beam
            GestureDetector(
              onTap: () => setState(() => _showBeams = !_showBeams),
              child: Container(width: 34, height: 34, decoration: const BoxDecoration(shape: BoxShape.circle), child: Center(child: Icon(Icons.bolt, size: 20, color: _showBeams ? BColor.gold : BColor.muted))),
            ),

            // Text input
            Expanded(child: Container(
              constraints: const BoxConstraints(maxHeight: 120),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: BColor.bg2,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: _anon ? BColor.green.withAlpha(128) : BColor.border),
              ),
              child: TextField(
                controller: _ctrl,
                maxLines: null,
                style: const TextStyle(color: BColor.text, fontSize: 14),
                decoration: InputDecoration(
                  hintText: _anon ? '👻 Message anonymously...' : 'Message ${widget.chat.name ?? "group"}...',
                  hintStyle: const TextStyle(color: BColor.muted, fontSize: 14),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: EdgeInsets.zero,
                ),
                onChanged: (_) => setState(() {}),
              ),
            )),

            // Voice note (hold)
            GestureDetector(
              onLongPressStart: (_) => _startRecording(),
              onLongPressEnd: (_) => _sendVoiceNote(app, auth),
              onTap: _ctrl.text.trim().isEmpty ? null : () => _send(app, auth),
              child: Container(
                width: 38, height: 38,
                decoration: BoxDecoration(
                  color: _ctrl.text.trim().isEmpty ? Colors.transparent : BColor.text,
                  shape: BoxShape.circle,
                  border: Border.all(color: _ctrl.text.trim().isEmpty ? BColor.border : Colors.transparent),
                ),
                child: Center(child: Icon(
                  _ctrl.text.trim().isEmpty ? Icons.mic_outlined : Icons.send_rounded,
                  size: 18,
                  color: _ctrl.text.trim().isEmpty ? BColor.muted : BColor.bg,
                )),
              ),
            ),
          ]),
        ),

        // Anonymous indicator strip
        if (_anon) Container(
          width: double.infinity,
          color: BColor.green.withAlpha(20),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: const Text('👻 You are posting anonymously — your identity is hidden', style: TextStyle(fontSize: 11, color: BColor.green, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
        ),
      ]),
    );
  }

  void sendVoiceNote(AppState app, AuthState auth) => _sendVoiceNote(app, auth);

  String _emoji(String topic) {
    switch (topic.toLowerCase()) {
      case 'photography': return '📷';
      case 'music': return '🎵';
      case 'mental health': return '💙';
      default: return '💬';
    }
  }
}

// ── MESSAGE BUBBLE ────────────────────────────────────────────────────────────
class _MessageBubble extends StatelessWidget {
  final BMessage msg;
  final AppState app;
  final AuthState auth;
  final String chatId;
  final VoidCallback onReact;
  final VoidCallback onPin;
  const _MessageBubble({required this.msg, required this.app, required this.auth, required this.chatId, required this.onReact, required this.onPin});

  bool get isMe => msg.senderId == (auth.user?.id ?? 'me') || msg.senderId == 'me';
  bool get isAi => msg.senderId == 'ai';
  bool get isAnon => msg.isAnonymous;

  @override
  Widget build(BuildContext context) {
    final sender = (!isAnon && !isMe && !isAi) ? app.getUserById(msg.senderId) : null;
    final name = isAi ? '🤖 Bondly AI' : isAnon ? '👻 Anonymous' : (sender?.name ?? msg.senderId);

    if (isAi) return _AiBubble(text: msg.text);

    if (msg.type == 'poll' && msg.poll != null) {
      return _PollBubble(msg: msg, name: name, isMe: isMe, app: app, chatId: chatId);
    }

    return GestureDetector(
      onLongPress: () => showModalBottomSheet(
        context: context,
        backgroundColor: BColor.bg1,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(16))),
        builder: (_) => _MessageActions(onReact: onReact, onPin: onPin),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 3),
        child: Row(
          mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            if (!isMe) ...[
              BAvatar(name: isAnon ? 'Anonymous' : (sender?.name ?? '?'), size: 30, faceVerified: sender?.faceVerified ?? false, isAnonymous: isAnon),
              const SizedBox(width: 8),
            ],
            Flexible(child: Column(
              crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isMe) Text(name, style: const TextStyle(fontSize: 11, color: BColor.muted, fontWeight: FontWeight.w600)),
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 14, vertical: msg.type == 'voice' ? 8 : 10),
                  decoration: BoxDecoration(
                    color: isMe ? BColor.text : (isAnon ? BColor.green.withAlpha(38) : BColor.bg1),
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(18),
                      topRight: const Radius.circular(18),
                      bottomLeft: Radius.circular(isMe ? 18 : 4),
                      bottomRight: Radius.circular(isMe ? 4 : 18),
                    ),
                    border: isMe ? null : Border.all(color: isAnon ? BColor.green.withAlpha(76) : BColor.border),
                  ),
                  child: msg.type == 'voice'
                      ? _VoiceBubble(duration: msg.voiceNote ?? '0:00', isMe: isMe)
                      : Text(msg.text, style: TextStyle(fontSize: 14, color: isMe ? BColor.bg : BColor.text, height: 1.4)),
                ),
                // Reactions
                if (msg.reactions.isNotEmpty) Padding(
                  padding: const EdgeInsets.only(top: 3),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: BColor.bg1, borderRadius: BorderRadius.circular(12), border: Border.all(color: BColor.border)),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      ...msg.reactions.take(3).map((e) => Text(e, style: const TextStyle(fontSize: 13))),
                      if (msg.reactions.length > 3) Text(' +${msg.reactions.length - 3}', style: const TextStyle(fontSize: 11, color: BColor.muted)),
                    ]),
                  ),
                ),
                Text(formatTime(msg.createdAt), style: const TextStyle(fontSize: 10, color: BColor.muted)),
              ],
            )),
            if (isMe) const SizedBox(width: 8),
          ],
        ),
      ),
    );
  }
}

class _VoiceBubble extends StatefulWidget {
  final String duration;
  final bool isMe;
  const _VoiceBubble({required this.duration, required this.isMe});
  @override
  State<_VoiceBubble> createState() => _VoiceBubbleState();
}

class _VoiceBubbleState extends State<_VoiceBubble> {
  bool _playing = false;
  double _progress = 0;

  void _toggle() async {
    setState(() { _playing = true; _progress = 0; });
    for (int i = 0; i < 20; i++) {
      await Future.delayed(const Duration(milliseconds: 120));
      if (!mounted || !_playing) break;
      setState(() => _progress = (i + 1) / 20);
    }
    if (mounted) setState(() { _playing = false; _progress = 0; });
  }

  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    GestureDetector(
      onTap: _toggle,
      child: Icon(_playing ? Icons.pause_circle_filled : Icons.play_circle_filled, color: widget.isMe ? BColor.bg : BColor.text, size: 28),
    ),
    const SizedBox(width: 8),
    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(
        width: 100,
        child: ClipRRect(borderRadius: BorderRadius.circular(2), child: LinearProgressIndicator(
          value: _progress, minHeight: 3,
          backgroundColor: (widget.isMe ? BColor.bg : BColor.text).withAlpha(51),
          valueColor: AlwaysStoppedAnimation(widget.isMe ? BColor.bg : BColor.text),
        )),
      ),
      const SizedBox(height: 4),
      Text(widget.duration, style: TextStyle(fontSize: 11, color: widget.isMe ? BColor.bg.withAlpha(179) : BColor.muted)),
    ]),
  ]);
}

class _AiBubble extends StatelessWidget {
  final String text;
  const _AiBubble({required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    child: Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: BColor.green.withAlpha(20), borderRadius: BorderRadius.circular(12), border: Border.all(color: BColor.green.withAlpha(76))),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Icon(Icons.smart_toy, color: BColor.green, size: 16),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: BColor.textSub, height: 1.4))),
      ]),
    ),
  );
}

class _PollBubble extends StatefulWidget {
  final BMessage msg;
  final String name;
  final bool isMe;
  final AppState app;
  final String chatId;
  const _PollBubble({required this.msg, required this.name, required this.isMe, required this.app, required this.chatId});
  @override
  State<_PollBubble> createState() => _PollBubbleState();
}

class _PollBubbleState extends State<_PollBubble> {
  int? _voted;
  @override
  Widget build(BuildContext context) {
    final poll = widget.msg.poll!;
    final opts = List<String>.from(poll['options'] as List);
    final votes = List<int>.from(poll['votes'] as List);
    final total = votes.fold(0, (a, b) => a + b);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: BColor.bg1, borderRadius: BorderRadius.circular(14), border: Border.all(color: BColor.border)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (!widget.isMe) Text(widget.name, style: const TextStyle(fontSize: 11, color: BColor.muted, fontWeight: FontWeight.w600)),
          Text(poll['question'] as String, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: BColor.text)),
          const SizedBox(height: 10),
          ...List.generate(opts.length, (i) {
            final pct = total == 0 ? 0.0 : votes[i] / total;
            final voted = _voted == i;
            return GestureDetector(
              onTap: () {
                if (_voted != null) return;
                setState(() { _voted = i; votes[i]++; });
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: voted ? BColor.text.withAlpha(20) : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: voted ? BColor.text : BColor.border),
                ),
                child: Stack(children: [
                  if (_voted != null) Positioned.fill(child: FractionallySizedBox(
                    widthFactor: pct, alignment: Alignment.centerLeft,
                    child: Container(decoration: BoxDecoration(color: BColor.text.withAlpha(15), borderRadius: BorderRadius.circular(8))),
                  )),
                  Row(children: [
                    Text(opts[i], style: TextStyle(fontSize: 13, color: voted ? BColor.text : BColor.textSub, fontWeight: voted ? FontWeight.w700 : FontWeight.w400)),
                    const Spacer(),
                    if (_voted != null) Text('${(pct * 100).round()}%', style: const TextStyle(fontSize: 12, color: BColor.muted, fontWeight: FontWeight.w600)),
                  ]),
                ]),
              ),
            );
          }),
          if (_voted != null) Text('$total vote${total == 1 ? '' : 's'}', style: const TextStyle(fontSize: 11, color: BColor.muted)),
        ]),
      ),
    );
  }
}

class _MessageActions extends StatelessWidget {
  final VoidCallback onReact;
  final VoidCallback onPin;
  const _MessageActions({required this.onReact, required this.onPin});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    const SizedBox(height: 8),
    Container(width: 36, height: 4, decoration: BoxDecoration(color: BColor.border, borderRadius: BorderRadius.circular(2))),
    const SizedBox(height: 16),
    _ActionTile(icon: Icons.emoji_emotions_outlined, label: 'React', onTap: () { Navigator.pop(context); onReact(); }),
    _ActionTile(icon: Icons.push_pin_outlined, label: 'Pin message', onTap: () { Navigator.pop(context); onPin(); }),
    _ActionTile(icon: Icons.reply_outlined, label: 'Reply', onTap: () => Navigator.pop(context)),
    _ActionTile(icon: Icons.copy_outlined, label: 'Copy text', onTap: () => Navigator.pop(context)),
    _ActionTile(icon: Icons.flag_outlined, label: 'Report', onTap: () => Navigator.pop(context), danger: true),
    const SizedBox(height: 12),
  ]);
}

class _ActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool danger;
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.danger = false});
  @override
  Widget build(BuildContext context) => ListTile(
    leading: Icon(icon, color: danger ? BColor.danger : BColor.text, size: 20),
    title: Text(label, style: TextStyle(color: danger ? BColor.danger : BColor.text, fontSize: 14, fontWeight: FontWeight.w600)),
    onTap: onTap,
    dense: true,
  );
}

class _MemberSheet extends StatelessWidget {
  final BChat chat;
  final AppState app;
  const _MemberSheet({required this.chat, required this.app});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    const SizedBox(height: 8),
    Container(width: 36, height: 4, decoration: BoxDecoration(color: BColor.border, borderRadius: BorderRadius.circular(2))),
    const SizedBox(height: 16),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: Row(children: [
      Text('Members', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: BColor.text)),
      const Spacer(),
      Text('${formatCount(chat.memberCount)} total', style: const TextStyle(fontSize: 13, color: BColor.muted)),
    ])),
    const SizedBox(height: 12),
    ...chat.participants.map((id) {
      final u = app.getUserById(id);
      if (u == null) return const SizedBox.shrink();
      return ListTile(
        leading: BAvatar(name: u.name, size: 38, faceVerified: u.faceVerified),
        title: Text(u.name, style: const TextStyle(color: BColor.text, fontSize: 14, fontWeight: FontWeight.w600)),
        subtitle: Text(u.handle, style: const TextStyle(color: BColor.muted, fontSize: 12)),
        trailing: id == chat.participants.first
            ? Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: BColor.gold.withAlpha(38), borderRadius: BorderRadius.circular(8)), child: const Text('Admin', style: TextStyle(color: BColor.gold, fontSize: 11, fontWeight: FontWeight.w700)))
            : null,
      );
    }),
    const SizedBox(height: 20),
  ]);
}

class _GroupInfoSheet extends StatelessWidget {
  final BChat chat;
  const _GroupInfoSheet({required this.chat});
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    const SizedBox(height: 8),
    Container(width: 36, height: 4, decoration: BoxDecoration(color: BColor.border, borderRadius: BorderRadius.circular(2))),
    const SizedBox(height: 20),
    Container(width: 64, height: 64, decoration: BoxDecoration(color: BColor.bg2, shape: BoxShape.circle, border: Border.all(color: BColor.border)), child: Center(child: Text('💬', style: const TextStyle(fontSize: 32)))),
    const SizedBox(height: 12),
    Text(chat.name ?? 'Group', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: BColor.text)),
    if (chat.topic.isNotEmpty) Text('# ${chat.topic}', style: const TextStyle(color: BColor.muted, fontSize: 13)),
    const SizedBox(height: 8),
    if (chat.isAiModerated) Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(color: BColor.green.withAlpha(25), borderRadius: BorderRadius.circular(8), border: Border.all(color: BColor.green.withAlpha(76))),
      child: const Text('🤖 AI Moderated — Bondly AI keeps this space safe', style: TextStyle(color: BColor.green, fontSize: 12)),
    ),
    const SizedBox(height: 20),
    ListTile(leading: const Icon(Icons.group_outlined, color: BColor.muted), title: Text('${formatCount(chat.memberCount)} members', style: const TextStyle(color: BColor.text, fontSize: 14))),
    ListTile(leading: const Icon(Icons.notifications_outlined, color: BColor.muted), title: const Text('Mute notifications', style: TextStyle(color: BColor.text, fontSize: 14))),
    ListTile(leading: const Icon(Icons.exit_to_app, color: BColor.danger), title: const Text('Leave group', style: TextStyle(color: BColor.danger, fontSize: 14)), onTap: () => Navigator.pop(context)),
    const SizedBox(height: 20),
  ]);
}
