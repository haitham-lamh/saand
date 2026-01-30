import 'dart:io';

import 'package:flutter/material.dart';

import '../services/ai_model_service.dart';

/// شاشة عرض الصورة والتعرف على الإشارة
///
/// هذه الشاشة تعرض الصورة المختارة وتسمح بتشغيل نموذج الذكاء الاصطناعي
/// للتعرف على لغة الإشارة في الصورة.
class ImagePreviewScreen extends StatefulWidget {
  const ImagePreviewScreen({super.key, required this.imageFile});

  /// ملف الصورة المراد عرضها وتحليلها
  final File imageFile;

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen> {
  // حالة التحميل أثناء الاستدلال
  bool _isRecognizing = false;

  // نتيجة الاستدلال (إن وُجدت)
  PredictionResult? _predictionResult;

  // رسالة خطأ (إن وُجدت)
  String? _errorMessage;

  /// تشغيل نموذج الذكاء الاصطناعي على الصورة
  Future<void> _recognizeSign() async {
    setState(() {
      _isRecognizing = true;
      _predictionResult = null;
      _errorMessage = null;
    });

    try {
      // الحصول على نسخة من خدمة AI
      final aiService = AIModelService.instance;

      // تشغيل الاستدلال
      final result = await aiService.predict(widget.imageFile);

      if (!mounted) return;

      setState(() {
        _predictionResult = result;
        _isRecognizing = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _errorMessage = 'حدث خطأ أثناء التعرف على الإشارة: $e';
        _isRecognizing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('عرض الصورة')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // عرض الصورة
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: AspectRatio(
                    aspectRatio: 1.0,
                    child: Image.file(widget.imageFile, fit: BoxFit.contain),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // زر التعرف على الإشارة
              SizedBox(
                height: 56,
                child: ElevatedButton.icon(
                  onPressed: _isRecognizing ? null : _recognizeSign,
                  icon:
                      _isRecognizing
                          ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white,
                              ),
                            ),
                          )
                          : const Icon(Icons.psychology),
                  label: Text(
                    _isRecognizing ? 'جاري التعرف...' : 'التعرف على الإشارة',
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // عرض النتيجة أو رسالة الخطأ
              if (_isRecognizing)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        CircularProgressIndicator(),
                        SizedBox(height: 16),
                        Text(
                          'جاري تحليل الصورة...',
                          style: TextStyle(fontSize: 14, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_errorMessage != null)
                Card(
                  color: Colors.red.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.error_outline, color: Colors.red.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.red.shade700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              else if (_predictionResult != null)
                Card(
                  color: colorScheme.primaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: colorScheme.primary,
                              size: 28,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'نتيجة التعرف',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        // التسمية المتوقعة
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          decoration: BoxDecoration(
                            color: colorScheme.primary,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'الإشارة المتوقعة: ',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                _predictionResult!.label,
                                style: TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // درجة الثقة
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'درجة الثقة:',
                              style: TextStyle(
                                fontSize: 14,
                                color: colorScheme.onPrimaryContainer,
                              ),
                            ),
                            Text(
                              '${(_predictionResult!.confidence * 100).toStringAsFixed(1)}%',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // شريط التقدم لدرجة الثقة
                        LinearProgressIndicator(
                          value: _predictionResult!.confidence,
                          backgroundColor: Colors.grey.shade300,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            colorScheme.primary,
                          ),
                          minHeight: 8,
                        ),
                      ],
                    ),
                  ),
                )
              else
                Card(
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(Icons.info_outline, color: Colors.grey.shade700),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'اضغط على الزر أعلاه للتعرف على الإشارة في الصورة.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade700,
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
