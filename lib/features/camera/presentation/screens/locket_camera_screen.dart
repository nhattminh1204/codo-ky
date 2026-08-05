import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/config/localization/app_localizations.dart';
import '../../../../core/theme/motion.dart';

/// 📸 Màn hình Chụp Ảnh Quét Di Sản phong cách Locket UI 2026
class LocketCameraScreen extends StatefulWidget {
  const LocketCameraScreen({super.key});

  @override
  State<LocketCameraScreen> createState() => _LocketCameraScreenState();
}

class _LocketCameraScreenState extends State<LocketCameraScreen>
    with SingleTickerProviderStateMixin {
  XFile? _capturedImage;
  bool _isAnalyzing = false;
  bool _isFlashOn = false;
  bool _isFrontCamera = false;
  bool _isSpeaking = false;
  final String _selectedCategory = 'Di sản & Lăng tẩm';
  String? _landmarkName;
  String? _landmarkDescription;

  late FlutterTts _flutterTts;
  late AnimationController _scanAnimationController;

  @override
  void initState() {
    super.initState();
    _initTts();
    _scanAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
  }

  void _initTts() {
    _flutterTts = FlutterTts();
    _flutterTts.setLanguage('vi-VN');
    _flutterTts.setSpeechRate(0.5);
    _flutterTts.setPitch(1.0);
    _flutterTts.setCompletionHandler(() {
      if (mounted) setState(() => _isSpeaking = false);
    });
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _scanAnimationController.dispose();
    super.dispose();
  }

  Future<void> _capturePhoto(ImageSource source) async {
    if (!kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.android ||
            defaultTargetPlatform == TargetPlatform.iOS)) {
      try {
        HapticFeedback.heavyImpact();
      } catch (_) {}
    }
    try {
      final picker = ImagePicker();
      XFile? image;

      final isDesktop = !kIsWeb &&
          (defaultTargetPlatform == TargetPlatform.windows ||
              defaultTargetPlatform == TargetPlatform.macOS ||
              defaultTargetPlatform == TargetPlatform.linux);
      final targetSource = isDesktop ? ImageSource.gallery : source;

      try {
        image = await picker.pickImage(
          source: targetSource,
          preferredCameraDevice:
              _isFrontCamera ? CameraDevice.front : CameraDevice.rear,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 88,
        );
      } catch (_) {
        image = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: 1280,
          maxHeight: 1280,
          imageQuality: 88,
        );
      }

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _isAnalyzing = true;
          _landmarkName = null;
          _landmarkDescription = null;
        });

        // Giả lập AI Gemini nhận diện đa phương thức từ hình ảnh thực tế
        await Future.delayed(const Duration(milliseconds: 1600));

        if (mounted) {
          setState(() {
            _isAnalyzing = false;
            if (_selectedCategory == 'Ẩm thực Huế') {
              _landmarkName = 'Bún Bò Huế Chuẩn Vị Imperial';
              _landmarkDescription =
                  'Món ăn đặc sản Cố đô với nước dùng đậm đà sả ớt, chả quết tươi và sợi bánh to trứ danh.';
            } else if (_selectedCategory == 'Hiện vật & Áo dài') {
              _landmarkName = 'Áo Dài Nhật Bình Triều Nguyễn';
              _landmarkDescription =
                  'Trang phục triều đình Huế dành cho Hoàng hậu và Công chúa với hoa văn thêu tay tinh xảo.';
            } else {
              _landmarkName = 'Đại Nội Huế (Hoàng Thành Huế)';
              _landmarkDescription =
                  'Kinh thành triều Nguyễn xây dựng từ năm 1804, di sản văn hóa thế giới được UNESCO công nhận năm 1993.';
            }
          });
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.cameraCaptureError('$e'))),
        );
      }
    }
  }

  Future<void> _toggleAudioNarration() async {
    if (_landmarkDescription == null) return;

    if (_isSpeaking) {
      await _flutterTts.stop();
      if (mounted) setState(() => _isSpeaking = false);
    } else {
      if (mounted) setState(() => _isSpeaking = true);
      await _flutterTts.speak('$_landmarkName. $_landmarkDescription');
    }
  }

  void _resetCamera() {
    _flutterTts.stop();
    setState(() {
      _capturedImage = null;
      _isAnalyzing = false;
      _landmarkName = null;
      _landmarkDescription = null;
      _isSpeaking = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFF090D16),
      body: SafeArea(
        child: Column(
          children: [
            // ── 1. Top Header Bar (Locket Style) ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const SizedBox.shrink(),

                  // Nút Flip Camera / Flash
                  Row(
                    children: [
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white
                              .withValues(alpha: _isFlashOn ? 0.35 : 0.12),
                          shape: const CircleBorder(),
                        ),
                        icon: Icon(
                          _isFlashOn
                              ? Icons.flash_on_rounded
                              : Icons.flash_off_rounded,
                          color: _isFlashOn
                              ? const Color(0xFFFACC15)
                              : Colors.white,
                          size: 20,
                        ),
                        onPressed: () =>
                            setState(() => _isFlashOn = !_isFlashOn),
                      ),
                      const SizedBox(width: 4),
                      IconButton(
                        style: IconButton.styleFrom(
                          backgroundColor: Colors.white.withValues(alpha: 0.12),
                          shape: const CircleBorder(),
                        ),
                        icon: const Icon(Icons.cameraswitch_rounded,
                            color: Colors.white, size: 20),
                        onPressed: () =>
                            setState(() => _isFrontCamera = !_isFrontCamera),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),

            // ── 2. Center Squircle Viewfinder Area (Locket Frame) ──
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Center(
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(32),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.20),
                          width: 2.0,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.45),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            if (_capturedImage != null)
                              Image.file(
                                File(_capturedImage!.path),
                                fit: BoxFit.cover,
                              )
                            else
                              // Placeholder Live Camera View
                              GestureDetector(
                                onTap: () => _capturePhoto(ImageSource.camera),
                                child: Container(
                                  color: const Color(0xFF111827),
                                  child: Stack(
                                    alignment: Alignment.center,
                                    children: [
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.add_a_photo_rounded,
                                            size: 56,
                                            color: Color(0xFF2DBAC6),
                                          ),
                                          const SizedBox(height: 12),
                                          Text(
                                            context.l10n.cameraTapHint,
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            context.l10n.cameraDevHint,
                                            style: const TextStyle(
                                              color: Colors.white54,
                                              fontSize: 11,
                                            ),
                                          ),
                                        ],
                                      ),
                                    // Laser Beam scanning animation
                                    AnimatedBuilder(
                                      animation: _scanAnimationController,
                                      builder: (context, child) {
                                        return Positioned(
                                          top: _scanAnimationController.value *
                                              (mediaQuery.size.height * 0.42),
                                          left: 0,
                                          right: 0,
                                          child: Container(
                                            height: 2.5,
                                            decoration: BoxDecoration(
                                              gradient: LinearGradient(
                                                colors: [
                                                  const Color(0xFF2DBAC6)
                                                      .withValues(alpha: 0.0),
                                                  const Color(0xFF2DBAC6),
                                                  const Color(0xFF2DBAC6)
                                                      .withValues(alpha: 0.0),
                                                ],
                                              ),
                                              boxShadow: const [
                                                BoxShadow(
                                                  color: Color(0xFF2DBAC6),
                                                  blurRadius: 10,
                                                  spreadRadius: 2,
                                                ),
                                              ],
                                            ),
                                          ),
                                        );
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Overlay gradient & status badge
                            if (_isAnalyzing)
                              Container(
                                color: Colors.black.withValues(alpha: 0.65),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const SizedBox(
                                      width: 44,
                                      height: 44,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 3.5,
                                        color: Color(0xFF2DBAC6),
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      context.l10n.cameraAnalyzing,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 14,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // ── 3. AI Analysis Result Card (If captured) ──
            if (_landmarkName != null)
              Container(
                margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E293B),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                      color: const Color(0xFF2DBAC6).withValues(alpha: 0.4)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _landmarkName!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        IconButton(
                          style: IconButton.styleFrom(
                            backgroundColor:
                                const Color(0xFF2DBAC6).withValues(alpha: 0.2),
                          ),
                          icon: Icon(
                            _isSpeaking
                                ? Icons.volume_up_rounded
                                : Icons.volume_mute_rounded,
                            color: const Color(0xFF2DBAC6),
                            size: 22,
                          ),
                          onPressed: _toggleAudioNarration,
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _landmarkDescription!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 12.5,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),



            // ── 5. Bottom Controls Bar (Locket Shutter Button) ──
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 4, 24, 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  // Left: Thư viện Ảnh / Retake Button
                  if (_capturedImage != null)
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        minimumSize: const Size(54, 54),
                      ),
                      icon: const Icon(Icons.refresh_rounded,
                          color: Colors.white, size: 26),
                      onPressed: _resetCamera,
                    )
                  else
                    IconButton(
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.15),
                        minimumSize: const Size(54, 54),
                      ),
                      icon: const Icon(Icons.photo_library_rounded,
                          color: Colors.white, size: 24),
                      onPressed: () => _capturePhoto(ImageSource.gallery),
                    ),

                  // Center: Locket Yellow/Cyan Big Shutter Ring
                  _LocketShutterButton(
                    onTap: () {
                      if (_capturedImage != null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(context.l10n.cameraSaved),
                          ),
                        );
                      } else {
                        _capturePhoto(ImageSource.camera);
                      }
                    },
                    isCaptured: _capturedImage != null,
                  ),

                  // Right: Send/Share or Mode Switcher
                  IconButton(
                    style: IconButton.styleFrom(
                      backgroundColor: const Color(0xFF2DBAC6)
                          .withValues(alpha: _capturedImage != null ? 1.0 : 0.20),
                      minimumSize: const Size(54, 54),
                    ),
                    icon: Icon(
                      _capturedImage != null
                          ? Icons.send_rounded
                          : Icons.auto_awesome_rounded,
                      color: Colors.white,
                      size: 24,
                    ),
                    onPressed: () {
                      if (_capturedImage != null) {
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(context
                                  .l10n
                                  .cameraShared(_landmarkName ?? context.l10n.heritageHue))),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(context.l10n.cameraNoPhoto)),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// 🟡 Nút Bấm Chụp Locket Shutter Button 2026
class _LocketShutterButton extends StatefulWidget {
  final VoidCallback onTap;
  final bool isCaptured;

  const _LocketShutterButton({
    required this.onTap,
    required this.isCaptured,
  });

  @override
  State<_LocketShutterButton> createState() => _LocketShutterButtonState();
}

class _LocketShutterButtonState extends State<_LocketShutterButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) {
        setState(() => _isPressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedScale(
        scale: _isPressed ? 0.88 : 1.0,
        duration: AppMotion.micro,
        curve: AppMotion.standardCurve,
        child: Container(
          width: 80,
          height: 80,
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: widget.isCaptured ? const Color(0xFF2DBAC6) : Colors.white,
              width: 4,
            ),
          ),
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: widget.isCaptured
                  ? const Color(0xFF2DBAC6)
                  : const Color(0xFFFACC15),
              boxShadow: [
                BoxShadow(
                  color: (widget.isCaptured
                          ? const Color(0xFF2DBAC6)
                          : const Color(0xFFFACC15))
                      .withValues(alpha: 0.45),
                  blurRadius: 16,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              widget.isCaptured
                  ? Icons.check_rounded
                  : Icons.camera_alt_rounded,
              color: Colors.black87,
              size: 32,
            ),
          ),
        ),
      ),
    );
  }
}
