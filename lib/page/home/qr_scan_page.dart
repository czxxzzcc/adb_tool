import 'dart:io';

import 'package:adb_tool/config/candy_colors.dart';
import 'package:adb_tool/config/config.dart';
import 'package:adb_tool/config/global.dart';
import 'package:adb_tool/global/widget/custom_card.dart';
import 'package:adb_tool/page/home/provider/device_entitys.dart';
import 'package:adb_tool/page/home_page.dart';
import 'package:adb_tool/page/list/devices_list.dart';
import 'package:adb_tool/utils/socket_util.dart';
import 'package:custom_log/custom_log.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';
import 'package:qr_flutter/qr_flutter.dart';

class QrScanPage extends StatefulWidget {
  @override
  _QrScanPageState createState() => _QrScanPageState();
}

class _QrScanPageState extends State<QrScanPage> {
  String content = '';
  // Random random = Random();
  Future<void> getQrCode() async {
    // port = 9000 + Random().nextInt(9) * 10 + Random().nextInt(9);
    // print('port -> $port');

    final List<String> localAddress = await PlatformUtil.localAddress();
    print(localAddress);
    for (final String localAddress in localAddress) {
      if (localAddress.startsWith('192.')) {
        content += localAddress + ':${Config.qrPort}\n';
      }
    }
    content = content.trim().replaceAll('\n', ';');
    setState(() {});
    Log.v('content -> $content');
  }

  Future<void> connectDevices(String ip) async {
    final DeviceEntitys deviceEntitys = Global.instance.deviceEntitys;
    NiToast.initContext(context);
    NiToast.showToast('扫描成功');

    DevicesEntity devicesEntity;
    for (int i = 0; i < deviceEntitys.devicesEntitys.length; i++) {
      if (deviceEntitys.devicesEntitys[i].serial.contains(ip)) {
        devicesEntity = deviceEntitys.devicesEntitys[i];
      }
    }
    if (devicesEntity != null) {
      if (!devicesEntity.connect()) {
        final ProcessResult result = await Process.run(
          'adb',
          [
            'disconnect',
            ip + ':5555',
          ],
          runInShell: true,
          includeParentEnvironment: true,
          environment: PlatformUtil.environment(),
        );
      }
    }
    final ProcessResult result = await Process.run(
      'adb',
      [
        'connect',
        ip + ':5555',
      ],
      runInShell: true,
      includeParentEnvironment: true,
      environment: PlatformUtil.environment(),
    );
    Log.w(result.stdout);
    if (result.stdout.toString().contains('unable to connect') ||
        result.stdout.toString().contains('failed to connect')) {
      NiToast.showToast('连接失败，对方设备可能未打开网络ADB调试');
      return;
    }
    NiToast.showToast((devicesEntity != null ? '尝试重新连接，' : '') + '等待授权');
    while (true) {
      await Future<void>.delayed(const Duration(milliseconds: 100), () {});
      DevicesEntity devicesEntity;
      for (int i = 0; i < deviceEntitys.devicesEntitys.length; i++) {
        if (deviceEntitys.devicesEntitys[i].serial.contains(ip)) {
          devicesEntity = deviceEntitys.devicesEntitys[i];
          //  if(deviceEntitys.devicesEntitys[i].connect()){
          //    break;
          //  }
        }
      }
      if (devicesEntity == null) {
        continue;
      }
      if (devicesEntity.connect()) {
        break;
      }
    }

    Log.v('result.stdout -> ${result.stdout}');
    Log.e('result.stderr -> ${result.stderr}');
  }

  @override
  void initState() {
    super.initState();
    getQrCode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (content.isEmpty) {
      return const Material(
        color: Colors.transparent,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    return Stack(
      alignment: Alignment.center,
      children: [
        NiCardButton(
          onTap: () {
            setState(() {});
          },
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                width: 1,
                color: CandyColors.getRandomColor(),
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: QrImage(
              data: content,
              version: QrVersions.auto,
              size: 300.0,
            ),
          ),
        ), // Center(
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Material(
                color: Colors.transparent,
                child: Padding(
                  padding: EdgeInsets.symmetric(
                    horizontal: 8.0,
                  ),
                  child: Text(
                    '使用魇系列任意app扫描即可快速连接\n- 扫码设备与本设备需要在同一局域网\n- 扫码设备需要打开wifi adb调试',
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
    // return Image.memory(result);
  }
}
