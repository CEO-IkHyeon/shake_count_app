import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:shake/shake.dart';
import 'package:shake_count_app/red_box.dart';
import 'package:velocity_x/velocity_x.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  int _counter = 0;
  late ShakeDetector detector;

  @override
  void initState() {
    //addObserver에 관찰할 대상을 넣어줘야함 -> 해당 class는 State이기에 this를 넣어도 WidgetsBinding으로 인식안함
    // -> 그래서 'with WidgetsBindingObserver' 를 추가 -> '_MyHomePageState' 자체가 'WidgetsBindingObserver로 인식' (믹싱 형태로 구현)
    // with 대신 implements 사용 가능하지만 모든 함수를 override해서 구현해야함 -> 불필요
    WidgetsBinding.instance.addObserver(this);

    // initState에서 생성되어 하단의 lifecycle에서도 사용가능
    detector = ShakeDetector.autoStart(
      onPhoneShake: () {
        setState(() => _counter++);
      },
      shakeThresholdGravity: 1.5,
    );
    super.initState();
  }

  @override
  void dispose() {
    // 위에서 초기화할 때 listener 열어주고
    // 닫을 때 remove를 해야 리소스가 빠져나갈 가능성을 사전에 방지
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _incrementCounter() {
    setState(() {
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const RedBox(),
                // Container(
                //   color: Colors.red,
                //   width: 20,
                //   height: 20,
                // ),
                Column(
                  children: [
                    // redbox 주변으로 30의 여백이 있는 파란색 박스 만들기
                    const RedBox().box.padding(EdgeInsets.all(30)).color(Colors.blue).make(),
                    // Text() 위젯을 가독성있게 바꿀 수 있음 -> 마지막에 선언된 색이 적용된다
                    // 첫번째 .make를 했을 때 Text() 위젯을 반환하는 것이 아닌 'AutoSizeText'를 반환한다
                    // -> 'Text'위젯을 반환하게 하려면 .make() 이전에 _isIntrinsic()를 호출하면 된다
                    '흔들어서 카운트를 올려보세요.'
                        .text
                        .size(20)
                        .color(Colors.red)
                        .bold
                        .white
                        .black
                        .isIntrinsic
                        .makeCentered() // 텍스트가 중앙에 오게
                        .box // 여기서부턴 박스 관련 호출들
                        .withRounded(value: 50) //박스 둥글게 만듦
                        .color(Colors.green)
                        .height(150)
                        .make()
                        .pSymmetric(h: 20, v: 50),
                    const RedBox(),
                  ],
                ),
                const RedBox(),
              ],
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.displayLarge,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  // 앱 lifecycle이 바뀔 때 어떤 처리를 할 수 있는지
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    switch (state) {
      case AppLifecycleState.resumed:
        detector.startListening();
        break;
      case AppLifecycleState.inactive:
        break;
      case AppLifecycleState.detached:
        break;
      case AppLifecycleState.paused:
        detector.stopListening();
        break;
    }
  }
}
