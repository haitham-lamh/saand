import 'package:flutter/material.dart';

/// شاشة الكاميرا المباشرة
///
/// في هذه الشاشة سيتم لاحقًا عرض بث حي من الكاميرا وتحليل الإشارات
/// في الوقت الحقيقي باستخدام نموذج الذكاء الاصطناعي.
/// حاليًا هذه الشاشة فقط لتجهيز التصميم والتنقّل.
class LiveCameraScreen extends StatelessWidget {
  const LiveCameraScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الكاميرا المباشرة')),
      body: const Center(
        child: Padding(
          padding: EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, size: 64, color: Colors.grey),
              SizedBox(height: 16),
              Text(
                'شاشة الكاميرا المباشرة',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'في المراحل القادمة سيتم هنا عرض بث مباشر من الكاميرا\n'
                'مع تحليل الإشارات في الوقت الحقيقي.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              SizedBox(height: 24),
              Text(
                'هذه الشاشة جاهزة الآن لدمج نموذج الذكاء الاصطناعي لاحقًا.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
