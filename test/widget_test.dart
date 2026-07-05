import 'package:flutter_test/flutter_test.dart';

// Pastikan import ini sesuai dengan nama project Anda
import 'package:geo_attend/main.dart'; 

void main() {
  testWidgets('GeoAttend app smoke test', (WidgetTester tester) async {
    // Build aplikasi kita menggunakan class yang baru
    await tester.pumpWidget(const GeoAttendApp());

    // Karena aplikasi kita sekarang diawali dengan layar Login,
    // kita cukup menguji apakah teks 'Selamat Datang' muncul di layar.
    expect(find.text('Selamat Datang'), findsOneWidget);
  });
}