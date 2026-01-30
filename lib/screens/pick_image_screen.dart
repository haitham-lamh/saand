import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'image_preview_screen.dart';

/// شاشة اختيار صورة من المعرض
///
/// في هذه الشاشة يستطيع المستخدم اختيار صورة من معرض الصور.
/// في المراحل القادمة سيتم إرسال هذه الصورة لنموذج الذكاء الاصطناعي
/// للتعرّف على لغة الإشارة.
class PickImageScreen extends StatefulWidget {
  const PickImageScreen({super.key});

  @override
  State<PickImageScreen> createState() => _PickImageScreenState();
}

class _PickImageScreenState extends State<PickImageScreen> {
  // كائن من ImagePicker من حزمة image_picker.
  final ImagePicker _picker = ImagePicker();

  // نحتفظ بآخر صورة تم اختيارها (إن وُجدت).
  File? _selectedImageFile;

  /// فتح المعرض والسماح للمستخدم باختيار صورة واحدة.
  ///
  /// عند اختيار صورة:
  /// - نخزنها في _selectedImageFile باستخدام setState.
  /// - ننتقل إلى شاشة عرض الصورة ImagePreviewScreen.
  Future<void> _pickImageFromGallery() async {
    try {
      // على الويب سنعرض رسالة توضيحية بدلاً من محاولة فتح المعرض.
      if (kIsWeb) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'اختيار الصورة من المعرض متاح على الهاتف فقط.\n'
                'جرّب تشغيل التطبيق على أندرويد أو iOS.',
              ),
            ),
          );
        }
        return;
      }

      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
      );

      if (pickedFile == null) {
        // المستخدم أغلق نافذة المعرض بدون اختيار صورة.
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('لم يتم اختيار أي صورة.')),
          );
        }
        return;
      }

      final File imageFile = File(pickedFile.path);

      if (!mounted) return;

      setState(() {
        _selectedImageFile = imageFile;
      });

      // الانتقال إلى شاشة عرض الصورة.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ImagePreviewScreen(imageFile: imageFile),
        ),
      );
    } catch (e) {
      // معالجة بسيطة للأخطاء (مناسبة لمشروع جامعي).
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء اختيار الصورة: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('اختيار صورة من المعرض')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'اختر صورة من المعرض',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              // نص توضيحي يظهر عندما لا يتم اختيار أي صورة بعد.
              Text(
                _selectedImageFile == null
                    ? 'لم يتم اختيار صورة بعد.\nاضغط على الزر في الأسفل لاختيار صورة.'
                    : 'آخر صورة تم اختيارها:\n${_selectedImageFile!.path}',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _pickImageFromGallery,
                  icon: const Icon(Icons.photo_library),
                  label: const Text(
                    'اختيار صورة من المعرض',
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
