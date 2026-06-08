import 'package:flutter/material.dart';
import '../../theme.dart';
import '../../widgets/bondly_logo.dart';
import 'login_screen.dart';
import 'register_screen.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColor.bg,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 28),
          child: Column(children: [
            const Spacer(flex: 2),
            // Logo
            const BondlyLogo(size: 72, showText: true),
            const SizedBox(height: 24),
            const Text(
              'Real connection,\nno performance.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: BColor.text, letterSpacing: -1, height: 1.2),
            ),
            const SizedBox(height: 12),
            const Text(
              'Ghost mode. Mood filters. Anonymous posts.\nA social app built for Gen Z authenticity.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 15, color: BColor.muted, height: 1.5),
            ),
            const Spacer(flex: 2),

            // Feature pills
            Wrap(spacing: 8, runSpacing: 8, alignment: WrapAlignment.center, children: const [
              _FeaturePill('👻 Ghost Mode'),
              _FeaturePill('🌙 Mood Feed'),
              _FeaturePill('🎙️ Voice Notes'),
              _FeaturePill('📹 Video Calls'),
              _FeaturePill('🔒 Anonymous Posts'),
              _FeaturePill('🤖 AI Vibe Check'),
            ]),
            const SizedBox(height: 40),

            // Actions
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen())),
                style: FilledButton.styleFrom(
                  backgroundColor: BColor.text,
                  foregroundColor: BColor.bg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                child: const Text('Create account'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const LoginScreen())),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: BColor.border),
                  foregroundColor: BColor.text,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                child: const Text('Sign in'),
              ),
            ),
            const SizedBox(height: 20),
            const Text('By joining, you agree to our Terms & Privacy Policy.', style: TextStyle(fontSize: 11, color: BColor.muted), textAlign: TextAlign.center),
            const SizedBox(height: 8),
          ]),
        ),
      ),
    );
  }
}

class _FeaturePill extends StatelessWidget {
  final String label;
  const _FeaturePill(this.label);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(20), border: Border.all(color: BColor.border)),
    child: Text(label, style: const TextStyle(fontSize: 12, color: BColor.textSub, fontWeight: FontWeight.w600)),
  );
}
