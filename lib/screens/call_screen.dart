import 'package:flutter/material.dart';
import '../theme.dart';

class CallScreen extends StatefulWidget {
  final String name;
  final bool isVideo;
  const CallScreen({super.key, required this.name, required this.isVideo});
  @override
  State<CallScreen> createState() => _CallScreenState();
}

class _CallScreenState extends State<CallScreen> with TickerProviderStateMixin {
  bool _connected = false;
  bool _muted = false;
  bool _speakerOn = true;
  bool _cameraOn = true;
  bool _frontCamera = true;
  int _seconds = 0;
  late AnimationController _pulseCtrl;
  late Animation<double> _pulse;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _pulse = Tween<double>(begin: 0.95, end: 1.05).animate(CurvedAnimation(parent: _pulseCtrl, curve: Curves.easeInOut));
    // Simulate connecting
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _connected = true);
      _startTimer();
    });
  }

  void _startTimer() async {
    while (_connected && mounted) {
      await Future.delayed(const Duration(seconds: 1));
      if (mounted && _connected) setState(() => _seconds++);
    }
  }

  @override
  void dispose() { _pulseCtrl.dispose(); super.dispose(); }

  String get _timerStr {
    final m = _seconds ~/ 60;
    final s = _seconds % 60;
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A12),
      body: Stack(children: [
        // Background video (simulated)
        if (widget.isVideo && _connected && _cameraOn)
          Positioned.fill(child: Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF000000), Color(0xFF0D1A12), Color(0xFF000000)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
            ),
            child: const Center(child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(Icons.videocam_off_outlined, color: Colors.white24, size: 60),
              SizedBox(height: 12),
              Text('Camera preview', style: TextStyle(color: Colors.white24, fontSize: 14)),
            ])),
          ))
        else
          Positioned.fill(child: Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                colors: [Color(0xFF1C1C2E), Color(0xFF0A0A12)],
                center: Alignment.center, radius: 1.2,
              ),
            ),
          )),

        // Self-view (video mode)
        if (widget.isVideo) Positioned(
          top: 60, right: 20,
          child: Container(
            width: 100, height: 140,
            decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.white24)),
            child: _cameraOn
                ? const Center(child: Icon(Icons.person, color: Colors.white24, size: 40))
                : const Center(child: Icon(Icons.videocam_off, color: Colors.white24, size: 30)),
          ),
        ),

        SafeArea(child: Column(children: [
          // Top bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white, size: 28),
                onPressed: () => Navigator.pop(context),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.white.withAlpha(25), borderRadius: BorderRadius.circular(20)),
                child: Row(children: [
                  Container(width: 8, height: 8, decoration: BoxDecoration(color: _connected ? const Color(0xFF00BA7C) : Colors.orange, shape: BoxShape.circle)),
                  const SizedBox(width: 6),
                  Text(_connected ? 'Connected' : 'Connecting...', style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
                ]),
              ),
            ]),
          ),

          const Spacer(),

          // Caller info
          if (!widget.isVideo || !_connected) ...[
            ScaleTransition(
              scale: _connected ? const AlwaysStoppedAnimation(1) : _pulse,
              child: Container(
                width: 110, height: 110,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [BColor.green, BColor.text]),
                  shape: BoxShape.circle,
                  boxShadow: [BoxShadow(color: BColor.green.withAlpha(102), blurRadius: 30, spreadRadius: 5)],
                ),
                child: Center(child: Text(
                  widget.name.isNotEmpty ? widget.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 44, fontWeight: FontWeight.w900, color: Colors.white),
                )),
              ),
            ),
            const SizedBox(height: 20),
          ],

          Text(widget.name, style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.white, letterSpacing: -0.5)),
          const SizedBox(height: 8),
          Text(
            _connected ? _timerStr : 'Calling...',
            style: TextStyle(fontSize: 16, color: _connected ? const Color(0xFF00BA7C) : Colors.white54, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(color: Colors.white.withAlpha(20), borderRadius: BorderRadius.circular(20)),
            child: Text(widget.isVideo ? '📹 Video call' : '🎙️ Voice call', style: const TextStyle(color: Colors.white60, fontSize: 12)),
          ),

          const Spacer(),

          // Controls
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
            child: Column(children: [
              // Secondary controls
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                if (widget.isVideo) _CtrlBtn(icon: _frontCamera ? Icons.flip_camera_ios_outlined : Icons.flip_camera_ios, label: 'Flip', onTap: () => setState(() => _frontCamera = !_frontCamera)),
                _CtrlBtn(icon: _speakerOn ? Icons.volume_up_outlined : Icons.volume_off_outlined, label: 'Speaker', onTap: () => setState(() => _speakerOn = !_speakerOn), active: _speakerOn),
                if (widget.isVideo) _CtrlBtn(icon: _cameraOn ? Icons.videocam_outlined : Icons.videocam_off_outlined, label: 'Camera', onTap: () => setState(() => _cameraOn = !_cameraOn), active: _cameraOn),
                _CtrlBtn(icon: Icons.chat_outlined, label: 'Chat', onTap: () => Navigator.pop(context)),
              ]),
              const SizedBox(height: 30),
              // Primary controls
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                _CtrlBtn(
                  icon: _muted ? Icons.mic_off : Icons.mic_outlined,
                  label: _muted ? 'Unmute' : 'Mute',
                  onTap: () => setState(() => _muted = !_muted),
                  size: 58,
                  active: !_muted,
                ),
                // End call (big red)
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 72, height: 72,
                    decoration: BoxDecoration(color: BColor.danger, shape: BoxShape.circle, boxShadow: [BoxShadow(color: BColor.danger.withAlpha(102), blurRadius: 20)]),
                    child: const Center(child: Icon(Icons.call_end_rounded, color: Colors.white, size: 30)),
                  ),
                ),
                _CtrlBtn(
                  icon: Icons.person_add_outlined,
                  label: 'Add',
                  onTap: () {},
                  size: 58,
                ),
              ]),
            ]),
          ),
        ])),
      ]),
    );
  }
}

class _CtrlBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double size;
  final bool active;
  const _CtrlBtn({required this.icon, required this.label, required this.onTap, this.size = 52, this.active = true});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Column(children: [
      Container(
        width: size, height: size,
        decoration: BoxDecoration(
          color: active ? Colors.white.withAlpha(30) : Colors.white.withAlpha(10),
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white.withAlpha(active ? 51 : 20)),
        ),
        child: Center(child: Icon(icon, color: active ? Colors.white : Colors.white38, size: size * 0.42)),
      ),
      const SizedBox(height: 6),
      Text(label, style: TextStyle(color: active ? Colors.white60 : Colors.white24, fontSize: 11)),
    ]),
  );
}
