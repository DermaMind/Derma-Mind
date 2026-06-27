import 'package:dermamind_app/Authentication/login.dart';
import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  static const String routeName = 'editProfileScreen';

  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  // ── Form key ────────────────────────────────────────────────────────────────
  final _formKey = GlobalKey<FormState>();

  // ── Gender selection ────────────────────────────────────────────────────────
  bool _isFemale = true;
  String? _pickedImagePath;
  final ImagePicker _picker = ImagePicker();

  // ── Form controllers ────────────────────────────────────────────────────────
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    final auth = context.read<AuthProvider>();
    _nameCtrl.text = auth.userName;
    _emailCtrl.text = auth.email;
    _phoneCtrl.text = auth.phone;
    _dobCtrl.text = auth.dateOfBirth;
    _isFemale = auth.gender == 'Female';
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.blueColor,
      body: Column(
        children: [
          // ── Blue top area ────────────────────────────────────────────────
          SafeArea(
            bottom: false,
            child: _buildBlueHeader(context),
          ),

          // ── White form area ──────────────────────────────────────────────
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                color: AppColor.primaryColor,
                borderRadius:
                    BorderRadius.vertical(top: Radius.circular(28)),
              ),
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 32),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Section label
                    _sectionLabel('PERSONAL INFORMATION'),
                    const SizedBox(height: 16),

                    // Form card
                    Form(
                      key: _formKey,
                      child: Container(
                        padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                        decoration: BoxDecoration(
                          color: AppColor.white2Color,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 10,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            _FormField(
                              label: 'FULL NAME',
                              controller: _nameCtrl,
                              keyboardType: TextInputType.name,
                              validator: (v) =>
                                  (v == null || v.trim().isEmpty)
                                      ? 'Name is required'
                                      : null,
                            ),
                            _FormField(
                              label: 'EMAIL ADDRESS',
                              controller: _emailCtrl,
                              keyboardType: TextInputType.emailAddress,
                              validator: (v) {
                                if (v == null || v.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                    .hasMatch(v.trim())) {
                                  return 'Enter a valid email';
                                }
                                return null;
                              },
                            ),
                            _FormField(
                              label: 'PHONE NUMBER',
                              controller: _phoneCtrl,
                              keyboardType: TextInputType.phone,
                            ),
                            _FormField(
                              label: 'DATE OF BIRTH',
                              controller: _dobCtrl,
                              isLast: true,
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // ── Gender selector ──────────────────────────────────
                    _sectionLabel('GENDER'),
                    const SizedBox(height: 12),
                    _buildGenderSelector(),

                    const SizedBox(height: 28),

                    // ── Save Changes button ──────────────────────────────
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;
                          try {
                            await context.read<AuthProvider>().updateProfile(
                                  name: _nameCtrl.text.trim(),
                                  email: _emailCtrl.text.trim(),
                                  phone: _phoneCtrl.text.trim(),
                                  dob: _dobCtrl.text.trim(),
                                  gender: _isFemale ? 'Female' : 'Male',
                                  imagePath: _pickedImagePath,
                                );
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Profile updated successfully!'),
                                backgroundColor: AppColor.blueColor,
                                duration: Duration(seconds: 2),
                              ),
                            );
                            Navigator.pop(context);
                          } catch (e) {
                            if (!context.mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Failed to update profile: $e'),
                                backgroundColor: Colors.red,
                                duration: const Duration(seconds: 3),
                              ),
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.blueColor,
                          padding:
                              const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: Text(
                          'Save Changes',
                          style: AppStyle.regular.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 14),

                    // ── Delete Account ───────────────────────────────────
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (_) => AlertDialog(
                              title: const Text('Delete Account'),
                              content: const Text(
                                  'Are you sure? All your data will be deleted.'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () async {
                                    Navigator.pop(context); // close dialog
                                    await context
                                        .read<AuthProvider>()
                                        .deleteAccount();
                                    if (context.mounted) {
                                      Navigator.pushNamedAndRemoveUntil(
                                        context,
                                        LoginScreen.RoutName,
                                        (route) => false,
                                      );
                                    }
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.red, size: 18),
                        label: Text(
                          'Delete Account',
                          style: AppStyle.regular.copyWith(
                            color: Colors.red,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Blue header: back + avatar + name/email ────────────────────────────────

  Widget _buildBlueHeader(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 20),
      child: Column(
        children: [
          // Back + title row
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new,
                    color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
              Expanded(
                child: Text(
                  'Edit Profile',
                  textAlign: TextAlign.center,
                  style: AppStyle.semi40linear.copyWith(
                    color: Colors.white,
                    fontSize: 18,
                  ),
                ),
              ),
              // Spacer to balance back button
              const SizedBox(width: 48),
            ],
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: _pickProfileImage,
            child: Stack(
              children: [
                ProfileAvatar(
                  networkUrl: auth.profileImageUrl,
                  localPath: _pickedImagePath,
                  size: 80,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 26,
                    height: 26,
                    decoration: const BoxDecoration(
                      color: AppColor.blueColor,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 4,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.white, size: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            auth.userName.isNotEmpty ? auth.userName : 'User',
            style: AppStyle.nameLinear.copyWith(
                color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 4),
          Text(
            auth.email.isNotEmpty ? auth.email : '',
            style: AppStyle.regular.copyWith(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickProfileImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.pop(ctx, ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_outlined),
              title: const Text('Take a photo'),
              onTap: () => Navigator.pop(ctx, ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source == null || !mounted) return;

    try {
      final file = await _picker.pickImage(
        source: source,
        imageQuality: 85,
        maxWidth: 800,
      );
      if (file != null && mounted) {
        setState(() => _pickedImagePath = file.path);
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not pick image')),
      );
    }
  }

  // ── Gender selector ────────────────────────────────────────────────────────

  Widget _buildGenderSelector() {
    return Row(
      children: [
        Expanded(
          child: _GenderButton(
            label: 'Female',
            selected: _isFemale,
            onTap: () => setState(() => _isFemale = true),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _GenderButton(
            label: 'Male',
            selected: !_isFemale,
            onTap: () => setState(() => _isFemale = false),
          ),
        ),
      ],
    );
  }

  // ── Section label ──────────────────────────────────────────────────────────

  Widget _sectionLabel(String label) {
    return Text(
      label,
      style: AppStyle.regular.copyWith(
        color: AppColor.grayColor,
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ── Form field (bottom border only) ───────────────────────────────────────────

class _FormField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType keyboardType;
  final bool isLast;
  final String? Function(String?)? validator;

  const _FormField({
    required this.label,
    required this.controller,
    this.keyboardType = TextInputType.text,
    this.isLast = false,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 12),
          Text(
            label,
            style: AppStyle.regular.copyWith(
              color: AppColor.grayColor,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.6,
            ),
          ),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: controller,
                  keyboardType: keyboardType,
                  validator: validator,
                  style: AppStyle.regular.copyWith(fontSize: 15),
                  decoration: InputDecoration(
                    isDense: true,
                    contentPadding: const EdgeInsets.only(top: 8, bottom: 8),
                    border: InputBorder.none,
                    enabledBorder: UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: Colors.grey.shade200, width: 1),
                    ),
                    focusedBorder: const UnderlineInputBorder(
                      borderSide:
                          BorderSide(color: AppColor.blueColor, width: 1.5),
                    ),
                  ),
                ),
              ),
              Icon(Icons.edit_outlined,
                  size: 16,
                  color: AppColor.grayColor.withValues(alpha: 0.6)),
            ],
          ),
        ],
      ),
    );
  }
}

// ── Gender button ─────────────────────────────────────────────────────────────

class _GenderButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        height: 46,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? AppColor.blueColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? AppColor.blueColor : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppStyle.regular.copyWith(
            color: selected ? Colors.white : Colors.black54,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
      ),
    );
  }
}
