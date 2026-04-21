import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../../core/theme/theme.dart';
import '../../core/constants/menu_data.dart';
import '../../core/providers/cart_provider.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  // Filter States
  String _searchQuery = '';
  String _selectedCategory = 'All';
  bool _isVegOnly = false;
  bool _isUnder100 = false;
  bool _isHighProtein = false;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Real-time filtering logic
  List<MenuItem> get _filteredItems {
    return MenuData.items.where((item) {
      final matchesSearch = item.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          item.description.toLowerCase().contains(_searchQuery.toLowerCase());
      final matchesCategory = _selectedCategory == 'All' || item.category == _selectedCategory;
      final matchesVeg = !_isVegOnly || item.isVeg;
      final matchesPrice = !_isUnder100 || item.price < 100;
      final matchesProtein = !_isHighProtein || item.protein >= 15;

      return matchesSearch && matchesCategory && matchesVeg && matchesPrice && matchesProtein;
    }).toList();
  }

  void _startVoiceSearch() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => const _VoiceSearchOverlay(),
    ).then((spokenText) {
      // If the mock voice search returns text, put it in the search bar
      if (spokenText != null && spokenText is String && spokenText.isNotEmpty) {
        setState(() {
          _searchController.text = spokenText;
          _searchQuery = spokenText;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final results = _filteredItems;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // 1. Sleek Search Bar
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Container(
              height: 55,
              decoration: BoxDecoration(
                color: const Color(0xFF101010),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withOpacity(0.08)),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primaryGold.withOpacity(0.05),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                  )
                ],
              ),
              child: TextField(
                controller: _searchController,
                onChanged: (value) => setState(() => _searchQuery = value),
                style: GoogleFonts.urbanist(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                cursorColor: AppTheme.primaryGold,
                decoration: InputDecoration(
                  hintText: 'Search for burgers, momos...',
                  hintStyle: GoogleFonts.urbanist(color: Colors.white38),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                    icon: const Icon(Icons.close_rounded, color: Colors.white54, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      setState(() => _searchQuery = '');
                    },
                  )
                      : IconButton(
                    icon: const Icon(Icons.mic_none_rounded, color: AppTheme.primaryGold, size: 22),
                    onPressed: _startVoiceSearch, // Hooks up the mic button
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(vertical: 18),
                ),
              ),
            ),
          ),

          // 2. Main Categories Scroll
          SizedBox(
            height: 50,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildCategoryChip('All'),
                ...MenuData.categories.map((cat) => _buildCategoryChip(cat)),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // 3. Quick Smart Filters
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                _buildSmartFilter('Veg Only 🥦', _isVegOnly, () => setState(() => _isVegOnly = !_isVegOnly)),
                _buildSmartFilter('Under ₹100 💸', _isUnder100, () => setState(() => _isUnder100 = !_isUnder100)),
                _buildSmartFilter('High Protein 💪', _isHighProtein, () => setState(() => _isHighProtein = !_isHighProtein)),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 4. Results Grid or Empty State
          Expanded(
            child: results.isEmpty
                ? _buildEmptyState()
                : GridView.builder(
              padding: const EdgeInsets.only(left: 24, right: 24, bottom: 120),
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.72,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
              ),
              itemCount: results.length,
              itemBuilder: (context, index) => _GridFoodCard(item: results[index]),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryChip(String category) {
    final isSelected = _selectedCategory == category;
    return GestureDetector(
      onTap: () => setState(() => _selectedCategory = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primaryGold : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppTheme.primaryGold : Colors.white.withOpacity(0.1),
          ),
        ),
        child: Center(
          child: Text(
            category,
            style: GoogleFonts.urbanist(
              color: isSelected ? Colors.black : Colors.white70,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSmartFilter(String label, bool isActive, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        decoration: BoxDecoration(
          color: isActive ? AppTheme.accentPurple.withOpacity(0.3) : const Color(0xFF101010),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive ? AppTheme.accentPurple : Colors.white.withOpacity(0.05),
          ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.urbanist(
              color: isActive ? Colors.white : Colors.white54,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off_rounded, color: Colors.white.withOpacity(0.1), size: 80),
          const SizedBox(height: 16),
          Text(
            'No cravings found',
            style: GoogleFonts.urbanist(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your filters or searching\nfor something else.',
            textAlign: TextAlign.center,
            style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

// The Voice Search Overlay UI
class _VoiceSearchOverlay extends StatefulWidget {
  const _VoiceSearchOverlay();

  @override
  State<_VoiceSearchOverlay> createState() => _VoiceSearchOverlayState();
}

class _VoiceSearchOverlayState extends State<_VoiceSearchOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // MOCK: Automatically close after 3 seconds and search for "Burger"
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) Navigator.pop(context, 'Burger');
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(40)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: 350,
          width: double.infinity,
          decoration: BoxDecoration(
            color: const Color(0xFF0A0A0A).withOpacity(0.85),
            border: Border(top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Listening...',
                style: GoogleFonts.urbanist(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'Try saying "Spicy Momos"',
                style: GoogleFonts.urbanist(color: Colors.white54, fontSize: 16),
              ),
              const SizedBox(height: 60),
              AnimatedBuilder(
                animation: _pulseAnimation,
                builder: (context, child) {
                  return Transform.scale(
                    scale: _pulseAnimation.value,
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.accentPurple.withOpacity(0.3),
                        border: Border.all(color: AppTheme.accentPurple.withOpacity(0.5), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.accentPurple.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 10,
                          )
                        ],
                      ),
                      child: const Icon(Icons.mic_rounded, color: Colors.white, size: 40),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GridFoodCard extends StatelessWidget {
  final MenuItem item;
  const _GridFoodCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF101010),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.03)),
      ),
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                child: Image.network(
                  item.imageUrl,
                  height: 120,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: GoogleFonts.urbanist(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.star_rounded, color: AppTheme.primaryGold, size: 12),
                        const SizedBox(width: 4),
                        Text(
                          '${item.rating}',
                          style: GoogleFonts.urbanist(color: AppTheme.primaryGold, fontSize: 12, fontWeight: FontWeight.bold),
                        ),
                        Text(
                          ' • ${item.calories} Kcal',
                          style: GoogleFonts.urbanist(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '₹${item.price}',
                      style: GoogleFonts.spaceGrotesk(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 10,
            right: 10,
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
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppTheme.primaryGold, Color(0xFFFAEA73)],
                  ),
                ),
                child: const Icon(Icons.add_shopping_cart_rounded, color: Colors.black, size: 16),
              ),
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(Icons.circle, color: item.isVeg ? Colors.greenAccent : Colors.redAccent, size: 10),
            ),
          ),
        ],
      ),
    );
  }
}