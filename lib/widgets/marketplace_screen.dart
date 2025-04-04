import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'package:flutter/services.dart'; // For clipboard

class MarketplaceScreen extends StatefulWidget {
  final int experience;

  const MarketplaceScreen({Key? key, required this.experience})
      : super(key: key);

  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String? userId;
  int availableXP = 0;
  String selectedCategory = 'All';
  Map<String, DateTime?> couponExpiration = {};

  final List<Map<String, dynamic>> coupons = [
    {
      'name': '10% Off Gym Membership',
      'cost': 10, // Updated cost
      'description': 'Save on your next gym membership!',
      'category': 'Fitness',
      'image': 'assets/images/gym_membership.png',
      'code': 'GYM10OFF'
    },
    {
      'name': 'Free Protein Shake',
      'cost': 70,
      'description': 'Redeem at any partnered store.',
      'category': 'Food',
      'image': 'assets/images/protein_shake.png',
      'code': 'SHAKEFREE'
    },
    {
      'name': 'Workout Gear Discount',
      'cost': 150,
      'description': '20% off fitness apparel.',
      'category': 'Merchandise',
      'image': 'assets/images/workout_gear.png',
      'code': 'GEAR20'
    },
    {
      'name': 'Personal Training Session',
      'cost': 400,
      'description': 'One free session with a trainer.',
      'category': 'Fitness',
      'image': 'assets/images/personal_training.png',
      'code': 'TRAINFREE'
    },
  ];

  @override
  void initState() {
    super.initState();
    userId = FirebaseAuth.instance.currentUser?.uid;
    availableXP = widget.experience;
    _loadCouponExpirations();
    _startExpirationCheck();
  }

  Future<void> _loadCouponExpirations() async {
    final snapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('coupons')
        .get();

    setState(() {
      for (var doc in snapshot.docs) {
        final data = doc.data();
        couponExpiration[data['name']] =
            (data['redeemedAt'] as Timestamp?)?.toDate();
      }
    });
  }

  void _startExpirationCheck() {
    Timer.periodic(Duration(minutes: 1), (timer) {
      setState(() {
        couponExpiration.forEach((key, value) {
          if (value != null && DateTime.now().difference(value).inDays >= 15) {
            couponExpiration[key] = null;
          }
        });
      });
    });
  }

  Future<void> _redeemCoupon(int cost, String couponName, String code) async {
    try {
      // Run a transaction to ensure XP never goes below zero.
      await _firestore.runTransaction((transaction) async {
        final gamificationRef = _firestore
            .collection('users')
            .doc(userId)
            .collection('gamification')
            .doc('data');

        final snapshot = await transaction.get(gamificationRef);
        int currentXP = snapshot.get('experience') ?? 0;
        int newXP = currentXP - cost;
        if (newXP < 0) newXP = 0;

        // Update the gamification document with the new XP value.
        transaction.update(gamificationRef, {'experience': newXP});
      });

      // Add coupon document under the user's coupons subcollection.
      await _firestore
          .collection('users')
          .doc(userId)
          .collection('coupons')
          .add({
        'name': couponName,
        'redeemedAt': FieldValue.serverTimestamp(),
        'code': code,
      });

      // Update local state accordingly.
      setState(() {
        availableXP = availableXP - cost < 0 ? 0 : availableXP - cost;
        couponExpiration[couponName] = DateTime.now();
      });

      // Show confirmation dialog with coupon code.
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: Colors.black.withOpacity(0.9),
          title: Text(
            'Coupon Redeemed!',
            style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Your coupon code for $couponName:',
                style: TextStyle(color: Colors.white70),
              ),
              SizedBox(height: 10),
              Text(
                code,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.green,
                  fontSize: 20,
                ),
              ),
              SizedBox(height: 10),
              Text(
                'Valid for 15 days',
                style: TextStyle(color: Colors.white70),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'OK',
                style: TextStyle(color: Colors.green),
              ),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error redeeming coupon: $e")),
      );
    }
  }

  void _showConfirmationDialog(int cost, String couponName, String code) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Confirm Redemption',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Do you want to redeem "$couponName" for $cost XP?',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: TextStyle(color: Colors.green),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _redeemCoupon(cost, couponName, code);
            },
            child: Text(
              'Confirm',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.black.withOpacity(0.9),
        title: Text(
          'Error',
          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
        ),
        content: Text(
          message,
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'OK',
              style: TextStyle(color: Colors.green),
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _filteredCoupons() {
    if (selectedCategory == 'All') return coupons;
    return coupons
        .where((coupon) => coupon['category'] == selectedCategory)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A3B1C),
      appBar: AppBar(
        backgroundColor: Colors.black.withOpacity(0.5),
        title: const Text(
          'Marketplace',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Card(
                  color: Colors.black.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available XP: $availableXP',
                          style: const TextStyle(
                            color: Colors.green,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildCategoryChip('All', selectedCategory == 'All'),
                      _buildCategoryChip(
                          'Fitness', selectedCategory == 'Fitness'),
                      _buildCategoryChip('Food', selectedCategory == 'Food'),
                      _buildCategoryChip(
                          'Merchandise', selectedCategory == 'Merchandise'),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Available Rewards',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _filteredCoupons().length,
                  itemBuilder: (context, index) {
                    final coupon = _filteredCoupons()[index];
                    // Determine if the coupon is redeemed and still valid.
                    final redeemedTime = couponExpiration[coupon['name']];
                    final isRedeemed = redeemedTime != null &&
                        DateTime.now().difference(redeemedTime).inDays < 15;

                    return Card(
                      color: Colors.black.withOpacity(0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(8),
                                image: DecorationImage(
                                  image: AssetImage(coupon['image']),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    coupon['name'],
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    coupon['description'],
                                    style:
                                        const TextStyle(color: Colors.white70),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            Column(
                              children: [
                                Text(
                                  '${coupon['cost']} XP',
                                  style: const TextStyle(
                                    color: Colors.green,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                // If redeemed, show the coupon code and copy button. Otherwise, show Redeem button.
                                isRedeemed
                                    ? Column(
                                        children: [
                                          Text(
                                            'Code:',
                                            style: TextStyle(
                                              color: Colors.green,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Row(
                                            children: [
                                              Text(
                                                coupon['code'],
                                                style: TextStyle(
                                                  color: Colors.white70,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                              IconButton(
                                                icon: Icon(
                                                  Icons.copy,
                                                  color: Colors.green,
                                                  size: 16,
                                                ),
                                                onPressed: () {
                                                  Clipboard.setData(
                                                      ClipboardData(
                                                          text:
                                                              coupon['code']));
                                                  ScaffoldMessenger.of(context)
                                                      .showSnackBar(
                                                    SnackBar(
                                                      content: Text(
                                                          'Coupon code copied!'),
                                                      backgroundColor:
                                                          Colors.green,
                                                    ),
                                                  );
                                                },
                                              )
                                            ],
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            '${15 - DateTime.now().difference(redeemedTime).inDays} days left',
                                            style: TextStyle(
                                              color: Colors.white70,
                                              fontSize: 12,
                                            ),
                                          )
                                        ],
                                      )
                                    : ElevatedButton(
                                        onPressed: () {
                                          if (availableXP < coupon['cost']) {
                                            _showErrorDialog(
                                                'Not enough XP to redeem this coupon! You need ${coupon['cost'] - availableXP} more XP.');
                                          } else {
                                            _showConfirmationDialog(
                                                coupon['cost'],
                                                coupon['name'],
                                                coupon['code']);
                                          }
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.black,
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(8),
                                            side:
                                                BorderSide(color: Colors.green),
                                          ),
                                        ),
                                        child: Text(
                                          'Redeem',
                                          style: const TextStyle(
                                            color: Colors.green,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String category, bool isSelected) {
    return Padding(
      padding: const EdgeInsets.only(right: 8.0),
      child: ChoiceChip(
        label: Text(category),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            selectedCategory = category;
          });
        },
        selectedColor: Colors.green,
        backgroundColor: Colors.grey.shade800,
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
