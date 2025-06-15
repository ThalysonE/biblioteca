import 'package:biblioteca/data/providers/login_provider.dart';
import 'package:biblioteca/data/services/redefinir_senha_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';

class MockRedefinirSenhaService extends Mock implements RedefinirSenhaService {}

void main() {
  late MockRedefinirSenhaService mockService;

  setUp(() {
    mockService = MockRedefinirSenhaService();
  });

  testWidgets('Deve alternar entre modos de login corretamente', (tester) async {
    final provider = LoginProvider()..redefinirSenhaService = mockService;

    await tester.pumpWidget(
      MaterialApp(
        home: ChangeNotifierProvider.value(
          value: provider,
          child: Builder(
            builder: (context) {
              return Scaffold(
                body: Column(
                  children: [
                    Text(context.watch<LoginProvider>().modoLogin.name),
                    TextButton(
                      onPressed: () => context.read<LoginProvider>().setModo(ModoLogin.redefinirSenha),
                      child: const Text('Redefinir Senha'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('login'), findsOneWidget);
    await tester.tap(find.text('Redefinir Senha'));
    await tester.pumpAndSettle();
    expect(find.text('redefinirSenha'), findsOneWidget);
  });

testWidgets('Deve iniciar com valores padrão corretos', (tester) async {
  final provider = LoginProvider()..redefinirSenhaService = mockService;

  await tester.pumpWidget(
    MaterialApp(
      home: ChangeNotifierProvider.value(
        value: provider,
        child: Builder(
          builder: (context) {
            return Scaffold(
              body: Column(
                children: [
                  Text(context.watch<LoginProvider>().modoLogin.name),
                  Text(context.watch<LoginProvider>().error),
                ],
              ),
            );
          },
        ),
      ),
    ),
  );

  expect(find.text('login'), findsOneWidget);
  expect(find.text(''), findsOneWidget); // Verifica erro vazio
});




}