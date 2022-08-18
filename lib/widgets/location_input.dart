import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:great_places/helpers/location_helper.dart';
import 'package:great_places/screens/map_screen.dart';
import 'package:location/location.dart';

class LocationInput extends StatefulWidget {
  const LocationInput({Key? key}) : super(key: key);

  @override
  State<LocationInput> createState() => _LocationInputState();
}

class _LocationInputState extends State<LocationInput> {
  String? _previewImageUrl;

  Future<void> _getCurrentUserLocation() async {
    Location location = Location();

    bool serviceEnabled;
    PermissionStatus permissionGranted;
    LocationData locData;

    serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return;
      }
    }

    locData = await location.getLocation();
    print(locData.latitude);
    print(locData.longitude);
    final staticMapImageUrl = LocationHelper.generateLocationPreviewImage(
        latitude: locData.latitude!, longitude: locData.longitude!);

    setState(() {
      _previewImageUrl = staticMapImageUrl;
    });
  }

  Future<void> _selectOnMap() async {
    // if (defaultTargetPlatform == TargetPlatform.android) {
    //   AndroidGoogleMapsFlutter.useAndroidViewSurface = true;
    // }
    final selectedLocation = await Navigator.of(context).push(
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (ctx) => MapScreen(
          isSelecting: true,
        ),
      ),
    );
    if(selectedLocation == null) return;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 170,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            border: Border.all(
              width: 1,
              color: Colors.grey,
            ),
          ),
          child: _previewImageUrl == null
              ? const Text(
                  'No Location Chosen',
                  textAlign: TextAlign.center,
                )
              : Image.network(
                  _previewImageUrl!,
                  fit: BoxFit.cover,
                  width: double.infinity,
                ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FlatButton.icon(
              onPressed: _getCurrentUserLocation,
              icon: const Icon(Icons.location_on),
              label: const Text('Current Location'),
              textColor: Theme.of(context).primaryColor,
            ),
            FlatButton.icon(
              onPressed: _selectOnMap,
              icon: const Icon(Icons.map),
              label: const Text('Select on map'),
              textColor: Theme.of(context).primaryColor,
            ),
          ],
        ),
      ],
    );
  }
}
