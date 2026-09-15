import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('Hermes Studio Mobile has the expected release identity', () {
    final pubspec = File('pubspec.yaml').readAsStringSync();
    final match = RegExp(
      r'^version:\s*([^\s+]+)\+(\d+)\s*$',
      multiLine: true,
    ).firstMatch(pubspec);

    expect(match, isNotNull);
    expect(match!.group(1), '1.0.0');
    expect(int.parse(match.group(2)!), 1);
  });

  test('Gradle declares the fresh-app identity without the upstream floor', () {
    final gradle = File('android/app/build.gradle.kts').readAsStringSync();

    // New app: no upgrade guard from the upstream Hermes APK.
    expect(gradle, contains('applicationId = "com.hermesstudio.mobile"'));
    expect(gradle, contains('manifestPlaceholders["appLabel"] = "Hermes Studio"'));
  });
}
