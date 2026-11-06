import 'dart:convert';
import 'package:my_order/order.dart';

void main() {
  
  String jsonString = '''
  [
    {
      "Item": "A1000",
      "ItemName": "Iphone 15",
      "Price": 1200,
      "Currency": "USD",
      "Quantity": 1
    },
    {
      "Item": "A1001",
      "ItemName": "Iphone 16",
      "Price": 1500,
      "Currency": "USD",
      "Quantity": 1
    }
  ]
  ''';

  
  List<dynamic> jsonList = jsonDecode(jsonString);

  
  List<Order> orders = jsonList
      .map((json) => Order.fromJson(json))
      .toList();

  
  for (var order in orders) {
    print('Item: ${order.item}');
    print('Item Name: ${order.itemName}');
    print('Price: ${order.price}');
    print('Currency: ${order.currency}');
    print('Quantity: ${order.quantity}');
    print('----------------------');
  }
}