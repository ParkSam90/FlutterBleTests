import 'package:bluetooth_low_energy_android_example/const/data.dart';
import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'router_config.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<Splash> {
  @override
  void initState() {
    super.initState();
    print('initState 실행');
    checkUuid(); // UUID 확인 함수 호출
  }

  // UUID 삭제 함수 (필요시 사용)
  void deleteUuid() async {
    await storage.deleteAll();
  }

  // UUID 체크 함수
  void checkUuid() async {
    final newUuid = await storage.read(key: NEW_UUID); // 저장된 UUID 읽어오기
    print('UUID 확인 중...');
    print('uuid : $newUuid');

    if (newUuid != null && newUuid.isNotEmpty) {
      // UUID가 존재하는 경우
      print('UUID가 존재함. 메인 화면으로 이동');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => MaterialApp.router(
            routerConfig: routerConfig, // 앱의 라우터 설정
            theme: ThemeData.light().copyWith(
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
            darkTheme: ThemeData.dark().copyWith(
              materialTapTargetSize: MaterialTapTargetSize.padded,
            ),
          ),
        ),
        (route) => false, // 이전 화면 모두 제거
      );
    } else {
      // UUID가 없는 경우
      print('UUID가 없음. 로그인 화면으로 이동');
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(
          builder: (_) => LoginScreen(), // 로그인 화면으로 이동
        ),
        (route) => false, // 이전 화면 모두 제거
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.blueGrey, // 배경 색상 설정
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 16.0),
            CircularProgressIndicator(
              color: Colors.white, // 로딩 인디케이터 색상
            ),
          ],
        ),
      ),
    );
  }
}
