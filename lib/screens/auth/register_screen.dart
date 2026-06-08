import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth_state.dart';
import '../../theme.dart';
import '../../widgets/bondly_logo.dart';
import '../../widgets/widgets.dart';
import '../../main.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  int _step = 1;
  bool _loading = false;
  String _error = '';

  // Step 1
  final _nameCtrl = TextEditingController();
  final _handleCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  // Step 2
  final _pwCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _showPw = false, _showConfirm = false;
  bool _agreedTerms = false;

  // Step 3
  final _bioCtrl = TextEditingController();
  String _role = 'Creator';
  final _locationCtrl = TextEditingController();
  final List<String> _tags = [];
  final _tagCtrl = TextEditingController();

  static const _roles = ['Creator', 'Artist', 'Photographer', 'Musician', 'Poet', 'Developer', 'Designer', 'Writer', 'Other'];

  @override
  void dispose() {
    for (final c in [_nameCtrl, _handleCtrl, _emailCtrl, _pwCtrl, _confirmCtrl, _bioCtrl, _locationCtrl, _tagCtrl]) {
      c.dispose();
    }
    super.dispose();
  }

  void _next() async {
    setState(() => _error = '');

    if (_step == 1) {
      if (_nameCtrl.text.trim().isEmpty) { setState(() => _error = 'Enter your display name'); return; }
      if (_handleCtrl.text.trim().isEmpty) { setState(() => _error = 'Choose a unique handle'); return; }
      if (!RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(_handleCtrl.text.replaceAll('@', ''))) { setState(() => _error = 'Handle: 3–20 chars, letters/numbers/underscores only'); return; }
      if (!RegExp(r'^[\w.+-]+@[\w-]+\.[a-zA-Z]{2,}$').hasMatch(_emailCtrl.text)) { setState(() => _error = 'Enter a valid email address'); return; }
      setState(() => _step = 2);
    } else if (_step == 2) {
      if (_pwCtrl.text.length < 8) { setState(() => _error = 'Password must be at least 8 characters'); return; }
      if (!RegExp(r'[A-Z]').hasMatch(_pwCtrl.text)) { setState(() => _error = 'Must contain at least one uppercase letter'); return; }
      if (!RegExp(r'[a-z]').hasMatch(_pwCtrl.text)) { setState(() => _error = 'Must contain at least one lowercase letter'); return; }
      if (!RegExp(r'[0-9]').hasMatch(_pwCtrl.text)) { setState(() => _error = 'Must contain at least one number'); return; }
      if (_pwCtrl.text != _confirmCtrl.text) { setState(() => _error = 'Passwords do not match'); return; }
      if (!_agreedTerms) { setState(() => _error = 'You must agree to the Terms & Privacy Policy'); return; }
      setState(() => _step = 3);
    } else {
      // Final submit
      setState(() => _loading = true);
      final result = await context.read<AuthState>().register(
        name: _nameCtrl.text, handle: _handleCtrl.text,
        email: _emailCtrl.text, password: _pwCtrl.text,
        confirmPassword: _confirmCtrl.text,
        bio: _bioCtrl.text, role: _role,
        location: _locationCtrl.text, tags: _tags,
      );
      if (!mounted) return;
      setState(() => _loading = false);
      if (result['ok'] == true) {
        Navigator.of(context).pushAndRemoveUntil(MaterialPageRoute(builder: (_) => const MainShell()), (_) => false);
      } else {
        setState(() => _error = result['error'] ?? 'Registration failed');
      }
    }
  }

  void _addTag(String tag) {
    final t = tag.startsWith('#') ? tag : '#$tag';
    if (t.length > 1 && !_tags.contains(t) && _tags.length < 5) {
      setState(() { _tags.add(t); _tagCtrl.clear(); });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: BColor.bg,
      body: SafeArea(
        child: Column(children: [
          // Progress header
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: Row(children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: BColor.text),
                onPressed: () => _step == 1 ? Navigator.pop(context) : setState(() { _step--; _error = ''; }),
              ),
              const SizedBox(width: 8),
              Expanded(child: Row(children: List.generate(3, (i) => Expanded(child: Container(
                height: 4, margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  color: i < _step ? BColor.text : BColor.bg2,
                  borderRadius: BorderRadius.circular(2),
                ),
              ))))),
              const SizedBox(width: 8),
              Text('$_step/3', style: const TextStyle(color: BColor.muted, fontSize: 12)),
            ]),
          ),
          Expanded(child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const SizedBox(height: 28),
              Text(_stepTitle(), style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: BColor.text, letterSpacing: -1)),
              const SizedBox(height: 6),
              Text(_stepSubtitle(), style: const TextStyle(fontSize: 15, color: BColor.muted)),
              const SizedBox(height: 32),

              if (_error.isNotEmpty) _ErrorBox(_error),

              if (_step == 1) _buildStep1(),
              if (_step == 2) _buildStep2(),
              if (_step == 3) _buildStep3(),

              const SizedBox(height: 28),
              SizedBox(width: double.infinity, child: FilledButton(
                onPressed: _loading ? null : _next,
                style: FilledButton.styleFrom(
                  backgroundColor: BColor.text, foregroundColor: BColor.bg,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
                child: _loading
                    ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: BColor.bg, strokeWidth: 2))
                    : Text(_step == 3 ? 'Create my account' : 'Continue'),
              )),
              if (_step == 1) ...[
                const SizedBox(height: 16),
                Center(child: GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Text.rich(TextSpan(text: 'Already have an account? ', style: TextStyle(color: BColor.muted, fontSize: 13), children: [TextSpan(text: 'Sign in', style: TextStyle(color: BColor.text, fontWeight: FontWeight.w700))])),
                )),
              ],
              const SizedBox(height: 32),
            ]),
          )),
        ]),
      ),
    );
  }

  Widget _buildStep1() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label('Display Name'),
    _Field(controller: _nameCtrl, hint: 'How others see you'),
    const SizedBox(height: 16),
    _Label('Handle'),
    TextField(
      controller: _handleCtrl,
      autocorrect: false,
      textCapitalization: TextCapitalization.none,
      style: const TextStyle(color: BColor.text, fontSize: 15),
      onChanged: (v) => setState(() {}),
      decoration: InputDecoration(
        hintText: 'your_handle',
        prefixText: '@',
        prefixStyle: const TextStyle(color: BColor.muted, fontSize: 15),
        suffixIcon: _handleCtrl.text.length >= 3 && RegExp(r'^[a-zA-Z0-9_]{3,20}$').hasMatch(_handleCtrl.text)
            ? const Icon(Icons.check_circle, color: BColor.green, size: 18) : null,
      ),
    ),
    const SizedBox(height: 16),
    _Label('Email'),
    _Field(controller: _emailCtrl, hint: 'you@example.com', keyboardType: TextInputType.emailAddress),
  ]);

  Widget _buildStep2() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label('Password'),
    _PasswordField(controller: _pwCtrl, show: _showPw, onToggle: () => setState(() => _showPw = !_showPw), hint: 'Create a strong password', onChange: (_) => setState(() {})),
    const SizedBox(height: 10),
    PasswordStrengthBar(password: _pwCtrl.text),
    const SizedBox(height: 8),
    // Requirements list
    ...[
      ('At least 8 characters', _pwCtrl.text.length >= 8),
      ('One uppercase letter (A–Z)', RegExp(r'[A-Z]').hasMatch(_pwCtrl.text)),
      ('One lowercase letter (a–z)', RegExp(r'[a-z]').hasMatch(_pwCtrl.text)),
      ('One number (0–9)', RegExp(r'[0-9]').hasMatch(_pwCtrl.text)),
    ].map((req) => _Requirement(req.$1, req.$2)),
    const SizedBox(height: 16),
    _Label('Confirm Password'),
    _PasswordField(controller: _confirmCtrl, show: _showConfirm, onToggle: () => setState(() => _showConfirm = !_showConfirm), hint: 'Repeat your password'),
    if (_confirmCtrl.text.isNotEmpty && _confirmCtrl.text != _pwCtrl.text)
      const Padding(padding: EdgeInsets.only(top: 4), child: Text('Passwords do not match', style: TextStyle(color: BColor.danger, fontSize: 12))),
    if (_confirmCtrl.text.isNotEmpty && _confirmCtrl.text == _pwCtrl.text)
      const Padding(padding: EdgeInsets.only(top: 4), child: Text('Passwords match ✓', style: TextStyle(color: BColor.green, fontSize: 12))),
    const SizedBox(height: 20),
    GestureDetector(
      onTap: () => setState(() => _agreedTerms = !_agreedTerms),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 20, height: 20, margin: const EdgeInsets.only(top: 2),
          decoration: BoxDecoration(
            color: _agreedTerms ? BColor.text : Colors.transparent,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: _agreedTerms ? BColor.text : BColor.border),
          ),
          child: _agreedTerms ? const Icon(Icons.check, color: BColor.bg, size: 14) : null,
        ),
        const SizedBox(width: 10),
        const Expanded(child: Text.rich(TextSpan(text: 'I agree to Bondly\'s ', style: TextStyle(color: BColor.muted, fontSize: 13), children: [
          TextSpan(text: 'Terms of Service', style: TextStyle(color: BColor.text, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
          TextSpan(text: ' and '),
          TextSpan(text: 'Privacy Policy', style: TextStyle(color: BColor.text, fontWeight: FontWeight.w700, decoration: TextDecoration.underline)),
        ]))),
      ]),
    ),
  ]);

  Widget _buildStep3() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    _Label('Bio (optional)'),
    TextField(
      controller: _bioCtrl,
      maxLines: 3,
      maxLength: 160,
      style: const TextStyle(color: BColor.text, fontSize: 15),
      decoration: const InputDecoration(hintText: 'Tell your story...', counterStyle: TextStyle(color: BColor.muted)),
    ),
    const SizedBox(height: 16),
    _Label('Role'),
    Wrap(spacing: 8, runSpacing: 8, children: _roles.map((r) => GestureDetector(
      onTap: () => setState(() => _role = r),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: _role == r ? BColor.text.withAlpha(25) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: _role == r ? BColor.text : BColor.border),
        ),
        child: Text(r, style: TextStyle(fontSize: 13, color: _role == r ? BColor.text : BColor.muted, fontWeight: _role == r ? FontWeight.w700 : FontWeight.w400)),
      ),
    )).toList()),
    const SizedBox(height: 16),
    _Label('Location (optional)'),
    _Field(controller: _locationCtrl, hint: 'City, Country'),
    const SizedBox(height: 16),
    _Label('Tags / Interests (up to 5)'),
    Row(children: [
      Expanded(child: TextField(
        controller: _tagCtrl,
        style: const TextStyle(color: BColor.text, fontSize: 14),
        textCapitalization: TextCapitalization.none,
        decoration: const InputDecoration(hintText: '#photography, #music...', prefixText: '#', prefixStyle: TextStyle(color: BColor.muted)),
        onSubmitted: _addTag,
      )),
      const SizedBox(width: 8),
      IconButton(icon: const Icon(Icons.add, color: BColor.text), onPressed: () => _addTag(_tagCtrl.text)),
    ]),
    if (_tags.isNotEmpty) Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Wrap(spacing: 8, runSpacing: 8, children: _tags.map((t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: BColor.bg2, borderRadius: BorderRadius.circular(16), border: Border.all(color: BColor.border)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(t, style: const TextStyle(color: BColor.text, fontSize: 12, fontWeight: FontWeight.w600)),
          const SizedBox(width: 6),
          GestureDetector(onTap: () => setState(() => _tags.remove(t)), child: const Icon(Icons.close, size: 12, color: BColor.muted)),
        ]),
      )).toList()),
    ),
  ]);

  String _stepTitle() => const ['Who are you?', 'Secure your account', 'Make it yours'][_step - 1];
  String _stepSubtitle() => const ['Create your Bondly identity.', 'Choose a strong password.', 'Personalise your profile (optional).'][_step - 1];
}

class _Requirement extends StatelessWidget {
  final String label;
  final bool met;
  const _Requirement(this.label, this.met);
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 2),
    child: Row(children: [
      Icon(met ? Icons.check_circle : Icons.radio_button_unchecked, size: 13, color: met ? BColor.green : BColor.border),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontSize: 12, color: met ? BColor.green : BColor.muted)),
    ]),
  );
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
  const _Field({required this.controller, required this.hint, this.keyboardType = TextInputType.text});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    keyboardType: keyboardType,
    autocorrect: false,
    style: const TextStyle(color: BColor.text, fontSize: 15),
    decoration: InputDecoration(hintText: hint),
  );
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final bool show;
  final VoidCallback onToggle;
  final String hint;
  final ValueChanged<String>? onChange;
  const _PasswordField({required this.controller, required this.show, required this.onToggle, required this.hint, this.onChange});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    obscureText: !show,
    onChanged: onChange,
    style: const TextStyle(color: BColor.text, fontSize: 15),
    decoration: InputDecoration(
      hintText: hint,
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
