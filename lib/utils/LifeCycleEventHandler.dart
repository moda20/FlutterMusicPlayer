import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class LifecycleEventHandler extends WidgetsBindingObserver {
  LifecycleEventHandler({this.resumeCallBack, this.suspendingCallBack});

  final Future<void> resumeCallBack;
  final Future<void> suspendingCallBack;

  @override
  Future<Null> didChangeAppLifecycleState(AppLifecycleState state) async {


    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
      case AppLifecycleState.suspending:
        print("Suspending");
        await suspendingCallBack;
        break;
      case AppLifecycleState.resumed:
        print("Resuming");
        await resumeCallBack;
        break;
    }
  }
}