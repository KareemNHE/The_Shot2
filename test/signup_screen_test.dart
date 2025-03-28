import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:the_shot2/components/SUbutton.dart';
import 'package:the_shot2/components/textfield.dart';
import 'package:the_shot2/user_auth/firebase_auth_implementation/firebase_auth_services.dart';
import 'package:the_shot2/views/signup_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockFirebaseAuthService extends Mock implements FirebaseAuthService {
  @override
  Future<User?> signUpWithEmailAndPassword(String email, String password) {
    return super.noSuchMethod(
      Invocation.method(#signUpWithEmailAndPassword, [email, password]),
      returnValue: Future.value(MockUser(uid: 'user123', email: email)),
    );
  }
}

void main() {
  group('Signup', () {
    late MockFirebaseAuthService mockAuthService;

    setUp(() {
      mockAuthService = MockFirebaseAuthService();
    });

    testWidgets('User can sign up with valid credentials', (WidgetTester tester) async {
      // Arrange
      final firstName = 'John';
      final lastName = 'Doe';
      final email = 'johndoe@example.com';
      final password = 'password123';

      await tester.pumpWidget(
        MaterialApp(
          home: Signup(),
        ),
      );

      // Act
      await tester.enterText(find.byType(MyTextField).at(0), firstName);
      await tester.enterText(find.byType(MyTextField).at(1), lastName);
      await tester.enterText(find.byType(MyTextField).at(2), email);
      await tester.enterText(find.byType(MyTextField).at(3), password);
      await tester.tap(find.byType(MyButton));
      await tester.pumpAndSettle();

      // Assert
      verify(mockAuthService.signUpWithEmailAndPassword(email, password)).called(1);
      expect(find.text('User is successfully created'), findsOneWidget);
    });
  });
}

class MockUser extends Mock implements User {
  final String uid;
  final String email;

  MockUser({required this.uid, required this.email});
}