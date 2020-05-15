import 'dart:ui';

import 'package:google_maps_flutter/google_maps_flutter.dart';

class Place {
  List<Entries> entries;
  LatLng position;

  Place({this.entries, this.position});

  Place.fromJson(Map<String, dynamic> json) {
    if (json['entries'] != null) {
      entries = new List<Entries>();
      json['entries'].forEach((v) {
        entries.add(new Entries.fromJson(v));
      });
    }
    double lon = double.parse(json['lon']);
    double lat = double.parse(json['lat']);
    this.position = LatLng(lat, lon);
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    if (this.entries != null) {
      data['entries'] = this.entries.map((v) => v.toJson()).toList();
    }
    data['lon'] = this.position.longitude;
    data['lat'] = this.position.latitude;
    return data;
  }

  List<String> getImages() {
    List<String> images = new List();
    //TODO: catcha bilder?
    this.entries.forEach((entry) {images.add(entry.img);});
    return images;
  }
}

class Entries {
  String date;
  String img;
  String name;
  String title;
  String desc;

  Entries({this.date, this.img, this.name, this.title, this.desc});

  Entries.fromJson(Map<String, dynamic> json) {
    date = json['date'];
    img = json['img'];
    name = json['name'];
    title = json['title'];
    desc = json['desc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['date'] = this.date;
    data['img'] = this.img;
    data['name'] = this.name;
    data['title'] = this.title;
    data['desc'] = this.desc;
    return data;
  }
}

/*  Place({this.position, this.entries});

  factory Place.fromJson(var json) {
    return Place(
      position: _getPos(json['lat'], json['lon']),
      entries: _getEntries(json['entries'])
    );
  }

  static List<PlaceEntry> _getEntries(List<dynamic> json) {
    List<PlaceEntry> entries = new List();
    for (var entry in json) {
      entries.add(PlaceEntry.fromJson(entry));
    }
    return entries;
  }

  @override
  String toString() {
    return "Place position: ${position.toString()} \nEntries:\n${entries.toString()}";
  }
}

class PlaceEntry {
  final String title;
  final String description;
  final Image image;
  final String date;

  PlaceEntry({this.title, this.description, this.image, this.date});

  factory PlaceEntry.fromJson(var json) {
    return PlaceEntry(
      title: json['title'],
      description: json['desc'],
      image: Image.network(json['img']),
      date: json['date']
    );
  }

  @override
  String toString() {
    return "Entry: ${this.title}, ${this.description}}, ${this.date}";
  }
}*/