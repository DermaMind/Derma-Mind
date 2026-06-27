import 'package:dermamind_app/providers/auth_provider.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/assets_Maneger.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GoogleSignInButton extends StatelessWidget {
  const GoogleSignInButton({
    super.key,
    required this.onSuccess,
    this.onError,
  });

  final VoidCallback onSuccess;
  final void Function(String message)? onError;

  static const double _size = 56;

  Future<void> _handleTap(BuildContext context) async {
    final auth = context.read<AuthProvider>();
    if (auth.isGoogleLoading) return;

    try {
      await auth.googleSignIn();
      if (!context.mounted) return;
      if (auth.isLoggedIn) onSuccess();
    } catch (e) {
      if (!context.mounted) return;
      final message = e.toString().replaceFirst('Exception: ', '');
      if (onError != null) {
        onError!(message);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Center(
      child: Material(
        color: AppColor.white2Color,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          onTap: auth.isGoogleLoading ? null : () => _handleTap(context),
          customBorder: const CircleBorder(),
          child: Ink(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColor.white2Color,
              boxShadow: [
                BoxShadow(
                  color: AppColor.blueColor.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Center(
              child: auth.isGoogleLoading
                  ? SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColor.blueColor,
                      ),
                    )
                  : Image.asset(
                      AssetsManager.googleIcon,
                      height: 26,
                      width: 26,
                    ),
            ),
          ),
        ),
      ),
    );
  }
}
