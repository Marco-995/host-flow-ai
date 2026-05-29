import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:host_flow/main.dart';

void main() {
  test('MyApp can be constructed without rendering shell', () {
    const app = MyApp();
    expect(app, isA<StatelessWidget>());
  });
}
