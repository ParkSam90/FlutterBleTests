import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:mCandle_Scanner/view/device_screen.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import './view/settings_screen.dart'; // 설정 화면 import
import './view/splash_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(), // 초기 화면을 SplashScreen으로 설정
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final targetDeviceName = 'mCandle Server App';
  int rssiThreshold = -71; // 기본 rssi 값
  int scanDuration = 60; // 기본 스캔 시간

  // FlutterBluePlus flutterBlue = FlutterBluePlus.instance;c
  List<ScanResult> scanResultList = [];
  bool _isScanning = false;
  List<BluetoothService> services = [];
  bool _isConnected = false;

  @override
  initState() {
    super.initState();
    // 블루투스 초기화
    initBle();
  }

  void initBle() {
    // BLE 스캔 상태 얻기 위한 리스너
    FlutterBluePlus.isScanning.listen((isScanning) {
      _isScanning = isScanning;
      setState(() {});
    });
  }

  /*
  스캔 시작/정지 함수
  */
  scan() async {
    if (!_isScanning) {
      // 스캔 중이 아니라면
      // 기존에 스캔된 리스트 삭제
      scanResultList.clear();
      FlutterBluePlus.startScan(timeout: Duration(seconds: scanDuration));

      // 스캔 결과 리스너
      FlutterBluePlus.scanResults.listen((results) {
        setState(() {
          scanResultList.clear();

          for (var result in results) {
            //rssi의 값이 -71 보다 작은 데이터를 스캔한다.
            if (-71 < result.rssi &&
                result.rssi < 0 &&
                !_isConnected &&
                result.device.advName == targetDeviceName) {
              if (!scanResultList.any((element) =>
                  element.device.remoteId == result.device.remoteId)) {
                scanResultList.add(result);
              }
              connectToDevice(result);
            }
            //스캔결과가 3개 이상이면 for문 종료.
            if (3 < scanResultList.length) {
              break;
            }
          }
        });
      });
    } else {
      // 스캔 중이라면 스캔 정지
      FlutterBluePlus.stopScan();
    }
  }

  // 선택된 장치에 연결하고 서비스 UUID를 가져오는 함수
  Future<void> connectToDevice(ScanResult result) async {
    try {
      // 장치와 연결 시도
      await result.device.connect();
      print('장치와 연결되었습니다.');

      // 연결 후, 장치의 서비스 목록 가져오기
      List<BluetoothService> servicesList =
          await result.device.discoverServices();
      setState(() {
        services = servicesList;
      });
    } catch (e) {
      print('장치 연결에 실패했습니다: $e');
    }
  }

  Widget serviceUuidWidget() {
    return services.isEmpty
        ? Text('Not connected yet...')
        : ListView.builder(
            shrinkWrap: true,
            itemCount: services.length,
            itemBuilder: (context, index) {
              String uuid = services[index].uuid.toString();

              // UUID 길이가 올바르지 않으면 스킵
              if (uuid.length < 32) {
                return Container(); // 잘못된 UUID는 렌더링하지 않음
              }

              // UUID 값을 형식화
              String formattedUuid = formatString(uuid);
              String first16 = getCustomUUid(formattedUuid);
              String seventeenth = getUseKakao(formattedUuid);

              if (seventeenth == '1') {
                seventeenth = '사용 가능';
              } else {
                seventeenth = '사용 불가능';
              }

              return ListTile(
                title: Text('멤버쉽 카드 번호: $first16'),
                subtitle: Text('Kakao Pay Y/N: $seventeenth'),
              );
            },
          );
  }

  Widget deviceSignal(ScanResult r) {
    return Text(r.rssi.toString());
  }

  /* 장치 아이템 위젯 */
  Widget listItem(ScanResult r) {
    return ListTile(
      onTap: () => connectToDevice(r), // 장치를 탭하면 연결 시도
      leading: Icon(Icons.bluetooth),
      title:
          Text(r.device.advName.isEmpty ? 'Unknown Device' : r.device.advName),
      // subtitle: Text(s.uuid.toString()),
      subtitle: serviceUuidWidget(),
      trailing: deviceSignal(r),
    );
  }

  /* 설정 화면에서 값 변경 후 받아오기 */
  Future<void> _navigateToSettings() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          rssiThreshold: rssiThreshold,
          scanDuration: scanDuration,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        rssiThreshold = result['rssiThreshold'];
        scanDuration = result['scanDuration'];
      });
    }
  }

  /* BLE 아이콘 위젯 */
  Widget leading(ScanResult r) {
    return CircleAvatar(
      child: Icon(
        Icons.bluetooth,
        color: Colors.white,
      ),
      backgroundColor: Colors.cyan,
    );
  }

  /* 장치 아이템을 탭 했을때 호출 되는 함수 */
  void onTap(ScanResult r) {
    // 단순히 이름만 출력
    print('${r.device.advName}');
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => DeviceScreen(device: r.device)),
    );
  }

  String formatString(String input) {
    // 하이픈(-)을 제거한 문자열 반환
    return input.replaceAll('-', '');
  }

  String getCustomUUid(String uuid) {
    if (uuid.length >= 16) {
      String first16 = uuid.substring(0, 16); // 앞 16자리 가져오기

      // 네자리마다 하이픈 추가
      List<String> chunks = [];
      for (int i = 0; i < first16.length; i += 4) {
        chunks.add(first16.substring(i, i + 4));
      }

      return chunks.join('-'); // 네 자리마다 '-' 추가된 문자열 반환
    } else {
      return uuid; // 만약 UUID가 16자리보다 짧으면 전체 반환
    }
  }

  /* Service UUID의 17번째 자리 가져오는 함수 */
  String getUseKakao(String uuid) {
    if (uuid.length >= 17) {
      return uuid[16]; // 17번째 문자 가져오기 (index는 0부터 시작)
    } else {
      return ''; // 만약 UUID가 17자리보다 짧으면 빈 문자열 반환
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        /* 장치 리스트 출력 */
        child: ListView.separated(
          itemCount: scanResultList.length,
          itemBuilder: (context, index) {
            return listItem(scanResultList[index]);
          },
          separatorBuilder: (BuildContext context, int index) {
            return Divider();
          },
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              TextButton(
                onPressed: scan, // 설정 화면으로 이동
                child: Text(_isScanning ? '스캔 중지' : '스캔 시작'),
              ),
              TextButton(
                onPressed: _navigateToSettings, // 설정 화면으로 이동
                child: Text('설정'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
