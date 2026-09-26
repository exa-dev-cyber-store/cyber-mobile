# Cyber Mobile — App Store & Google Play Store Metadata Specification

Official store listing metadata, copy, screenshot storyboards, and compliance documentation for **Cyber Mobile** on **Apple App Store Connect** and **Google Play Console**.

---

## 1. Quick Copy-Paste Reference

### 🍎 Apple App Store Connect

| Field                  | Limit | Cyber Store Content                                                                                                                                                 | Character Count |
| :-----------------------| :-----:| :--------------------------------------------------------------------------------------------------------------------------------------------------------------------| :---------------:|
| **App Name**           | 30    | `Cyber - Tech & Apple Store`                                                                                                                                        | 26 / 30         |
| **Subtitle**           | 30    | `Shop Genuine Tech & Apple Gear`                                                                                                                                    | 30 / 30         |
| **Primary Category**   | —     | `Shopping`                                                                                                                                                          | —               |
| **Secondary Category** | —     | `Lifestyle` / `Productivity`                                                                                                                                        | —               |
| **Age Rating**         | —     | `4+` (No unrestricted web access, no gambling/violence)                                                                                                             | —               |
| **Promotional Text**   | 170   | `Discover authentic Apple devices, MacBooks, iPhones, iPads, and accessories. Enjoy lightning-fast checkout, real-time shipment tracking, and verified warranties.` | 168 / 170       |
| **Keywords**           | 100   | `apple,store,iphone,macbook,ipad,airpods,gadgets,tech,electronics,shopping,cyber,accessories,buy`                                                                   | 95 / 100        |
| **Support URL**        | —     | `https://store.cyber.example.com/support`                                                                                                                           | —               |
| **Marketing URL**      | —     | `https://store.cyber.example.com`                                                                                                                                   | —               |
| **Privacy Policy URL** | —     | `https://store.cyber.example.com/privacy-policy`                                                                                                                    | —               |
| **Copyright**          | —     | `© 2026 Cyber Store Inc. All rights reserved.`                                                                                                                      | —               |

#### Description (App Store — max 4,000 chars)
```text
Welcome to Cyber, your premier destination for authentic Apple devices, premium gadgets, and modern tech accessories.

Whether you are upgrading to the latest iPhone, equipping your workstation with a powerful MacBook Pro, or accessorizing with AirPods and Apple Watch bands, Cyber delivers a seamless and reliable shopping experience from catalog to doorstep.

KEY FEATURES

Explore Genuine Apple and Tech Catalog

Browse iPhones, iPads, MacBooks, Apple Watches, and premium tech essentials.

View detailed product specifications, product galleries, variant options, and customer reviews.

Use instant search and smart category filters to find products quickly.

Fast and Secure Checkout

Multiple payment options with secure verification.

Transparent pricing, itemized discounts, and instant invoice generation.

Manage multiple delivery addresses for your home, office, and other destinations.

Real-Time Order Tracking and Status

Track every stage of your order, including Pending, Processing, Shipped, and Delivered.

Access digital invoices and export them as PDF files.

View your complete order history and archived receipts.

Push Notifications and Exclusive Alerts

Receive notifications about flash sales, product restocks, and promotional codes.

Get live delivery updates directly on your device.

Modern and Intuitive Experience

Enjoy a sleek interface with smooth animations and intuitive navigation.

Sign in quickly and securely with Google or Apple.

Switch between dark and light mode based on your preference.

Download Cyber today and elevate your tech shopping experience.
```

---

### 🤖 Google Play Console

| Field | Limit | Cyber Store Content | Character Count |
| :--- | :---: | :--- | :---: |
| **App Title** | 30 | `Cyber - Tech & Apple Store` | 26 / 30 |
| **Short Description** | 80 | `Shop genuine Apple products, MacBooks, phones & gear with instant tracking.` | 76 / 80 |
| **App Category** | — | `Shopping` | — |
| **Tags** | — | `Shopping`, `Online shopping`, `Consumer electronics`, `Gadgets` | — |
| **Content Rating** | — | `PEGI 3` / `Everyone` | — |
| **Developer Email** | — | `support@cyber.example.com` | — |
| **Privacy Policy URL** | — | `https://store.cyber.example.com/privacy-policy` | — |

#### Full Description (Google Play — max 4,000 chars)
```text
Cyber is your trusted shopping app for genuine Apple products, high-performance laptops, smartphones, and curated tech accessories. Experience effortless browsing, secure checkout, and real-time package delivery tracking right at your fingertips.

🌟 Why Shop on Cyber?

🛍️ 100% Genuine Tech & Apple Devices
• Discover official iPhones, iPads, MacBooks, Apple Watch, AirPods, chargers, cases, and workstation accessories.
• Comprehensive technical specifications, variant configurations (storage, color), and verified buyer ratings.
• Powerful search with filters for brand, category, and price range.

💳 Smooth & Safe Payments
• Flexible payment methods supported by industry-standard secure payment processing.
• Clear price breakdown with instant order confirmation.
• Manage multiple delivery addresses with precision.

🚚 Live Order Tracking & Invoices
• Monitor your package journey from warehouse fulfillment to final delivery.
• Download and print digital PDF invoices directly from the app.
• Complete order history available 24/7.

⚡ Instant Alerts & Offers
• Real-time push notifications for order progress, exclusive promotions, and price drops.
• Quick and secure 1-tap Google Sign-In.

Upgrade your devices with confidence. Download Cyber today!
```

---

## 2. Screenshot Storyboard & Copy Specifications

Use these 6 high-converting screen designs for both **iOS (6.9" & 6.7" Super Retina XDR)** and **Android (1080x2400 / 9:16 FHD+)**.

| Slide # | Target Screen | Marketing Headline (Top) | Supporting Subtitle (Bottom) | UI Focus Area |
| :---: | :--- | :--- | :--- | :--- |
| **1** | `HomeView` | **Premium Tech & Apple Gear** | *Discover authentic devices with exclusive store offers* | Featured banner, Apple category pills, product grid |
| **2** | `DetailProductView` | **Detailed Specs & Variants** | *Choose colors, storage capacities, and view verified reviews* | Image gallery carousel, variant chips, price & Add to Cart button |
| **3** | `CartView` & `CheckoutView` | **Fast & Secure Checkout** | *Flexible payment gateways with transparent breakdown* | Cart items list, address card, payment method selector |
| **4** | `OrderHistoryView` | **Real-Time Order Tracking** | *Track fulfillment from warehouse dispatch to doorstep delivery* | Order timeline stepper (Pending ➔ Shipped ➔ Delivered) |
| **5** | `InvoiceView` | **Instant Digital Invoices** | *View, download, and print official PDF tax invoices anytime* | Receipt preview with barcode, itemized table, and print button |
| **6** | `NotificationsView` & `Profile` | **Stay Informed & In Control** | *Instant order status alerts and custom profile preferences* | Notification list items with status badges and avatar setup |

### 📐 Graphic Dimensions & Requirements

#### Apple App Store:
- **iPhone 6.9" Display (iPhone 16 Pro Max)**: `1320 x 2868 pixels` (or `1290 x 2796 pixels` for 6.7")
- **iPhone 6.5" Display (iPhone 11 Pro Max / Plus)**: `1242 x 2688 pixels`
- **iPad Pro 13" (6th Gen / M4)**: `2064 x 2752 pixels` (Portrait)

#### Google Play Store:
- **App Icon**: `512 x 512 pixels` (32-bit PNG, max 1024KB, no transparency)
- **Feature Graphic**: `1024 x 500 pixels` (PNG or JPEG, no transparency, key visual centered)
- **Phone Screenshots**: Minimum 4 screenshots, `1080 x 2400 pixels` (9:16 aspect ratio)
- **7-inch & 10-inch Tablet Screenshots**: `1200 x 1920 pixels` / `1600 x 2560 pixels`

---

## 3. Release Notes / "What's New" (v1.0.0 / v1.0.2)

### iOS Release Notes (`release_notes.txt`):
```text
Welcome to the official launch of Cyber!
• Explore our curated catalog of authentic Apple devices and premium tech gadgets.
• Seamless 1-tap Apple and Google Sign-In.
• Fast, secure checkout with real-time order tracking.
• Instant digital PDF invoices and push notification updates.
• Performance improvements and bug fixes.
```

### Google Play What's New (`changelogs/default.txt`):
```text
Welcome to Cyber!
• Browse authentic Apple products and tech accessories.
• Fast and secure checkout with multiple payment methods.
• Live package tracking and order status notifications.
• Digital invoice generation and PDF printing.
• Bug fixes and UI performance optimizations.
```

---

## 4. App Store Connect & Google Play Submission Checklist

### 🛡️ Privacy & Data Safety Declarations
- **Contact Info** (Name, Email, Phone Number, Shipping Address): Collected for account creation, order delivery, and customer service.
- **Financial Info**: Payment card/transaction data is processed directly via PCI-DSS compliant payment gateway (Midtrans); card numbers are **not** stored on Cyber servers.
- **Photos / Camera**: `NSCameraUsageDescription` and `NSPhotoLibraryUsageDescription` are strictly used for user profile avatar selection.
- **User Identifiers**: User ID and Device Push Token (Firebase Cloud Messaging) collected for push notifications and account authentication.
- **App Diagnostics**: Crash logs and telemetry collected via Loki for performance monitoring.

### 🧪 App Review Information (Reviewer Notes & Sandbox Guide)

#### 1. Demo / Reviewer Test Account
- **Sign-in Method**: Email & Password or Native 1-Tap Sign in with Apple / Google
- **Demo Email**: `reviewer@cyber.example.com` (or your configured test account)
- **Demo Password**: `CyberReview2026!`
- **Account Type**: Full standard customer account with pre-filled sample address and order history

#### 2. Sandbox Payment Notice (Midtrans Payment Gateway)
> **IMPORTANT NOTE FOR REVIEWERS**:
> All payment transactions in this build are processed through the **Midtrans Sandbox Gateway**. **No real currency is charged.**
> Reviewers can complete the entire checkout flow and test live order status transitions using the official Midtrans Sandbox Simulator.

#### 3. Midtrans Simulator Instructions & Test Credentials
- **Official Midtrans Simulator Portal**: `https://simulator.sandbox.midtrans.com/`

##### A. Virtual Account (VA) Testing:
1. At checkout, select **Bank Transfer / Virtual Account** (e.g., BCA, Mandiri, BNI, BRI, or Permata).
2. Copy the generated **Virtual Account Number** shown on the payment screen.
3. Open the bank's simulator:
   - **BCA VA Simulator**: `https://simulator.sandbox.midtrans.com/bca/va/index`
   - **BNI VA Simulator**: `https://simulator.sandbox.midtrans.com/bni/va/index`
   - **BRI VA Simulator**: `https://simulator.sandbox.midtrans.com/bri/va/index`
   - **Mandiri Bill Simulator**: `https://simulator.sandbox.midtrans.com/mandiri/bill/index`
   - **Permata VA Simulator**: `https://simulator.sandbox.midtrans.com/permata/va/index`
4. Paste the Virtual Account Number and click **Inquire / Pay**.
5. Return to the app — the order will immediately transition to **Processing / Paid**.

##### B. Credit / Debit Card Sandbox Testing:
- **Card Number**: `4811 1111 1111 1114`
- **Expiry Date**: `12/28` (any future MM/YY)
- **CVV**: `123`
- **3D Secure OTP**: `112233` (when prompted)

##### C. QRIS Sandbox Testing:
1. Select **QRIS** at checkout.
2. Open the **QRIS Simulator**: `https://simulator.sandbox.midtrans.com/qris/index`
3. Enter the transaction QR string or upload the QR code screenshot to simulate instant payment.

#### 4. Step-by-Step App Review Flow
1. **Sign In**: Log in using the test account above or tap **Sign in with Apple**.
2. **Browse**: Explore the Apple catalog (iPhone, Mac, iPad, Watch, AirPods).
3. **Product Details**: Select any product, choose variant options (color, storage), and tap **Add to Cart**.
4. **Checkout**: Proceed from Cart to Checkout. Select or add a delivery address.
5. **Simulate Payment**: Choose any payment method (Virtual Account, QRIS, or Credit Card) and complete the transaction using the simulator links above.
6. **Order Tracking & Invoices**: Navigate to **Orders** to see live order tracking (Pending ➔ Processing ➔ Shipped ➔ Delivered) and view/download the official PDF Tax Invoice.
7. **Profile & Account Management**: Open **Profile** to view linked accounts (Apple / Google), update avatar, and manage addresses.
