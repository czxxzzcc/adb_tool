import 'dart:developer';
import 'dart:io';

import 'package:adb_tool/drawer.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';
import 'config/global.dart';
import 'global/provider/devices_state.dart';
import 'global/provider/process_info.dart';
import 'global/widget/custom_scaffold.dart';
import 'page/exec_cmd_page.dart';
import 'page/home_page.dart';
import 'page/install/adb_install_page.dart';
import 'page/install/adb_insys_page.dart';
import 'page/logo_page.dart';
import 'page/net_debug/remote_debug_page.dart';
import 'page/search_ip_page.dart';

void main() {
  runApp(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'sarasa',
      ),
      home: AdbTool(),
    ),
  );
  log(
    'error',
    level: 0,
    // le
  );
  log(
    'error',
    level: 1,
    // le
  );
  log(
    'error',
    level: 2,
    // le
  );
  log(
    'error',
    level: 3,
    // le
  );
  Log.w('waring');
  Log.e('error');
  Log.i('info');
  Log.d('debug');
  // if (Platform.isAndroid) {
  //   final MethodChannel methodChannel = MethodChannel('multicast-lock');
  //   methodChannel.invokeMethod<void>('aquire');
  // }
  PlatformUtil.setPackageName('com.nightmare.adbtools');
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarDividerColor: Colors.transparent,
    ),
  );
}

class AdbTool extends StatefulWidget {
  @override
  _AdbToolState createState() => _AdbToolState();
}

class _AdbToolState extends State<AdbTool> {
  @override
  void initState() {
    super.initState();
  }

  Future<bool> adbExist() async {
    await Global.instance.initGlobal();
    // print(PlatformUtil.environment()['PATH']);
    // print(await NiProcess.exec('echo \$PATH'));
    // print("-> ${await PlatformUtil.cmdIsExist('scrcpy')}");
    return PlatformUtil.cmdIsExist('adb');
  }

  // void test() {
  //   if (Platform.isAndroid) {
  //     RawDatagramSocket.bind(InternetAddress('192.168.208.0'), 0)
  //         .then((RawDatagramSocket socket) {
  //       print('Sending from ${socket.address.address}:${socket.port}');
  //       int port = 6666;
  //       socket.send('Hello from UDP land!\n'.codeUnits,
  //           InternetAddress.LOOPBACK_IP_V4, port);
  //     });
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    // test();
    return MultiProvider(
      providers: <SingleChildCloneableWidget>[
        ChangeNotifierProvider<ProcessState>(
          create: (_) => ProcessState(),
        ),
        ChangeNotifierProvider<DevicesState>(
          create: (_) => DevicesState(),
        ),
      ],
      child: Theme(
        data: ThemeData(
          appBarTheme: const AppBarTheme(
            color: Colors.transparent,
            elevation: 0.0,
            centerTitle: true,
            iconTheme: IconThemeData(color: Colors.black),
            textTheme: TextTheme(
              headline6: TextStyle(
                height: 1.0,
                fontSize: 20.0,
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        child: FutureBuilder<bool>(
          future: adbExist(),
          builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
            Global.instance.processState = Provider.of(context);
            NiToast.initContext(context);
            if (PlatformUtil.isDesktop()) {
              ScreenUtil.init(
                context,
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                allowFontScaling: false,
              );
            } else {
              ScreenUtil.init(
                context,
                width: 414,
                height: 896,
                allowFontScaling: false,
              );
            }
            return LogoPage();
            // if (Platform.isAndroid) return NFCReader();
            return _AdbTool();
            switch (snapshot.connectionState) {
              case ConnectionState.none:
                print('还没有开始网络请求');
                return const Text('');
              case ConnectionState.active:
                return const Text('ConnectionState.active');
              case ConnectionState.waiting:
                return const Center(
                  child: CircularProgressIndicator(),
                );
              case ConnectionState.done:
                if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                }
                if (!snapshot.data) {
                  return AdbInstallPage();
                }
                return _AdbTool();
              default:
                return null;
            }
          },
        ),
      ),
    );
  }
}

class _AdbTool extends StatefulWidget {
  @override
  __AdbToolState createState() => __AdbToolState();
}

class __AdbToolState extends State<_AdbTool> {
  int currentIndex = 0;
  int pageIndex = 0;
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Global.instance.processState = Provider.of<ProcessState>(context);
    return Material(
      child: Scaffold(
        // backgroundColor: Colors.white,
        // floatingActionButton: FloatingActionButton(onPressed: () {
        //   NiProcess.exit();
        // }),
        body: NiScaffold(
          drawer: DrawerPage(
            index: pageIndex,
            onChange: (index) {
              pageIndex = index;
              setState(() {});
              if (PlatformUtil.isMobilePhone()) {
                Navigator.pop(context);
              }
            },
          ),
          body: listWidget[pageIndex],
        ),
      ),
    );
  }
}

List<Widget> listWidget = [
  HomePage(),
  AdbInstallToSystemPage(),
  SearchIpPage(),
  RemoteDebugPage(),
  ExecCmdPage(),
];

// class NetworkInterfaceWidget extends StatefulWidget {
//   @override
//   _NetworkInterfaceState createState() => _NetworkInterfaceState();
// }

// class _NetworkInterfaceState extends State<NetworkInterfaceWidget> {
//   String _networkInterface;
//   @override
//   initState() {
//     super.initState();

//     NetworkInterface.list(includeLoopback: false, type: InternetAddressType.any)
//         .then((List<NetworkInterface> interfaces) {
//       setState(() {
//         _networkInterface = "";
//         interfaces.forEach((interface) {
//           _networkInterface += "### name: ${interface.name}\n";
//           int i = 0;
//           interface.addresses.forEach((address) {
//             _networkInterface += "${i++}) ${address.address}\n";
//           });
//         });
//       });
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("NetworkInterface"),
//       ),
//       body: Container(
//         padding: EdgeInsets.all(10.0),
//         child:
//             Text("Only in iOS.. :(\n\nNetworkInterface:\n $_networkInterface"),
//       ),
//     );
//   }
// }
