/**
 * Shahganj.online — Production-Grade Firestore Demo Seeding Script
 * Version: 1.0.0
 * 
 * This script seeds the active Firebase project's Firestore database with the required
 * high-quality production demo data to run the Customer and Merchant/Rider apps immediately.
 * 
 * Target Collections:
 * - merchants (3 Restaurants, 2 Service Providers, 1 Hospital)
 * - menuItems (Full menus for all 3 restaurants)
 * - riders (5 Captive riders linked to merchants)
 * - ads (3 Banners for homepage ads carousel)
 * 
 * How to Run:
 * 1. Download your service account key from the Firebase Console:
 *    Project Settings -> Service Accounts -> Generate New Private Key
 * 2. Save the downloaded JSON file as 'service-account.json' in this folder ('firebase/').
 * 3. Run: node seed.js
 */

const admin = require("firebase-admin");
const path = require("path");
const fs = require("fs");

const SERVICE_ACCOUNT_PATH = path.join(__dirname, "service-account.json");

if (!fs.existsSync(SERVICE_ACCOUNT_PATH)) {
    console.error("❌ Error: 'service-account.json' not found!");
    console.error("Please place your Firebase service account private key in this directory:\n", SERVICE_ACCOUNT_PATH);
    console.error("\nTo get a private key:");
    console.error("1. Go to Firebase Console -> Project Settings -> Service Accounts");
    console.error("2. Click 'Generate New Private Key' and download the JSON file.");
    process.exit(1);
}

// Initialize Firebase Admin SDK
const serviceAccount = require(SERVICE_ACCOUNT_PATH);
admin.initializeApp({
    credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

// Coordinate bounds for Shahganj, Uttar Pradesh (approx. lat: 26.01, lng: 82.69)
const baseLat = 26.0125;
const baseLng = 82.6890;

const createGeoPoint = (latOffset, lngOffset) => {
    return new admin.firestore.GeoPoint(baseLat + latOffset, baseLng + lngOffset);
};

// Seed Data definition
const SEED_DATA = {
    // ----------------------------------------------------
    // MERCHANTS (Restaurants, Service Providers, Hospital)
    // ----------------------------------------------------
    merchants: [
        // 1. Restaurant 1: Shahganj Durbar
        {
            uid: "merchant_durbar_001",
            businessName: "Shahganj Durbar Restaurant",
            ownerName: "Zain Khan",
            phone: "+919876543210",
            email: "durbar@shahganj.online",
            category: "restaurant",
            status: "approved",
            location: createGeoPoint(0.0012, -0.0008),
            addressFormatted: "Main Market Road, Near Sabzi Mandi, Shahganj, UP - 223101",
            rating: 4.8,
            ratingCount: 142,
            isOpen: true,
            createdAt: admin.firestore.Timestamp.now(),
            approvedAt: admin.firestore.Timestamp.now(),
            settings: {
                minOrder: 150.0,
                deliveryRadius: 6.5,
                deliveryFee: 25.0,
                avgPrepTime: 25,
                hourlyRate: 0.0,
                deliverySlots: ["11:00 AM - 03:00 PM", "06:00 PM - 10:00 PM"],
                availableDays: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            }
        },
        // 2. Restaurant 2: Zaika Biryani Junction
        {
            uid: "merchant_zaika_002",
            businessName: "Zaika Biryani Junction",
            ownerName: "Arman Qureshi",
            phone: "+919876543211",
            email: "zaika@shahganj.online",
            category: "restaurant",
            status: "approved",
            location: createGeoPoint(-0.0021, 0.0015),
            addressFormatted: "Station Road, Opp. Railway Station Gate, Shahganj, UP - 223101",
            rating: 4.5,
            ratingCount: 98,
            isOpen: true,
            createdAt: admin.firestore.Timestamp.now(),
            approvedAt: admin.firestore.Timestamp.now(),
            settings: {
                minOrder: 100.0,
                deliveryRadius: 5.0,
                deliveryFee: 20.0,
                avgPrepTime: 20,
                hourlyRate: 0.0,
                deliverySlots: ["12:00 PM - 04:00 PM", "07:00 PM - 11:00 PM"],
                availableDays: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            }
        },
        // 3. Restaurant 3: Sweets & Treats Cafe
        {
            uid: "merchant_sweets_003",
            businessName: "Sweets & Treats Cafe",
            ownerName: "Ramesh Gupta",
            phone: "+919876543212",
            email: "sweets@shahganj.online",
            category: "restaurant",
            status: "approved",
            location: createGeoPoint(0.0005, 0.0028),
            addressFormatted: "Jौनपुर Road, Near Gandhi Murti, Shahganj, UP - 223101",
            rating: 4.6,
            ratingCount: 215,
            isOpen: true,
            createdAt: admin.firestore.Timestamp.now(),
            approvedAt: admin.firestore.Timestamp.now(),
            settings: {
                minOrder: 80.0,
                deliveryRadius: 4.0,
                deliveryFee: 15.0,
                avgPrepTime: 15,
                hourlyRate: 0.0,
                deliverySlots: ["09:00 AM - 09:00 PM"],
                availableDays: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday", "Sunday"]
            }
        },
        // 4. Service Provider 1: Guru Kirpa Electricals
        {
            uid: "merchant_guru_004",
            businessName: "Guru Kirpa Electricals & Repair",
            ownerName: "Jasbir Singh",
            phone: "+919876543213",
            email: "guru.electric@shahganj.online",
            category: "electrician",
            status: "approved",
            location: createGeoPoint(0.0041, -0.0035),
            addressFormatted: "Cinema Hall Crossing, Shahganj, UP - 223101",
            rating: 4.9,
            ratingCount: 64,
            isOpen: true,
            createdAt: admin.firestore.Timestamp.now(),
            approvedAt: admin.firestore.Timestamp.now(),
            settings: {
                minOrder: 0.0,
                deliveryRadius: 10.0,
                deliveryFee: 0.0,
                avgPrepTime: 0,
                hourlyRate: 150.0,
                deliverySlots: ["09:00 AM - 01:00 PM", "02:00 PM - 06:00 PM"],
                availableDays: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            }
        },
        // 5. Service Provider 2: Alpha Plumbing Solutions
        {
            uid: "merchant_alpha_005",
            businessName: "Alpha Plumbing & Pipe Fittings",
            ownerName: "Harish Verma",
            phone: "+919876543214",
            email: "alpha.plumb@shahganj.online",
            category: "plumber",
            status: "approved",
            location: createGeoPoint(-0.0032, -0.0018),
            addressFormatted: "Bhadon Crossing Road, Shahganj, UP - 223101",
            rating: 4.7,
            ratingCount: 38,
            isOpen: true,
            createdAt: admin.firestore.Timestamp.now(),
            approvedAt: admin.firestore.Timestamp.now(),
            settings: {
                minOrder: 0.0,
                deliveryRadius: 8.0,
                deliveryFee: 0.0,
                avgPrepTime: 0,
                hourlyRate: 120.0,
                deliverySlots: ["10:00 AM - 06:00 PM"],
                availableDays: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            }
        },
        // 6. Hospital: Shahganj Community Hospital
        {
            uid: "merchant_hospital_006",
            businessName: "Shahganj Community Hospital & Trauma Center",
            ownerName: "Dr. A. K. Mishra",
            phone: "+919876543215",
            email: "hospital@shahganj.online",
            category: "hospital",
            status: "approved",
            location: createGeoPoint(0.0055, 0.0042),
            addressFormatted: "Azamgarh High Road, Shahganj, UP - 223101",
            rating: 4.4,
            ratingCount: 320,
            isOpen: true,
            createdAt: admin.firestore.Timestamp.now(),
            approvedAt: admin.firestore.Timestamp.now(),
            settings: {
                minOrder: 0.0,
                deliveryRadius: 15.0,
                deliveryFee: 0.0,
                avgPrepTime: 0,
                hourlyRate: 300.0, // Consultation fee
                deliverySlots: ["09:00 AM - 01:00 PM (OPD)", "04:00 PM - 08:00 PM (OPD)"],
                availableDays: ["Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"]
            }
        }
    ],

    // ----------------------------------------------------
    // MENU ITEMS (For the 3 Restaurants)
    // ----------------------------------------------------
    menuItems: [
        // Menu for Restaurant 1: Shahganj Durbar
        {
            id: "menu_durbar_paneer_001",
            merchantId: "merchant_durbar_001",
            name: "Shahi Paneer Durbar Special",
            description: "Premium cottage cheese blocks simmered in an aromatic rich cashew and tomato gravy.",
            category: "Main Course",
            imageUrl: "https://images.unsplash.com/photo-1631452180519-c014fe946bc7?auto=format&fit=crop&w=400&q=80",
            isVeg: true,
            isAvailable: true,
            hasHalfPortion: true,
            fullPrice: 220.0,
            halfPrice: 120.0,
            addons: [
                { name: "Extra Butter", price: 20.0 },
                { name: "Cheese Cubes", price: 30.0 }
            ],
            preparationTime: 20,
            popularityScore: 95
        },
        {
            id: "menu_durbar_dal_002",
            merchantId: "merchant_durbar_001",
            name: "Dal Makhani Handi",
            description: "Slow-cooked black lentils and kidney beans enriched with dairy cream and white butter.",
            category: "Main Course",
            imageUrl: "https://images.unsplash.com/photo-1546833999-b9f581a1996d?auto=format&fit=crop&w=400&q=80",
            isVeg: true,
            isAvailable: true,
            hasHalfPortion: false,
            fullPrice: 160.0,
            halfPrice: null,
            addons: [
                { name: "Extra Butter Swirl", price: 15.0 }
            ],
            preparationTime: 15,
            popularityScore: 88
        },
        {
            id: "menu_durbar_roti_003",
            merchantId: "merchant_durbar_001",
            name: "Butter Tandoori Roti",
            description: "Whole wheat bread baked in a clay tandoor smeared with yellow butter.",
            category: "Breads",
            imageUrl: "https://images.unsplash.com/photo-1589301760014-d929f3979dbc?auto=format&fit=crop&w=400&q=80",
            isVeg: true,
            isAvailable: true,
            hasHalfPortion: false,
            fullPrice: 15.0,
            halfPrice: null,
            addons: [],
            preparationTime: 5,
            popularityScore: 99
        },

        // Menu for Restaurant 2: Zaika Biryani Junction
        {
            id: "menu_zaika_chicken_001",
            merchantId: "merchant_zaika_002",
            name: "Zaika Chicken Dum Biryani",
            description: "Aromatic basmati rice cooked in authentic spices on a slow fire, layered with juicy chicken.",
            category: "Rice Items",
            imageUrl: "https://images.unsplash.com/photo-1563379091339-03b21ab4a4f8?auto=format&fit=crop&w=400&q=80",
            isVeg: false,
            isAvailable: true,
            hasHalfPortion: true,
            fullPrice: 190.0,
            halfPrice: 110.0,
            addons: [
                { name: "Extra Raita", price: 10.0 },
                { name: "Double Egg", price: 20.0 }
            ],
            preparationTime: 15,
            popularityScore: 97
        },
        {
            id: "menu_zaika_kebab_002",
            merchantId: "merchant_zaika_002",
            name: "Mutton Seekh Kebab (4 Pcs)",
            description: "Minced mutton seasoned with fresh green herbs and skewered inside our hot tandoor.",
            category: "Starters",
            imageUrl: "https://images.unsplash.com/photo-1599487488170-d11ec9c172f0?auto=format&fit=crop&w=400&q=80",
            isVeg: false,
            isAvailable: true,
            hasHalfPortion: false,
            fullPrice: 240.0,
            halfPrice: null,
            addons: [
                { name: "Mint Chutney Bowl", price: 5.0 }
            ],
            preparationTime: 22,
            popularityScore: 82
        },

        // Menu for Restaurant 3: Sweets & Treats Cafe
        {
            id: "menu_sweets_samosa_001",
            merchantId: "merchant_sweets_003",
            name: "Special Desi Ghee Samosa (2 Pcs)",
            description: "Crispy outer crust filled with crushed spiced potatoes and dry fruits.",
            category: "Snacks",
            imageUrl: "https://images.unsplash.com/photo-1601050690597-df056fb4ce78?auto=format&fit=crop&w=400&q=80",
            isVeg: true,
            isAvailable: true,
            hasHalfPortion: false,
            fullPrice: 30.0,
            halfPrice: null,
            addons: [
                { name: "Extra Chole", price: 10.0 }
            ],
            preparationTime: 8,
            popularityScore: 96
        },
        {
            id: "menu_sweets_rasgulla_002",
            merchantId: "merchant_sweets_003",
            name: "Kesar Sponge Rasgulla (2 Pcs)",
            description: "Soft spongy cottage cheese dumplings soaked in sugar syrup with a hint of saffron.",
            category: "Sweets",
            imageUrl: "https://images.unsplash.com/photo-1589135306090-e7273ca1d6cd?auto=format&fit=crop&w=400&q=80",
            isVeg: true,
            isAvailable: true,
            hasHalfPortion: false,
            fullPrice: 40.0,
            halfPrice: null,
            addons: [],
            preparationTime: 3,
            popularityScore: 92
        }
    ],

    // ----------------------------------------------------
    // RIDERS (5 Captive Riders linked to Merchants)
    // ----------------------------------------------------
    riders: [
        // Rider 1: Linked to Shahganj Durbar
        {
            uid: "rider_deepak_001",
            merchantId: "merchant_durbar_001",
            name: "Deepak Yadav",
            phone: "+919876543216",
            vehicleNumber: "UP62-AB-1234",
            vehicleType: "bike",
            isOnline: true,
            currentLocation: createGeoPoint(0.0014, -0.0010),
            locationTimestamp: admin.firestore.Timestamp.now(),
            status: "available",
            totalDeliveries: 45,
            earnings: 1250.00,
            rating: 4.8,
            inviteCode: "DURBAR1"
        },
        // Rider 2: Linked to Shahganj Durbar
        {
            uid: "rider_amit_002",
            merchantId: "merchant_durbar_001",
            name: "Amit Maurya",
            phone: "+919876543217",
            vehicleNumber: "UP62-CF-5678",
            vehicleType: "scooter",
            isOnline: true,
            currentLocation: createGeoPoint(0.0008, -0.0005),
            locationTimestamp: admin.firestore.Timestamp.now(),
            status: "available",
            totalDeliveries: 28,
            earnings: 890.00,
            rating: 4.6,
            inviteCode: "DURBAR2"
        },
        // Rider 3: Linked to Zaika Biryani Junction
        {
            uid: "rider_rahul_003",
            merchantId: "merchant_zaika_002",
            name: "Rahul Tiwari",
            phone: "+919876543218",
            vehicleNumber: "UP62-DX-9012",
            vehicleType: "bike",
            isOnline: true,
            currentLocation: createGeoPoint(-0.0018, 0.0012),
            locationTimestamp: admin.firestore.Timestamp.now(),
            status: "available",
            totalDeliveries: 62,
            earnings: 1980.00,
            rating: 4.9,
            inviteCode: "ZAIKA01"
        },
        // Rider 4: Linked to Sweets & Treats Cafe (e-rickshaw)
        {
            uid: "rider_sunil_004",
            merchantId: "merchant_sweets_003",
            name: "Sunil Nishad",
            phone: "+919876543219",
            vehicleNumber: "UP62-ER-3456",
            vehicleType: "e-rickshaw",
            isOnline: true,
            currentLocation: createGeoPoint(0.0003, 0.0022),
            locationTimestamp: admin.firestore.Timestamp.now(),
            status: "available",
            totalDeliveries: 15,
            earnings: 450.00,
            rating: 4.7,
            inviteCode: "SWEETS4"
        },
        // Rider 5: Linked to Sweets & Treats Cafe (scooter)
        {
            uid: "rider_vikram_005",
            merchantId: "merchant_sweets_003",
            name: "Vikram Chauhan",
            phone: "+919876543220",
            vehicleNumber: "UP62-SZ-7890",
            vehicleType: "scooter",
            isOnline: false,
            currentLocation: createGeoPoint(0.0005, 0.0028),
            locationTimestamp: admin.firestore.Timestamp.now(),
            status: "offline",
            totalDeliveries: 34,
            earnings: 1100.00,
            rating: 4.5,
            inviteCode: "SWEETS5"
        }
    ],

    // ----------------------------------------------------
    // ADS (3 Banner Advertisements for Homepage Carousel)
    // ----------------------------------------------------
    ads: [
        {
            adId: "ad_foodfest_001",
            imageUrl: "https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=800&q=80",
            title: "Shahganj Food Fest — 30% Off!",
            deepLink: "shahganj.online/festivals/food_fest",
            priority: 1,
            startDate: admin.firestore.Timestamp.now(),
            endDate: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 30 * 24 * 60 * 60 * 1000)) // 30 days
        },
        {
            adId: "ad_erickshaw_002",
            imageUrl: "https://images.unsplash.com/photo-1568605117036-5fe5e7bab0b7?auto=format&fit=crop&w=800&q=80",
            title: "E-Rickshaw Ride Pass at ₹49/week",
            deepLink: "shahganj.online/rides/pass",
            priority: 2,
            startDate: admin.firestore.Timestamp.now(),
            endDate: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 15 * 24 * 60 * 60 * 1000)) // 15 days
        },
        {
            adId: "ad_hospital_003",
            imageUrl: "https://images.unsplash.com/photo-1516549655169-df83a0774514?auto=format&fit=crop&w=800&q=80",
            title: "Free Diagnostics Camp on Sunday",
            deepLink: "shahganj.online/hospitals/merchant_hospital_006",
            priority: 3,
            startDate: admin.firestore.Timestamp.now(),
            endDate: admin.firestore.Timestamp.fromDate(new Date(Date.now() + 6 * 24 * 60 * 60 * 1000)) // 6 days
        }
    ]
};

// Seeding engine
async function seedDatabase() {
    console.log("🚀 Starting Firestore Seeding Engine...");
    
    try {
        // 1. Seed Merchants
        console.log("\n📦 Seeding 'merchants'...");
        const merchantBatch = db.batch();
        for (const merchant of SEED_DATA.merchants) {
            const ref = db.collection("merchants").doc(merchant.uid);
            merchantBatch.set(ref, merchant);
            console.log(` - Staged merchant: ${merchant.businessName} (${merchant.category})`);
        }
        await merchantBatch.commit();
        console.log("✅ Merchants seeded successfully.");

        // 2. Seed Menu Items
        console.log("\n🍔 Seeding 'menuItems'...");
        const menuBatch = db.batch();
        for (const item of SEED_DATA.menuItems) {
            const ref = db.collection("menuItems").doc(item.id);
            menuBatch.set(ref, item);
            console.log(` - Staged menu item: ${item.name}`);
        }
        await menuBatch.commit();
        console.log("✅ Menu items seeded successfully.");

        // 3. Seed Riders
        console.log("\n🛵 Seeding 'riders'...");
        const riderBatch = db.batch();
        for (const rider of SEED_DATA.riders) {
            const ref = db.collection("riders").doc(rider.uid);
            riderBatch.set(ref, rider);
            console.log(` - Staged rider: ${rider.name} (${rider.vehicleType})`);
        }
        await riderBatch.commit();
        console.log("✅ Riders seeded successfully.");

        // 4. Seed Ads
        console.log("\n✨ Seeding 'ads'...");
        const adsBatch = db.batch();
        for (const ad of SEED_DATA.ads) {
            const ref = db.collection("ads").doc(ad.adId);
            adsBatch.set(ref, ad);
            console.log(` - Staged banner ad: ${ad.title}`);
        }
        await adsBatch.commit();
        console.log("✅ Banners seeded successfully.");

        console.log("\n🎉 CONGRATULATIONS! Firestore Database Seeding Completed successfully!");
        process.exit(0);

    } catch (error) {
        console.error("\n❌ Critical Seeding Error:", error);
        process.exit(1);
    }
}

seedDatabase();
