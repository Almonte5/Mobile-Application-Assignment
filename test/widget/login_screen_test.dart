import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mq_marketplace/screens/login_screen.dart';
import 'package:mq_marketplace/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
  });

  Widget buildSubject() {
    return MaterialApp(
      home: LoginScreen(
        authService: AuthService(auth: mockAuth, firestore: fakeFirestore),
      ),
    );
  }

  group('LoginScreen', () {
    testWidgets('renders email and password fields and login button',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.text('Log In'), findsWidgets);
    });

    testWidgets('shows validation errors when submitted empty', (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('shows snackbar on auth error', (tester) async {
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      await tester.pumpWidget(buildSubject());

      await tester.enterText(
        find.byType(TextFormField).at(0),
        'test@students.mq.edu.au',
      );
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'wrongpassword',
      );

      await tester.tap(find.widgetWithText(ElevatedButton, 'Log In'));
      await tester.pumpAndSettle();

      expect(find.text('Email or password is incorrect.'), findsOneWidget);
    });

    testWidgets('navigates to SignUpScreen when sign up link tapped',
        (tester) async {
      await tester.pumpWidget(buildSubject());

      await tester.tap(find.text("Don't have an account? Sign up"));
      await tester.pumpAndSettle();

      expect(find.text('Sign Up'), findsWidgets);
    });
  });
}
