import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/menu_data.dart';
import '../../widgets/custom_bottom_bar.dart';
import '../../core/providers/cart_provider.dart';
import '../../core/providers/order_provider.dart';
import '../../core/providers/auth_provider.dart';
import '../../core/services/routing_service.dart';
import '../location/map_picker_screen.dart';

import '../cart/cart_screen.dart';
import '../profile/profile_screen.dart';
import '../menu/search_screen.dart';
import '../orders/orders_screen.dart';
import '../orders/order_tracking_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;
  StoreBranch? _currentBranch;
  bool _isLoadingLocation = true;
  final List<Widget> _pages = [
    const HomePageBody(),
    const SearchScreen(),
    const CartScreen(),
    const OrdersScreen(),
    const ProfileScreen(),
  ];

  @override
  void initState() {
    super.initState();
    // Start branch check immediately to avoid "Closed" flicker
    _preInitializeBranch();
  }

  void _preInitializeBranch() {
    final auth = Provider.of<AuthProvider>(context, listen: false);

    // Default to Pondha coordinates if no user/coords found
    double lat = auth.currentUser?.lat ?? 30.3708;
    double lng = auth.currentUser?.lng ?? 77.9748;

    setState(() {
      _currentBranch = StoreRoutingService.getFulfillmentBranch(
          Position(
            latitude: lat, longitude: lng,
            timestamp: DateTime.now(), accuracy: 0, altitude: 0,
            heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
          )
      );
      _isLoadingLocation = false;
    });

    // Refine with live GPS sensor
    _determinePosition();
  }

  Future<void> _determinePosition() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      LocationPermission permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (serviceEnabled && (permission == LocationPermission.always || permission == LocationPermission.whileInUse)) {
        Position position = await Geolocator.getCurrentPosition().timeout(const Duration(seconds: 3));
        if (mounted) {
          setState(() {
            _currentBranch = StoreRoutingService.getFulfillmentBranch(position);
            _isLoadingLocation = false;
          });
        }
      }
    } catch (e) {
      debugPrint("GPS Timeout: Kept saved location branch.");
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  void _openLocationPicker() async {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    LatLng initial = LatLng(auth.currentUser?.lat ?? 30.3708, auth.currentUser?.lng ?? 77.9748);

    if (!mounted) return;
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPickerScreen(initialPosition: initial),
      ),
    );

    if (result != null) {
      final LatLng picked = result['position'];
      final String pickedAddress = result['address'];

      await auth.updateAddress(pickedAddress, lat: picked.latitude, lng: picked.longitude);

      setState(() {
        _currentBranch = StoreRoutingService.getFulfillmentBranch(
            Position(
              latitude: picked.latitude, longitude: picked.longitude,
              timestamp: DateTime.now(), accuracy: 0, altitude: 0,
              heading: 0, speed: 0, speedAccuracy: 0, altitudeAccuracy: 0, headingAccuracy: 0,
            )
        );
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final user = auth.currentUser;

    final displayName = user != null ? 'Hi, ${user.name.split(' ').first}' : 'Welcome to Dusk';
    final displayAddress = user != null ? user.address : 'Set Delivery Location';

    String branchTag = "Detecting Store...";
    if (!_isLoadingLocation) {
      if (_currentBranch == StoreBranch.bidholi) branchTag = "Fulfilling from Bidholi";
      else if (_currentBranch == StoreBranch.pondha) branchTag = "Fulfilling from Pondha";
      else branchTag = "Stores Currently Closed";
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned(top: -100, right: -50, child: _GlowDisk(color: AppTheme.accentPurple.withOpacity(0.15), size: 300)),
          Positioned(bottom: 200, left: -100, child: _GlowDisk(color: AppTheme.primaryGold.withOpacity(0.05), size: 400)),

          Positioned(
            top: 60, left: 20, right: 20,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(displayName, style: GoogleFonts.urbanist(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 4),
                      GestureDetector(
                        onTap: _openLocationPicker,
                        child: Row(
                          children: [
                            Icon(
                                Icons.flash_on_rounded,
                                color: _isLoadingLocation || _currentBranch == null
                                    ? Colors.white24
                                    : AppTheme.primaryGold,
                                size: 14
                            ),
                            const SizedBox(width: 4),
                            Text(
                                branchTag,
                                style: GoogleFonts.urbanist(
                                    color: _isLoadingLocation || _currentBranch == null
                                        ? Colors.white54
                                        : AppTheme.primaryGold,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600
                                )
                            ),
                            const SizedBox(width: 8),
                            Text('•', style: TextStyle(color: Colors.white.withOpacity(0.2))),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                displayAddress,
                                style: GoogleFonts.urbanist(color: Colors.white70, fontSize: 12),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white70, size: 16),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?q=80&w=100',
                    width: 40, height: 40, fit: BoxFit.cover,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(top: 120),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (Widget child, Animation<double> animation) {
                return FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.0, 0.05), end: Offset.zero).animate(animation),
                    child: child,
                  ),
                );
              },
              child: Container(
                key: ValueKey<int>(_currentIndex),
                child: _pages[_currentIndex],
              ),
            ),
          ),

          CustomBottomBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
          ),
        ],
      ),
    );
  }
}

class HomePageBody extends StatefulWidget {
  const HomePageBody({super.key});

  @override
  State<HomePageBody> createState() => _HomePageBodyState();
}

class _HomePageBodyState extends State<HomePageBody> {
  String _selectedCategory = 'Burgers';
  bool _isVegOnly = false;

  @override
  Widget build(BuildContext context) {
    var filteredItems = MenuData.items.where((item) => item.category == _selectedCategory).toList();
    if (_isVegOnly) filteredItems = filteredItems.where((item) => item.isVeg).toList();

    final activeOrder = Provider.of<OrderProvider>(context).activeOrder;

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (activeOrder != null) _buildLiveOrderBanner(context, activeOrder),

          SizedBox(
            height: 120,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 15),
              itemCount: MenuData.categories.length,
              itemBuilder: (context, index) {
                String cat = MenuData.categories[index];
                bool isSelected = _selectedCategory == cat;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: Container(
                    width: 70, margin: const EdgeInsets.only(right: 15),
                    child: Column(
                      children: [
                        Container(
                          height: 70, width: 70,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: isSelected ? AppTheme.primaryGold : Colors.white10, width: isSelected ? 3 : 1),
                            image: DecorationImage(image: NetworkImage(MenuData.categoryImages[cat]!), fit: BoxFit.cover),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(cat, style: GoogleFonts.urbanist(color: isSelected ? AppTheme.primaryGold : Colors.white70, fontSize: 12, fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(color: const Color(0xFF101010), borderRadius: BorderRadius.circular(15)),
              child: Row(
                children: [
                  _FilterButton(label: 'All Food', isSelected: !_isVegOnly, onTap: () => setState(() => _isVegOnly = false)),
                  _FilterButton(label: 'Veg Only 🥦', isSelected: _isVegOnly, onTap: () => setState(() => _isVegOnly = true)),
                ],
              ),
            ),
          ),

          _SectionHeader(title: "Today's Special Picks"),
          SizedBox(
            height: 250,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              itemCount: filteredItems.isNotEmpty ? 2 : 0,
              itemBuilder: (context, index) => _FoodCardLarge(item: filteredItems[index]),
            ),
          ),

          _SectionHeader(title: 'Hot picks around you'),
          ListView.builder(
            shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: filteredItems.length,
            itemBuilder: (context, index) => _FoodCardSmall(item: filteredItems[index]),
          ),
        ],
      ),
    );
  }

  Widget _buildLiveOrderBanner(BuildContext context, OrderItem order) {
    int m = order.remainingSeconds ~/ 60;
    int s = order.remainingSeconds % 60;
    String time = '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => OrderTrackingScreen(orderId: order.id)),
        );
      },
      child: Container(
        margin: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.accentPurple.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppTheme.accentPurple.withOpacity(0.5)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.accentPurple.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.electric_bike_rounded, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Live Order: ${order.status}', style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  Text('Arriving in $time', style: GoogleFonts.urbanist(color: AppTheme.primaryGold, fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios_rounded, color: Colors.white54, size: 16),
          ],
        ),
      ),
    );
  }
}

class _GlowDisk extends StatelessWidget {
  final Color color; final double size;
  const _GlowDisk({required this.color, required this.size});
  @override build(context) => Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color, boxShadow: [BoxShadow(color: color, blurRadius: 100, spreadRadius: 50)]));
}

class _FilterButton extends StatelessWidget {
  final String label; final bool isSelected; final VoidCallback onTap;
  const _FilterButton({required this.label, required this.isSelected, required this.onTap});
  @override build(context) => Expanded(child: GestureDetector(onTap: onTap, child: Container(padding: const EdgeInsets.symmetric(vertical: 12), decoration: BoxDecoration(color: isSelected ? AppTheme.primaryGold.withOpacity(0.1) : Colors.transparent, borderRadius: BorderRadius.circular(12), border: Border.all(color: isSelected ? AppTheme.primaryGold.withOpacity(0.5) : Colors.transparent)), child: Text(label, textAlign: TextAlign.center, style: GoogleFonts.urbanist(color: isSelected ? AppTheme.primaryGold : Colors.white60, fontWeight: FontWeight.bold, fontSize: 13)))));
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});
  @override build(context) => Padding(padding: const EdgeInsets.fromLTRB(20, 20, 20, 10), child: Text(title, style: GoogleFonts.urbanist(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)));
}

class _FoodCardLarge extends StatelessWidget {
  final MenuItem item;
  const _FoodCardLarge({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170, margin: const EdgeInsets.only(right: 15, bottom: 10),
      decoration: BoxDecoration(color: const Color(0xFF101010), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.03))),
      child: Stack(
        children: [
          Column(
            children: [
              ClipRRect(borderRadius: const BorderRadius.vertical(top: Radius.circular(20)), child: Image.network(item.imageUrl, height: 110, width: double.infinity, fit: BoxFit.cover)),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 4),
                    Text(item.description, style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 11), maxLines: 1, overflow: TextOverflow.ellipsis),
                    const SizedBox(height: 8),
                    Row(children: [Icon(Icons.star_rounded, color: AppTheme.primaryGold, size: 12), const SizedBox(width: 2), Text('${item.rating}', style: GoogleFonts.urbanist(color: AppTheme.primaryGold, fontSize: 11, fontWeight: FontWeight.bold))]),
                    const SizedBox(height: 12),
                    Text('₹${item.price}', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: GestureDetector(
              onTap: () {
                Provider.of<CartProvider>(context, listen: false).addItem(item);
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('${item.name} added to cart', style: GoogleFonts.urbanist(color: Colors.white)),
                  backgroundColor: const Color(0xFF222222),
                  duration: const Duration(seconds: 1),
                ));
              },
              child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: LinearGradient(colors: [AppTheme.primaryGold, Color(0xFFFAEA73)])),
                  child: const Icon(Icons.add, color: Colors.black, size: 18)
              ),
            ),
          ),
          Positioned(top: 10, right: 10, child: Container(padding: const EdgeInsets.all(4), decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(6)), child: Icon(Icons.circle, color: item.isVeg ? Colors.green : Colors.red, size: 8))),
        ],
      ),
    );
  }
}

class _FoodCardSmall extends StatelessWidget {
  final MenuItem item;
  const _FoodCardSmall({required this.item});

  void _showItemDetail(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF101010),
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(30))),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6, minChildSize: 0.4, maxChildSize: 0.9, expand: false,
        builder: (_, scroller) => Stack(
          children: [
            ListView(
              controller: scroller, padding: const EdgeInsets.all(25),
              children: [
                ClipRRect(borderRadius: BorderRadius.circular(20), child: Image.network(item.imageUrl, height: 200, fit: BoxFit.cover)),
                const SizedBox(height: 20),
                Text(item.name, style: GoogleFonts.urbanist(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                Row(children: [Text('₹${item.price}', style: GoogleFonts.spaceGrotesk(color: AppTheme.primaryGold, fontSize: 22, fontWeight: FontWeight.bold)), const Spacer(), Icon(Icons.star_rounded, color: AppTheme.primaryGold), Text('${item.rating} (${item.reviewCount}+)', style: const TextStyle(color: Colors.white70))]),
                const SizedBox(height: 20),
                Text('Description', style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold)),
                Text(item.description, style: GoogleFonts.urbanist(color: Colors.white70, height: 1.5)),
                const SizedBox(height: 20),
                Container(padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white.withOpacity(0.03), borderRadius: BorderRadius.circular(15)), child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: [_Nutrient(label: 'CALORIES', value: '${item.calories}KCal'), _Nutrient(label: 'PROTEIN', value: '${item.protein}G')])),
              ],
            ),
            Positioned(
              bottom: 20,
              left: 20,
              right: 20,
              child: ElevatedButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).addItem(item);
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text('${item.name} added to cart', style: GoogleFonts.urbanist(color: Colors.white)),
                    backgroundColor: const Color(0xFF222222),
                    duration: const Duration(seconds: 1),
                  ));
                },
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryGold, foregroundColor: Colors.black, padding: const EdgeInsets.symmetric(vertical: 16), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
                child: Text('Add to Cart - ₹${item.price}', style: GoogleFonts.urbanist(fontWeight: FontWeight.bold, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showItemDetail(context),
      child: Container(
        height: 120, margin: const EdgeInsets.only(bottom: 15),
        decoration: BoxDecoration(color: const Color(0xFF101010), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withOpacity(0.03))),
        child: Row(
          children: [
            Padding(padding: const EdgeInsets.all(10), child: ClipRRect(borderRadius: BorderRadius.circular(15), child: Image.network(item.imageUrl, height: 100, width: 100, fit: BoxFit.cover))),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item.name, style: GoogleFonts.urbanist(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16), maxLines: 1),
                    Text(item.description, style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 12), maxLines: 1),
                    const Spacer(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('₹${item.price}', style: GoogleFonts.spaceGrotesk(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                        GestureDetector(
                          onTap: () {
                            Provider.of<CartProvider>(context, listen: false).addItem(item);
                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text('${item.name} added to cart', style: GoogleFonts.urbanist(color: Colors.white)),
                              backgroundColor: const Color(0xFF222222),
                              duration: const Duration(seconds: 1),
                            ));
                          },
                          child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(color: AppTheme.accentPurple, borderRadius: BorderRadius.circular(10)),
                              child: const Icon(Icons.add_shopping_cart, color: Colors.white, size: 16)
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Nutrient extends StatelessWidget {
  final String label; final String value;
  const _Nutrient({required this.label, required this.value});
  @override build(context) => Column(children: [Text(label, style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 11)), const SizedBox(height: 4), Text(value, style: GoogleFonts.spaceGrotesk(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16))]);
}