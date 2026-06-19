import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medistock_mobile/core/theme/app_text_styles.dart';

void main() {
  group('AppTextStyles', () {
    test('exposes the six required roles', () {
      for (final role in const [
        'screenTitle',
        'sectionHeader',
        'cardTitle',
        'body',
        'caption',
        'numericMetric',
      ]) {
        expect(AppTextStyles.of(role), isA<TextStyle>());
      }
    });

    test('each role has a distinct size and weight', () {
      final roles = <String, TextStyle>{
        'screenTitle': AppTextStyles.screenTitle,
        'sectionHeader': AppTextStyles.sectionHeader,
        'cardTitle': AppTextStyles.cardTitle,
        'body': AppTextStyles.body,
        'caption': AppTextStyles.caption,
        'numericMetric': AppTextStyles.numericMetric,
      };
      final signatures = <String>{};
      for (final entry in roles.entries) {
        signatures.add('${entry.value.fontSize}/${entry.value.fontWeight}');
      }
      expect(signatures.length, roles.length,
          reason: 'roles must differ in size or weight');
    });

    test('unknown role falls back to body', () {
      expect(AppTextStyles.of('nope'), AppTextStyles.body);
      expect(AppTextStyles.of(null), AppTextStyles.body);
    });

    test('numericMetric uses tabular figures', () {
      expect(
        AppTextStyles.numericMetric.fontFeatures,
        isNotNull,
      );
      expect(
        AppTextStyles.numericMetric.fontFeatures!
            .any((f) => f.feature == 'tnum'),
        isTrue,
      );
    });
  });
}
