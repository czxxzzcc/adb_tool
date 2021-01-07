import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';

import 'package:adb_tool/global/widget/custom_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:global_repository/global_repository.dart';

class LogoPage extends StatefulWidget {
  @override
  _LogoPageState createState() => _LogoPageState();
}

class _LogoPageState extends State<LogoPage> {
  @override
  void initState() {
    super.initState();
  }

  final GlobalKey _globalKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // _globalKey为需要图像化的widget的key
          final RenderRepaintBoundary boundary = _globalKey.currentContext
              .findRenderObject() as RenderRepaintBoundary;
          // ui.Image => image.Image
          final dynamic img = await boundary.toImage();
          final ByteData byteData =
              await img.toByteData(format: ImageByteFormat.png) as ByteData;
          final Uint8List pngBytes = byteData.buffer.asUint8List();
          File(PlatformUtil.getDataPath() + '/ic_launcher.png')
              .writeAsBytes(pngBytes);
        },
      ),
      body: Center(
        child: NiCardButton(
          borderRadius: 32,
          child: RepaintBoundary(
            key: _globalKey,
            child: Material(
              borderRadius: BorderRadius.circular(32),
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.symmetric(
                  vertical: 16.0,
                  horizontal: 16.0,
                ),
                child: Icon(
                  Icons.adb_rounded,
                  size: 160,
                  color: Color(0xff282b3e),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}