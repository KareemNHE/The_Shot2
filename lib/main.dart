// main.dart

import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:the_shot2/db/user_db.dart';
import 'package:provider/provider.dart';
import 'package:the_shot2/services/api_service.dart';
import 'package:the_shot2/viewmodels/camera_viewmodel.dart';
import 'package:the_shot2/viewmodels/edit_profile_viewmodel.dart';
import 'package:the_shot2/viewmodels/profile_viewmodel.dart';
import 'package:the_shot2/viewmodels/search_viewmodel.dart';
import 'package:the_shot2/views/bnb.dart';
import 'package:the_shot2/views/search_screen.dart';
import 'viewmodels/create_post_viewmodel.dart';
import 'viewmodels/captured_photo_viewmodel.dart';
import 'viewmodels/post_viewmodel.dart';
import 'viewmodels/home_viewmodel.dart';
import 'views/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();
  await FirebaseAppCheck.instance.activate();

  // Initialize the database
  await UserDatabase.instance.initDatabase();

  // Insert sample users
  await UserDatabase.instance.insertSampleUsers();

  runApp(const TheShot());
}

class TheShot extends StatelessWidget {
  const TheShot({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeViewModel()),
        ChangeNotifierProvider(create: (context) => PostViewModel()),
        ChangeNotifierProvider(create: (context) => CreatePostViewModel()), //Add back
        ChangeNotifierProvider(create: (context) => CapturedPhotoViewModel()), //Add back
        ChangeNotifierProvider(create: (context) => CameraViewModel()),
        ChangeNotifierProvider(create: (context) => ProfileViewModel()),
        ChangeNotifierProvider(create: (_) => EditProfileViewModel()),
        ChangeNotifierProvider(create: (_) => SearchViewModel(apiService: ApiService()), child: const SearchScreen(),)
      ],
      child: MaterialApp(
        title: 'The Shot',
        theme: ThemeData(useMaterial3: true),
        debugShowCheckedModeBanner: false,
        home: Login(), // Show login screen first
        routes: {
          '/home': (_) => const BottomNavBar(),
        },
      ),

    );
  }
}
