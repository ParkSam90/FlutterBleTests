import 'package:bluetooth_low_energy_android_example/const/data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'router_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  String userUuid = '';
  final storage = FlutterSecureStorage(); // SecureStorage를 여기서 인스턴스화

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SafeArea(
            top: true,
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const _Title(), // 제목 위젯
                  const SizedBox(height: 16.0),
                  TextFormField(
                    decoration: const InputDecoration(
                      hintText: '카드번호를 입력해주세요.',
                    ),
                    onChanged: (value) {
                      setState(() {
                        userUuid = value; // 입력된 값을 상태로 업데이트
                      });
                    },
                  ),
                  const SizedBox(height: 16.0),
                  ElevatedButton(
                    child: const Text('확인'),
                    onPressed: () async {
                      // 입력된 UUID를 안전 저장소에 저장
                      final testUuid = userUuid + '000000000000000';
                      print('uuid :: $testUuid');
                      final finalUuid = formatString(testUuid);
                      print('final uuid :: $finalUuid');
                      await storage.write(key: NEW_UUID, value: finalUuid);

                      // 화면 전환: 라우터 설정된 화면으로 이동
                      Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                          builder: (_) => MaterialApp.router(
                            routerConfig: routerConfig,
                            theme: ThemeData.light().copyWith(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                            ),
                            darkTheme: ThemeData.dark().copyWith(
                              materialTapTargetSize:
                                  MaterialTapTargetSize.padded,
                            ),
                          ),
                        ),
                        (route) => false, // 이전 화면 모두 제거
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

String formatString(String input) {
  // 각 구분자의 길이
  List<int> segmentLengths = [8, 4, 4, 4, 12];
  int startIndex = 0;
  List<String> segments = [];

  // 각 길이에 맞춰서 문자열을 자른 후 리스트에 추가
  for (int length in segmentLengths) {
    segments.add(input.substring(startIndex, startIndex + length));
    startIndex += length;
  }

  // 리스트를 하이픈으로 합쳐서 최종 문자열 반환
  return segments.join('-');
}

class _Title extends StatelessWidget {
  const _Title({super.key});

  @override
  Widget build(BuildContext context) {
    return const Text(
      '안녕하세요. \n회원님의 카드정보16자리와 카카오페이 1자리를 입력해주세요.',
      style: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w500,
        color: Colors.black,
      ),
    );
  }
}
