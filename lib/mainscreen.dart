import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:midterm/location.dart';
import 'package:http/http.dart' as http;
import 'package:midterm/viewdestination.dart';
import 'package:progress_dialog/progress_dialog.dart';
import 'package:toast/toast.dart';
import 'package:shared_preferences/shared_preferences.dart';

//import 'profilescreen.dart';
//import 'cartscreen.dart';
//import 'package:furniture/adminproduct.dart';
import 'package:cached_network_image/cached_network_image.dart';

class MainScreen extends StatefulWidget {
  // const MainScreen({Key key, this.user}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  List locations;
  int curnumber = 1;
  double screenHeight, screenWidth;

  String curstate = "Kedah";

  String selectedState;
  int quantity = 1;

  List<String> listType = [
    "Kedah",
    "Johor",
    "Kelantan",
    "Perak",
    "Selangor",
    "Melaka",
    "Negeri Sembilan",
    "Pahang",
    "Perlis",
    "Penang",
    "Sabah",
    "Sarawak",
    "Terengganu"
  ];

  @override
  
  void initState() {
    super.initState();

    _loadData();
    loadPref();
  }

  @override
  Widget build(BuildContext context) {
    
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;

    if (locations == null) {
     
      return Scaffold(
          backgroundColor: Colors.lightBlue[100],
          appBar: AppBar(
            backgroundColor: Colors.lightBlue[200],
            title: Text('Location List'),
          ),
          body: Container(
              child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading The Location",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.black),
                )
              ],
            ),
          )));
    }

      
    return WillPopScope(
      
        onWillPop: _onBackPressed,
        child: Scaffold(
          appBar: AppBar(
            title: Text('Location List'),
            backgroundColor: Colors.lightBlue[200],
            actions: <Widget>[
              //
            ],
          ),
          body: Container(
            color: Colors.lightBlue[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Container(
                  color: Colors.lightBlue[50],
                  child: DropdownButton(
                    dropdownColor: Colors.lightBlue[50],
                    //sorting dropdownoption

                    hint: Text(
                      'State',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black,
                      ),
                    ),

                    // Not necessary for Option 1
                    value: selectedState,
                    onChanged: (newValue) {
                      setState(() {
                        selectedState = newValue;

                        print(selectedState);
                        _sortItem(selectedState);
                      });
                    },

                    items: listType.map((selectedState) {
                      return DropdownMenuItem(
                        child: new Text(selectedState,
                            style: TextStyle(color: Colors.black)),
                        value: selectedState,
                      );
                    }).toList(),
                  ),
                ),
                Text(curstate,
                    style:
                        TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        
                Flexible(
                    child: GridView.count(
                        crossAxisCount: 2,
                        childAspectRatio: (screenWidth / screenHeight),
                        children: List.generate(locations.length, (index) {
                          return Card(
                              color: Colors.lightBlue[50],
                              elevation: 10,
                              child: Padding(
                                padding: EdgeInsets.all(5),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: <Widget>[
                                    GestureDetector(
                                      
                                      onTap: () => _onDestinationDetail(index),
                                      child: Container(
                                        height: screenHeight / 5.9,
                                        width: screenWidth / 3.5,
                                        child: ClipOval(
                                            child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          imageUrl:
                                              "http://slumberjer.com/visitmalaysia/images/${locations[index]['imagename']}",
                                          placeholder: (context, url) =>
                                              new CircularProgressIndicator(),
                                          errorWidget: (context, url, error) =>
                                              new Icon(Icons.error),
                                        )),
                                      ),
                                    ),
                                    Text(locations[index]['loc_name'],
                                        maxLines: 1,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold)),
                                    Text(
                                      "State: " + locations[index]['state'],
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ));
                        })))
              ],
            ),
          ),
        ));
  }

  _onDestinationDetail(int index) async {
    print(locations[index]['loc_name']);
    Destination destination = new Destination(
        pid: locations[index]['pid'],
        locname: locations[index]['loc_name'],
        state: locations[index]['state'],
        description: locations[index]['description'],
        latitude: locations[index]['latitude'],
        longitude: locations[index]['longitude'],
        url: locations[index]['url'],
        contact: locations[index]['contact'],
        address: locations[index]['address'],
        imagename: locations[index]['imagename']);

    await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (BuildContext context) => ViewDestination(
                  destination: destination,
                )));
    _loadData();
  }

  void _loadData() {
    
    String urlLoadJobs =
        "https://slumberjer.com/visitmalaysia/load_destinations.php";
    http.post(urlLoadJobs, body: {}).then((res) {
      setState(() {
        var extractdata = json.decode(res.body);
        locations = extractdata["locations"];
        
        _sortItem(curstate);
      });
    }).catchError((err) {
      print(err);
    });
  }

  void _sortItem(String state) {
    
   
    try {
      ProgressDialog pr = new ProgressDialog(context,
          type: ProgressDialogType.Normal, isDismissible: true);
      pr.style(message: "Searching...");
      pr.show();
      String urlLoadJobs =
          "https://slumberjer.com/visitmalaysia/load_destinations.php";
      http.post(urlLoadJobs, body: {
        "state": state,
      }).then((res) {
        setState(() {
          
          curstate = state;
          var extractdata = json.decode(res.body);
          locations = extractdata["locations"];
          FocusScope.of(context).requestFocus(new FocusNode());
          pr.dismiss();
        });
      }).catchError((err) {
        print(err);
        pr.dismiss();
      });
      pr.dismiss();
    } 
    
    catch (e) {
      Toast.show("Error", context,
          duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
    }
    
  }

  Future<bool> _onBackPressed() {
    savepref(true);
    
    return showDialog(
          context: context,
          builder: (context) => new AlertDialog(
            backgroundColor: Colors.lightBlue[50],
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(20.0))),
            title: new Text(
              'Are you sure?',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            content: new Text(
              'Do you want to exit an App',
              style: TextStyle(
                color: Colors.black,
              ),
            ),
            actions: <Widget>[
              MaterialButton(
                  onPressed: () {
                    
                    SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  },
                  child: Text(
                    "Exit",
                    style: TextStyle(
                      color: Colors.blue[400],
                    ),
                  )),
              MaterialButton(
                  onPressed: () {
                    Navigator.of(context).pop(false);
                  },
                  child: Text(
                    "Cancel",
                    style: TextStyle(
                      color: Colors.blue[400],
                    ),
                  )),
            ],
          ),
        ) ??
        false;
  }

  void savepref(bool value) async {
    String state = curstate;

    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (value) {
      //save preference
      await prefs.setString('state', state);
    }
  }

  Future<void> loadPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String state = (prefs.getString('state')) ?? '';

    setState(() {
      this.curstate = state;
    });
  }
}
