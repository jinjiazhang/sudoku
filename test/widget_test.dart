import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sudoku/main.dart';

void main() {
  testWidgets('Sudoku app loads', (WidgetTester tester) async {
    await tester.pumpWidget(const SudokuApp());
    expect(find.text('主页'), findsOneWidget);
    expect(find.text('我'), findsOneWidget);
  });
}
