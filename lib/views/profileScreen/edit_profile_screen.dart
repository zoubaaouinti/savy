import 'dart:io';
import 'dart:math' as math;
import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/auth_service.dart';

// ══════════════════════════════════════════════════════════════
//  SAVVY – EDIT PROFILE SCREEN
// ══════════════════════════════════════════════════════════════

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String currentEmail;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    required this.currentEmail,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with TickerProviderStateMixin {
  late final TextEditingController _nameCtrl;
  late final TextEditingController _emailCtrl;
  final TextEditingController _currentPassCtrl = TextEditingController();
  final TextEditingController _newPassCtrl = TextEditingController();
  final TextEditingController _confirmPassCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  bool _obscureCurrent = true;
  bool _obscureNew = true;
  bool _obscureConfirm = true;
  bool _changePassword = false;
  String? _errorMessage;
  String? _successMessage;
  String? _photoUrl;
  File? _localPhoto;
  List<int>? _base64Bytes;
  final ImagePicker _picker = ImagePicker();

  late final AnimationController _bgController;
  late final Animation<double> _bgAnim;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.currentName);
    _emailCtrl = TextEditingController(text: widget.currentEmail);
    _photoUrl = FirebaseAuth.instance.currentUser?.photoURL;
    _loadPhotoFromFirestore();

    _bgController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 7),
    )..repeat(reverse: true);
    _bgAnim =
        CurvedAnimation(parent: _bgController, curve: Curves.easeInOut);
  }

  @override
  void dispose() {
    _bgController.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _currentPassCtrl.dispose();
    _newPassCtrl.dispose();
    _confirmPassCtrl.dispose();
    super.dispose();
  }

  // ── Initiales de l'avatar ─────────────────────────────────
  String get _initials {
    final parts = _nameCtrl.text.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return parts[0].isNotEmpty ? parts[0][0].toUpperCase() : '?';
  }

  // ── Choix de la photo ────────────────────────────────────
  void _showPhotoOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF0B1535),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1A2E52),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Photo de profil',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 20),

              // Galerie
              _photoOption(
                icon: Icons.photo_library_rounded,
                label: 'Choisir depuis la galerie',
                color: const Color(0xFF3EFFA8),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
              const SizedBox(height: 12),

              // Caméra
              _photoOption(
                icon: Icons.camera_alt_rounded,
                label: 'Prendre une photo',
                color: const Color(0xFF00D4FF),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),

              // Supprimer photo (si existe)
              if (_photoUrl != null || _localPhoto != null) ...[
                const SizedBox(height: 12),
                _photoOption(
                  icon: Icons.delete_outline_rounded,
                  label: 'Supprimer la photo',
                  color: const Color(0xFFFF5C7A),
                  onTap: () {
                    Navigator.pop(context);
                    setState(() {
                      _localPhoto = null;
                      _photoUrl = null;
                      _base64Bytes = null;
                    });
                  },
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _photoOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: color.withOpacity(0.07),
          border: Border.all(color: color.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: color.withOpacity(0.12),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 14),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    // Demande la permission selon la source
    PermissionStatus status;

    if (source == ImageSource.camera) {
      status = await Permission.camera.request();
    } else {
      // Android 13+ utilise READ_MEDIA_IMAGES
      if (Platform.isAndroid) {
        status = await Permission.photos.request();
        if (status.isDenied) {
          status = await Permission.storage.request();
        }
      } else {
        status = await Permission.photos.request();
      }
    }

    // Permission refusée
    if (status.isDenied || status.isPermanentlyDenied) {
      setState(() => _errorMessage =
      status.isPermanentlyDenied
          ? 'Permission refusée définitivement. Activez-la dans les paramètres de l\'app.'
          : 'Permission ${source == ImageSource.camera ? 'caméra' : 'galerie'} refusée');

      if (status.isPermanentlyDenied) {
        await openAppSettings();
      }
      return;
    }

    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 85,
      );
      if (picked != null) {
        setState(() {
          _localPhoto = File(picked.path);
          _errorMessage = null;
        });
      }
    } catch (e) {
      setState(() => _errorMessage =
      'Impossible d\'accéder à ${source == ImageSource.camera ? 'la caméra' : 'la galerie'}: ${e.toString()}');
    }
  }

  /// Sauvegarde la photo localement et retourne le chemin
  /// Encode la photo en base64 et la sauvegarde dans Firestore
  Future<String?> _savePhotoToFirestore() async {
    if (_localPhoto == null) return _photoUrl;
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return null;

      // Lire les bytes de l'image
      final bytes = await _localPhoto!.readAsBytes();

      // Encoder en base64
      final base64Image = base64Encode(bytes);

      // Sauvegarder dans Firestore
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .set({'photoBase64': base64Image}, SetOptions(merge: true));

      // Retourne un indicateur qu'on a une photo Firestore
      return 'firestore:${user.uid}';
    } catch (e) {
      setState(() => _errorMessage = 'Erreur lors de la sauvegarde de la photo');
      return null;
    }
  }

  /// Charge la photo base64 depuis Firestore
  Future<void> _loadPhotoFromFirestore() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (doc.exists && doc.data()?['photoBase64'] != null) {
        final base64Str = doc.data()!['photoBase64'] as String;
        final bytes = base64Decode(base64Str);
        setState(() => _base64Bytes = bytes);
      }
    } catch (e) {
      // Pas de photo
    }
  }

  // ── Sauvegarde les modifications ──────────────────────────
  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;

      // ── Upload photo si nouvelle sélectionnée ──────────
      String? newPhotoUrl = _photoUrl;
      if (_localPhoto != null) {
        newPhotoUrl = await _savePhotoToFirestore();
        if (newPhotoUrl != null) {
          // On stocke le chemin local dans photoURL de Firebase
          await user.updatePhotoURL('firestore:${user.uid}');
          setState(() => _photoUrl = newPhotoUrl);
        }
      } else if (_photoUrl == null) {
        // Photo supprimée
        await user.updatePhotoURL(null);
      }

      // ── Met à jour le nom ──────────────────────────────
      if (_nameCtrl.text.trim() != widget.currentName) {
        await user.updateDisplayName(_nameCtrl.text.trim());
      }

      // ── Met à jour l'email ────────────────────────────
      if (_emailCtrl.text.trim() != widget.currentEmail) {
        // Nécessite une ré-authentification
        if (_currentPassCtrl.text.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage =
            'Entrez votre mot de passe actuel pour changer l\'email';
            _changePassword = true;
          });
          return;
        }

        // Ré-authentification
        final credential = EmailAuthProvider.credential(
          email: widget.currentEmail,
          password: _currentPassCtrl.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.verifyBeforeUpdateEmail(_emailCtrl.text.trim());
        setState(() => _successMessage =
        'Un email de vérification a été envoyé à ${_emailCtrl.text}');
      }

      // ── Met à jour le mot de passe ────────────────────
      if (_changePassword && _newPassCtrl.text.isNotEmpty) {
        if (_currentPassCtrl.text.isEmpty) {
          setState(() {
            _isLoading = false;
            _errorMessage = 'Entrez votre mot de passe actuel';
          });
          return;
        }

        final credential = EmailAuthProvider.credential(
          email: widget.currentEmail,
          password: _currentPassCtrl.text,
        );
        await user.reauthenticateWithCredential(credential);
        await user.updatePassword(_newPassCtrl.text);
      }

      await user.reload();

      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _successMessage = _successMessage ?? 'Profil mis à jour avec succès ✓';
      });

      // Retourne les nouvelles données au ProfileScreen
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) {
        Navigator.of(context).pop({
          'name': _nameCtrl.text.trim(),
          'email': _emailCtrl.text.trim(),
        });
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = _mapError(e.code);
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur s\'est produite';
      });
    }
  }

  String _mapError(String code) {
    switch (code) {
      case 'wrong-password':
      case 'invalid-credential':
        return 'Mot de passe actuel incorrect';
      case 'email-already-in-use':
        return 'Cet email est déjà utilisé';
      case 'weak-password':
        return 'Nouveau mot de passe trop faible (min. 6 caractères)';
      case 'requires-recent-login':
        return 'Session expirée. Reconnectez-vous et réessayez';
      default:
        return 'Erreur ($code)';
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
          // Background
          AnimatedBuilder(
            animation: _bgAnim,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _BgPainter(_bgAnim.value),
            ),
          ),
          _GridPainter.widget(size),

          SafeArea(
            child: Column(
              children: [
                // ── Top Bar ──────────────────────────────
                _buildTopBar(context),

                // ── Scrollable content ───────────────────
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.fromLTRB(hPad, 24, hPad, 40),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Avatar
                          _buildAvatar(),
                          const SizedBox(height: 32),

                          // Infos personnelles
                          _buildSectionTitle('Informations personnelles'),
                          const SizedBox(height: 12),
                          _buildCard([
                            _buildField(
                              label: 'Nom complet',
                              controller: _nameCtrl,
                              icon: Icons.person_outline_rounded,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Nom requis';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 16),
                            _buildField(
                              label: 'Adresse email',
                              controller: _emailCtrl,
                              icon: Icons.alternate_email_rounded,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.isEmpty) {
                                  return 'Email requis';
                                }
                                if (!RegExp(
                                    r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$')
                                    .hasMatch(v)) {
                                  return 'Email invalide';
                                }
                                return null;
                              },
                            ),
                          ]),

                          const SizedBox(height: 20),

                          // Section mot de passe
                          _buildSectionTitle('Sécurité'),
                          const SizedBox(height: 12),
                          _buildCard([
                            // Toggle changer mot de passe
                            GestureDetector(
                              onTap: () => setState(
                                      () => _changePassword = !_changePassword),
                              child: Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(10),
                                      color: const Color(0xFF7B61FF)
                                          .withOpacity(0.12),
                                    ),
                                    child: const Icon(
                                        Icons.lock_outline_rounded,
                                        color: Color(0xFF7B61FF),
                                        size: 17),
                                  ),
                                  const SizedBox(width: 14),
                                  const Expanded(
                                    child: Text(
                                      'Changer le mot de passe',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500),
                                    ),
                                  ),
                                  AnimatedRotation(
                                    turns: _changePassword ? 0.25 : 0,
                                    duration:
                                    const Duration(milliseconds: 200),
                                    child: Icon(
                                      Icons.arrow_forward_ios_rounded,
                                      color: _changePassword
                                          ? const Color(0xFF7B61FF)
                                          : const Color(0xFF3A5070),
                                      size: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // Champs mot de passe (animés)
                            AnimatedSize(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeOutCubic,
                              child: _changePassword
                                  ? Column(
                                children: [
                                  const SizedBox(height: 16),
                                  Container(
                                    height: 1,
                                    color: const Color(0xFF1A2E52)
                                        .withOpacity(0.5),
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Mot de passe actuel',
                                    controller: _currentPassCtrl,
                                    icon: Icons.lock_outline_rounded,
                                    obscure: _obscureCurrent,
                                    suffixIcon: _eyeIcon(
                                      _obscureCurrent,
                                          () => setState(() =>
                                      _obscureCurrent =
                                      !_obscureCurrent),
                                    ),
                                    validator: (v) {
                                      if (_changePassword &&
                                          (v == null || v.isEmpty)) {
                                        return 'Mot de passe actuel requis';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Nouveau mot de passe',
                                    controller: _newPassCtrl,
                                    icon: Icons.lock_open_rounded,
                                    obscure: _obscureNew,
                                    suffixIcon: _eyeIcon(
                                      _obscureNew,
                                          () => setState(() =>
                                      _obscureNew = !_obscureNew),
                                    ),
                                    validator: (v) {
                                      if (_changePassword &&
                                          (v == null || v.length < 6)) {
                                        return 'Minimum 6 caractères';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 16),
                                  _buildField(
                                    label: 'Confirmer le mot de passe',
                                    controller: _confirmPassCtrl,
                                    icon: Icons.lock_rounded,
                                    obscure: _obscureConfirm,
                                    suffixIcon: _eyeIcon(
                                      _obscureConfirm,
                                          () => setState(() =>
                                      _obscureConfirm =
                                      !_obscureConfirm),
                                    ),
                                    validator: (v) {
                                      if (_changePassword &&
                                          v != _newPassCtrl.text) {
                                        return 'Les mots de passe ne correspondent pas';
                                      }
                                      return null;
                                    },
                                  ),
                                ],
                              )
                                  : const SizedBox.shrink(),
                            ),
                          ]),

                          const SizedBox(height: 20),

                          // Messages erreur / succès
                          if (_errorMessage != null)
                            _buildAlert(_errorMessage!, isError: true),
                          if (_successMessage != null)
                            _buildAlert(_successMessage!, isError: false),

                          const SizedBox(height: 20),

                          // Bouton sauvegarder
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

  // ── Top Bar ───────────────────────────────────────────────
  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF1A2E52)),
                color: const Color(0xFF0D1B38),
              ),
              child: const Icon(Icons.arrow_back_ios_new_rounded,
                  color: Color(0xFF8BA8D4), size: 16),
            ),
          ),
          const SizedBox(width: 16),
          ShaderMask(
            shaderCallback: (b) => const LinearGradient(
              colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
            ).createShader(b),
            child: const Text(
              'Modifier le profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Avatar ────────────────────────────────────────────────
  Widget _buildAvatar() {
    return GestureDetector(
      onTap: _showPhotoOptions,
      child: AnimatedBuilder(
        animation: _nameCtrl,
        builder: (_, __) => Stack(
          alignment: Alignment.center,
          children: [
            // Glow
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF3EFFA8).withOpacity(0.2),
                    blurRadius: 30,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
            // Avatar circle — photo ou initiales
            Container(
              width: 90,
              height: 90,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
                ),
              ),
              child: ClipOval(
                child: _localPhoto != null
                // Photo nouvellement sélectionnée (fichier local)
                    ? Image.file(
                  _localPhoto!,
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                )
                    : _base64Bytes != null
                // Photo depuis Firestore (base64)
                    ? Image.memory(
                  Uint8List.fromList(_base64Bytes!),
                  fit: BoxFit.cover,
                  width: 90,
                  height: 90,
                )
                    : Center(
                  child: Text(
                    _initials,
                    style: const TextStyle(
                      color: Color(0xFF060D1F),
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
            ),
            // Badge édition
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFF0D1B38),
                  border: Border.all(
                      color: const Color(0xFF3EFFA8).withOpacity(0.5),
                      width: 1.5),
                ),
                child: const Icon(Icons.camera_alt_rounded,
                    color: Color(0xFF3EFFA8), size: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Section title ─────────────────────────────────────────
  Widget _buildSectionTitle(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFF3A5070),
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  // ── Card container ────────────────────────────────────────
  Widget _buildCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: const Color(0xFF0B1535),
        border:
        Border.all(color: const Color(0xFF1A2E52).withOpacity(0.6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // ── Field ─────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Color(0xFF8BA8D4),
                fontSize: 12,
                fontWeight: FontWeight.w500)),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscure,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          decoration: InputDecoration(
            hintText: label,
            hintStyle:
            const TextStyle(color: Color(0xFF3A5068), fontSize: 14),
            prefixIcon:
            Icon(icon, color: const Color(0xFF3EFFA8), size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFF0D1B38),
            contentPadding:
            const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A2E52)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFF1A2E52)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFF3EFFA8), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFFF5C7A), width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
              const BorderSide(color: Color(0xFFFF5C7A), width: 1.5),
            ),
            errorStyle:
            const TextStyle(color: Color(0xFFFF5C7A), fontSize: 11),
          ),
        ),
      ],
    );
  }

  // ── Eye icon ──────────────────────────────────────────────
  Widget _eyeIcon(bool obscure, VoidCallback onTap) {
    return IconButton(
      icon: Icon(
        obscure ? Icons.visibility_off_outlined : Icons.visibility_outlined,
        color: const Color(0xFF4A6080),
        size: 18,
      ),
      onPressed: onTap,
    );
  }

  // ── Alert ─────────────────────────────────────────────────
  Widget _buildAlert(String message, {required bool isError}) {
    final color = isError ? const Color(0xFFFF5C7A) : const Color(0xFF3EFFA8);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: color.withOpacity(0.08),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline_rounded : Icons.check_circle_outline_rounded,
            color: color,
            size: 16,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(message,
                style: TextStyle(color: color, fontSize: 12, height: 1.4)),
          ),
        ],
      ),
    );
  }

  // ── Save button ───────────────────────────────────────────
  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: _isLoading
          ? Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
          ),
        ),
        child: const Center(
          child: SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor:
              AlwaysStoppedAnimation(Color(0xFF060D1F)),
            ),
          ),
        ),
      )
          : DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            colors: [Color(0xFF3EFFA8), Color(0xFF00D4FF)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF3EFFA8).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: _handleSave,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14)),
          ),
          child: const Text(
            'Enregistrer les modifications',
            style: TextStyle(
              color: Color(0xFF060D1F),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
//  PAINTERS
// ══════════════════════════════════════════════════════════════
class _BgPainter extends CustomPainter {
  final double t;
  _BgPainter(this.t);
  @override
  void paint(Canvas canvas, Size size) {
    void orb(Offset c, double r, Color color) {
      canvas.drawCircle(
        c,
        r,
        Paint()
          ..shader = RadialGradient(
              colors: [color, Colors.transparent])
              .createShader(Rect.fromCircle(center: c, radius: r)),
      );
    }

    orb(
      Offset(size.width * (0.1 + 0.06 * math.sin(t * math.pi)),
          size.height * 0.15),
      size.width * 0.4,
      const Color(0xFF3EFFA8).withOpacity(0.05),
    );
    orb(
      Offset(size.width * 0.85,
          size.height * (0.75 + 0.05 * math.cos(t * math.pi))),
      size.width * 0.35,
      const Color(0xFF00D4FF).withOpacity(0.04),
    );
  }

  @override
  bool shouldRepaint(_BgPainter old) => old.t != t;
}

class _GridPainter {
  static Widget widget(Size size) => CustomPaint(
    size: size,
    painter: _GridCustomPainter(),
  );
}

class _GridCustomPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF1A2E52).withOpacity(0.15)
      ..strokeWidth = 0.5;
    const step = 44.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridCustomPainter old) => false;
}