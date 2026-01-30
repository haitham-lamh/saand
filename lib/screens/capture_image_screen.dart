import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'image_preview_screen.dart';

/// شاشة التقاط صورة بالكاميرا
///
/// في هذه الشاشة يتم فتح الكاميرا لالتقاط صورة جديدة.
/// بعد التقاط الصورة يتم الانتقال إلى شاشة عرض الصورة ImagePreviewScreen.
/// لا يوجد أي منطق للذكاء الاصطناعي في هذه المرحلة.
class CaptureImageScreen extends StatefulWidget {
  const CaptureImageScreen({super.key});

  @override
  State<CaptureImageScreen> createState() => _CaptureImageScreenState();
}

class _CaptureImageScreenState extends State<CaptureImageScreen> {
  // كائن ImagePicker لاستخدام الكاميرا.
  final ImagePicker _picker = ImagePicker();

  // نحتفظ بآخر صورة تم التقاطها (اختياري - لأغراض العرض فقط).
  File? _capturedImageFile;

  /// فتح الكاميرا لالتقاط صورة واحدة.
  ///
  /// في حال تم التقاط صورة بنجاح:
  /// - نخزنها في _capturedImageFile باستخدام setState.
  /// - ننتقل إلى شاشة عرض الصورة ImagePreviewScreen.
  Future<void> _captureImageWithCamera() async {
    try {
      // على الويب سنعرض رسالة توضيحية بدلاً من محاولة فتح الكاميرا.
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'استخدام الكاميرا متاح على الهاتف فقط.\n'
                'جرّب تشغيل التطبيق على أندرويد أو iOS.',
              ),
            ),
          );
        }
        return;
      }

      final XFile? capturedFile = await _picker.pickImage(
        source: ImageSource.camera,
      );

      if (capturedFile == null) {
        // المستخدم أغلق الكاميرا بدون التقاط صورة.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم التقاط أي صورة.')),
          );
        }
        return;
      }

      final File imageFile = File(capturedFile.path);

      if (!mounted) return;

      setState(() {
        _capturedImageFile = imageFile;
      });

      // الانتقال إلى شاشة عرض الصورة.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imageFile: imageFile),
        ),
      );
    } catch (e) {
      // رسائل خطأ واضحة عند حدوث مشكلة (مثل رفض صلاحية الكاميرا).
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'لا يمكن الوصول إلى الكاميرا.\nتأكد من منح صلاحية الكاميرا للتطبيق.',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('التقاط صورة بالكاميرا')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'التقاط صورة جديدة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                _capturedImageFile == null
                    ? 'لم يتم التقاط أي صورة بعد.\nاضغط على الزر في الأسفل لفتح الكاميرا.'
                    : 'آخر صورة تم التقاطها:\n${_capturedImageFile!.path}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _captureImageWithCamera,
                  icon: const Icon(Icons.camera_alt_outlined),
                  label: const Text(
                    'فتح الكاميرا والتقاط صورة',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
