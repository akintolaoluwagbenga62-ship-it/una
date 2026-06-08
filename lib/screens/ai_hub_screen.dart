import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

class AiHubScreen extends StatefulWidget {
  const AiHubScreen({super.key});
  @override
  State<AiHubScreen> createState() => _AiHubScreenState();
}

class _AiHubScreenState extends State<AiHubScreen> {
  final _ctrl = TextEditingController();
  String? _activeFeature;
  String? _result;
  bool _loading = false;
  final List<Map<String, String>> _chat = [];

  static const _features = [
    {'id': 'vibe', 'icon': '🎯', 'title': 'Vibe Check', 'desc': 'AI analyses your post before you share it.'},
    {'id': 'caption', 'icon': '✍️', 'title': 'Caption Writer', 'desc': 'Generate captions from a vibe description.'},
    {'id': 'mood', 'icon': '🌙', 'title': 'Mood Compass', 'desc': 'Discover what mood your words are giving.'},
    {'id': 'safe', 'icon': '🛡️', 'title': 'Safe Space AI', 'desc': 'AI moderates group chats for your safety.'},
    {'id': 'ghost', 'icon': '👻', 'title': 'Ghost Advisor', 'desc': 'AI helps you browse without leaving a trail.'},
    {'id': 'capsule', 'icon': '⏳', 'title': 'Capsule Predictor', 'desc': 'AI guesses the best time to release your capsule.'},
    {'id': 'chat', 'icon': '🤖', 'title': 'AI Chat', 'desc': 'Chat with Bondly AI — ask anything.'},
  ];

  static const _captionPool = [
    'real ones know the silence speaks louder.',
    'not every thought needs an audience.',
    'capturing the in-between.',
    'this moment existed. that\'s enough.',
    'the city never asked to be beautiful. it just is.',
    'somewhere between noise and nothing.',
  ];

  static const _moodResults = {
    'hype': {'label': 'High Energy', 'desc': 'Your words carry electric frequency. People will feel it.', 'color': 'hype'},
    'chill': {'label': 'Relaxed Clarity', 'desc': 'Clear and calm. Like a thought that finally settled.', 'color': 'chill'},
    'deep': {'label': 'Depth Mode', 'desc': "You're thinking in layers. This resonates with the quiet ones.", 'color': 'deep'},
    'funny': {'label': 'Levity', 'desc': "You're lightening the room. Keep it.", 'color': 'funny'},
    'raw': {'label': 'Vulnerable', 'desc': 'Real and unfiltered. This is the rarest kind of content.', 'color': 'chill'},
  };

  static const _aiReplies = {
    'ghost': ['Ghost mode gives you 30 minutes of invisible browsing — no traces left in feed algorithms.', 'When Ghost Mode is on, your views and interactions are hidden from creators.'],
    'safe': ['Bondly AI monitors for harmful language and sends gentle reminders to keep spaces kind.', 'Our safe space detection flags distress signals and connects users with resources.'],
    'capsule': ['Best time to release: schedule for 7am local time — engagement peaks in the morning window.', 'Your capsule vibes match peak evening engagement (8–10pm). Consider timing it there.'],
  };

  void _run(AppState app) async {
    final text = _ctrl.text.trim();
    setState(() { _loading = true; _result = null; });
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final rng = Random();

    if (_activeFeature == 'chat') {
      setState(() {
        _chat.add({'role': 'user', 'text': text});
        _loading = false;
        _ctrl.clear();
      });
      await Future.delayed(const Duration(milliseconds: 600));
      final reply = _generateChatReply(text, app);
      setState(() => _chat.add({'role': 'ai', 'text': reply}));
      return;
    }

    String result;
    if (_activeFeature == 'vibe') {
      final r = app.vibeCheck(text);
      result = '${r['score']}/100 — ${r['label']}\n\n${r['desc']}';
    } else if (_activeFeature == 'caption') {
      result = _captionPool[rng.nextInt(_captionPool.length)];
    } else if (_activeFeature == 'mood') {
      final moods = _moodResults.keys.toList();
      final key = moods[rng.nextInt(moods.length)];
      final m = _moodResults[key]!;
      result = '${m['label']}\n\n${m['desc']}';
    } else if (_activeFeature == 'ghost') {
      result = _aiReplies['ghost']![rng.nextInt(2)];
    } else if (_activeFeature == 'safe') {
      result = _aiReplies['safe']![rng.nextInt(2)];
    } else if (_activeFeature == 'capsule') {
      result = _aiReplies['capsule']![rng.nextInt(2)];
    } else {
      result = 'Try typing something and I\'ll analyse it for you.';
    }

    setState(() { _result = result; _loading = false; });
  }

  String _generateChatReply(String text, AppState app) {
    final lower = text.toLowerCase();
    if (RegExp(r'hi|hello|hey|sup').hasMatch(lower)) return "Hey! I'm Bondly AI 🤖 I can help with vibe checks, caption ideas, mood analysis, and more. What's on your mind?";
    if (RegExp(r'ghost|anonymous|invisible').hasMatch(lower)) return "Ghost Mode makes you invisible for 30 minutes — your views, likes, and profile visits won't show up for anyone. It's perfect for browsing without leaving a trail. 👻";
    if (RegExp(r'vibe|energy|mood').hasMatch(lower)) return "Your vibe matters. Every word you post carries frequency — ${['chill', 'deep', 'hype', 'raw'][Random().nextInt(4)]} vibes tend to get the most real engagement on Bondly.";
    if (RegExp(r'sad|anxious|lonely|stress|mental').hasMatch(lower)) return "You're not alone in feeling that. Bondly has Safe Space groups where you can share anonymously, no judgment. Want me to point you there? 💙";
    if (RegExp(r'caption|write|post idea|what to post').hasMatch(lower)) return "Here's a caption idea: \"${_captionPool[Random().nextInt(_captionPool.length)]}\"";
    if (RegExp(r'time capsule|capsule|schedule').hasMatch(lower)) return "Time capsules are posts that unlock after 24 hours — perfect for thoughts you want to marinate first. ⏳ The best release time is usually 7–9am your local time.";
    return "Interesting. Bondly AI is still learning — but my take: ${['be real, be raw, be you.', 'your authentic voice is your superpower.', 'the quiet ones are usually the most interesting.', 'post it. the algorithm rewards consistency.'][Random().nextInt(4)]} 🤖";
  }

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    return Scaffold(
      backgroundColor: BColor.bg,
      appBar: AppBar(
        backgroundColor: BColor.bg,
        leading: _activeFeature != null
            ? IconButton(icon: const Icon(Icons.arrow_back, color: BColor.text), onPressed: () => setState(() { _activeFeature = null; _result = null; _chat.clear(); _ctrl.clear(); }))
            : null,
        automaticallyImplyLeading: false,
        title: Text(_activeFeature != null ? (_features.firstWhere((f) => f['id'] == _activeFeature)['title'] ?? 'AI Hub') : 'AI Hub', style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
      ),
      body: _activeFeature == null ? _buildGrid(context) : _activeFeature == 'chat' ? _buildChat(app) : _buildFeature(app),
    );
  }

  Widget _buildGrid(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.all(16),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('Bondly AI Tools', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: BColor.text)),
      const SizedBox(height: 4),
      const Text('AI-powered tools to help you create authentically.', style: TextStyle(fontSize: 14, color: BColor.muted)),
      const SizedBox(height: 20),
      GridView.count(
        shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 1.2,
        children: _features.map((f) => GestureDetector(
          onTap: () => setState(() => _activeFeature = f['id']),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: BColor.bg1, borderRadius: BorderRadius.circular(14), border: Border.all(color: BColor.border)),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(f['icon']!, style: const TextStyle(fontSize: 28)),
              const Spacer(),
              Text(f['title']!, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: BColor.text)),
              const SizedBox(height: 4),
              Text(f['desc']!, style: const TextStyle(fontSize: 11, color: BColor.muted, height: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
            ]),
          ),
        )).toList(),
      ),
    ]),
  );

  Widget _buildFeature(AppState app) => Column(children: [
    Expanded(child: SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(_features.firstWhere((f) => f['id'] == _activeFeature)['desc']!, style: const TextStyle(fontSize: 14, color: BColor.muted)),
        const SizedBox(height: 20),
        if (_result != null) Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: BColor.bg1, borderRadius: BorderRadius.circular(14), border: Border.all(color: BColor.border)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Row(children: [Text('🤖 ', style: TextStyle(fontSize: 16)), Text('Result', style: TextStyle(fontWeight: FontWeight.w800, color: BColor.text))]),
            const SizedBox(height: 10),
            Text(_result!, style: const TextStyle(fontSize: 15, color: BColor.text, height: 1.5)),
          ]),
        ),
      ]),
    )),
    Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: BColor.border, width: 0.5))),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _ctrl,
          style: const TextStyle(color: BColor.text, fontSize: 14),
          decoration: InputDecoration(hintText: 'Type something to analyse...', filled: true, fillColor: BColor.bg2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _ctrl.text.trim().isEmpty || _loading ? null : () => _run(app),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _loading ? BColor.bg2 : BColor.text, shape: BoxShape.circle),
            child: _loading ? const Center(child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: BColor.muted, strokeWidth: 2))) : const Center(child: Icon(Icons.send_rounded, color: BColor.bg, size: 18)),
          ),
        ),
      ]),
    ),
  ]);

  Widget _buildChat(AppState app) => Column(children: [
    Expanded(child: _chat.isEmpty
        ? const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('🤖', style: TextStyle(fontSize: 48)),
            SizedBox(height: 12),
            Text('Ask Bondly AI anything', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: BColor.text)),
            SizedBox(height: 6),
            Text('Mood advice, caption ideas, ghost mode tips, and more.', style: TextStyle(color: BColor.muted, fontSize: 14), textAlign: TextAlign.center),
          ]))
        : ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            itemCount: _chat.length,
            itemBuilder: (ctx, i) {
              final m = _chat[i];
              final isMe = m['role'] == 'user';
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Row(
                  mainAxisAlignment: isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isMe) Container(width: 32, height: 32, margin: const EdgeInsets.only(right: 8), decoration: BoxDecoration(color: BColor.green.withAlpha(51), shape: BoxShape.circle), child: const Center(child: Text('🤖', style: TextStyle(fontSize: 16)))),
                    Flexible(child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                      decoration: BoxDecoration(
                        color: isMe ? BColor.text : BColor.bg1,
                        borderRadius: BorderRadius.only(topLeft: const Radius.circular(16), topRight: const Radius.circular(16), bottomLeft: Radius.circular(isMe ? 16 : 4), bottomRight: Radius.circular(isMe ? 4 : 16)),
                        border: isMe ? null : Border.all(color: BColor.border),
                      ),
                      child: Text(m['text']!, style: TextStyle(fontSize: 14, color: isMe ? BColor.bg : BColor.text, height: 1.5)),
                    )),
                  ],
                ),
              );
            },
          )),
    Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
      decoration: const BoxDecoration(border: Border(top: BorderSide(color: BColor.border, width: 0.5))),
      child: Row(children: [
        Expanded(child: TextField(
          controller: _ctrl,
          style: const TextStyle(color: BColor.text, fontSize: 14),
          decoration: InputDecoration(hintText: 'Ask Bondly AI...', filled: true, fillColor: BColor.bg2, border: OutlineInputBorder(borderRadius: BorderRadius.circular(20), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12)),
          onChanged: (_) => setState(() {}),
        )),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _ctrl.text.trim().isEmpty || _loading ? null : () => _run(app),
          child: Container(
            width: 44, height: 44,
            decoration: BoxDecoration(color: _ctrl.text.trim().isEmpty ? BColor.bg2 : BColor.text, shape: BoxShape.circle),
            child: Center(child: Icon(Icons.send_rounded, color: _ctrl.text.trim().isEmpty ? BColor.muted : BColor.bg, size: 18)),
          ),
        ),
      ]),
    ),
  ]);
}
