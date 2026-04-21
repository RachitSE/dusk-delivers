class MenuItem {
  final String id;
  final String name;
  final String description;
  final int price;
  final String category;
  final bool isVeg;
  final String imageUrl;
  final double rating;
  final int reviewCount;
  final int calories;
  final int protein;

  MenuItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.category,
    this.isVeg = true,
    required this.imageUrl,
    this.rating = 4.8,
    this.reviewCount = 120,
    required this.calories,
    required this.protein,
  });
}

class MenuData {
  static final List<String> categories = [
    'Burgers',
    'Momos',
    'Noodles & Rice',
    'Snacks & Meals',
    'Fries',
    'Maggi & Pasta',
    'Wraps & Sandwiches',
    'Desi Main Course',
    'Beverages',
    'Desserts'
  ];

  static final Map<String, String> categoryImages = {
    'Fries': 'https://images.unsplash.com/photo-1576107232684-1279f3908594?q=80&w=400',
    'Maggi & Pasta': 'https://images.unsplash.com/photo-1621996346565-e3dbc646d9a9?q=80&w=400',
    'Wraps & Sandwiches': 'https://images.unsplash.com/photo-1628840042765-356cda07504e?q=80&w=400',
    'Beverages': 'https://images.unsplash.com/photo-1572490122747-3968b75bb699?q=80&w=400',
    'Momos': 'https://images.unsplash.com/photo-1625220194771-7ebdea0b70b9?q=80&w=400',
    'Noodles & Rice': 'https://images.unsplash.com/photo-1612929633738-8fe01f7280f2?q=80&w=400',
    'Desserts': 'https://images.unsplash.com/photo-1624353365286-cb18d6ee4dce?q=80&w=400',
    'Desi Main Course': 'https://images.unsplash.com/photo-1585937421612-70a008356fbe?q=80&w=400',
    'Burgers': 'https://images.unsplash.com/photo-1568901346375-23c9450c58cd?q=80&w=400',
    'Snacks & Meals': 'https://images.unsplash.com/photo-1562967914-608f82629710?q=80&w=400',
  };

  static String _getImage(String category) => categoryImages[category]!;

  static final List<MenuItem> items = [
    // FRIES
    MenuItem(id: 'fr1', name: 'Salted Fries', description: 'Classic crispy salted french fries.', price: 70, category: 'Fries', imageUrl: _getImage('Fries'), calories: 312, protein: 3),
    MenuItem(id: 'fr2', name: 'Peri Peri Fries', description: 'Crispy fries tossed in spicy peri peri mix.', price: 90, category: 'Fries', imageUrl: _getImage('Fries'), calories: 320, protein: 3),
    MenuItem(id: 'fr3', name: 'Honey Chilly Potato', description: 'Sweet and spicy crispy potato bites.', price: 120, category: 'Fries', imageUrl: _getImage('Fries'), calories: 410, protein: 4),
    MenuItem(id: 'fr4', name: 'Cheesy Loaded Fries', description: 'Fries smothered in melted cheese sauce.', price: 120, category: 'Fries', imageUrl: _getImage('Fries'), calories: 450, protein: 8),
    MenuItem(id: 'fr5', name: 'Cheesy Loaded Peri Peri', description: 'Spicy peri peri fries topped with liquid cheese.', price: 130, category: 'Fries', imageUrl: _getImage('Fries'), calories: 460, protein: 8),

    // MAGGI & PASTA
    MenuItem(id: 'mp1', name: 'Masala Maggi', description: 'Classic comfort street-style maggi.', price: 50, category: 'Maggi & Pasta', imageUrl: _getImage('Maggi & Pasta'), calories: 280, protein: 6),
    MenuItem(id: 'mp2', name: 'Veggie-Loaded Maggi', description: 'Masala maggi tossed with fresh mixed vegetables.', price: 70, category: 'Maggi & Pasta', imageUrl: _getImage('Maggi & Pasta'), calories: 310, protein: 7),
    MenuItem(id: 'mp3', name: 'Tornadomaggi Veg', description: 'Spicy and tangy loaded vegetable maggi.', price: 100, category: 'Maggi & Pasta', imageUrl: _getImage('Maggi & Pasta'), calories: 350, protein: 8),
    MenuItem(id: 'mp4', name: 'Tornadomaggi Chicken', description: 'Spicy maggi loaded with chicken chunks.', price: 120, category: 'Maggi & Pasta', isVeg: false, imageUrl: _getImage('Maggi & Pasta'), calories: 420, protein: 18),
    MenuItem(id: 'mp5', name: 'Spl. Italian Cheese Maggi', description: 'Rich maggi prepared with Italian herbs and cheese.', price: 120, category: 'Maggi & Pasta', imageUrl: _getImage('Maggi & Pasta'), calories: 400, protein: 12),
    MenuItem(id: 'mp6', name: 'Penne Red Sauce Pasta', description: 'Penne tossed in tangy arrabbiata tomato sauce.', price: 160, category: 'Maggi & Pasta', imageUrl: _getImage('Maggi & Pasta'), calories: 380, protein: 10),
    MenuItem(id: 'mp7', name: 'Penne White Sauce Pasta', description: 'Creamy and cheesy white sauce penne pasta.', price: 160, category: 'Maggi & Pasta', imageUrl: _getImage('Maggi & Pasta'), calories: 450, protein: 14),
    MenuItem(id: 'mp8', name: 'Penne Pink Sauce Pasta', description: 'Perfect blend of creamy white and tangy red sauce.', price: 160, category: 'Maggi & Pasta', imageUrl: _getImage('Maggi & Pasta'), calories: 420, protein: 12),

    // WRAPS & SANDWICHES
    MenuItem(id: 'ws1', name: 'Veg Wrap', description: 'Fresh veggies and sauces wrapped in a soft tortilla.', price: 100, category: 'Wraps & Sandwiches', imageUrl: _getImage('Wraps & Sandwiches'), calories: 290, protein: 8),
    MenuItem(id: 'ws2', name: 'Paneer Wrap', description: 'Spiced paneer cubes wrapped with fresh greens.', price: 120, category: 'Wraps & Sandwiches', imageUrl: _getImage('Wraps & Sandwiches'), calories: 380, protein: 16),
    MenuItem(id: 'ws3', name: 'Chicken Wrap', description: 'Juicy chicken pieces wrapped with signature sauces.', price: 130, category: 'Wraps & Sandwiches', isVeg: false, imageUrl: _getImage('Wraps & Sandwiches'), calories: 410, protein: 22),
    MenuItem(id: 'ws4', name: 'Spl. Chicken Breast Wrap', description: 'Premium grilled chicken breast loaded wrap.', price: 180, category: 'Wraps & Sandwiches', isVeg: false, imageUrl: _getImage('Wraps & Sandwiches'), calories: 450, protein: 32),
    MenuItem(id: 'ws5', name: 'Veg Sandwich', description: 'Classic grilled sandwich with fresh vegetables.', price: 100, category: 'Wraps & Sandwiches', imageUrl: _getImage('Wraps & Sandwiches'), calories: 250, protein: 6),
    MenuItem(id: 'ws6', name: 'Veg Cheese Sandwich', description: 'Grilled vegetable sandwich loaded with cheese.', price: 120, category: 'Wraps & Sandwiches', imageUrl: _getImage('Wraps & Sandwiches'), calories: 320, protein: 10),
    MenuItem(id: 'ws7', name: 'Paneer Sandwich', description: 'Grilled sandwich stuffed with spiced paneer filling.', price: 120, category: 'Wraps & Sandwiches', imageUrl: _getImage('Wraps & Sandwiches'), calories: 350, protein: 14),
    MenuItem(id: 'ws8', name: 'Paneer Cheese Sandwich', description: 'Rich paneer and melting cheese grilled sandwich.', price: 140, category: 'Wraps & Sandwiches', imageUrl: _getImage('Wraps & Sandwiches'), calories: 420, protein: 18),
    MenuItem(id: 'ws9', name: 'Chicken Sandwich', description: 'Grilled sandwich with seasoned chicken filling.', price: 130, category: 'Wraps & Sandwiches', isVeg: false, imageUrl: _getImage('Wraps & Sandwiches'), calories: 380, protein: 20),
    MenuItem(id: 'ws10', name: 'Chicken Cheese Sandwich', description: 'Juicy chicken and melting cheese in a grilled sandwich.', price: 150, category: 'Wraps & Sandwiches', isVeg: false, imageUrl: _getImage('Wraps & Sandwiches'), calories: 450, protein: 24),

    // BEVERAGES
    MenuItem(id: 'bv1', name: 'Cafe Frappe', description: 'Classic chilled blended coffee.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 180, protein: 4),
    MenuItem(id: 'bv2', name: 'Hazelnut Frappe', description: 'Cold coffee blended with rich hazelnut syrup.', price: 120, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 220, protein: 4),
    MenuItem(id: 'bv3', name: 'Kitkat Shake', description: 'Thick creamy shake blended with KitKat chunks.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 350, protein: 6),
    MenuItem(id: 'bv4', name: 'Oreo Shake', description: 'Classic thick shake blended with crushed Oreos.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 340, protein: 6),
    MenuItem(id: 'bv5', name: 'Strawberry Shake', description: 'Sweet and creamy strawberry flavored thick shake.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 280, protein: 5),
    MenuItem(id: 'bv6', name: 'Mango Shake', description: 'Refreshing sweet mango blended shake.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 290, protein: 5),
    MenuItem(id: 'bv7', name: 'Butterscotch Shake', description: 'Rich shake with crunchy butterscotch bits.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 320, protein: 5),
    MenuItem(id: 'bv8', name: 'Kiwi Blast Shake', description: 'Tangy and sweet refreshing kiwi shake.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 270, protein: 4),
    MenuItem(id: 'bv9', name: 'Black Currant Shake', description: 'Sweet and tart black currant blended shake.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 280, protein: 4),
    MenuItem(id: 'bv10', name: 'Pineapple Shake', description: 'Tropical sweet pineapple blended thick shake.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 270, protein: 4),
    MenuItem(id: 'bv11', name: 'Vanilla Shake', description: 'Classic smooth and creamy vanilla shake.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 250, protein: 5),
    MenuItem(id: 'bv12', name: 'Fresh Lime Soda', description: 'Refreshing sweet and salty lime soda.', price: 70, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 90, protein: 0),
    MenuItem(id: 'bv13', name: 'Virgin Mojito', description: 'Classic mint and lime refreshing cooler.', price: 80, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 120, protein: 0),
    MenuItem(id: 'bv14', name: 'Mint Mojito', description: 'Cooler packed with extra fresh mint leaves.', price: 80, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 120, protein: 0),
    MenuItem(id: 'bv15', name: 'Green Apple Mojito', description: 'Tangy green apple flavored refreshing cooler.', price: 80, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 130, protein: 0),
    MenuItem(id: 'bv16', name: 'Watermelon Mojito', description: 'Sweet watermelon flavored summer cooler.', price: 80, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 130, protein: 0),
    MenuItem(id: 'bv17', name: 'Orange Mojito', description: 'Citrusy and refreshing orange cooler.', price: 80, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 130, protein: 0),
    MenuItem(id: 'bv18', name: 'Ice Tea Lemon / Peach', description: 'Chilled refreshing ice tea in lemon or peach flavor.', price: 100, category: 'Beverages', imageUrl: _getImage('Beverages'), calories: 110, protein: 0),

    // MOMOS
    MenuItem(id: 'mo1', name: 'Veg Steam Momos', description: 'Classic steamed momos stuffed with fresh veggies.', price: 70, category: 'Momos', imageUrl: _getImage('Momos'), calories: 220, protein: 6),
    MenuItem(id: 'mo2', name: 'Veg Pan Fried Momos', description: 'Crispy bottom pan-fried vegetable momos.', price: 80, category: 'Momos', imageUrl: _getImage('Momos'), calories: 260, protein: 6),
    MenuItem(id: 'mo3', name: 'Veg Deep Fried Momos', description: 'Golden crispy deep-fried vegetable momos.', price: 80, category: 'Momos', imageUrl: _getImage('Momos'), calories: 310, protein: 6),
    MenuItem(id: 'mo4', name: 'Veg Devil Momos', description: 'Spicy pan-fried momos tossed in devil sauce.', price: 110, category: 'Momos', imageUrl: _getImage('Momos'), calories: 290, protein: 6),
    MenuItem(id: 'mo5', name: 'Veg Kurkure Momos', description: 'Extra crunchy crusted fried vegetable momos.', price: 100, category: 'Momos', imageUrl: _getImage('Momos'), calories: 340, protein: 7),
    MenuItem(id: 'mo6', name: 'Paneer Cheese Steam Momos', description: 'Steamed momos filled with paneer and melting cheese.', price: 90, category: 'Momos', imageUrl: _getImage('Momos'), calories: 280, protein: 12),
    MenuItem(id: 'mo7', name: 'Paneer Cheese Pan Fried Momos', description: 'Pan-fried momos with rich paneer and cheese filling.', price: 100, category: 'Momos', imageUrl: _getImage('Momos'), calories: 320, protein: 12),
    MenuItem(id: 'mo8', name: 'Paneer Cheese Deep Fried Momos', description: 'Crispy fried momos packed with paneer and cheese.', price: 100, category: 'Momos', imageUrl: _getImage('Momos'), calories: 370, protein: 12),
    MenuItem(id: 'mo9', name: 'Paneer Cheese Devil Momos', description: 'Spicy paneer and cheese momos in devil sauce.', price: 130, category: 'Momos', imageUrl: _getImage('Momos'), calories: 350, protein: 12),
    MenuItem(id: 'mo10', name: 'Paneer Cheese Kurkure Momos', description: 'Crunchy crusted paneer and cheese momos.', price: 120, category: 'Momos', imageUrl: _getImage('Momos'), calories: 400, protein: 13),
    MenuItem(id: 'mo11', name: 'Chicken Steam Momos', description: 'Classic steamed momos with juicy chicken filling.', price: 90, category: 'Momos', isVeg: false, imageUrl: _getImage('Momos'), calories: 250, protein: 18),
    MenuItem(id: 'mo12', name: 'Chicken Pan Fried Momos', description: 'Crispy bottom pan-fried chicken momos.', price: 100, category: 'Momos', isVeg: false, imageUrl: _getImage('Momos'), calories: 290, protein: 18),
    MenuItem(id: 'mo13', name: 'Chicken Deep Fried Momos', description: 'Golden crispy deep-fried chicken momos.', price: 100, category: 'Momos', isVeg: false, imageUrl: _getImage('Momos'), calories: 340, protein: 18),
    MenuItem(id: 'mo14', name: 'Chicken Devil Momos', description: 'Spicy chicken momos tossed in fiery devil sauce.', price: 130, category: 'Momos', isVeg: false, imageUrl: _getImage('Momos'), calories: 320, protein: 18),
    MenuItem(id: 'mo15', name: 'Chicken Kurkure Momos', description: 'Extra crunchy crusted fried chicken momos.', price: 120, category: 'Momos', isVeg: false, imageUrl: _getImage('Momos'), calories: 380, protein: 19),

    // NOODLES & RICE
    MenuItem(id: 'nr1', name: 'Veg Hakka Noodles', description: 'Classic street-style wok-tossed hakka noodles.', price: 80, category: 'Noodles & Rice', imageUrl: _getImage('Noodles & Rice'), calories: 350, protein: 8),
    MenuItem(id: 'nr2', name: 'Egg Hakka Noodles', description: 'Hakka noodles wok-tossed with scrambled eggs.', price: 100, category: 'Noodles & Rice', isVeg: false, imageUrl: _getImage('Noodles & Rice'), calories: 420, protein: 16),
    MenuItem(id: 'nr3', name: 'Chicken Hakka Noodles', description: 'Hakka noodles wok-tossed with juicy chicken pieces.', price: 110, category: 'Noodles & Rice', isVeg: false, imageUrl: _getImage('Noodles & Rice'), calories: 450, protein: 22),
    MenuItem(id: 'nr4', name: 'Veg Chilly Garlic Noodles', description: 'Spicy garlic-flavored wok-tossed veg noodles.', price: 100, category: 'Noodles & Rice', imageUrl: _getImage('Noodles & Rice'), calories: 370, protein: 8),
    MenuItem(id: 'nr5', name: 'Egg Chilly Garlic Noodles', description: 'Spicy garlic noodles wok-tossed with eggs.', price: 120, category: 'Noodles & Rice', isVeg: false, imageUrl: _getImage('Noodles & Rice'), calories: 440, protein: 16),
    MenuItem(id: 'nr6', name: 'Chicken Chilly Garlic Noodles', description: 'Spicy garlic noodles tossed with chicken.', price: 130, category: 'Noodles & Rice', isVeg: false, imageUrl: _getImage('Noodles & Rice'), calories: 470, protein: 22),
    MenuItem(id: 'nr7', name: 'Veg Green Fried Rice', description: 'Healthy and flavorful green vegetable fried rice.', price: 80, category: 'Noodles & Rice', imageUrl: _getImage('Noodles & Rice'), calories: 320, protein: 6),
    MenuItem(id: 'nr8', name: 'Veg Chilly Garlic Fried Rice', description: 'Spicy garlic-flavored vegetable fried rice.', price: 100, category: 'Noodles & Rice', imageUrl: _getImage('Noodles & Rice'), calories: 340, protein: 6),
    MenuItem(id: 'nr9', name: 'Egg Fried Rice', description: 'Classic wok-tossed fried rice with eggs.', price: 100, category: 'Noodles & Rice', isVeg: false, imageUrl: _getImage('Noodles & Rice'), calories: 400, protein: 14),
    MenuItem(id: 'nr10', name: 'Egg Chilly Garlic Fried Rice', description: 'Spicy garlic fried rice wok-tossed with eggs.', price: 120, category: 'Noodles & Rice', isVeg: false, imageUrl: _getImage('Noodles & Rice'), calories: 420, protein: 14),
    MenuItem(id: 'nr11', name: 'Chicken Fried Rice', description: 'Classic wok-tossed fried rice with chicken chunks.', price: 110, category: 'Noodles & Rice', isVeg: false, imageUrl: _getImage('Noodles & Rice'), calories: 430, protein: 20),
    MenuItem(id: 'nr12', name: 'Chicken Chilly Garlic Fried Rice', description: 'Spicy garlic fried rice tossed with chicken.', price: 130, category: 'Noodles & Rice', isVeg: false, imageUrl: _getImage('Noodles & Rice'), calories: 450, protein: 20),
    MenuItem(id: 'nr13', name: 'Paneer Fried Rice', description: 'Fried rice tossed with spiced paneer cubes.', price: 100, category: 'Noodles & Rice', imageUrl: _getImage('Noodles & Rice'), calories: 410, protein: 14),
    MenuItem(id: 'nr14', name: 'Paneer Chilly Garlic Fried Rice', description: 'Spicy garlic fried rice with paneer.', price: 120, category: 'Noodles & Rice', imageUrl: _getImage('Noodles & Rice'), calories: 430, protein: 14),

    // DESSERTS
    MenuItem(id: 'ds1', name: 'Decadent Walnut Brownie', description: 'Rich chocolate brownie packed with walnuts.', price: 120, category: 'Desserts', imageUrl: _getImage('Desserts'), calories: 450, protein: 6),
    MenuItem(id: 'ds2', name: 'Choco Lava Cake', description: 'Warm chocolate cake with a gooey molten center.', price: 100, category: 'Desserts', imageUrl: _getImage('Desserts'), calories: 380, protein: 5),

    // DESI MAIN COURSE
    MenuItem(id: 'dm1', name: 'Dal Makhni', description: 'Slow-cooked rich and creamy black lentils.', price: 180, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 450, protein: 15),
    MenuItem(id: 'dm2', name: 'Paneer Butter Masala', description: 'Paneer cubes in a rich, creamy tomato gravy.', price: 200, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 520, protein: 18),
    MenuItem(id: 'dm3', name: 'Kadhai Paneer', description: 'Spicy paneer cooked with bell peppers and onions.', price: 200, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 480, protein: 18),
    MenuItem(id: 'dm4', name: 'Dal Makhni & Rice', description: 'Classic combo of creamy dal makhni and steamed rice.', price: 160, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 650, protein: 20),
    MenuItem(id: 'dm5', name: 'Paneer Butter Masala & Rice', description: 'Rich paneer butter masala served with steamed rice.', price: 180, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 720, protein: 23),
    MenuItem(id: 'dm6', name: 'Kadhai Paneer & Rice', description: 'Spicy kadhai paneer served with steamed rice.', price: 180, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 680, protein: 23),
    MenuItem(id: 'dm7', name: 'Steamed Rice', description: 'Plain fluffy steamed basmati rice.', price: 60, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 200, protein: 4),
    MenuItem(id: 'dm8', name: 'Jeera Rice', description: 'Basmati rice tempered with cumin seeds.', price: 80, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 220, protein: 4),
    MenuItem(id: 'dm9', name: 'Tawa Roti', description: 'Classic Indian flatbread cooked on a tawa.', price: 10, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 120, protein: 3),
    MenuItem(id: 'dm10', name: 'Butter Roti', description: 'Tawa roti brushed with fresh butter.', price: 15, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 150, protein: 3),
    MenuItem(id: 'dm11', name: 'Plain Paratha', description: 'Layered and flaky Indian flatbread.', price: 30, category: 'Desi Main Course', imageUrl: _getImage('Desi Main Course'), calories: 250, protein: 5),

    // BURGERS
    MenuItem(id: 'bg1', name: 'Veg Burger', description: 'Crispy veg patty with fresh lettuce and mayo.', price: 70, category: 'Burgers', imageUrl: _getImage('Burgers'), calories: 350, protein: 8),
    MenuItem(id: 'bg2', name: 'Veg Cheese Burger', description: 'Classic veg burger topped with a cheese slice.', price: 90, category: 'Burgers', imageUrl: _getImage('Burgers'), calories: 420, protein: 12),
    MenuItem(id: 'bg3', name: 'Tandoori Veg Cheese Burger', description: 'Veg burger flavored with smoky tandoori sauce.', price: 100, category: 'Burgers', imageUrl: _getImage('Burgers'), calories: 440, protein: 12),
    MenuItem(id: 'bg4', name: 'Paneer Burger', description: 'Burger layered with a thick crispy paneer patty.', price: 80, category: 'Burgers', imageUrl: _getImage('Burgers'), calories: 410, protein: 14),
    MenuItem(id: 'bg5', name: 'Paneer Cheese Burger', description: 'Crispy paneer burger topped with melting cheese.', price: 100, category: 'Burgers', imageUrl: _getImage('Burgers'), calories: 480, protein: 18),
    MenuItem(id: 'bg6', name: 'Tandoori Paneer Cheese Burger', description: 'Paneer cheese burger with a smoky tandoori twist.', price: 110, category: 'Burgers', imageUrl: _getImage('Burgers'), calories: 500, protein: 18),
    MenuItem(id: 'bg7', name: 'Chicken Burger', description: 'Juicy chicken patty with fresh lettuce and mayo.', price: 90, category: 'Burgers', isVeg: false, imageUrl: _getImage('Burgers'), calories: 420, protein: 22),
    MenuItem(id: 'bg8', name: 'Chicken Cheese Burger', description: 'Classic chicken burger topped with a cheese slice.', price: 110, category: 'Burgers', isVeg: false, imageUrl: _getImage('Burgers'), calories: 490, protein: 26),
    MenuItem(id: 'bg9', name: 'Tandoori Chicken Cheese Burger', description: 'Chicken cheese burger with smoky tandoori flavors.', price: 120, category: 'Burgers', isVeg: false, imageUrl: _getImage('Burgers'), calories: 510, protein: 26),
    MenuItem(id: 'bg10', name: 'Spl. Chicken Breast Burger', description: 'Premium burger with a full grilled chicken breast.', price: 170, category: 'Burgers', isVeg: false, imageUrl: _getImage('Burgers'), calories: 550, protein: 35),

    // SNACKS & MEALS
    MenuItem(id: 'sm1', name: 'Chilly Paneer', description: 'Spicy wok-tossed paneer cubes with bell peppers.', price: 140, category: 'Snacks & Meals', imageUrl: _getImage('Snacks & Meals'), calories: 420, protein: 16),
    MenuItem(id: 'sm2', name: 'Chilly Chicken', description: 'Spicy wok-tossed chicken chunks with bell peppers.', price: 160, category: 'Snacks & Meals', isVeg: false, imageUrl: _getImage('Snacks & Meals'), calories: 450, protein: 24),
    MenuItem(id: 'sm3', name: 'Drums of Heaven', description: 'Spicy and tangy frenched chicken winglets.', price: 180, category: 'Snacks & Meals', isVeg: false, imageUrl: _getImage('Snacks & Meals'), calories: 520, protein: 28),
    MenuItem(id: 'sm4', name: 'Spl. Paneer Chatpata', description: 'Tangy and spicy special paneer preparation.', price: 180, category: 'Snacks & Meals', imageUrl: _getImage('Snacks & Meals'), calories: 460, protein: 18),
    MenuItem(id: 'sm5', name: 'Daaru Dana (Peanut Chat)', description: 'Spicy and tangy roasted peanut chaat.', price: 130, category: 'Snacks & Meals', imageUrl: _getImage('Snacks & Meals'), calories: 350, protein: 12),
    MenuItem(id: 'sm6', name: 'Crispy Corn', description: 'Deep-fried sweet corn tossed in spicy seasoning.', price: 150, category: 'Snacks & Meals', imageUrl: _getImage('Snacks & Meals'), calories: 380, protein: 6),
    MenuItem(id: 'sm7', name: 'Noodles + Chilly Paneer', description: 'Combo bowl of hakka noodles and chilly paneer.', price: 180, category: 'Snacks & Meals', imageUrl: _getImage('Snacks & Meals'), calories: 650, protein: 20),
    MenuItem(id: 'sm8', name: 'Fried Rice + Chilly Paneer', description: 'Combo bowl of fried rice and chilly paneer.', price: 180, category: 'Snacks & Meals', imageUrl: _getImage('Snacks & Meals'), calories: 680, protein: 20),
    MenuItem(id: 'sm9', name: 'Noodles + Chilly Chicken', description: 'Combo bowl of hakka noodles and chilly chicken.', price: 200, category: 'Snacks & Meals', isVeg: false, imageUrl: _getImage('Snacks & Meals'), calories: 700, protein: 28),
    MenuItem(id: 'sm10', name: 'Fried Rice + Chilly Chicken', description: 'Combo bowl of fried rice and chilly chicken.', price: 200, category: 'Snacks & Meals', isVeg: false, imageUrl: _getImage('Snacks & Meals'), calories: 720, protein: 28),
  ];
}