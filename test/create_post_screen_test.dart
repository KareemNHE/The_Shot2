import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:the_shot2/views/create_post_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {
  @override
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return MockCollectionReference();
  }
}

class MockCollectionReference extends Mock implements CollectionReference<Map<String, dynamic>> {}
class MockDocumentReference extends Mock implements DocumentReference<Map<String, dynamic>> {}

void main() {
  group('CreatePostScreen', () {
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockUsersCollection;
    late MockDocumentReference mockUserDocument;
    late MockCollectionReference mockPostsCollection;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockUsersCollection = MockCollectionReference();
      mockUserDocument = MockDocumentReference();
      mockPostsCollection = MockCollectionReference();

      when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(mockUsersCollection.doc(any)).thenReturn(mockUserDocument);
      when(mockUserDocument.collection('posts')).thenReturn(mockPostsCollection);
    });

    testWidgets('createPost creates a new post in Firestore', (WidgetTester tester) async {
      // Arrange
      final imageUrl = 'https://example.com/image.jpg';
      final caption = 'Test caption';
      final userId = 'user123';

      // Act
      await tester.pumpWidget(MaterialApp(
        home: CreatePostScreen(imageUrl: imageUrl),
      ));
      await tester.enterText(find.byType(TextField), caption);
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert
      verify(mockPostsCollection.add({
        'imageUrl': imageUrl,
        'caption': caption,
        'timestamp': anyNamed('timestamp'),
      })).called(1);
      expect(find.text('Post created successfully!'), findsOneWidget);
    });
  });
}