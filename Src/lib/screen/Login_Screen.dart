import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:ossproj_comfyride/screen/choice_style.dart';

class Login_Screen extends StatefulWidget {
  const Login_Screen({super.key});

  @override
  State<Login_Screen> createState() => _Login_ScreenState();
}

class _Login_ScreenState extends State<Login_Screen> {
  String _uid = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(''),
        backgroundColor: Color(0xFF2196F3),
      ),
      body: SafeArea(
        child: Container(
          color: Colors.blue,
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start, // Align children at the start
            children: [
              Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 30), // Add padding for spacing
                  child: Text(
                    'FTTI',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 75,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Center(
                child: Text(
                  'Fashion Tendency Types Indicator',
                  style: TextStyle(color: Colors.white, fontSize: 23),
                ),
              ),
              SizedBox(height: 200),
              Center(
                child: Text(
                  '알려줘, 나의 패션 코드!',
                  style: TextStyle(color: Colors.white, fontSize: 30),
                ),
              ),
              SizedBox(height: 130),
              Center(
                child: ElevatedButton(
                  onPressed: () async {
                    // 구글 로그인 수행
                    final UserCredential? userCredential =
                        await signInWithGoogle();
                    // Firestore에 사용자 추가
                    await addUser(userCredential!);

                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => Choice_Style(uid: _uid),
                    ));
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      SizedBox(width: 50),
                      SizedBox(
                        width: 30,
                        height: 50,
                        child: Image.asset(
                          'assets/google.png',
                        ),
                      ),
                      SizedBox(width: 15),
                      Text(
                        'Google로 시작하기',
                        style: TextStyle(color: Colors.black, fontSize: 17),
                      ),
                      SizedBox(width: 50),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Trigger the authentication flow (구글 로그인 요청)
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      if (googleUser == null) {
        print('Google 로그인이 취소되었습니다.');
        return null;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in with Firebase
      final UserCredential userCredential =
          await FirebaseAuth.instance.signInWithCredential(credential);

      // Get the Firebase UID
      _uid = userCredential.user?.uid ?? "UID not available";

      // Print the Firebase UID to the console
      print('Firebase UID: $_uid');

      // Return the UserCredential
      return userCredential;
    } catch (e) {
      print('error: $e');
      return null;
    }
  }

  Future<void> addUser(UserCredential userCredential) async {
    try {
      // Get the Firebase UID
      _uid = userCredential.user?.uid ?? "UID not available";

      // UID를 문서 ID로 설정하여 문서 참조 생성
      final userDocRef =
          FirebaseFirestore.instance.collection('users').doc(_uid);

      // Firestore에서 사용자 문서 확인
      final docSnapshot = await userDocRef.get();

      // 'selected_codes'와 'FTTI' 필드가 이미 있는지 확인
      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null &&
            data.containsKey('selected_codes') &&
            data.containsKey('FTTI') &&
            data['selected_codes'] != '' &&
            data['FTTI'] != '') {
          print('User data already exists and is set properly.');
          return;
        }
      }

      // 기 등록 데이터 없을 경우 Firestore 문서에 user Data 저장
      final userData = {
        'uid': _uid,
        'selected_codes': '',
        'FTTI': '',
      };

      // Firestore 문서에 사용자 데이터를 설정
      await userDocRef.set(userData);

      print('Success add user id!');
    } catch (e) {
      print('Error: $e');
    }
  }
}
