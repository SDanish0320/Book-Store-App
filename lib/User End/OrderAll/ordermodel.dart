class Order {
  final String orderId;
  final String shippingAddress;
  final String orderStatus;
  final List<OrderItem> items;
  final DateTime orderDate;
  final String userId;
  List<Review> reviews; // Add this line

  Order({
    required this.orderId,
    required this.shippingAddress,
    required this.orderStatus,
    required this.items,
    required this.orderDate,
    required this.userId,
    List<Review>? reviews, // Add this line
  }) : reviews = reviews ?? [];
}

class Review {
  final String orderId;
  final String userId;
  final String reviewText;
  final int rating;
  final String productName; // Add this line

  Review({
    required this.orderId,
    required this.userId,
    required this.reviewText,
    required this.rating,
    required this.productName, // Add this line
  });
}



class OrderItem {
  final String name;
  final double unitPrice;
  final int quantity;
  final String imageUrl;
  final String productId; // Add this line

  OrderItem({
    required this.name,
    required this.unitPrice,
    required this.quantity,
    required this.imageUrl,
    required this.productId, // Add this line
  });
}
