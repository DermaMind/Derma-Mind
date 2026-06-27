import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../l10n/app_localizations.dart';
import '../skin_test/Question_screen.dart';
import '../utils/app_color.dart';

class RegisterScreen extends StatefulWidget {
  static const String RoutName = 'register_screen';

  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _dobCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  String _selectedGender = 'Female';
  bool _obscureText = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _phoneCtrl.dispose();
    _dobCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  void _showSocialSnackBar() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Social login coming soon!'),
        backgroundColor: AppColor.blueColor,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 2),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1940),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _dobCtrl.text = DateFormat('MMMM dd, yyyy').format(picked);
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.register(
        name: _nameCtrl.text.trim(),
        email: _emailCtrl.text.trim(),
        phone: _phoneCtrl.text.trim(),
        dob: _dobCtrl.text.trim(),
        gender: _selectedGender,
        password: _passwordCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, QuestionScreen.RoutName);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    var width = MediaQuery.of(context).size.width;
    var height = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColor.primaryColor,
      body: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: width * 0.04,
          vertical: height * 0.02,
        ),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Image.asset(AssetsManager.logo, height: height * 0.20),
                Text('DermaMind', style: AppStyle.logoText),
                Text(
                  AppLocalizations.of(context)!.whereAiMeetsSkinHealth,
                  style: AppStyle.semi20Linear,
                ),
                SizedBox(height: height * 0.06),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColor.blueColor,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(60),
                      topRight: Radius.circular(60),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.40),
                        blurRadius: 35,
                        spreadRadius: 5,
                        offset: const Offset(0, -5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Name
                      Text(
                        AppLocalizations.of(context)!.name,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _nameCtrl,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Name is required'
                                : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: AppLocalizations.of(context)!.enterYourName,
                          hintStyle: const TextStyle(
                              color: AppColor.transparentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle:
                              const TextStyle(color: Colors.yellowAccent),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Email
                      Text(
                        AppLocalizations.of(context)!.email,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
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
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText:
                              AppLocalizations.of(context)!.enterYourEmail,
                          hintStyle: const TextStyle(
                              color: AppColor.transparentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle:
                              const TextStyle(color: Colors.yellowAccent),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Phone
                      const Text(
                        'Phone',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _phoneCtrl,
                        keyboardType: TextInputType.phone,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Phone is required'
                                : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Enter your phone number',
                          hintStyle: const TextStyle(
                              color: AppColor.transparentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle:
                              const TextStyle(color: Colors.yellowAccent),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Date of Birth
                      const Text(
                        'Date of Birth',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _dobCtrl,
                        readOnly: true,
                        onTap: _pickDate,
                        validator: (v) =>
                            (v == null || v.trim().isEmpty)
                                ? 'Date of birth is required'
                                : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText: 'Select date of birth',
                          hintStyle: const TextStyle(
                              color: AppColor.transparentColor),
                          suffixIcon: const Icon(Icons.calendar_today_outlined,
                              color: Colors.grey),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle:
                              const TextStyle(color: Colors.yellowAccent),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Gender
                      const Text(
                        'Gender',
                        style: TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: ['Female', 'Male'].map((g) {
                          final selected = _selectedGender == g;
                          return Expanded(
                            child: GestureDetector(
                              onTap: () =>
                                  setState(() => _selectedGender = g),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                margin: EdgeInsets.only(
                                    right: g == 'Female' ? 8 : 0),
                                height: 44,
                                alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: selected
                                      ? Colors.white
                                      : Colors.transparent,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? Colors.white
                                        : Colors.white54,
                                    width: 1.5,
                                  ),
                                ),
                                child: Text(
                                  g,
                                  style: TextStyle(
                                    color: selected
                                        ? AppColor.blueColor
                                        : Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      SizedBox(height: height * 0.03),

                      // Password
                      Text(
                        AppLocalizations.of(context)!.password,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscureText,
                        validator: (v) =>
                            (v == null || v.isEmpty)
                                ? 'Password is required'
                                : null,
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText:
                              AppLocalizations.of(context)!.enterYourPassword,
                          hintStyle: const TextStyle(
                              color: AppColor.transparentColor),
                          suffixIcon: IconButton(
                            onPressed: () =>
                                setState(() => _obscureText = !_obscureText),
                            icon: Icon(
                              _obscureText
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: Colors.grey,
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle:
                              const TextStyle(color: Colors.yellowAccent),
                        ),
                      ),
                      SizedBox(height: height * 0.03),

                      // Sign Up button
                      SizedBox(
                        width: width * 0.01,
                        height: height * 0.05,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          onPressed: auth.isLoading ? null : _submit,
                          child: auth.isLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : Align(
                                  alignment: Alignment.center,
                                  child: Text(
                                    AppLocalizations.of(context)!.signUp,
                                    style: AppStyle.semi20Linear.copyWith(
                                        color: AppColor.whiteColor),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                InkWell(
                  onTap: () => Navigator.pop(context),
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: AppLocalizations.of(context)!
                              .alreadyHaveAnAccount,
                          style: const TextStyle(
                            color: AppColor.blackColor,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.login,
                          style: AppStyle.regular.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColor.blueColor,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColor.blueColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: height * 0.02),
                Row(
                  children: [
                    Expanded(
                      child: Divider(
                        thickness: 2,
                        color: AppColor.dividerColor,
                        endIndent: 20,
                        indent: 10,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.or,
                      style: AppStyle.regular,
                    ),
                    Expanded(
                      child: Divider(
                        indent: 20,
                        endIndent: 10,
                        thickness: 2,
                        color: AppColor.dividerColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    GestureDetector(
                      onTap: () => _showSocialSnackBar(),
                      child: Image.asset(AssetsManager.googleIcon, height: 40),
                    ),
                    GestureDetector(
                      onTap: () => _showSocialSnackBar(),
                      child: Image.asset(AssetsManager.facebookIcon, height: 40),
                    ),
                    GestureDetector(
                      onTap: () => _showSocialSnackBar(),
                      child: Image.asset(AssetsManager.appleIcon, height: 40),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
