import 'package:derm_iapp/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  // Se quita el skip cuando el entorno disponga de Flutter SDK.
  testWidgets(
    'La app renderiza la pantalla de inicio',
    (tester) async {
      await tester.pumpWidget(const DermIappApp());
      expect(find.text('Inicio'), findsOneWidget);
    },
    skip:
        'Requiere Flutter SDK local (no disponible en la máquina de desarrollo durante S2). Ver app/README.md y la checklist de app/docs/S2_initialize.md §7.',
  );
}
