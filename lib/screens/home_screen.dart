import 'package:flutter/material.dart';

import 'capture_image_screen.dart';
import 'live_camera_screen.dart';
import 'pick_image_screen.dart';

/// الشاشة الرئيسية
///
/// هذه هي الشاشة الأساسية للتطبيق، ومنها ينتقل المستخدم لاختيار
/// طريقة إدخال الصورة (من المعرض، من الكاميرا، أو كاميرا مباشرة).
///
/// ملاحظة: حتى الآن لا يوجد أي منطق للذكاء الاصطناعي، فقط التنقل بين الشاشات.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('التعرّف على لغة الإشارة')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Card(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 24,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.front_hand_outlined,
                            color: colorScheme.primary,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'تطبيق التعرّف على لغة الإشارة',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'اختر الطريقة التي تريد إدخال الصورة بها لبدء التحضير للمعالجة بالذكاء الاصطناعي.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13, color: Colors.grey),
                      ),
                      const SizedBox(height: 28),
                      // زر اختيار صورة من المعرض
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const PickImageScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.photo_library_outlined),
                          label: const Text(
                            'اختيار صورة من المعرض',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // زر التقاط صورة بالكاميرا
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const CaptureImageScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.camera_alt_outlined),
                          label: const Text(
                            'التقاط صورة بالكاميرا',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // زر الكاميرا المباشرة
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const LiveCameraScreen(),
                              ),
                            );
                          },
                          icon: const Icon(Icons.videocam_outlined),
                          label: const Text(
                            'الكاميرا المباشرة',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ),
                    ],
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
