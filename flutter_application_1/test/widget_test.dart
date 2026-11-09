import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_1/main.dart';

void main() {
  testWidgets('KiemTraFlutterApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const KiemTraFlutterApp());
    expect(find.text('Khoa CNTT'), findsOneWidget);
    expect(find.text('MSSV 1250080122'), findsOneWidget);
    expect(find.text('Họ tên Trần Hữu Nhân'), findsOneWidget);
    expect(find.text('MSSV 1250080139'), findsOneWidget);
    expect(find.text('Họ tên Trương Gia Phát'), findsOneWidget);
  });
}
