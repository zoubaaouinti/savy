import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../models/profile_models.dart';

class EditProfileScreen extends StatefulWidget {
  final UserProfile profile;
  const EditProfileScreen({super.key, required this.profile});
  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  File? _localPhoto;
  Uint8List? _photoBytes;
  late Gender _selectedGender;
  DateTime? _selectedBirthDate;
  final ImagePicker _picker = ImagePicker();
  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _nameCtrl  = TextEditingController(text: widget.profile.name);
    _emailCtrl = TextEditingController(text: widget.profile.email);
    _selectedGender    = widget.profile.gender;
    _selectedBirthDate = widget.profile.birthDate;
    _bgController = AnimationController(vsync: this, duration: const Duration(seconds: 7))..repeat(reverse: true);
    _bgAnim = CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
    _loadPhoto();
  }

  @override
  void dispose() {
    _bgController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  String get _initials {
    final parts = _nameCtrl.text.trim().split(' ');
    if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  Future<void> _loadPhoto() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (doc.exists && doc.data()?['photoBase64'] != null) {
        final bytes = base64Decode(doc.data()!['photoBase64']);
        if (mounted) setState(() => _photoBytes = Uint8List.fromList(bytes));
      }
    } catch (_) {}
  }

  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1535),
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: const Color(0xFF1A2E52), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              const Text('Photo de profil', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 20),
              _photoOption(Icons.photo_library_rounded, 'Choisir depuis la galerie', const Color(0xFF3EFFA8), () { Navigator.pop(context); _pickImage(ImageSource.gallery); }),
              const SizedBox(height: 12),
              _photoOption(Icons.camera_alt_rounded, 'Prendre une photo', const Color(0xFF00D4FF), () { Navigator.pop(context); _pickImage(ImageSource.camera); }),
              if (_photoBytes != null || _localPhoto != null) ...[
                const SizedBox(height: 12),
                _photoOption(Icons.delete_outline_rounded, 'Supprimer la photo', const Color(0xFFFF5C7A), () { Navigator.pop(context); setState(() { _localPhoto = null; _photoBytes = null; }); }),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoOption(IconData icon, String label, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), color: color.withOpacity(0.07), border: Border.all(color: color.withOpacity(0.3))),
        child: Row(children: [
          Container(width: 38, height: 38, decoration: BoxDecoration(shape: BoxShape.circle, color: color.withOpacity(0.12)), child: Icon(icon, color: color, size: 20)),
          const SizedBox(width: 14),
          Text(label, style: TextStyle(color: color, fontSize: 14, fontWeight: FontWeight.w600)),
        ]),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    PermissionStatus status = source == ImageSource.camera ? await Permission.camera.request() : await Permission.photos.request();
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() => _errorMessage = 'Permission refusée');
      if (status.isPermanentlyDenied) await openAppSettings();
      return;
    }
    try {
      final XFile? picked = await _picker.pickImage(source: source, maxWidth: 512, maxHeight: 512, imageQuality: 85);
      if (picked != null) setState(() { _localPhoto = File(picked.path); _errorMessage = null; });
    } catch (e) {
      setState(() => _errorMessage = "Impossible d'accéder à la source");
    }
  }

  Future<void> _pickBirthDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now().subtract(const Duration(days: 365 * 13)),
      builder: (context, child) => Theme(
        data: Theme.of(context).copyWith(colorScheme: const ColorScheme.dark(
            primary: Color(0xFF3EFFA8), onPrimary: Color(0xFF060D1F),
            surface: Color(0xFF0B1535), onSurface: Colors.white),
            dialogBackgroundColor: const Color(0xFF0B1535)),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedBirthDate = picked);
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() { _isLoading = true; _errorMessage = null; _successMessage = null; });
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      String? base64Photo;
      if (_localPhoto != null) {
        final bytes = await _localPhoto!.readAsBytes();
        base64Photo = base64Encode(bytes);
      }
      if (_nameCtrl.text.trim() != widget.profile.name) await user.updateDisplayName(_nameCtrl.text.trim());
      if (_emailCtrl.text.trim() != widget.profile.email) {
        await user.verifyBeforeUpdateEmail(_emailCtrl.text.trim());
        setState(() => _successMessage = 'Email de vérification envoyé à ${_emailCtrl.text}');
      }
      final updatedProfile = widget.profile.copyWith(
        name: _nameCtrl.text.trim(), email: _emailCtrl.text.trim(),
        gender: _selectedGender, birthDate: _selectedBirthDate,
        photoBase64: base64Photo ?? widget.profile.photoBase64,
      );
      await FirebaseFirestore.instance.collection('users').doc(user.uid).set(updatedProfile.toMap(), SetOptions(merge: true));
      if (base64Photo != null) setState(() => _photoBytes = base64Decode(base64Photo!));
      if (!mounted) return;
      setState(() { _isLoading = false; _successMessage ??= 'Profil mis à jour ✓'; });
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.of(context).pop(updatedProfile);
    } on FirebaseAuthException catch (e) {
      setState(() { _isLoading = false; _errorMessage = _mapError(e.code); });
    } catch (e) {
      setState(() { _isLoading = false; _errorMessage = "Une erreur s'est produite"; });
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'email-already-in-use': return 'Cet email est déjà utilisé';
      case 'requires-recent-login': return 'Reconnectez-vous et réessayez';
      default: return 'Erreur ($code)';
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final hPad = size.shortestSide > 600 ? size.width * 0.2 : 20.0;
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      body: Stack(
        children: [
          AnimatedBuilder(animation: _bgAnim, builder: (_, __) => CustomPaint(size: size, painter: _BgPainter(_bgAnim.value))),
          CustomPaint(size: size, painter: _GridPainter()),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          _buildAvatar(),
                          const SizedBox(height: 32),
                          _sectionTitle('Informations personnelles'),
                          const SizedBox(height: 12),
                          _card([
                            _field(label: 'Nom complet', controller: _nameCtrl, icon: Icons.person_outline_rounded,
                                validator: (v) => (v == null || v.trim().isEmpty) ? 'Nom requis' : null),
                            const SizedBox(height: 16),
                            _field(label: 'Adresse email', controller: _emailCtrl, icon: Icons.alternate_email_rounded,
                                keyboardType: TextInputType.emailAddress,
                                validator: (v) {
                                  if (v == null || v.isEmpty) return 'Email requis';
                                  if (!RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) return 'Email invalide';
                                  return null;
                                }),
                          ]),
                          const SizedBox(height: 20),
                          _sectionTitle('Informations complémentaires'),
                          const SizedBox(height: 12),
                          _card([
                            _fieldLabel('Genre'),
                            const SizedBox(height: 8),
                            _buildGenderSelector(),
                            const SizedBox(height: 16),
                            _fieldLabel('Date de naissance'),
                            const SizedBox(height: 8),
                            _buildBirthDatePicker(),
                          ]),
                          const SizedBox(height: 20),
                          if (_errorMessage != null) _alertWidget(_errorMessage!, isError: true),
                          if (_successMessage != null) _alertWidget(_successMessage!, isError: false),
                          const SizedBox(height: 8),
                          _buildSaveButton(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
    child: Row(children: [
      GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: Container(width: 40, height: 40,
            decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), border: Border.all(color: const Color(0xFF1A2E52)), color: const Color(0xFF0D1B38)),
            child: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF8BA8D4), size: 16)),
      ),
      const SizedBox(width: 16),
      ShaderMask(
        shaderCallback: (b) => const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]).createShader(b),
        child: const Text('Modifier le profil', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      ),
    ]),
  );

  Widget _buildAvatar() => GestureDetector(
    onTap: _showPhotoOptions,
    child: AnimatedBuilder(
      animation: _nameCtrl,
      builder: (_, __) => Stack(alignment: Alignment.center, children: [
        Container(width: 100, height: 100, decoration: BoxDecoration(shape: BoxShape.circle, boxShadow: [BoxShadow(color: const Color(0xFF3EFFA8).withOpacity(0.2), blurRadius: 30, spreadRadius: 5)])),
        Container(width: 90, height: 90,
            decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)])),
            child: ClipOval(
              child: _localPhoto != null ? Image.file(_localPhoto!, fit: BoxFit.cover, width: 90, height: 90)
                  : _photoBytes != null ? Image.memory(_photoBytes!, fit: BoxFit.cover, width: 90, height: 90)
                  : Center(child: Text(_initials, style: const TextStyle(color: Color(0xFF060D1F), fontSize: 28, fontWeight: FontWeight.w800))),
            )),
        Positioned(bottom: 0, right: 0,
            child: Container(width: 28, height: 28,
                decoration: BoxDecoration(shape: BoxShape.circle, color: const Color(0xFF0D1B38), border: Border.all(color: const Color(0xFF3EFFA8).withOpacity(0.5), width: 1.5)),
                child: const Icon(Icons.camera_alt_rounded, color: Color(0xFF3EFFA8), size: 14))),
      ]),
    ),
  );

  Widget _buildGenderSelector() {
    final genders = [Gender.male, Gender.female, Gender.other, Gender.notSpecified];
    return Wrap(
      spacing: 8, runSpacing: 8,
      children: genders.map((g) {
        final isSelected = _selectedGender == g;
        return GestureDetector(
          onTap: () => setState(() => _selectedGender = g),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              color: isSelected ? const Color(0xFF3EFFA8).withOpacity(0.12) : const Color(0xFF0D1B38),
              border: Border.all(color: isSelected ? const Color(0xFF3EFFA8) : const Color(0xFF1A2E52)),
            ),
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              if (isSelected) ...[const Icon(Icons.check_rounded, color: Color(0xFF3EFFA8), size: 14), const SizedBox(width: 4)],
              Text(g.label, style: TextStyle(color: isSelected ? const Color(0xFF3EFFA8) : const Color(0xFF6B8CAE), fontSize: 13, fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400)),
            ]),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBirthDatePicker() {
    final hasDate = _selectedBirthDate != null;
    return GestureDetector(
      onTap: _pickBirthDate,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: const Color(0xFF0D1B38), border: Border.all(color: const Color(0xFF1A2E52))),
        child: Row(children: [
          const Icon(Icons.cake_rounded, color: Color(0xFF3EFFA8), size: 20),
          const SizedBox(width: 12),
          Expanded(child: Text(
            hasDate ? '${_selectedBirthDate!.day.toString().padLeft(2, '0')}/${_selectedBirthDate!.month.toString().padLeft(2, '0')}/${_selectedBirthDate!.year}' : 'Sélectionner votre date de naissance',
            style: TextStyle(color: hasDate ? Colors.white : const Color(0xFF3A5068), fontSize: 14),
          )),
          if (hasDate) ...[
            Text('${_calcAge(_selectedBirthDate!)} ans', style: const TextStyle(color: Color(0xFF3EFFA8), fontSize: 12)),
            const SizedBox(width: 8),
          ],
          const Icon(Icons.arrow_forward_ios_rounded, color: Color(0xFF3A5070), size: 13),
        ]),
      ),
    );
  }

  int _calcAge(DateTime birth) {
    final today = DateTime.now();
    int age = today.year - birth.year;
    if (today.month < birth.month || (today.month == birth.month && today.day < birth.day)) age--;
    return age;
  }

  Widget _sectionTitle(String title) => Align(
    alignment: Alignment.centerLeft,
    child: Text(title.toUpperCase(), style: const TextStyle(color: Color(0xFF3A5070), fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 1.2)),
  );

  Widget _card(List<Widget> children) => Container(
    width: double.infinity, padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(borderRadius: BorderRadius.circular(20), color: const Color(0xFF0B1535), border: Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: children),
  );

  Widget _fieldLabel(String label) => Text(label, style: const TextStyle(color: Color(0xFF8BA8D4), fontSize: 12, fontWeight: FontWeight.w500));

  Widget _field({required String label, required TextEditingController controller, required IconData icon, bool obscure = false, TextInputType? keyboardType, String? Function(String?)? validator}) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _fieldLabel(label),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller, obscureText: obscure, keyboardType: keyboardType, validator: validator,
        style: const TextStyle(color: Colors.white, fontSize: 14),
        decoration: InputDecoration(
          hintText: label, hintStyle: const TextStyle(color: Color(0xFF3A5068), fontSize: 14),
          prefixIcon: Icon(icon, color: const Color(0xFF3EFFA8), size: 18),
          filled: true, fillColor: const Color(0xFF0D1B38),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A2E52))),
          enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF1A2E52))),
          focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFF3EFFA8), width: 1.5)),
          errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF5C7A))),
          focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: Color(0xFFFF5C7A), width: 1.5)),
          errorStyle: const TextStyle(color: Color(0xFFFF5C7A), fontSize: 11),
        ),
      ),
    ]);
  }

  Widget _alertWidget(String msg, {required bool isError}) {
    final color = isError ? const Color(0xFFFF5C7A) : const Color(0xFF3EFFA8);
    return Container(
      width: double.infinity, padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12), margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(borderRadius: BorderRadius.circular(12), color: color.withOpacity(0.08), border: Border.all(color: color.withOpacity(0.4))),
      child: Row(children: [
        Icon(isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded, color: color, size: 16),
        const SizedBox(width: 10),
        Expanded(child: Text(msg, style: TextStyle(color: color, fontSize: 12, height: 1.4))),
      ]),
    );
  }

  Widget _buildSaveButton() => SizedBox(
    width: double.infinity, height: 52,
    child: _isLoading
        ? Container(
        decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), gradient: const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)])),
        child: const Center(child: SizedBox(width: 22, height: 22, child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation(Color(0xFF060D1F))))))
        : DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        gradient: const LinearGradient(colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)]),
        boxShadow: [BoxShadow(color: const Color(0xFF3EFFA8).withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 6))],
      ),
      child: ElevatedButton(
        onPressed: _handleSave,
        style: ElevatedButton.styleFrom(backgroundColor: Colors.transparent, shadowColor: Colors.transparent, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
        child: const Text('Enregistrer les modifications', style: TextStyle(color: Color(0xFF060D1F), fontSize: 15, fontWeight: FontWeight.w700)),
      ),
    ),
  );
}

class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    void orb(Offset c, double r, Color color) => canvas.drawCircle(c, r, Paint()..shader = RadialGradient(colors: [color, Colors.transparent]).createShader(Rect.fromCircle(center: c, radius: r)));
    orb(Offset(size.width * (0.1 + 0.06 * math.sin(t * math.pi)), size.height * 0.15), size.width * 0.4, const Color(0xFF3EFFA8).withOpacity(0.05));
    orb(Offset(size.width * 0.85, size.height * (0.75 + 0.05 * math.cos(t * math.pi))), size.width * 0.35, const Color(0xFF00D4FF).withOpacity(0.04));
  }
  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()..color = const Color(0xFF1A2E52).withOpacity(0.15)..strokeWidth = 0.5;
    for (double x = 0; x < size.width; x += 44) canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    for (double y = 0; y < size.height; y += 44) canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
  }
  @override
  bool shouldRepaint(_GridPainter _) => false;
}