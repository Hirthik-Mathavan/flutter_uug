import 'package:flutter/material.dart';
import 'package:flutter_qr_bar_scanner/qr_bar_scanner_camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qr_bar_scanner_example/services/barcode.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:liquid_progress_indicator/liquid_progress_indicator.dart';
import 'package:circular_countdown/circular_countdown.dart';
void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter QR/Bar Code Reader',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Flutter QR/Bar Code Reader'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  BarcodeModel b = BarcodeModel();
  String _qrInfo = 'Scan a QR/Bar code';
  bool _camState = false;
  String t;
  read(String code) async {
    var name = await b.getBarcode(code);
    print(name['items'][0]['title']);
    t = name['items'][0]['title'];
  }

  _qrCallback(String code) {
    // read(code);
    setState(() {
      _camState = false;
      _qrInfo = code;
    });
  }

  _scanCode() {
    setState(() {
      _camState = true;
    });
  }

  TabController _tabController;
  int _activeTabIndex = 0;
  @override
  void initState() {
    super.initState();
    _scanCode();
    _tabController = new TabController(vsync: this, length: 4);
  }

  // void _setActiveTabIndex() {
  //   setState(() {
  //     _activeTabIndex = _tabController.index;
  //   });
  // }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  int segmentedControlValue = 0;

  Widget segmentedControl() {
    return Container(
      child: CupertinoSlidingSegmentedControl(
          groupValue: segmentedControlValue,
          backgroundColor: Color(0xff3D3D41),
          children: <int, Widget>{
            0: Padding(
              padding: EdgeInsets.all(15.0),
              child: Text(
                'Scan Code',
                style: TextStyle(
                  color:
                      segmentedControlValue == 0 ? Colors.black : Colors.white,
                ),
              ),
            ),
            1: Text(
              'Enter Code',
              style: TextStyle(
                color: segmentedControlValue == 1 ? Colors.black : Colors.white,
              ),
            )
          },
          onValueChanged: (value) {
            if (value == 1) {
              _movewidget("Up");
              setState(() {
                focus = true;
              });
            }
            if (value == 0) {
              _movewidget("Down");
            }
            setState(() {
              segmentedControlValue = value;
            });
          }),
    );
  }

  double pos_l = 20;
  double pos_r = 20;
  double pos_t = 450;
  double pos_b = 0;
  void _movewidget(String pos) {
    setState(() {
      if (pos == "Up") {
        pos_t = 0;
        pos_b = 0;
      } else if (pos == "Down") {
        pos_t = 450;
        pos_b = 0;
      }
    });
  }

  bool _btnEnabled = false;
  var barcode = TextEditingController();

  bool isLoading = false;
  bool focus = true;
  Widget load() {
    return Container(
      decoration: BoxDecoration(
        color: Color(0xff328297),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          Padding(
            padding: const EdgeInsets.all(15.0),
            child: Text(
              "Hang on....\n\nWe are fetching data from multiple sources for you!!",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 25.0,
                color: Color(0xff6AC5FB),
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
          TimeCircularCountdown(
            textStyle: TextStyle(
              color: Colors.black,
              fontSize: 40.0,
            ),
            unit: CountdownUnit.second,
            countdownTotal: 10,
            countdownCurrentColor: Colors.red,
            countdownRemainingColor: Color(0xff328297),
            countdownTotalColor: Color(0xff6AC5FB),
            strokeWidth: 30.0,
            repeat: true,
            diameter: 150.0,
            onUpdated: (unit, remainingTime) => print('Updated'),
            onFinished: () => print('Countdown finished'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleClickMe() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return CupertinoAlertDialog(
          title: Text('Oops!'),
          content: Text('We could not find any data related to this product'),
          actions: <Widget>[
            CupertinoDialogAction(
              child: Text('Ok'),
              onPressed: () {
                setState(() {
                  _camState = true;
                });
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double size = MediaQuery.of(context).size.height * .58;
    return Scaffold(
      resizeToAvoidBottomPadding: false,
      // appBar: AppBar(
      //   title: Text(widget.title),
      // ),
      body: isLoading
          ? load()
          : Stack(
              children: <Widget>[
                Column(
                  children: <Widget>[
                    SizedBox(
                      height: MediaQuery.of(context).size.height,
                      width: 500,
                      child: segmentedControlValue == 0
                          ? QRBarScannerCamera(
                              onError: (context, error) => Text(
                                error.toString(),
                                style: TextStyle(color: Colors.red),
                              ),
                              qrCodeCallback: (code) async {
                                print(_activeTabIndex);
                                if (_camState) {
                                  _qrCallback(code);
                                  setState(() {
                                    isLoading = true;
                                    print("Starting");
                                  });
                                  if (isLoading) {
                                    print("yes");
                                  }
                                  String m1 = "";
                                  String m2 = "";
                                  String m1v = "";
                                  String m2v = "";

                                  var name = await b.getBarcode(code);
                                  print(name);
                                  // print(name['total']);

                                  if (name != null && name['total'] != 0) {
                                    if (name['total'] != 0) {
                                      print(name['items'][0]['title']);
                                      t = name['items'][0]['brand'];
                                      t = t + " " + name['items'][0]['model'];
                                      // var inst = await b.getLink(
                                      //     t, " installation");
                                      var mant =
                                          await b.getLink(t, " maintenance");
                                      // var rep = await b.getLink(
                                      //     t, " repair");
                                      // var hel = await b.getLink(
                                      //     t, " helps and tips");
                                      // print(
                                      //     inst['organic'][0]['url']);
                                      // String l1 =
                                      //     inst['organic'][0]['url'];
                                      // String l2 =
                                      //     inst['organic'][1]['url'];
                                      setState(() {
                                        m1 = mant['organic'][0]['url'];
                                        m2 = mant['organic'][1]['url'];
                                      });
                                      // String r1 =
                                      //     rep['organic'][0]['url'];
                                      // String r2 =
                                      //     rep['organic'][1]['url'];
                                      // String h1 =
                                      //     hel['organic'][0]['url'];
                                      // String h2 =
                                      //     hel['organic'][1]['url'];
                                      //
                                      // var instv =
                                      //     await b.getVideoLink(
                                      //         t, " installation");
                                      var mantv = await b.getVideoLink(
                                          t, " maintenance");
                                      // var repv = await b.getVideoLink(
                                      //     t, " repair");
                                      // var helv = await b.getVideoLink(
                                      //     t, " helps and tips");
                                      // print(
                                      //     inst['organic'][0]['url']);
                                      // String l1v =
                                      //     instv['video_results'][0]
                                      //         ['url'];
                                      // String l2v =
                                      //     instv['video_results'][1]
                                      //         ['url'];
                                      setState(() {
                                        m1v = mantv['video_results'][0]['url'];
                                        m2v = mantv['video_results'][1]['url'];
                                      });
                                      // String r1v =
                                      //     repv['video_results'][0]
                                      //         ['url'];
                                      // String r2v =
                                      //     repv['video_results'][1]
                                      //         ['url'];
                                      // String h1v =
                                      //     helv['video_results'][0]
                                      //         ['url'];
                                      // String h2v =
                                      //     helv['video_results'][1]
                                      //         ['url'];

                                      setState(() {
                                        isLoading = false;
                                        print("done");
                                      });

                                      String h1 = "";
                                      String h2 = "";
                                      String h1v = "";
                                      String h2v = "";
                                      // String l1 = "";
                                      // String l2 = "";
                                      // String l1v = "";
                                      // String l2v = "";

                                      showModalBottomSheet<void>(
                                          isScrollControlled: true,
                                          backgroundColor: Color(0xff328297),
                                          shape: RoundedRectangleBorder(
                                              borderRadius:
                                                  BorderRadius.vertical(
                                                      top:
                                                          Radius.circular(40))),
                                          context: context,
                                          builder: (context) {
                                            return StatefulBuilder(builder:
                                                (BuildContext context,
                                                    StateSetter setModalState
                                                    /*You can rename this!*/) {
                                              _tabController
                                                  .addListener(() async {
                                                setState(() {
                                                  _activeTabIndex =
                                                      _tabController.index;
                                                });
                                                if (_activeTabIndex == 1) {
                                                  setModalState(() {
                                                    isLoading = true;
                                                  });

                                                  var hel = await b.getLink(
                                                      t, " installation");
                                                  var helv =
                                                      await b.getVideoLink(
                                                          t, " installation");

                                                  setState(() {
                                                    h1 = hel['organic'][0]
                                                        ['url'];
                                                    h2 = hel['organic'][1]
                                                        ['url'];
                                                    h1v = helv['video_results']
                                                        [0]['url'];
                                                    h2v = helv['video_results']
                                                        [1]['url'];
                                                  });
                                                }
                                                if (_activeTabIndex == 2) {
                                                  setModalState(() {
                                                    isLoading = true;
                                                  });

                                                  var hel = await b.getLink(
                                                      t, " repair");
                                                  var helv =
                                                      await b.getVideoLink(
                                                          t, " repair");
                                                  setState(() {
                                                    h1 = hel['organic'][0]
                                                        ['url'];
                                                    h2 = hel['organic'][1]
                                                        ['url'];
                                                    h1v = helv['video_results']
                                                        [0]['url'];
                                                    h2v = helv['video_results']
                                                        [1]['url'];
                                                  });
                                                }
                                                if (_activeTabIndex == 3) {
                                                  setModalState(() {
                                                    isLoading = true;
                                                  });

                                                  var hel = await b.getLink(
                                                      t, " helps and tips");
                                                  var helv =
                                                      await b.getVideoLink(
                                                          t, " helps and tips");
                                                  setState(() {
                                                    h1 = hel['organic'][0]
                                                        ['url'];
                                                    h2 = hel['organic'][1]
                                                        ['url'];
                                                    h1v = helv['video_results']
                                                        [0]['url'];
                                                    h2v = helv['video_results']
                                                        [1]['url'];
                                                  });
                                                }
                                                setModalState(() {
                                                  isLoading = false;
                                                });
                                              });
                                              return Padding(
                                                padding: MediaQuery.of(context)
                                                    .viewInsets,
                                                child: isLoading
                                                    ? load()
                                                    : DefaultTabController(
                                                        length: 4,
                                                        initialIndex: 0,
                                                        child: Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          children: <Widget>[
                                                            Container(
                                                              child: TabBar(
                                                                // onTap:
                                                                //     (index) {
                                                                // print(index);
                                                                //
                                                                // if (index ==
                                                                //     3) {
                                                                //   setModalState(() {
                                                                //     isLoading = true;
                                                                //     print("Ok");
                                                                //   });
                                                                // }
                                                                // // var hel =
                                                                // //     await b.getLink(t, " helps and tips");
                                                                // // h1 =
                                                                // //     hel['organic'][0]['url'];
                                                                // // h2 =
                                                                // //     hel['organic'][1]['url'];
                                                                //
                                                                // setModalState(() {
                                                                //   isLoading = false;
                                                                // });
                                                                // },
                                                                controller:
                                                                    _tabController,
                                                                indicatorColor:
                                                                    Colors
                                                                        .white,
                                                                tabs: <Widget>[
                                                                  Tab(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .arrow_circle_down,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Tab(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .settings_outlined,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Tab(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .home_repair_service,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                  Tab(
                                                                    icon: Icon(
                                                                      Icons
                                                                          .help_outline_rounded,
                                                                      color: Colors
                                                                          .white,
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            Container(
                                                              height: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .height *
                                                                  0.75,
                                                              //I want to use dynamic height instead of fixed height
                                                              child: TabBarView(
                                                                controller:
                                                                    _tabController,
                                                                children: <
                                                                    Widget>[
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                        "Maintenance",
                                                                        style:
                                                                            TextStyle(
                                                                          fontSize:
                                                                              20.0,
                                                                          color:
                                                                              Colors.white,
                                                                          fontWeight:
                                                                              FontWeight.bold,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Alpha text - 1',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(m1)) {
                                                                                      await launch(m1);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Bravo text - 2',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(m2)) {
                                                                                      await launch(m2);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Charlie Video - 1',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(m1v)) {
                                                                                      await launch(m1v);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Delta Video - 2',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(m2v)) {
                                                                                      await launch(m2v);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                          "Installation",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                20.0,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          )),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Alpha text - 1',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h1)) {
                                                                                      await launch(h1);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Bravo text - 2',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h2)) {
                                                                                      await launch(h2);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Charlie Video - 1',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h1v)) {
                                                                                      await launch(h1v);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Delta Video - 2',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h2v)) {
                                                                                      await launch(h2v);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                          "Repair",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                20.0,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          )),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Alpha text - 1',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h1)) {
                                                                                      await launch(h1);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Bravo text - 2',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h2)) {
                                                                                      await launch(h2);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Charlie Video - 1',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h1v)) {
                                                                                      await launch(h1v);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Delta Video - 2',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h2v)) {
                                                                                      await launch(h2v);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  Column(
                                                                    mainAxisAlignment:
                                                                        MainAxisAlignment
                                                                            .spaceEvenly,
                                                                    children: <
                                                                        Widget>[
                                                                      Text(
                                                                          "Help & Tips",
                                                                          style:
                                                                              TextStyle(
                                                                            fontSize:
                                                                                20.0,
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight:
                                                                                FontWeight.bold,
                                                                          )),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      "Alpha Text - 1",
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h1)) {
                                                                                      await launch(h1);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Bravo text - 2',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h2)) {
                                                                                      await launch(h2);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Charlie Video - 1',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h1v)) {
                                                                                      await launch(h1v);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.only(
                                                                            top:
                                                                                12.5,
                                                                            left:
                                                                                10,
                                                                            right:
                                                                                10),
                                                                        child:
                                                                            Card(
                                                                          shape:
                                                                              RoundedRectangleBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(15.0),
                                                                          ),
                                                                          color:
                                                                              Color(0xff6AC5FB),
                                                                          elevation:
                                                                              10,
                                                                          child:
                                                                              Column(
                                                                            mainAxisSize:
                                                                                MainAxisSize.min,
                                                                            children: <Widget>[
                                                                              Padding(
                                                                                padding: const EdgeInsets.all(10.0),
                                                                                child: ListTile(
                                                                                  leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                  title: Padding(
                                                                                    padding: const EdgeInsets.only(left: 40.0),
                                                                                    child: Text(
                                                                                      'Delta Video - 2',
                                                                                      textAlign: TextAlign.left,
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Color(0xff2A35B8),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                  onTap: () async {
                                                                                    if (await canLaunch(h2v)) {
                                                                                      await launch(h2v);
                                                                                    }
                                                                                  },
                                                                                ),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  )
                                                                ],
                                                              ),
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                              );
                                            });
                                          }).whenComplete(() {
                                        setState(() {
                                          _camState = true;
                                        });
                                        print(
                                            'Hey there, I\'m calling after hide bottomSheet');
                                      });
                                    }
                                  } else {
                                    setState(() {
                                      isLoading = false;
                                    });
                                    _handleClickMe();
                                  }
                                }
                              },
                            )
                          : Container(
                              padding: const EdgeInsets.all(40.0),
                              decoration:
                                  BoxDecoration(color: Color(0xff328297)),
                              child: new Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                  Expanded(
                                    child: Padding(
                                      padding:
                                          const EdgeInsets.only(top: 100.0),
                                      child: AnimatedOpacity(
                                        opacity: segmentedControlValue == 1
                                            ? 1.0
                                            : 0.0,
                                        curve: Curves.easeInOut,
                                        duration: Duration(milliseconds: 500),
                                        child: TextFormField(
                                          // autovalidate: true,
                                          // // ignore: missing_return
                                          // validator: (String txt) {
                                          //   if (txt.length == 11) {
                                          //     setState(() {
                                          //       _btnEnabled = true;
                                          //     });
                                          //   } else {
                                          //     setState(() {
                                          //       _btnEnabled = false;
                                          //     });
                                          //   }
                                          // },
                                          controller: barcode,
                                          autofocus: focus,
                                          decoration: InputDecoration(
                                            fillColor: Colors.white,
                                            filled: true,
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(25.0),
                                              borderSide: BorderSide(
                                                color: Colors.white,
                                                width: 2.0,
                                              ),
                                            ),
                                            enabledBorder: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(15.0),
                                              borderSide: BorderSide(
                                                width: 2.0,
                                                color: Colors.white,
                                              ),
                                            ),
                                            prefixIcon:
                                                Icon(Icons.code_rounded),
                                            suffixIcon:
                                                //Icon(Icons.check_circle_outline),
                                                IconButton(
                                              icon: Icon(
                                                Icons.check_circle,
                                                size: 30.0,
                                              ),
                                              onPressed: () async {
                                                print(_activeTabIndex);
                                                setState(() {
                                                  isLoading = true;
                                                  print("Starting");
                                                });
                                                if (isLoading) {
                                                  print("yes");
                                                }
                                                String m1 = "";
                                                String m2 = "";
                                                String m1v = "";
                                                String m2v = "";

                                                var name = await b
                                                    .getBarcode(barcode.text);
                                                print(name);
                                                // print(name['total']);

                                                if (name != null &&
                                                    name['total'] != 0) {
                                                  if (name['total'] != 0) {
                                                    print(name['items'][0]
                                                        ['title']);
                                                    t = name['items'][0]
                                                        ['brand'];
                                                    t = t +
                                                        " " +
                                                        name['items'][0]
                                                            ['model'];
                                                    // var inst = await b.getLink(
                                                    //     t, " installation");
                                                    var mant = await b.getLink(
                                                        t, " maintenance");
                                                    // var rep = await b.getLink(
                                                    //     t, " repair");
                                                    // var hel = await b.getLink(
                                                    //     t, " helps and tips");
                                                    // print(
                                                    //     inst['organic'][0]['url']);
                                                    // String l1 =
                                                    //     inst['organic'][0]['url'];
                                                    // String l2 =
                                                    //     inst['organic'][1]['url'];
                                                    setState(() {
                                                      m1 = mant['organic'][0]
                                                          ['url'];
                                                      m2 = mant['organic'][1]
                                                          ['url'];
                                                    });
                                                    // String r1 =
                                                    //     rep['organic'][0]['url'];
                                                    // String r2 =
                                                    //     rep['organic'][1]['url'];
                                                    // String h1 =
                                                    //     hel['organic'][0]['url'];
                                                    // String h2 =
                                                    //     hel['organic'][1]['url'];
                                                    //
                                                    // var instv =
                                                    //     await b.getVideoLink(
                                                    //         t, " installation");
                                                    var mantv =
                                                        await b.getVideoLink(
                                                            t, " maintenance");
                                                    // var repv = await b.getVideoLink(
                                                    //     t, " repair");
                                                    // var helv = await b.getVideoLink(
                                                    //     t, " helps and tips");
                                                    // print(
                                                    //     inst['organic'][0]['url']);
                                                    // String l1v =
                                                    //     instv['video_results'][0]
                                                    //         ['url'];
                                                    // String l2v =
                                                    //     instv['video_results'][1]
                                                    //         ['url'];
                                                    setState(() {
                                                      m1v =
                                                          mantv['video_results']
                                                              [0]['url'];
                                                      m2v =
                                                          mantv['video_results']
                                                              [1]['url'];
                                                    });
                                                    // String r1v =
                                                    //     repv['video_results'][0]
                                                    //         ['url'];
                                                    // String r2v =
                                                    //     repv['video_results'][1]
                                                    //         ['url'];
                                                    // String h1v =
                                                    //     helv['video_results'][0]
                                                    //         ['url'];
                                                    // String h2v =
                                                    //     helv['video_results'][1]
                                                    //         ['url'];

                                                    setState(() {
                                                      isLoading = false;
                                                      focus = false;
                                                      print("done");
                                                    });

                                                    String h1 = "";
                                                    String h2 = "";
                                                    String h1v = "";
                                                    String h2v = "";
                                                    // String l1 = "";
                                                    // String l2 = "";
                                                    // String l1v = "";
                                                    // String l2v = "";

                                                    showModalBottomSheet<void>(
                                                        isScrollControlled:
                                                            true,
                                                        backgroundColor:
                                                            Color(0xff328297),
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius.vertical(
                                                                    top: Radius
                                                                        .circular(
                                                                            40))),
                                                        context: context,
                                                        builder: (context) {
                                                          return StatefulBuilder(
                                                              builder: (BuildContext
                                                                      context,
                                                                  StateSetter
                                                                      setModalState /*You can rename this!*/) {
                                                            _tabController
                                                                .addListener(
                                                                    () async {
                                                              setState(() {
                                                                _activeTabIndex =
                                                                    _tabController
                                                                        .index;
                                                              });
                                                              if (_activeTabIndex ==
                                                                  1) {
                                                                setModalState(
                                                                    () {
                                                                  isLoading =
                                                                      true;
                                                                });

                                                                var hel = await b
                                                                    .getLink(t,
                                                                        " installation");
                                                                var helv = await b
                                                                    .getVideoLink(
                                                                        t,
                                                                        " installation");

                                                                setState(() {
                                                                  h1 = hel[
                                                                          'organic']
                                                                      [
                                                                      0]['url'];
                                                                  h2 = hel[
                                                                          'organic']
                                                                      [
                                                                      1]['url'];
                                                                  h1v = helv[
                                                                          'video_results']
                                                                      [
                                                                      0]['url'];
                                                                  h2v = helv[
                                                                          'video_results']
                                                                      [
                                                                      1]['url'];
                                                                });
                                                              }
                                                              if (_activeTabIndex ==
                                                                  2) {
                                                                setModalState(
                                                                    () {
                                                                  isLoading =
                                                                      true;
                                                                });

                                                                var hel = await b
                                                                    .getLink(t,
                                                                        " repair");
                                                                var helv = await b
                                                                    .getVideoLink(
                                                                        t,
                                                                        " repair");
                                                                setState(() {
                                                                  h1 = hel[
                                                                          'organic']
                                                                      [
                                                                      0]['url'];
                                                                  h2 = hel[
                                                                          'organic']
                                                                      [
                                                                      1]['url'];
                                                                  h1v = helv[
                                                                          'video_results']
                                                                      [
                                                                      0]['url'];
                                                                  h2v = helv[
                                                                          'video_results']
                                                                      [
                                                                      1]['url'];
                                                                });
                                                              }
                                                              if (_activeTabIndex ==
                                                                  3) {
                                                                setModalState(
                                                                    () {
                                                                  isLoading =
                                                                      true;
                                                                });

                                                                var hel = await b
                                                                    .getLink(t,
                                                                        " helps and tips");
                                                                var helv = await b
                                                                    .getVideoLink(
                                                                        t,
                                                                        " helps and tips");
                                                                setState(() {
                                                                  h1 = hel[
                                                                          'organic']
                                                                      [
                                                                      0]['url'];
                                                                  h2 = hel[
                                                                          'organic']
                                                                      [
                                                                      1]['url'];
                                                                  h1v = helv[
                                                                          'video_results']
                                                                      [
                                                                      0]['url'];
                                                                  h2v = helv[
                                                                          'video_results']
                                                                      [
                                                                      1]['url'];
                                                                });
                                                              }
                                                              setModalState(() {
                                                                isLoading =
                                                                    false;
                                                              });
                                                            });
                                                            return Padding(
                                                              padding: MediaQuery
                                                                      .of(context)
                                                                  .viewInsets,
                                                              child: isLoading
                                                                  ? load()
                                                                  : DefaultTabController(
                                                                      length: 4,
                                                                      initialIndex:
                                                                          0,
                                                                      child:
                                                                          Column(
                                                                        mainAxisSize:
                                                                            MainAxisSize.min,
                                                                        children: <
                                                                            Widget>[
                                                                          Container(
                                                                            child:
                                                                                TabBar(
                                                                              // onTap:
                                                                              //     (index) {
                                                                              // print(index);
                                                                              //
                                                                              // if (index ==
                                                                              //     3) {
                                                                              //   setModalState(() {
                                                                              //     isLoading = true;
                                                                              //     print("Ok");
                                                                              //   });
                                                                              // }
                                                                              // // var hel =
                                                                              // //     await b.getLink(t, " helps and tips");
                                                                              // // h1 =
                                                                              // //     hel['organic'][0]['url'];
                                                                              // // h2 =
                                                                              // //     hel['organic'][1]['url'];
                                                                              //
                                                                              // setModalState(() {
                                                                              //   isLoading = false;
                                                                              // });
                                                                              // },
                                                                              controller: _tabController,
                                                                              indicatorColor: Colors.white,
                                                                              tabs: <Widget>[
                                                                                Tab(
                                                                                  icon: Icon(
                                                                                    Icons.arrow_circle_down,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                                Tab(
                                                                                  icon: Icon(
                                                                                    Icons.settings_outlined,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                                Tab(
                                                                                  icon: Icon(
                                                                                    Icons.home_repair_service,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                                Tab(
                                                                                  icon: Icon(
                                                                                    Icons.help_outline_rounded,
                                                                                    color: Colors.white,
                                                                                  ),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          Container(
                                                                            height:
                                                                                MediaQuery.of(context).size.height * 0.75, //I want to use dynamic height instead of fixed height
                                                                            child:
                                                                                TabBarView(
                                                                              controller: _tabController,
                                                                              children: <Widget>[
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: <Widget>[
                                                                                    Text(
                                                                                      "Maintenance",
                                                                                      style: TextStyle(
                                                                                        fontSize: 20.0,
                                                                                        color: Colors.white,
                                                                                        fontWeight: FontWeight.bold,
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Alpha text - 1',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(m1)) {
                                                                                                    await launch(m1);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Bravo text - 2',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(m2)) {
                                                                                                    await launch(m2);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Charlie Video - 1',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(m1v)) {
                                                                                                    await launch(m1v);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Delta Video - 2',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(m2v)) {
                                                                                                    await launch(m2v);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: <Widget>[
                                                                                    Text("Installation",
                                                                                        style: TextStyle(
                                                                                          fontSize: 20.0,
                                                                                          color: Colors.white,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        )),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Alpha text - 1',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h1)) {
                                                                                                    await launch(h1);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Bravo text - 2',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h2)) {
                                                                                                    await launch(h2);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Charlie Video - 1',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h1v)) {
                                                                                                    await launch(h1v);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Delta Video - 2',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h2v)) {
                                                                                                    await launch(h2v);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: <Widget>[
                                                                                    Text("Repair",
                                                                                        style: TextStyle(
                                                                                          fontSize: 20.0,
                                                                                          color: Colors.white,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        )),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Alpha text - 1',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h1)) {
                                                                                                    await launch(h1);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Bravo text - 2',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h2)) {
                                                                                                    await launch(h2);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Charlie Video - 1',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h1v)) {
                                                                                                    await launch(h1v);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Delta Video - 2',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h2v)) {
                                                                                                    await launch(h2v);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                ),
                                                                                Column(
                                                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                                  children: <Widget>[
                                                                                    Text("Help & Tips",
                                                                                        style: TextStyle(
                                                                                          fontSize: 20.0,
                                                                                          color: Colors.white,
                                                                                          fontWeight: FontWeight.bold,
                                                                                        )),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    "Alpha Text - 1",
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h1)) {
                                                                                                    await launch(h1);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.short_text_rounded, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Bravo text - 2',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(fontSize: 20.0, color: Color(0xff2A35B8)),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h2)) {
                                                                                                    await launch(h2);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Charlie Video - 1',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h1v)) {
                                                                                                    await launch(h1v);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                    Padding(
                                                                                      padding: const EdgeInsets.only(top: 12.5, left: 10, right: 10),
                                                                                      child: Card(
                                                                                        shape: RoundedRectangleBorder(
                                                                                          borderRadius: BorderRadius.circular(15.0),
                                                                                        ),
                                                                                        color: Color(0xff6AC5FB),
                                                                                        elevation: 10,
                                                                                        child: Column(
                                                                                          mainAxisSize: MainAxisSize.min,
                                                                                          children: <Widget>[
                                                                                            Padding(
                                                                                              padding: const EdgeInsets.all(10.0),
                                                                                              child: ListTile(
                                                                                                leading: Icon(Icons.video_library_outlined, color: Color(0xff2A35B8), size: 40),
                                                                                                title: Padding(
                                                                                                  padding: const EdgeInsets.only(left: 40.0),
                                                                                                  child: Text(
                                                                                                    'Delta Video - 2',
                                                                                                    textAlign: TextAlign.left,
                                                                                                    style: TextStyle(
                                                                                                      fontSize: 20.0,
                                                                                                      color: Color(0xff2A35B8),
                                                                                                    ),
                                                                                                  ),
                                                                                                ),
                                                                                                onTap: () async {
                                                                                                  if (await canLaunch(h2v)) {
                                                                                                    await launch(h2v);
                                                                                                  }
                                                                                                },
                                                                                              ),
                                                                                            ),
                                                                                          ],
                                                                                        ),
                                                                                      ),
                                                                                    ),
                                                                                  ],
                                                                                )
                                                                              ],
                                                                            ),
                                                                          )
                                                                        ],
                                                                      ),
                                                                    ),
                                                            );
                                                          });
                                                        }).whenComplete(() {
                                                      setState(() {
                                                        _camState = true;
                                                      });
                                                      print(
                                                          'Hey there, I\'m calling after hide bottomSheet');
                                                    });
                                                  }
                                                } else {
                                                  setState(() {
                                                    isLoading = false;
                                                    focus = false;
                                                  });
                                                  _handleClickMe();
                                                }
                                              },
                                            ),
                                            hintText: 'BARCODE',
                                          ),
                                          keyboardType: TextInputType.number,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
                AnimatedPositioned(
                  left: pos_l,
                  right: pos_r,
                  top: pos_t,
                  bottom: pos_b,
                  duration: Duration(milliseconds: 500),
                  child: segmentedControl(),
                ),
              ],
            ),
    );
  }
}

// if (_camState) {
// _qrCallback(code);
// setState(() {
// isLoading = true;
// print("Starting");
// });
// if (isLoading) {
// print("yes");
// }
// var name = await b.getBarcode(code);
