import 'package:flutter/material.dart';

import 'package:cached_network_image/cached_network_image.dart';
import 'location.dart';

import 'package:url_launcher/url_launcher.dart';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class ViewDestination extends StatefulWidget {
  final Destination destination;

  const ViewDestination({Key key, this.destination}) : super(key: key);

  @override
  _ViewDestinationState createState() => _ViewDestinationState();
}

class _ViewDestinationState extends State<ViewDestination> {
  double screenHeight, screenWidth;
  List<Marker> allMarkers = [];

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    screenHeight = MediaQuery.of(context).size.height;
    screenWidth = MediaQuery.of(context).size.width;
    allMarkers.add(Marker(
        markerId: MarkerId('myMarker'),
        draggable: false,
        onTap: () {
          print('Marker Tapped');
        },
        position: LatLng(double.parse(widget.destination.latitude),
            double.parse(widget.destination.longitude))));

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        backgroundColor: Colors.lightBlue[200],
        title: Text(
          " " + widget.destination.locname,
        ),
      ),
      body: Container(
        color: Colors.lightBlue[100],
        alignment: Alignment.topCenter,
        child: SingleChildScrollView(
            child: Column(
          children: <Widget>[
            SizedBox(height: 10),
            Container(
              height: screenHeight / 3,
              width: screenWidth / 1.5,
              child: CachedNetworkImage(
                fit: BoxFit.fill,
                imageUrl:
                    "http://slumberjer.com/visitmalaysia/images/${widget.destination.imagename}",
                placeholder: (context, url) => new CircularProgressIndicator(),
                errorWidget: (context, url, error) => new Icon(Icons.error),
              ),
            ),
            SizedBox(height: 6),
            Container(
                width: screenWidth / 1.2,
                //height: screenHeight / 2,
                child: Card(
                    color: Colors.lightBlue[50],
                    elevation: 6,
                    child: Padding(
                        padding: EdgeInsets.all(10),
                        child: Column(
                          children: <Widget>[
                            Table(
                                defaultColumnWidth: FlexColumnWidth(1.0),
                                children: [
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 400,
                                          child: Text("Description",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 400,
                                          child: Text(
                                            " " +
                                                widget.destination.description,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 100,
                                          child: Text("Web URL",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: GestureDetector(
                                          onTap: _launchURL,

                                          // alignment: Alignment.centerLeft,
                                          //height: 100,
                                          child: Text(
                                            " " + widget.destination.url,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 100,
                                          child: Text("Address",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 100,
                                          child: Text(
                                            " " + widget.destination.address,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 30,
                                          child: Text("Phone",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: GestureDetector(
                                          onTap: () => launch(
                                              "tel://${widget.destination.contact}"),
                                          child: Text(
                                            " " + widget.destination.contact,
                                            style: TextStyle(
                                              color: Colors.black,
                                            ),
                                          )),
                                    ),
                                  ]),
                                  TableRow(children: [
                                    TableCell(
                                      child: Container(
                                          alignment: Alignment.centerLeft,
                                          height: 200,
                                          child: Text("Location",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.black))),
                                    ),
                                    TableCell(
                                      child: Container(
                                        alignment: Alignment.centerLeft,
                                        height: 200,
                                        child: GoogleMap(
                                          initialCameraPosition: CameraPosition(
                                            target: LatLng(
                                                double.parse(widget
                                                    .destination.latitude),
                                                double.parse(widget
                                                    .destination.longitude)),
                                            zoom: 12,
                                          ),
                                          markers: Set.from(allMarkers),
                                        ),
                                      ),
                                    )
                                  ]),
                                ]),
                            SizedBox(height: 3),
                          ],
                        )))),
          ],
        )),
      ),
    );
  }

  _launchURL() async {
    String url = 'http://${widget.destination.url}';

    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }
}
