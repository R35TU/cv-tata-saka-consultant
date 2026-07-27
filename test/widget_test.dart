import 'package:flutter_test/flutter_test.dart';
import 'package:tugas_besar/main.dart';

void main() {
  testWidgets('app boots to the login screen', (tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(seconds: 3));
    await tester.pump();

    expect(find.text('Selamat Datang'), findsOneWidget);
    expect(find.text('Masuk'), findsOneWidget);
  });
}
