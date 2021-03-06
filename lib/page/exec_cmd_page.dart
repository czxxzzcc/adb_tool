import 'dart:io';

import 'package:adb_tool/config/dimens.dart';
import 'package:adb_tool/global/provider/process_info.dart';
import 'package:flutter/material.dart';
import 'package:global_repository/global_repository.dart';
import 'package:provider/provider.dart';

import 'process_page.dart';

class ExecCmdPage extends StatefulWidget {
  @override
  _ExecCmdPageState createState() => _ExecCmdPageState();
}

class _ExecCmdPageState extends State<ExecCmdPage> {
  TextEditingController editingController = TextEditingController();
  Future<void> execCmd() async {
    // Provider.of<ProcessState>(context).clear();
    // final String cmd = editingController.text;
    // final String result = await exec('echo $cmd\n$cmd');
    // Provider.of<ProcessState>(context).appendOut(result);
    Provider.of<ProcessState>(context).clear();
    NiProcess.exec(
      editingController.text,
      getStderr: true,
      callback: (output) {
        print('ss======>$output');

        if (output.trim() == 'process_exit') {
          return;
        }
        output = output.replaceAll('process_exit', '');
        Provider.of<ProcessState>(context).appendOut(output);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    AppBar appBar;
    if (Platform.isAndroid) {
      appBar = AppBar(
        brightness: Brightness.light,
        title: const Text('执行命令'),
      );
    }
    return Scaffold(
      // backgroundColor: Colors.white,
      appBar: appBar,
      body: Stack(
        alignment: Alignment.topCenter,
        children: [
          Padding(
            padding: EdgeInsets.fromLTRB(
              Dimens.gap_dp8,
              0,
              Dimens.gap_dp8,
              Dimens.gap_dp8,
            ),
            child: Stack(
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxHeight: MediaQuery.of(context).size.height -
                        kToolbarHeight -
                        120,
                  ),
                  // height: MediaQuery.of(context).size.height * 3 / 4,
                  child: const ProcessPage(),
                ),
                SizedBox(
                  height:
                      MediaQuery.of(context).size.height - kToolbarHeight - 120,
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.fromLTRB(
                  Dimens.gap_dp8,
                  0,
                  Dimens.gap_dp8,
                  Dimens.gap_dp28,
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(Dimens.gap_dp12),
                      child: TextField(
                        controller: editingController,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                        decoration: InputDecoration(
                          // border: OutlineInputBorder(
                          //   borderRadius: BorderRadius.circular(Dimens.gap_dp8),
                          // ),
                          border: InputBorder.none,
                          filled: true,
                          fillColor: Color(0xFFF0F0F0),
                        ),
                        onSubmitted: (_) {
                          execCmd();
                        },
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerRight,
                      child: IconButton(
                        icon: Icon(
                          Icons.arrow_forward_ios,
                          color: Colors.black.withOpacity(0.6),
                        ),
                        onPressed: () async {
                          execCmd();
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
