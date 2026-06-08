import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_state.dart';
import '../../theme.dart';
import '../../widgets/bondly_logo.dart';
import '../../main.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _pwCtrl = TextEditingController();
  bool _showPw = false, _loading = false;
  String _error = '';

  @override
  void dispose() { _emailCtrl.dispose(); _pwCtrl.dispose(); super.dispose(); }

  Future<void> _submit() async {
    setState(() { _loading = true; _error = ''; });
    final result = await context.read<AuthState>().login(_emailCtrl.text, _pwCtrl.text);
    if (!mounted) return;
    setState(() => _loading = false);
    if (result['ok'] == true) {
      Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
    } else {
      setState(() => _error = result['error'] ?? 'Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColor.bg,
      appBar: AppBar(
        backgroundColor: BColor.bg,
        leading: IconButton(icon: const Icon(Icons.arrow_back, color: BColor.text), onPressed: () => Navigator.pop(context)),
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const SizedBox(height: 8),
            const BondlyLogo(size: 36),
            const SizedBox(height: 28),
            const Text('Welcome back.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: BColor.text, letterSpacing: -1)),
            const SizedBox(height: 6),
            const Text('Sign in to continue.', style: TextStyle(fontSize: 15, color: BColor.muted)),
            const SizedBox(height: 36),

            if (_error.isNotEmpty) _ErrorBox(_error),

            _Label('Email or handle'),
            _Field(controller: _emailCtrl, hint: 'you@email.com or @handle', keyboardType: TextInputType.emailAddress, autoCapitalize: false),
            const SizedBox(height: 16),

            _Label('Password'),
            _PasswordField(controller: _pwCtrl, show: _showPw, onToggle: () => setState(() => _showPw = !_showPw)),
            const SizedBox(height: 8),

            Align(alignment: Alignment.centerRight, child: TextButton(
              onPressed: () {},
              child: const Text('Forgot password?', style: TextStyle(color: BColor.muted, fontSize: 13)),
            )),
            const SizedBox(height: 24),

            SizedBox(width: double.infinity, child: FilledButton(
              onPressed: _loading ? null : _submit,
              style: FilledButton.styleFrom(
                backgroundColor: BColor.text, foregroundColor: BColor.bg,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
              child: _loading ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: BColor.bg, strokeWidth: 2)) : const Text('Sign in'),
            )),
          ]),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  const _Label(this.text);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: BColor.muted)),
  );
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final TextInputType keyboardType;
  final bool autoCapitalize;
  const _Field({required this.controller, required this.hint, this.keyboardType = TextInputType.text, this.autoCapitalize = true});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    autocorrect: false,
    textCapitalization: autoCapitalize ? TextCapitalization.words : TextCapitalization.none,
    style: const TextStyle(color: BColor.text, fontSize: 15),
    decoration: InputDecoration(hintText: hint),
  );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool show;
  final VoidCallback onToggle;
  const _PasswordField({required this.controller, required this.show, required this.onToggle});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: !show,
    style: const TextStyle(color: BColor.text, fontSize: 15),
    decoration: InputDecoration(
      hintText: 'Your password',
      suffixIcon: IconButton(icon: Icon(show ? Icons.visibility_off : Icons.visibility, color: BColor.muted, size: 20), onPressed: onToggle),
    ),
  );
}

class _ErrorBox extends StatelessWidget {
  final String msg;
  const _ErrorBox(this.msg);
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(color: BColor.danger.withAlpha(25), borderRadius: BorderRadius.circular(10), border: Border.all(color: BColor.danger.withAlpha(102))),
    child: Row(children: [
      const Icon(Icons.error_outline, color: BColor.danger, size: 16),
      const SizedBox(width: 8),
      Expanded(child: Text(msg, style: const TextStyle(color: BColor.danger, fontSize: 13))),
    ]),
  );
}
