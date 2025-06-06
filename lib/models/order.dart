class Order {
  final List<Map<String, dynamic>> items;
  final double total;
  final DateTime date;

  Order({
    required this.items,
    required this.total,
    required this.date,
  });

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      items: List<Map<String, dynamic>>.from(map['items'].map((e) => Map<String, dynamic>.from(e))),
      total: (map['total'] as num).toDouble(),
      date: DateTime.parse(map['date']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'items': items,
      'total': total,
      'date': date.toIso8601String(),
    };
  }
}
