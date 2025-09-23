# TechPlaza - Local Electronics Marketplace App

A Flutter-based mobile application that digitizes local electronics plazas in Pakistan, connecting shopkeepers and customers through a simple, manual-first marketplace platform.

## 🎯 Project Overview

TechPlaza transforms physical electronics markets (like Dubai Plaza, Singapore Plaza, Imperial Market) into a digital catalog and discovery platform. Unlike complex e-commerce solutions, TechPlaza focuses on simplicity - no deliveries, no online payments initially - just connecting local shopkeepers with customers digitally while maintaining traditional in-person transactions.

### Key Features

- **Role-based Access**: Single app supporting both customers and shop owners
- **Plaza-specific Organization**: Browse products by specific market locations
- **Real-time Chat**: Direct communication between customers and shopkeepers
- **Subscription Model**: Tiered plans for shop owners based on product listing limits
- **Multi-language Support**: English and Urdu localization
- **Theme Support**: Light and dark mode with automatic system detection
- **Manual Payment System**: Easypaisa/JazzCash proof uploads for Pakistani market

## 🏗️ Architecture

### Tech Stack
- **Frontend**: Flutter with GetX state management
- **Backend**: Supabase (PostgreSQL, Auth, Storage, Real-time)
- **Authentication**: Supabase Auth with role-based access
- **Storage**: Supabase Storage for images
- **Real-time**: Supabase subscriptions for chat

### Project Structure
\`\`\`
lib/
├── app/
│   ├── bindings/          # GetX dependency injection
│   ├── controllers/       # Business logic and state management
│   ├── models/           # Data models
│   ├── routes/           # Navigation routing
│   ├── services/         # API and business services
│   ├── translations/     # Internationalization
│   ├── utils/            # Utilities and constants
│   ├── views/            # UI screens
│   │   ├── auth/         # Authentication screens
│   │   ├── customer/     # Customer flow screens
│   │   ├── settings/     # Settings screen
│   │   ├── shop/         # Shop owner screens
│   │   └── splash/       # Splash screen
│   └── widgets/          # Reusable UI components
└── main.dart             # App entry point
\`\`\`

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)
- Android Studio / VS Code
- Supabase account

### Installation

1. **Clone the repository**
   \`\`\`bash
   git clone <repository-url>
   cd techplaza-flutter
   \`\`\`

2. **Install dependencies**
   \`\`\`bash
   flutter pub get
   \`\`\`

3. **Setup Supabase**
   - Create a new Supabase project
   - Copy your project URL and anon key
   - Create environment variables or update constants in `lib/app/utils/app_constants.dart`

4. **Database Setup**
   Run the SQL scripts to create the required tables:
   \`\`\`sql
   -- Users table
   CREATE TABLE users (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     email TEXT UNIQUE NOT NULL,
     name TEXT NOT NULL,
     phone TEXT,
     cnic TEXT,
     role TEXT NOT NULL CHECK (role IN ('customer', 'shop_owner')),
     created_at TIMESTAMP DEFAULT NOW()
   );

   -- Plazas table
   CREATE TABLE plazas (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     name TEXT NOT NULL,
     address TEXT NOT NULL,
     created_at TIMESTAMP DEFAULT NOW()
   );

   -- Shops table
   CREATE TABLE shops (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     owner_id UUID REFERENCES users(id),
     plaza_id UUID REFERENCES plazas(id),
     name TEXT NOT NULL,
     description TEXT,
     logo_url TEXT,
     status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'active', 'suspended')),
     created_at TIMESTAMP DEFAULT NOW()
   );

   -- Products table
   CREATE TABLE products (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     shop_id UUID REFERENCES shops(id),
     name TEXT NOT NULL,
     description TEXT,
     price DECIMAL NOT NULL,
     category TEXT NOT NULL,
     image_urls TEXT[],
     created_at TIMESTAMP DEFAULT NOW()
   );

   -- Messages table
   CREATE TABLE messages (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     customer_id UUID REFERENCES users(id),
     shop_id UUID REFERENCES shops(id),
     sender_id UUID REFERENCES users(id),
     content TEXT NOT NULL,
     created_at TIMESTAMP DEFAULT NOW()
   );

   -- Subscriptions table
   CREATE TABLE subscriptions (
     id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
     shop_id UUID REFERENCES shops(id),
     plan TEXT NOT NULL CHECK (plan IN ('basic', 'standard', 'premium')),
     listing_limit INTEGER NOT NULL,
     expires_at TIMESTAMP,
     created_at TIMESTAMP DEFAULT NOW()
   );
   \`\`\`

5. **Run the app**
   \`\`\`bash
   flutter run
   \`\`\`

## 👥 User Flows

### Customer Flow
1. **Registration**: Sign up as customer
2. **Plaza Selection**: Choose local electronics plaza
3. **Browse Products**: Search and filter products by category/price
4. **Product Details**: View detailed product information
5. **Chat**: Contact shop owners directly
6. **Visit Shop**: Complete purchase in-person

### Shop Owner Flow
1. **Registration**: Sign up as shop owner with CNIC verification
2. **Shop Setup**: Create shop profile and upload payment proof
3. **Admin Approval**: Wait for manual verification
4. **Product Management**: Add/edit products within subscription limits
5. **Chat Management**: Respond to customer inquiries
6. **Analytics**: View basic shop performance metrics

## 🎨 Design System

### Colors
- **Primary**: Deep Blue (#1E40AF) - Trust and professionalism
- **Secondary**: Amber (#F59E0B) - Energy and attention
- **Neutrals**: Grays and whites for clean interface
- **Success/Error**: Standard green/red for feedback

### Typography
- **Headings**: Bold weights for hierarchy
- **Body**: Regular weight with good line-height (1.4-1.6)
- **Urdu Support**: Proper font rendering for Arabic script

### Components
- **Cards**: Elevated surfaces for products and shops
- **Buttons**: Consistent styling with proper touch targets
- **Forms**: Clean input fields with validation
- **Navigation**: Bottom tabs for main sections

## 🌐 Localization

The app supports both English and Urdu languages:
- **English**: Default language for tech-savvy users
- **Urdu**: Local language support for broader adoption
- **RTL Support**: Proper right-to-left layout for Urdu text

## 📱 Platform Support

- **Android**: Primary target platform
- **iOS**: Secondary support (requires additional testing)
- **Responsive**: Optimized for various screen sizes
- **Performance**: Optimized for low-end devices common in Pakistan

## 🔐 Security & Privacy

- **Authentication**: Secure Supabase Auth with email/password
- **CNIC Verification**: Required for shop owners
- **Data Protection**: Encrypted data transmission
- **Role-based Access**: Proper permission controls

## 🚀 Deployment

### Android Release
1. **Build APK**
   \`\`\`bash
   flutter build apk --release
   \`\`\`

2. **Build App Bundle**
   \`\`\`bash
   flutter build appbundle --release
   \`\`\`

### iOS Release
1. **Build iOS**
   \`\`\`bash
   flutter build ios --release
   \`\`\`

## 📈 Future Enhancements

### Phase 2 Features
- **Automated Payments**: Easypaisa/JazzCash API integration
- **Featured Listings**: Paid promotion for shops
- **Advanced Analytics**: Detailed performance metrics
- **Push Notifications**: Real-time chat and order updates

### Phase 3 Features
- **Multi-city Expansion**: Support for multiple cities
- **Delivery Integration**: Optional delivery services
- **Review System**: Customer feedback and ratings
- **Admin Dashboard**: Web-based management panel

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 📞 Support

For support and questions:
- Email: support@techplaza.pk
- Documentation: [Project Wiki]
- Issues: [GitHub Issues]

---

**TechPlaza** - Bridging the gap between traditional electronics markets and digital discovery in Pakistan.
