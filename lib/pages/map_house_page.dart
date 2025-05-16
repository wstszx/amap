import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:geolocator/geolocator.dart';
import '../models/house.dart';
import '../services/house_service.dart';

class MapHousePage extends StatefulWidget {
  const MapHousePage({Key? key}) : super(key: key);

  @override
  State<MapHousePage> createState() => _MapHousePageState();
}

class _MapHousePageState extends State<MapHousePage> {
  late WebViewController _controller;
  final TextEditingController _searchController = TextEditingController();
  List<House> _houses = [];
  bool _showList = false;
  double _searchRadius = 2000; // 默认搜索半径2000米
  bool _isMapReady = false;

  @override
  void initState() {
    super.initState();
    _initWebView();
    _loadHouses();
    _requestLocationPermission();
  }

  Future<void> _initWebView() async {
    final String mapHtml = await rootBundle.loadString('assets/web/map.html');
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadHtmlString(mapHtml)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageFinished: (String url) {
            setState(() {
              _isMapReady = true;
            });
            _updateMapMarkers();
          },
        ),
      );
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      if (_isMapReady) {
        _controller.runJavaScript(
          'setCenter(${position.longitude}, ${position.latitude})',
        );
      }
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _loadHouses() {
    setState(() {
      _houses = HouseService.getMockHouses();
      _updateMapMarkers();
    });
  }

  void _updateMapMarkers() {
    if (!_isMapReady) return;

    final String markersJson = jsonEncode(_houses
        .map((house) => {
              'id': house.id,
              'title': house.title,
              'lat': house.latitude,
              'lng': house.longitude,
              'price': house.price,
              'info': '${house.layout} | ${house.area}'
            })
        .toList());

    _controller.runJavaScript('updateMarkers($markersJson)');
  }

  void _onSearch(String value) {
    setState(() {
      _houses = HouseService.searchHouses(value);
      _updateMapMarkers();
      _showList = true;
    });
  }

  Future<void> _showFilterDialog() async {
    double tempRadius = _searchRadius;
    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('筛选条件'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('搜索半径'),
                  Slider(
                    value: tempRadius,
                    min: 500,
                    max: 5000,
                    divisions: 9,
                    label: '${(tempRadius / 1000).toStringAsFixed(1)}km',
                    onChanged: (value) {
                      setState(() {
                        tempRadius = value;
                      });
                    },
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _searchRadius = tempRadius;
                    _filterByDistance();
                  },
                  child: const Text('确定'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _filterByDistance() async {
    if (!_isMapReady) return;

    final String centerResult =
        await _controller.runJavaScriptReturningResult('getCurrentCenter()') as String;
    final Map<String, dynamic> center = jsonDecode(centerResult);

    setState(() {
      _houses = HouseService.filterByDistance(
        center['lat'],
        center['lng'],
        _searchRadius,
      );
      _updateMapMarkers();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('地图找房'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: _getCurrentLocation,
          ),
          IconButton(
            icon: Icon(_showList ? Icons.map : Icons.list),
            onPressed: () {
              setState(() {
                _showList = !_showList;
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: '搜索小区名称、地址',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.filter_list),
                  onPressed: _showFilterDialog,
                ),
              ),
              onSubmitted: _onSearch,
            ),
          ),
          Expanded(
            child: _showList ? _buildHouseList() : _buildMap(),
          ),
        ],
      ),
    );
  }

  Widget _buildMap() {
    if (!_isMapReady) {
      return const Center(child: CircularProgressIndicator());
    }
    return WebViewWidget(controller: _controller);
  }

  Widget _buildHouseList() {
    return ListView.builder(
      itemCount: _houses.length,
      itemBuilder: (context, index) {
        final house = _houses[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          child: ListTile(
            onTap: () {
              setState(() {
                _showList = false;
              });
              _controller.runJavaScript(
                'setCenter(${house.longitude}, ${house.latitude})',
              );
            },
            leading: house.imageUrl != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Image.network(
                      house.imageUrl!,
                      width: 80,
                      height: 80,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.home, size: 40);
                      },
                    ),
                  )
                : const Icon(Icons.home, size: 40),
            title: Text(house.title),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('${house.layout} | ${house.area}'),
                Text(house.address),
                Wrap(
                  spacing: 4,
                  children: house.tags
                      .map((tag) => Chip(
                            label: Text(
                              tag,
                              style: const TextStyle(fontSize: 12),
                            ),
                            padding: EdgeInsets.zero,
                            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ))
                      .toList(),
                ),
              ],
            ),
            trailing: Text(
              '¥${house.price}/月',
              style: const TextStyle(
                color: Colors.red,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
