# amap

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## 地图找房功能技术方案

目前实现的地图找房功能主要涉及以下几个部分：

**1. 数据模型 ([`lib/models/house.dart`](lib/models/house.dart))**

*   定义了 `House` 类，用于表示房源信息，包含 `latitude` 和 `longitude` 字段存储地理位置。
*   提供 `toJson()` 和 `fromJson()` 方法进行数据序列化和反序列化。

**2. 数据服务 ([`lib/services/house_service.dart`](lib/services/house_service.dart))**

*   `HouseService` 类提供模拟房源数据 (`_mockHouses` 列表)。
*   提供 `getMockHouses()` 获取全部模拟房源。
*   提供 `searchHouses()` 根据关键词搜索房源。
*   提供 `filterByDistance()` 根据中心点和半径筛选房源。

**3. Flutter 页面 ([`lib/pages/map_house_page.dart`](lib/pages/map_house_page.dart))**

*   `MapHousePage` 使用 `webview_flutter` 集成高德地图 Web SDK。
*   加载 [`assets/web/map.html`](assets/web/map.html) 文件。
*   从 `HouseService` 获取房源数据。
*   通过 `_controller.runJavaScript()` 调用 Web 视图中的 JavaScript 函数 (`updateMarkers`, `setCenter`) 传递数据和控制地图。
*   通过 `_controller.runJavaScriptReturningResult()` 调用 Web 视图中的 JavaScript 函数 (`getCurrentCenter`) 获取地图信息。
*   处理地理位置权限和获取当前位置。
*   实现搜索和筛选功能，并更新地图标记。

**4. Web 视图 ([`assets/web/map.html`](assets/web/map.html))**

*   包含高德地图 Web SDK 的 HTML、CSS 和 JavaScript 代码。
*   `initMap()` 初始化地图。
*   `setCenter(lng, lat)` 设置地图中心点。
*   `getCurrentCenter()` 获取当前地图中心点经纬度。
*   `clearMarkers()` 清除地图标记。
*   `updateMarkers(houses)` 接收房源数据，遍历并在地图上创建标记（显示房源标题）。
*   标记点击事件显示信息窗口，并通过 `window.flutter.postMessage()` 通知 Flutter。

**整体流程：**

Flutter 页面加载 -> 获取房源数据 -> 将数据传递给 Web 视图 -> Web 视图在地图上显示标记 -> 用户交互（点击标记、搜索、筛选、定位）-> Flutter 和 Web 视图之间进行数据和控制的双向通信。
