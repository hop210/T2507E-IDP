
import 'dart:convert';
import 'dart:io';

import 'package:my_order/order.dart';

Future<void> main() async {
  final file = File('order.json');

  
  Future<List<Order>> readOrders() async {
    if (!await file.exists()) {
      await file.writeAsString('[]');
    }

    String content = await file.readAsString();
    List<dynamic> data = jsonDecode(content);

    return data.map((json) => Order.fromJson(json)).toList();
  }

  
  Future<void> saveOrders(List<Order> orders) async {
    

    await file.writeAsString(
      const JsonEncoder.withIndent('  ').convert(
        orders.map((order) => order.toJson()).toList(),
      ),
    );
  }

  final server = await HttpServer.bind(
    InternetAddress.loopbackIPv4,
    8080,
  );

  print('Server running at http://localhost:8080');

  await for (HttpRequest request in server) {
    try {
      if (request.uri.path == '/api/orders' &&
          request.method == 'GET') {
        List<Order> orders = await readOrders();

        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode(
            orders.map((order) => order.toJson()).toList(),
          ));

      } else if (request.uri.path == '/api/orders' &&
          request.method == 'POST') {
        String body = await utf8.decoder.bind(request).join();

        Order newOrder = Order.fromJson(jsonDecode(body));

        List<Order> orders = await readOrders();

        if (orders.any((order) => order.item == newOrder.item)) {
          request.response
            ..statusCode = HttpStatus.conflict
            ..write('Item already exists');
        } else {
          orders.add(newOrder);
          await saveOrders(orders);

          request.response
            ..headers.contentType = ContentType.json
            ..write(jsonEncode(newOrder.toJson()));
        }

      } else if (request.uri.path == '/' &&
          request.method == 'GET') {
        final html = File('web/index.html');

        request.response
          ..headers.contentType = ContentType.html
          ..write(await html.readAsString());

      } else {
        request.response.statusCode = HttpStatus.notFound;
      }
    } catch (e) {
      request.response
        ..statusCode = HttpStatus.internalServerError
        ..write(e.toString());
    }

    await request.response.close();
  }
}
