import 'dart:math';
import '../models/house.dart';

class HouseService {
  static final List<House> _mockHouses = [
    House(
      id: '1',
      title: '阳光小区精装两居',
      price: 3500,
      layout: '2室1厅1卫',
      area: '89平米',
      latitude: 30.584355,
      longitude: 114.298572,
      address: '武汉市江汉区江汉路步行街',
      tags: ['精装修', '南北通透', '地铁房'],
      imageUrl: 'https://picsum.photos/200',
    ),
    House(
      id: '2',
      title: '翠湖花园三居室',
      price: 5000,
      layout: '3室2厅2卫',
      area: '120平米',
      latitude: 30.590355,
      longitude: 114.305572,
      address: '武汉市江汉区中山大道',
      tags: ['家电齐全', '拎包入住', '采光好'],
      imageUrl: 'https://picsum.photos/201',
    ),
    House(
      id: '3',
      title: '华府温馨一居',
      price: 2800,
      layout: '1室1厅1卫',
      area: '55平米',
      latitude: 30.578355,
      longitude: 114.291572,
      address: '武汉市江汉区解放大道',
      tags: ['交通便利', '配套齐全', '可月付'],
      imageUrl: 'https://picsum.photos/202',
    ),
  ];

  // 获取所有房源
  static List<House> getMockHouses() {
    return _mockHouses;
  }

  // 搜索房源
  static List<House> searchHouses(String keyword) {
    if (keyword.isEmpty) {
      return _mockHouses;
    }
    return _mockHouses.where((house) =>
        house.title.contains(keyword) ||
        house.address.contains(keyword) ||
        house.tags.any((tag) => tag.contains(keyword))).toList();
  }

  // 按距离筛选房源
  static List<House> filterByDistance(double centerLat, double centerLng, double radius) {
    return _mockHouses.where((house) {
      double distance = _calculateDistance(
        centerLat,
        centerLng,
        house.latitude,
        house.longitude,
      );
      return distance <= radius;
    }).toList();
  }

  // 计算两点之间的距离（米）
  static double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371000; // 地球半径（米）
    double dLat = _toRadians(lat2 - lat1);
    double dLon = _toRadians(lon2 - lon1);

    double a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRadians(double degree) {
    return degree * pi / 180;
  }
}
