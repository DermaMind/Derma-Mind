import 'dart:io';

import 'package:dermamind_app/Scan_Screen/scan_followup_screen.dart';
import 'package:dermamind_app/utils/app_color.dart';
import 'package:dermamind_app/utils/app_style.dart';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'package:image_picker/image_picker.dart';



// ─────────────────────────────────────────────────────────────────────────────
// CameraScreen: three visual states
//   • _CameraState.idle    → dark preview + capture / gallery buttons
//   • _CameraState.preview → selected image + Analyze button
//   • _CameraState.loading → full-screen overlay "Analyzing…"
//   • _CameraState.error   → error card + retry
// ─────────────────────────────────────────────────────────────────────────────

enum _CameraState { idle, preview, loading, error }

class CameraScreen extends StatefulWidget {
  static const String routeName = 'cameraScreen';

  const CameraScreen({super.key});

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _image;
  _CameraState _state = _CameraState.idle;

  // ── Pickers ────────────────────────────────────────────────────────────────

  Future<void> _pickCamera() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.camera, imageQuality: 90);
    if (file != null) {
      setState(() {
        _image = File(file.path);
        _state = _CameraState.preview;
      });
    }
  }

  Future<void> _pickGallery() async {
    final XFile? file =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 90);
    if (file != null) {
      setState(() {
        _image = File(file.path);
        _state = _CameraState.preview;
      });
    }
  }

  // ── Analyze (simulate 2-second API call) ──────────────────────────────────

  Future<void> _analyze() async {
    if (_image == null) return;

    setState(() {
      _state = _CameraState.loading;
    });

    try {

      debugPrint("Image Path: ${_image!.path}");
      debugPrint("Extension: ${_image!.path.split('.').last}");

      final file = File(_image!.path);

      debugPrint("Exists: ${file.existsSync()}");
      debugPrint("Length: ${file.lengthSync()} bytes");

      final lang = Localizations.localeOf(context).languageCode;
      final response = await ApiService.diagnoseStart(
        imagePath: _image!.path,
        lang: lang,
      );
      debugPrint(
        "Questions = ${response.data?.questions.length}",
      );
      if (!mounted) return;

      if (response.success && response.data != null) {
        debugPrint("========== CAMERA ==========");
        debugPrint(
            "Questions = ${response.data!.questions.length}");

        debugPrint(
            "Predictions = ${response.data!.predictions.length}");
        Navigator.pushNamed(
          context,
          ScanFollowupScreen.routeName,
          arguments: {
            "analyze": response.data,
            "lang": lang,
          },
        );

        setState(() {
          _state = _CameraState.preview;
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message ?? "Analyze failed"),
          ),
        );

        setState(() {
          _state = _CameraState.preview;
        });
      }
    } catch (e) {
      setState(() {
        _state = _CameraState.error;
      });
    }
  }
  void _retake() => setState(() {
        _image = null;
        _state = _CameraState.idle;
      });

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Main content ──────────────────────────────────────────────────
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            child: _state == _CameraState.idle
                ? _buildIdleView(key: const ValueKey('idle'))
                : _buildPreviewView(key: const ValueKey('preview')),
          ),

          // ── Loading overlay ───────────────────────────────────────────────
          if (_state == _CameraState.loading) _buildLoadingOverlay(),

          // ── Error overlay ─────────────────────────────────────────────────
          if (_state == _CameraState.error) _buildErrorOverlay(),
        ],
      ),
    );
  }

  // ── IDLE VIEW ──────────────────────────────────────────────────────────────

  Widget _buildIdleView({Key? key}) {
    return SizedBox.expand(
      key: key,
      child: Stack(
        children: [
          // Background
          Container(color: Colors.black),

          // Face-oval guide
          Center(
            child: CustomPaint(
              size: const Size(240, 300),
              painter: _OvalGuidePainter(),
            ),
          ),

          // Top row: back + flip
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _CircleIconButton(
                    icon: Icons.arrow_back_ios_new,
                    onTap: () => Navigator.pop(context),
                  ),
                  _CircleIconButton(
                    icon: Icons.flip_camera_android,
                    onTap: () {}, // flip handled by native camera
                  ),
                ],
              ),
            ),
          ),

          // Hint text above buttons
          Positioned(
            bottom: 160,
            left: 0,
            right: 0,
            child: Text(
              'Position your skin clearly inside the frame',
              textAlign: TextAlign.center,
              style: AppStyle.regular.copyWith(
                color: Colors.white70,
                fontSize: 13,
              ),
            ),
          ),

          // Bottom controls
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Gallery
                GestureDetector(
                  onTap: _pickGallery,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.photo_library_outlined,
                            color: Colors.white, size: 26),
                      ),
                      const SizedBox(height: 6),
                      Text('Gallery',
                          style: AppStyle.regular
                              .copyWith(color: Colors.white, fontSize: 12)),
                    ],
                  ),
                ),

                // Capture shutter
                GestureDetector(
                  onTap: _pickCamera,
                  child: Container(
                    width: 76,
                    height: 76,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 4),
                    ),
                    child: Center(
                      child: Container(
                        width: 58,
                        height: 58,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Spacer mirror
                const SizedBox(width: 52),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── PREVIEW VIEW ───────────────────────────────────────────────────────────

  Widget _buildPreviewView({Key? key}) {
    final h = MediaQuery.of(context).size.height;

    return SafeArea(
      key: key,
      child: Column(
        children: [
          // Back button row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 0),
            child: Row(
              children: [
                _CircleIconButton(
                  icon: Icons.arrow_back_ios_new,
                  onTap: _retake,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),

          // Image preview
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _image != null
                  ? Image.file(
                      _image!,
                      height: h * 0.48,
                      width: double.infinity,
                      fit: BoxFit.cover,
                    )
                  : Container(
                      height: h * 0.48,
                      color: Colors.grey.shade900,
                    ),
            ),
          ),

          const SizedBox(height: 16),

          // Hint text
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline,
                  color: Colors.white54, size: 15),
              const SizedBox(width: 6),
              Text(
                'Make sure the image is clear and well-lit',
                style: AppStyle.regular
                    .copyWith(color: Colors.white60, fontSize: 13),
              ),
            ],
          ),

          const Spacer(),

          // Analyze button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: ElevatedButton.icon(
                onPressed: _analyze,
                icon: const Icon(Icons.biotech_outlined, color: Colors.white),
                label: Text(
                  'Analyze',
                  style: AppStyle.priceDetailsText
                      .copyWith(color: Colors.white, fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.selectedColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ),

          const SizedBox(height: 14),

          // Retake link
          GestureDetector(
            onTap: _retake,
            child: Text(
              'Retake / Change photo',
              style: AppStyle.regular.copyWith(
                color: Colors.white60,
                fontSize: 14,
                decoration: TextDecoration.underline,
                decorationColor: Colors.white60,
              ),
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ── LOADING OVERLAY ────────────────────────────────────────────────────────

  Widget _buildLoadingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.78),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 64,
              height: 64,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Analyzing your skin...',
              style: AppStyle.semi40linear.copyWith(
                color: Colors.white,
                fontSize: 18,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'This usually takes a few seconds',
              style:
                  AppStyle.regular.copyWith(color: Colors.white60, fontSize: 13),
            ),
          ],
        ),
      ),
    );
  }

  // ── ERROR OVERLAY ──────────────────────────────────────────────────────────

  Widget _buildErrorOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.85),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.red.shade900.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.wifi_off_rounded,
                    color: Colors.white, size: 38),
              ),
              const SizedBox(height: 20),
              Text(
                'Something went wrong.',
                style: AppStyle.semi40linear
                    .copyWith(color: Colors.white, fontSize: 18),
              ),
              const SizedBox(height: 8),
              Text(
                'Please check your connection and try again.',
                textAlign: TextAlign.center,
                style: AppStyle.regular
                    .copyWith(color: Colors.white60, fontSize: 14),
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _analyze,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColor.selectedColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: Text(
                    'Try Again',
                    style: AppStyle.priceDetailsText
                        .copyWith(color: Colors.white, fontSize: 16),
                  ),
                ),
              ),
              const SizedBox(height: 14),
              GestureDetector(
                onTap: _retake,
                child: Text(
                  'Change photo',
                  style: AppStyle.regular
                      .copyWith(color: Colors.white54, fontSize: 14),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Helper widgets ─────────────────────────────────────────────────────────────

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _CircleIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

// ── Oval guide painter ────────────────────────────────────────────────────────

class _OvalGuidePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.35)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..isAntiAlias = true;

    // Dashed oval
    final path = Path()
      ..addOval(Rect.fromLTWH(0, 0, size.width, size.height));

    _drawDashedPath(canvas, path, paint);
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    final metrics = path.computeMetrics();
    final iterator = metrics.iterator;
    if (!iterator.moveNext()) return;

    final metric = iterator.current;
    if (metric.length <= 0) return;

    double distance = 0;
    const double dashLen = 12;
    const double gapLen = 8;
    bool drawing = true;
    while (distance < metric.length) {
      final len = drawing ? dashLen : gapLen;
      if (drawing) {
        canvas.drawPath(
          metric.extractPath(distance, distance + len),
          paint,
        );
      }
      distance += len;
      drawing = !drawing;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
