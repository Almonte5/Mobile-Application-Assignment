import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:mq_marketplace/services/auth_service.dart';

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

void main() {
  late MockFirebaseAuth mockAuth;
  late FakeFirebaseFirestore fakeFirestore;
  late AuthService authService;

  setUp(() {
    mockAuth = MockFirebaseAuth();
    fakeFirestore = FakeFirebaseFirestore();
    authService = AuthService(auth: mockAuth, firestore: fakeFirestore);
  });

  group('AuthService.signIn', () {
    test('succeeds when Firebase returns a credential', () async {
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => MockUserCredential());

      await expectLater(
        authService.signIn(
          email: 'test@students.mq.edu.au',
          password: 'password123',
        ),
        completes,
      );
    });

    test('throws AuthException with mapped message on FirebaseAuthException',
        () async {
      when(
        () => mockAuth.signInWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenThrow(FirebaseAuthException(code: 'invalid-credential'));

      expect(
        () => authService.signIn(
          email: 'test@students.mq.edu.au',
          password: 'wrongpassword',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Email or password is incorrect.',
          ),
        ),
      );
    });
  });

  group('AuthService.signUp', () {
    test('throws AuthException immediately for non-MQ email', () async {
      expect(
        () => authService.signUp(
          email: 'notmq@gmail.com',
          password: 'password123',
          displayName: 'Test User',
        ),
        throwsA(
          isA<AuthException>().having(
            (e) => e.message,
            'message',
            'Please use your MQ email address.',
          ),
        ),
      );

      verifyNever(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      );
    });

    test('creates Firestore user doc on successful signup', () async {
      final mockUser = MockUser();
      final mockCredential = MockUserCredential();

      when(() => mockUser.uid).thenReturn('uid-123');
      when(() => mockCredential.user).thenReturn(mockUser);
      when(
        () => mockAuth.createUserWithEmailAndPassword(
          email: any(named: 'email'),
          password: any(named: 'password'),
        ),
      ).thenAnswer((_) async => mockCredential);

      await authService.signUp(
        email: 'test@students.mq.edu.au',
        password: 'password123',
        displayName: 'Test User',
      );

      // Verify the doc was written to the fake Firestore
      final doc = await fakeFirestore.collection('users').doc('uid-123').get();
      expect(doc.exists, isTrue);
      expect(doc.data()!['displayName'], 'Test User');
      expect(doc.data()!['email'], 'test@students.mq.edu.au');
    });
  });

  group('AuthService.signOut', () {
    test('delegates to FirebaseAuth.signOut', () async {
      when(() => mockAuth.signOut()).thenAnswer((_) async {});

      await authService.signOut();

      verify(() => mockAuth.signOut()).called(1);
    });
  });
}
