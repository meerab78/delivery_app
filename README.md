# Delivery App

A single-store delivery app built with **Flutter** and **Supabase**.
One app, one backend. Customers and the store owner install the **same app**, and after login the app shows the customer side or the admin side depending on the user's role.

It suits one business that delivers its own products with its own staff: a restaurant or cloud kitchen, grocery store, pharmacy, bakery, water-can supplier, laundry, and so on.
It is **not** a multi-vendor marketplace.

> Status: Phase 1 (MVP) is almost complete. See [Project status](#project-status).

<!-- Add screenshots here, for example:
![Home](docs/screenshots/home.png) ![Admin orders](docs/screenshots/admin-orders.png)
-->

## Features

### Customer
- Login with **phone number + OTP** (the first login creates the account automatically)
- Home with store open/closed banner, category chips and a 2-column product grid
- Product detail, cart (saved on the phone), saved addresses with a default address
- Checkout with **Cash on Delivery**
- **Live order tracking** (Placed, Accepted, Preparing, On the way, Delivered)
- Order history and cancelling an order while it is still "placed"
- Push notifications for every status change

### Admin (store owner)
- Dashboard: today's orders, today's revenue, pending count, **open/close store** switch
- **Live orders board**: a new order appears by itself, with a push notification
- Order detail: items, customer name and phone (tap to call), address, notes
- Status buttons: Accept / Reject, Preparing, Out for delivery, Delivered (cash collected)
- Products and categories: add, edit, hide, in-stock switch, **image upload**
- Store settings: delivery fee, minimum order, opening hours
- Customers list (orders count and total spent)

### Security (the most important part)
- **Row Level Security (RLS) on every table.** Hiding admin screens is not security, so the database enforces everything.
- Orders cannot be inserted from the app. They are created only by the `place_order()` database function, which reads the **real prices** from the database and calculates the total itself. A total sent from the phone is never trusted.
- Status changes go through `update_order_status()`, which checks who may do which change.
- A customer cannot make themselves admin (a database trigger blocks role changes from the app).
- A 22-test security script was run against the database (customer vs customer vs admin vs visitor): all tests passed.

## Tech stack

| Part | Technology |
|---|---|
| App | Flutter (Android), Riverpod for state management |
| Backend | Supabase: Auth (phone OTP), Postgres, RLS, Realtime, Storage, RPC functions |
| Server code | Supabase Edge Function (Deno / TypeScript) + `pg_net` |
| Push notifications | Firebase Cloud Messaging (HTTP v1) |
| Main packages | `flutter_riverpod`, `supabase_flutter`, `shared_preferences`, `curved_navigation_bar`, `url_launcher`, `image_picker`, `firebase_core`, `firebase_messaging` |

## How it works

```
Flutter app  ──►  Supabase (Auth, Postgres + RLS, Realtime, Storage)
                       │
                       ├─ place_order()          creates orders safely
                       ├─ update_order_status()  checks who may change what
                       │
                       └─ trigger on orders ──► pg_net ──► Edge Function "send-push" ──► FCM ──► phone
```

### Order lifecycle

```
placed ──► accepted ──► preparing ──► out_for_delivery ──► delivered
   ├──► rejected    (admin only)
   └──► cancelled   (customer only, only while still "placed")
```

### Push notifications

| Event | Who gets the notification |
|---|---|
| New order | Admin |
| Customer cancels an order | Admin |
| Admin changes the status | That customer |
When the app is open a banner is shown. Tapping a notification opens the right order screen, even if the app was closed.
## Database

| Table | Purpose |
|---|---|
| `profiles` | One per user: name, phone, role (`customer` or `admin`) |
| `addresses` | Saved delivery addresses |
| `categories`, `products` | The menu (`is_active` hides an item, `in_stock` marks it sold out) |
| `orders`, `order_items` | Orders. Name, price and address are **copied** into the order, so later edits never change old orders |
| `store_settings` | A single row: open/closed, delivery fee, minimum order, hours |
| `device_tokens` | Push notification tokens |
Admins are never created from inside the app. A user signs up normally and the owner changes the role in the SQL Editor.
## Project structure
The app uses a **feature-first** structure. Every feature has the same shape: `view` (screen), `controller` (Riverpod providers and logic), `repository` (the only place that talks to Supabase), `model/` and `widget/`.
```
lib/
├── main.dart
├── app.dart
├── core/
│   ├── constants/     supabase config, app constants
│   ├── db/            Supabase client provider
│   ├── sessions/      login session providers
│   ├── navigation/    global navigator and messenger keys
│   ├── shared/        loading, error, qty stepper, product image...
│   ├── theme/         colors and theme
│   └── utils/         snackbar, errors, phone, money, date helpers
└── features/
    ├── auth/          phone login, OTP, addresses
    ├── profile/       name setup and profile screen
    ├── base/          decides which screen to show, customer shell
    ├── home/          menu, product detail
    ├── cart/          cart and checkout
    ├── order/         order history, placing orders
    ├── track_order/   live tracking
    ├── notifications/ FCM token and notification handling
    └── admin/         dashboard, orders, products, categories, settings, customers

supabase/
├── sql/               database setup, in order (see below)
└── functions/
    └── send-push/     Edge Function that sends the push notifications
```
## Getting started
### 1. Supabase
1. Create a new Supabase project.
2. Open the **SQL Editor** and run the files in `supabase/sql/` **in this order**:
   | File | What it does |
   |---|---|
   | `01_schema.sql` | Tables, profile trigger, `is_admin()`, RLS policies, realtime |
   | `02_functions.sql` | `place_order()`, `update_order_status()`, image bucket and policies |
   | `04_device_tokens.sql` | `register_device_token()` |
   | `05_push_trigger.sql` | Trigger that calls the Edge Function (**replace the placeholders first**) |
   | `07_default_address.sql` | `set_default_address()` |
   `03_test_data.sql` is optional sample data for testing only.
3. **Authentication, Providers, Phone**: enable it.
   - For development, add test phone numbers with a fixed OTP.
   - For real SMS, configure an SMS provider (for example Twilio) and clear the test numbers.
4. Make yourself the admin. Log in once from the app, then run:
   ```sql
   update public.profiles set role = 'admin', name = 'Store Owner'
   where id = (select id from auth.users where phone like '%YOUR_NUMBER');
   ```
   Log out and log in again.
### 2. Firebase and push notifications
1. Create a Firebase project.
2. In the Flutter project run `flutterfire configure` (Android). This creates `lib/firebase_options.dart`.
3. In Firebase, go to Project settings, Service accounts, and generate a private key.
4. In Supabase, go to **Edge Functions, Secrets** and add:
   - `FIREBASE_PROJECT_ID`
   - `FIREBASE_CLIENT_EMAIL`
   - `FIREBASE_PRIVATE_KEY`
   - `PUSH_WEBHOOK_SECRET` (any long random string)
5. Deploy the function in `supabase/functions/send-push/` with **JWT verification turned off**. It is protected by the `x-webhook-secret` header instead.
6. Put the same secret and your project reference in `05_push_trigger.sql` and run it.
> Never commit the Firebase service account JSON or any `service_role` key.
### 3. Flutter app
```bash
git clone <your-repo-url>
cd delivery_app
flutter pub get
```
Open `lib/core/constants/supabase_config.dart` and set your **Project URL** and **anon (public) key**, from Supabase, Project Settings, API.
```bash
flutter run
```
Required Android permissions (already in `AndroidManifest.xml`): `INTERNET`, `POST_NOTIFICATIONS`, and the `tel` query for `url_launcher`.
## Test accounts
During development the project uses Supabase **test phone numbers** (fixed OTP, no SMS is sent).
**Remove them before going live.**

## Project status
- [x] Database, RLS, order functions, storage, realtime
- [x] Phone OTP login, profile, addresses
- [x] Customer app: menu, cart, checkout, live tracking, order history
- [x] Admin app: dashboard, live orders, status updates, products and images, categories, store settings
- [x] Push notifications (foreground, background and closed app)
- [x] Security tests (22 of 22 passed)
- [x] Polish: default address, high-priority notification channel, customers list
- [ ] Map pin for addresses and a delivery radius check
- [ ] Launch preparation: real SMS provider, remove test data, release build

## License

Add your license here.
