import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

/// نتيجة الاستدلال من نموذج الذكاء الاصطناعي
///
/// تحتوي على التسمية المتوقعة (A, B, C, D, E) ودرجة الثقة.
class PredictionResult {
  const PredictionResult({required this.label, required this.confidence});

  /// التسمية المتوقعة: 'A', 'B', 'C', 'D', أو 'E'
  final String label;

  /// درجة الثقة (من 0.0 إلى 1.0)
  final double confidence;
}

/// خدمة نموذج الذكاء الاصطناعي
///
/// هذه الخدمة مسؤولة عن:
/// - تحميل نموذج TensorFlow Lite مرة واحدة
/// - معالجة الصور قبل الاستدلال (تغيير الحجم والتطبيع)
/// - تشغيل الاستدلال على الصور
/// - إرجاع النتائج بشكل واضح
///
/// ملاحظة: هذه خدمة بسيطة مناسبة لمشروع جامعي.
class AIModelService {
  // Singleton pattern - نحمّل النموذج مرة واحدة فقط
  static AIModelService? _instance;
  static AIModelService get instance {
    _instance ??= AIModelService._();
    return _instance!;
  }

  AIModelService._();

  Interpreter? _interpreter;
  bool _isLoading = false;
  bool _isLoaded = false;

  /// التسميات المحتملة للنموذج (A, B, C, D, E)
  static const List<String> _labels = ['A', 'B', 'C', 'D', 'E'];

  /// حجم الصورة المدخل المطلوب من النموذج (64x64)
  static const int _inputSize = 64;

  /// تحميل النموذج من ملف assets
  ///
  /// يتم استدعاء هذه الدالة مرة واحدة عند أول استخدام للخدمة.
  Future<void> loadModel() async {
    if (_isLoaded || _isLoading) return;

    _isLoading = true;

    try {
      // تحميل ملف النموذج من assets
      final ByteData modelData = await rootBundle.load(
        'assets/model/model.tflite',
      );
      final Uint8List modelBytes = modelData.buffer.asUint8List();

      // إنشاء مفسر TensorFlow Lite
      _interpreter = Interpreter.fromBuffer(modelBytes);

      _isLoaded = true;
      _isLoading = false;
    } catch (e) {
      _isLoading = false;
      throw Exception('فشل تحميل النموذج: $e');
    }
  }

  /// معالجة الصورة قبل الاستدلال
  ///
  /// الخطوات:
  /// 1. قراءة الصورة من الملف
  /// 2. تغيير الحجم إلى 64x64
  /// 3. تحويل الصورة إلى مصفوفة من القيم العددية
  /// 4. تطبيع القيم إلى النطاق [0, 1]
  Future<List<List<List<List<double>>>>> _preprocessImage(
    File imageFile,
  ) async {
    // قراءة الصورة من الملف
    final Uint8List imageBytes = await imageFile.readAsBytes();

    // فك تشفير الصورة (يدعم JPEG و PNG)
    img.Image? image = img.decodeImage(imageBytes);
    if (image == null) {
      throw Exception('فشل قراءة الصورة');
    }

    // تغيير حجم الصورة إلى 64x64 (الحجم المطلوب من النموذج)
    image = img.copyResize(image, width: _inputSize, height: _inputSize);

    // إنشاء مصفوفة الإدخال: [1, 64, 64, 3]
    // (batch=1, height=64, width=64, channels=3 RGB)
    final input = List.generate(
      1,
      (_) => List.generate(
        _inputSize,
        (y) => List.generate(_inputSize, (x) {
          // الحصول على لون البكسل في الموضع (x, y)
          final pixel = image!.getPixel(x, y);

          // استخراج قيم RGB وتطبيعها إلى [0, 1]
          return [
            (pixel.r / 255.0), // Red
            (pixel.g / 255.0), // Green
            (pixel.b / 255.0), // Blue
          ];
        }),
      ),
    );

    return input;
  }

  /// تشغيل الاستدلال على صورة واحدة
  ///
  /// المدخلات:
  /// - imageFile: ملف الصورة المراد تحليلها
  ///
  /// المخرجات:
  /// - PredictionResult: يحتوي على التسمية المتوقعة ودرجة الثقة
  Future<PredictionResult> predict(File imageFile) async {
    // التأكد من تحميل النموذج
    if (!_isLoaded) {
      await loadModel();
    }

    if (_interpreter == null) {
      throw Exception('النموذج غير محمّل');
    }

    try {
      // معالجة الصورة
      final input = await _preprocessImage(imageFile);

      // الحصول على شكل المخرج من النموذج
      final outputShape = _interpreter!.getOutputTensor(0).shape;

      // إنشاء مصفوفة المخرجات
      final output = List.generate(
        outputShape[0],
        (_) => List.filled(outputShape[1], 0.0),
      );

      // تشغيل الاستدلال
      _interpreter!.run(input, output);

      // العثور على أعلى قيمة في المخرجات (التسمية المتوقعة)
      final predictions = output[0];
      double maxConfidence = 0.0;
      int maxIndex = 0;

      // البحث عن أعلى قيمة في المخرجات
      for (int i = 0; i < predictions.length; i++) {
        final value = predictions[i];
        if (value > maxConfidence) {
          maxConfidence = value;
          maxIndex = i;
        }
      }

      // تطبيع درجة الثقة إلى [0, 1]
      // في معظم الحالات، النموذج يعيد احتمالات مباشرة بعد softmax
      // إذا كانت القيم خارج النطاق [0, 1]، قد تكون logits وتحتاج softmax
      double confidence = maxConfidence.clamp(0.0, 1.0);

      // إذا كانت القيم تبدو كـ logits (أكبر من 1 أو سالبة)، نطبق softmax
      bool isLogits = false;
      for (int i = 0; i < predictions.length; i++) {
        final value = predictions[i];
        if (value < 0 || value > 1) {
          isLogits = true;
          break;
        }
      }

      if (isLogits) {
        // تطبيق softmax للتحويل من logits إلى احتمالات
        double sumExp = 0.0;
        for (int i = 0; i < predictions.length; i++) {
          sumExp += math.exp((predictions[i] as num).clamp(-20, 20).toDouble());
        }
        if (sumExp > 0) {
          confidence = (math.exp(
                    (maxConfidence as num).clamp(-20, 20).toDouble(),
                  ) /
                  sumExp)
              .clamp(0.0, 1.0);
        }
      }

      // الحصول على التسمية المقابلة
      final label = _labels[maxIndex];

      return PredictionResult(label: label, confidence: confidence);
    } catch (e) {
      throw Exception('فشل الاستدلال: $e');
    }
  }

  /// إغلاق المفسر وتحرير الموارد
  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isLoaded = false;
    _isLoading = false;
  }
}
