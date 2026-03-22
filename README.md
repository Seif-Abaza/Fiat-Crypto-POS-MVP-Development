# POS Terminal - Android POS Device MVP

A complete MVP for an Android POS device that connects traditional (fiat) and cryptocurrency payments.

## Project Overview

This project consists of two main components:
1. **Fake Server (FSBP)** - Python Flask backend for managing backend operations
2. **Flutter POS App** - Android application for the POS terminal

## Project Structure

### 1. Fake Server (`/fake_server`)

```
fake_server/
├── main.py              # Flask server with all endpoints
└── requirements.txt     # Python dependencies
```

**Endpoints:**
- `POST /auth/verify` - Verify device PIN
- `POST /logs` - Receive logs from POS device
- `POST /p2p/transaction` - Record P2P transactions
- `GET /prices` - Get simulated exchange rates
- `POST /webhooks/{provider}` - Webhook endpoints for payment providers

### 2. Flutter POS App (`/flutter_pos_app`)

```
flutter_pos_app/
├── lib/
│   ├── core/
│   │   ├── constants/
│   │   │   └── app_constants.dart    # API & App constants
│   │   ├── services/
│   │   │   ├── api_service.dart       # API communication
│   │   │   └── p2p_price_service.dart # P2P price fetching
│   │   ├── theme/
│   │   │   └── app_theme.dart        # App theming
│   │   └── utils/
│   │       └── payment_url_generator.dart  # URL generation for gateways
│   ├── data/
│   │   ├── models/
│   │   │   ├── device_settings.dart   # Device configuration
│   │   │   ├── gateway_config.dart   # Gateway settings
│   │   │   └── wallet_config.dart    # Wallet addresses
│   │   └── repositories/
│   │       └── settings_repository.dart # Local storage
│   ├── presentation/
│   │   ├── screens/
│   │   │   ├── access/
│   │   │   │   └── access_screen.dart    # PIN entry screen
│   │   │   ├── main/
│   │   │   │   └── main_screen.dart      # Main dashboard
│   │   │   ├── card/
│   │   │   │   └── card_module_screen.dart # Card payment module
│   │   │   ├── p2p/
│   │   │   │   └── p2p_screen.dart        # P2P exchange module
│   │   │   └── settings/
│   │   │       └── settings_screen.dart   # Settings management
│   │   └── widgets/
│   │       └── pinpad/
│   │           └── numeric_pinpad.dart    # Numeric keypad widget
│   └── main.dart
└── pubspec.yaml
```

## Features

### Access Screen
- PIN verification via server endpoint
- Secure authentication flow

### Main Interface
- Two large buttons: CARD and P2P
- Device status display
- Quick access to settings

### Card Module
- **Manual Entry**: Enter amount and crypto details manually
- **Emulated NFC/Swipe**: Simulate card tap/swipe
- **WebView Integration**: Opens payment gateway widgets
- **Supported Gateways**: Onramper, Transak, MoonPay, Yellow Card
- Dynamic URL generation with API keys

### P2P Module
- Amount entry with numeric keypad
- Bank selection
- Real-time price search (OKX/Bybit)
- Transaction confirmation with:
  - Live price
  - Commission calculation
  - Final amount display
- Transaction recording via backend

### Settings System
1. **Fiat Gateways**
   - Configure API keys for each gateway
   - Set priority to avoid duplicates
   - Enable/disable gateways

2. **Wallets**
   - BTC, USDT, USDC address configuration
   - Default wallet selection

3. **System Apps**
   - Server URL (VPS: 144.172.100.67)
   - Device ID
   - Business name
   - Theme color customization

## Digital POS Design - Pencil Pinpad

### Layout Overview

```
┌─────────────────────────────────────┐
│           HEADER BAR                │
│  [Business Name]     [Settings]     │
├─────────────────────────────────────┤
│                                     │
│     ┌───────────────────────┐       │
│     │                       │       │
│     │     CARD BUTTON       │       │
│     │    (Blue/Indigo)      │       │
│     │                       │       │
│     └───────────────────────┘       │
│                                     │
│     ┌───────────────────────┐       │
│     │                       │       │
│     │      P2P BUTTON       │       │
│     │   (Teal/Green)       │       │
│     │                       │       │
│     └───────────────────────┘       │
│                                     │
├─────────────────────────────────────┤
│  [Wallets]              [Gateways] │
└─────────────────────────────────────┘
```

### PIN Pad Layout (Standard POS Style)

```
┌──────────────────────────────┐
│         DISPLAY AREA         │
│    ● ● ● ●  (4 dots)        │
│      [Error message]         │
├──────────────────────────────┤
│   [1]    [2]    [3]         │
│                              │
│   [4]    [5]    [6]         │
│                              │
│   [7]    [8]    [9]         │
│                              │
│   [C]    [0]    [OK]        │
└──────────────────────────────┘
```

### Amount Entry Pinpad

```
┌──────────────────────────────┐
│         $ 1,234.56          │
│           (USD)             │
├──────────────────────────────┤
│   [1]    [2]    [3]         │
│                              │
│   [4]    [5]    [6]         │
│                              │
│   [7]    [8]    [9]         │
│                              │
│   [.]    [0]    [⌫]        │
└──────────────────────────────┘
```

## Security Features

- **URL Signing**: Implemented for MoonPay and Transak
- **API Key Management**: Secure storage in settings
- **Wallet Address Validation**: Per-currency validation

## Running the Project

### Start Fake Server

```bash
cd fake_server
pip install -r requirements.txt
python main.py
```

Server runs on `http://0.0.0.0:8000`

### Build Flutter App

```bash
cd flutter_pos_app
flutter pub get
flutter build apk
```

## Configuration

### Default Settings
- **PIN**: 1234
- **Device ID**: POS-001
- **Server URL**: http://144.172.100.67:8000

### Supported Cryptocurrencies
- BTC (Bitcoin)
- ETH (Ethereum)
- USDT (Tether)
- USDC (USD Coin)

### Supported Fiat
- USD, EUR, GBP, NGN

## Architecture

```
┌─────────────────────────────────────────────────────┐
│                  Flutter App                        │
├─────────────────────────────────────────────────────┤
│  UI Layer          │  Business Logic               │
│  - Screens         │  - Services                    │
│  - Widgets         │  - URL Generation              │
│                    │  - Price Calculation           │
├─────────────────────────────────────────────────────┤
│  Data Layer                                        │
│  - Models         │  Repositories                   │
│  - Settings       │  - Local Storage               │
└─────────────────────────────────────────────────────┘
                           │
                           │ HTTP
                           ▼
┌─────────────────────────────────────────────────────┐
│              Fake Server (FSBP)                     │
├─────────────────────────────────────────────────────┤
│  - /auth/verify    - PIN verification               │
│  - /logs          - Log collection                 │
│  - /p2p/transaction - Transaction recording        │
│  - /prices        - Exchange rates                 │
│  - /webhooks/*    - Provider notifications        │
└─────────────────────────────────────────────────────┘
```

## License

MIT License
