import 'package:dermamind_app/Authentication/forget_password_screen.dart';
import 'package:dermamind_app/Authentication/register.dart';
import 'package:dermamind_app/Authentication/widgets/google_sign_in_button.dart';
import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../HomeScreen/wiidget/main_layout.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_color.dart';

class LoginScreen extends StatefulWidget {
  static const String RoutName = 'login_screen';

  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscureText = true;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();
    try {
      await auth.login(_emailCtrl.text.trim(), _passwordCtrl.text);
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, mainLayout.routeName);
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
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
                          hintStyle:
                              const TextStyle(color: AppColor.transparentColor),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          errorStyle:
                              const TextStyle(color: Colors.yellowAccent),
                        ),
                      ),
                      SizedBox(height: height * 0.04),
                      Text(
                        AppLocalizations.of(context)!.password,
                        style: const TextStyle(color: Colors.white),
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _passwordCtrl,
                        obscureText: _obscureText,
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Password is required';
                          }
                          return null;
                        },
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: Colors.white,
                          hintText:
                              AppLocalizations.of(context)!.enterYourPassword,
                          hintStyle:
                              const TextStyle(color: AppColor.transparentColor),
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
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: () => Navigator.pushNamed(
                              context, ForgetPasswordScreen.routeName),
                          child: Text(
                            AppLocalizations.of(context)!.forgetPassword,
                            style: const TextStyle(color: AppColor.whiteColor),
                          ),
                        ),
                      ),
                      SizedBox(height: height * 0.02),
                      SizedBox(
                        width: width * 0.01,
                        height: height * 0.05,
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColor.blueColor,
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
                                    AppLocalizations.of(context)!.login,
                                    style: AppStyle.semi20Linear
                                        .copyWith(color: AppColor.whiteColor),
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: height * 0.02),
                InkWell(
                  onTap: () => Navigator.pushNamed(
                      context, RegisterScreen.RoutName),
                  child: Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      children: [
                        TextSpan(
                          text:
                              AppLocalizations.of(context)!.dontHaveAnAccount,
                          style:  TextStyle(
                            color: Theme.of(context).textTheme.bodyMedium?.color,
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                        TextSpan(
                          text: AppLocalizations.of(context)!.createAccount,
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
                        color: Theme.of(context).dividerColor,
                        endIndent: 20,
                        indent: 10,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.or,
                      style: AppStyle.regular.copyWith(
                        color: Theme.of(context).textTheme.bodyMedium?.color,
                      ),
                    ),
                    Expanded(
                      child: Divider(
                        indent: 20,
                        endIndent: 10,
                        thickness: 2,
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: height * 0.04),
                GoogleSignInButton(
                  onSuccess: () => Navigator.pushReplacementNamed(
                    context,
                    mainLayout.routeName,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
