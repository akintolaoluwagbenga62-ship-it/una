import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../auth_state.dart';
import '../models.dart';
import '../theme.dart';
import '../widgets/widgets.dart';

class CreateScreen extends StatefulWidget {
  const CreateScreen({super.key});
  @override
  State<CreateScreen> createState() => _CreateScreenState();
}

class _CreateScreenState extends State<CreateScreen> {
  final _ctrl = TextEditingController();
  String _mood = 'chill';
  bool _isAnon = false;
  bool _isTimeCapsule = false;
  bool _vibeChecked = false;
  Map<String, dynamic>? _vibeResult;
  bool _posted = false;

  static const _moods = [
    {'key': 'hype', 'label': '🔥 Hype', 'color': BColor.text},
    {'key': 'chill', 'label': '🌊 Chill', 'color': BColor.green},
    {'key': 'deep', 'label': '🌙 Deep', 'color': BColor.green},
    {'key': 'funny', 'label': '😂 Funny', 'color': BColor.funny},
  ];

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  void _vibeCheck(AppState app) {
    if (_ctrl.text.trim().isEmpty) return;
    final result = app.vibeCheck(_ctrl.text);
    setState(() { _vibeResult = result; _vibeChecked = true; });
  }

  void _post(AppState app, AuthState auth) {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    final post = BPost(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}',
      userId: _isAnon ? 'anonymous' : (auth.user?.id ?? 'me'),
      text: text,
      mood: _mood,
      isAnonymous: _isAnon,
      isTimeCapsule: _isTimeCapsule,
      tags: _extractTags(text),
      vibeScore: _vibeResult?['score'] as int?,
      vibeLabel: _vibeResult?['label'] as String?,
      createdAt: DateTime.now().toIso8601String(),
    );
    app.addPost(post);
    setState(() { _posted = true; });
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() { _posted = false; _ctrl.clear(); _vibeResult = null; _vibeChecked = false; });
    });
  }

  List<String> _extractTags(String text) => RegExp(r'#\w+').allMatches(text).map((m) => m.group(0)!).toList();

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final auth = context.watch<AuthState>();
    final remaining = 280 - _ctrl.text.length;
    final user = auth.user;

    if (_posted) {
      return Scaffold(
        backgroundColor: BColor.bg,
        body: Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('✅', style: TextStyle(fontSize: 48)),
          const SizedBox(height: 16),
          Text(_isAnon ? 'Posted anonymously' : 'Posted!', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: BColor.text)),
          const SizedBox(height: 8),
          const Text('Your post is live on the feed.', style: TextStyle(fontSize: 14, color: BColor.muted)),
        ])),
      );
    }

    return Scaffold(
      backgroundColor: BColor.bg,
      appBar: AppBar(
        backgroundColor: BColor.bg,
        automaticallyImplyLeading: false,
        title: const Text('Create', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        actions: [
          if (_ctrl.text.isNotEmpty && !_vibeChecked)
            TextButton.icon(
              onPressed: () => _vibeCheck(app),
              icon: const Icon(Icons.psychology_outlined, size: 16),
              label: const Text('Vibe Check', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
              style: TextButton.styleFrom(foregroundColor: BColor.muted),
            ),
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _ctrl.text.trim().isEmpty ? null : () => _post(app, auth),
              style: FilledButton.styleFrom(
                backgroundColor: BColor.text, foregroundColor: BColor.bg,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                textStyle: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14),
              ),
              child: const Text('Post'),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Composer
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              BAvatar(name: _isAnon ? 'Anonymous' : (user?.name ?? 'Me'), size: 42, faceVerified: user?.faceVerified ?? false, isAnonymous: _isAnon),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(_isAnon ? '👻 Anonymous' : (user?.handle ?? '@you'), style: const TextStyle(fontWeight: FontWeight.w700, color: BColor.muted, fontSize: 13)),
                const SizedBox(height: 4),
                TextField(
                  controller: _ctrl,
                  maxLines: null,
                  maxLength: 280,
                  style: const TextStyle(color: BColor.text, fontSize: 17, height: 1.5),
                  decoration: const InputDecoration(
                    hintText: "What's happening in your world?",
                    hintStyle: TextStyle(color: BColor.muted, fontSize: 17, fontWeight: FontWeight.w400),
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                    counterText: '',
                  ),
                  onChanged: (_) => setState(() { _vibeChecked = false; _vibeResult = null; }),
                ),
              ])),
            ]),
          ),
          const BDivider(),

          // Mood selector
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 10),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Mood', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: BColor.muted, letterSpacing: 0.5)),
              const SizedBox(height: 10),
              Wrap(spacing: 8, children: _moods.map((m) {
                final selected = _mood == m['key'];
                final col = m['color'] as Color;
                return GestureDetector(
                  onTap: () => setState(() => _mood = m['key'] as String),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                    decoration: BoxDecoration(
                      color: selected ? col.withAlpha(38) : Colors.transparent,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: selected ? col : BColor.border, width: selected ? 1.5 : 1),
                    ),
                    child: Row(mainAxisSize: MainAxisSize.min, children: [
                      Container(width: 6, height: 6, margin: const EdgeInsets.only(right: 6), decoration: BoxDecoration(color: selected ? col : BColor.muted, shape: BoxShape.circle)),
                      Text(m['label'] as String, style: TextStyle(fontSize: 13, color: selected ? col : BColor.muted, fontWeight: selected ? FontWeight.w700 : FontWeight.w400)),
                    ]),
                  ),
                );
              }).toList()),
            ]),
          ),
          const BDivider(),

          // Anonymous toggle
          GestureDetector(
            onTap: () => setState(() => _isAnon = !_isAnon),
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isAnon ? BColor.green.withAlpha(20) : BColor.bg1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isAnon ? BColor.green.withAlpha(102) : BColor.border, width: _isAnon ? 1.5 : 1),
              ),
              child: Row(children: [
                const Text('👻', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Anonymous Post', style: TextStyle(fontWeight: FontWeight.w800, color: BColor.text, fontSize: 14)),
                  const Text('Your name & avatar are hidden. Only you know it was you.', style: TextStyle(fontSize: 12, color: BColor.muted, height: 1.4)),
                ])),
                _Toggle(value: _isAnon),
              ]),
            ),
          ),

          // Time capsule toggle
          GestureDetector(
            onTap: () => setState(() => _isTimeCapsule = !_isTimeCapsule),
            child: Container(
              margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: _isTimeCapsule ? BColor.green.withAlpha(20) : BColor.bg1,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _isTimeCapsule ? BColor.green.withAlpha(102) : BColor.border, width: _isTimeCapsule ? 1.5 : 1),
              ),
              child: Row(children: [
                const Text('⏳', style: TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Time Capsule', style: TextStyle(fontWeight: FontWeight.w800, color: BColor.text, fontSize: 14)),
                  const Text('Post unlocks in 24 hours · saved to local storage', style: TextStyle(fontSize: 12, color: BColor.muted, height: 1.4)),
                ])),
                _Toggle(value: _isTimeCapsule),
              ]),
            ),
          ),

          // Vibe check result
          if (_vibeResult != null) AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: BColor.bg1, borderRadius: BorderRadius.circular(14),
              border: Border.all(color: BColor.border),
            ),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Row(children: [
                Icon(Icons.psychology_outlined, color: BColor.text, size: 16),
                SizedBox(width: 8),
                Text('AI Vibe Check', style: TextStyle(fontWeight: FontWeight.w800, color: BColor.text, fontSize: 14)),
              ]),
              const SizedBox(height: 12),
              Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
                Text('${_vibeResult!['score']}', style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w900, color: BColor.text, letterSpacing: -3)),
                const SizedBox(width: 14),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('${_vibeResult!['label']}', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: BColor.text)),
                  const SizedBox(height: 2),
                  SizedBox(width: 200, child: Text('${_vibeResult!['desc']}', style: const TextStyle(fontSize: 13, color: BColor.muted, height: 1.4))),
                ]),
              ]),
            ]),
          ),

          // Character count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(children: [
              const Spacer(),
              Text('$remaining', style: TextStyle(
                fontSize: 13, fontWeight: FontWeight.w700,
                color: remaining < 20 ? (remaining < 0 ? BColor.danger : BColor.gold) : BColor.muted,
              )),
            ]),
          ),
        ]),
      ),
      // Bottom toolbar
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: const BoxDecoration(border: Border(top: BorderSide(color: BColor.border, width: 0.5))),
        child: Row(children: [
          _ToolbarBtn(icon: Icons.image_outlined, onTap: () {}),
          const SizedBox(width: 16),
          _ToolbarBtn(icon: Icons.videocam_outlined, onTap: () {}),
          const SizedBox(width: 16),
          _ToolbarBtn(icon: Icons.tag, onTap: () => _ctrl.text += ' #'),
          const SizedBox(width: 16),
          _ToolbarBtn(icon: Icons.alternate_email, onTap: () => _ctrl.text += ' @'),
          const Spacer(),
          if (_ctrl.text.isNotEmpty)
            SizedBox(
              width: 24, height: 24,
              child: CircularProgressIndicator(
                value: _ctrl.text.length / 280,
                strokeWidth: 2.5,
                backgroundColor: BColor.border,
                valueColor: AlwaysStoppedAnimation(_ctrl.text.length > 250 ? BColor.danger : BColor.text),
              ),
            ),
        ]),
      ),
    );
  }
}

class _Toggle extends StatelessWidget {
  final bool value;
  const _Toggle({required this.value});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: 44, height: 24,
    decoration: BoxDecoration(
      color: value ? BColor.text : BColor.bg2,
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: value ? BColor.text : BColor.border),
    ),
    child: AnimatedAlign(
      duration: const Duration(milliseconds: 200),
      alignment: value ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        width: 20, height: 20,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(
          color: value ? BColor.bg : BColor.muted,
          shape: BoxShape.circle,
        ),
      ),
    ),
  );
}

class _ToolbarBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _ToolbarBtn({required this.icon, required this.onTap});
  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Icon(icon, size: 22, color: BColor.muted),
  );
}
