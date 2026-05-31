// packages/firebase_sdk/lib/src/repositories/order_repository.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:core_models/core_models.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OrderRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _orders => _firestore.collection('orders');

  /// Creates a new order in Firestore. Backs up guest items and saves secure OTP hash.
  Future<void> createOrder(OrderModel order) async {
    await _orders.doc(order.id).set(order.toJson());
  }

  /// Fetches a single order document details
  Future<OrderModel?> getOrderById(String orderId) async {
    final doc = await _orders.doc(orderId).get();
    if (!doc.exists) return null;
    return OrderModel.fromJson(doc.data()!);
  }

  /// Updates status and logs a timestamped milestone in the order timeline
  Future<void> updateOrderStatus(String orderId, String newStatus, {String? notes}) async {
    final docRef = _orders.doc(orderId);
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(docRef);
      if (!snapshot.exists) return;

      final order = OrderModel.fromJson(snapshot.data()!);
      final updatedEvents = List<TimelineEvent>.from(order.timeline)
        ..add(TimelineEvent(
          status: newStatus,
          title: _getTimelineTitle(newStatus),
          description: notes ?? _getTimelineDesc(newStatus),
          timestamp: DateTime.now(),
        ));

      transaction.update(docRef, {
        'status': newStatus,
        'timeline': updatedEvents.map((e) => e.toJson()).toList(),
        if (newStatus == 'delivered') 'actualDeliveryTime': DateTime.now().toIso8601String(),
      });
    });
  }

  /// [CRITICAL REAL-TIME STREAM]: Stream active orders for a customer (using onSnapshot)
  Stream<List<OrderModel>> streamCustomerOrders(String customerId) {
    return _orders
        .where('customerId', isEqualTo: customerId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }

  /// [CRITICAL REAL-TIME STREAM]: Stream incoming orders for a specific merchant
  Stream<List<OrderModel>> streamMerchantOrders(String merchantId) {
    return _orders
        .where('merchantId', isEqualTo: merchantId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }

  /// [CRITICAL REAL-TIME STREAM]: Stream active deliveries assigned to a rider
  Stream<List<OrderModel>> streamRiderDeliveries(String riderId) {
    return _orders
        .where('riderId', isEqualTo: riderId)
        .where('status', whereIn: ['confirmed', 'preparing', 'ready', 'picked_up'])
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OrderModel.fromJson(doc.data()))
            .toList());
  }

  String _getTimelineTitle(String status) {
    switch (status) {
      case 'confirmed': return 'Order Confirmed';
      case 'preparing': return 'Preparing Food';
      case 'ready': return 'Food is Ready';
      case 'picked_up': return 'Out for Delivery';
      case 'delivered': return 'Delivered Successfully';
      case 'cancelled': return 'Order Cancelled';
      default: return 'Status Update';
    }
  }

  String _getTimelineDesc(String status) {
    switch (status) {
      case 'confirmed': return 'The store has accepted your order.';
      case 'preparing': return 'Our chefs are working on preparing your meal.';
      case 'ready': return 'Food is packed and waiting for our rider.';
      case 'picked_up': return 'Our rider is heading towards your location.';
      case 'delivered': return 'Handoff confirmed. Enjoy your food!';
      case 'cancelled': return 'The order has been cancelled.';
      default: return 'Order has updated.';
    }
  }
}

// RIVERPOD STREAM PROVIDERS FOR REALTIME UI RENDERING
final orderRepositoryProvider = Provider((ref) => OrderRepository());

final customerOrdersStreamProvider = StreamProvider.family<List<OrderModel>, String>((ref, customerId) {
  return ref.watch(orderRepositoryProvider).streamCustomerOrders(customerId);
});

final merchantOrdersStreamProvider = StreamProvider.family<List<OrderModel>, String>((ref, merchantId) {
  return ref.watch(orderRepositoryProvider).streamMerchantOrders(merchantId);
});

final riderDeliveriesStreamProvider = StreamProvider.family<List<OrderModel>, String>((ref, riderId) {
  return ref.watch(orderRepositoryProvider).streamRiderDeliveries(riderId);
});
