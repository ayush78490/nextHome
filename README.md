# Next Home 🏠

> **A modern, full-stack rental homes platform** built with Flutter, Node.js, Oracle Database, and deployed on Oracle Cloud Infrastructure.

---

## 📋 Table of Contents

- [Architecture Overview](#architecture-overview)
- [Tech Stack](#tech-stack)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Project Structure](#project-structure)
- [Development](#development)
- [Testing](#testing)
- [Deployment](#deployment)
- [API Reference](#api-reference)
- [Environment Variables](#environment-variables)

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────────┐
│                        CLIENT LAYER                              │
│   Flutter App (Android + iOS)                                   │
│   • Riverpod state management   • Dio HTTP client               │
│   • GoRouter navigation         • Hive local storage            │
│   • Socket.IO (chat/notif)      • Firebase Auth                 │
└──────────────────────────────────────────────────────────────────┘
                              │ HTTPS / WSS
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                        API LAYER (Node.js + Express)             │
│   • REST API (port 3000)        • Socket.IO (port 3001)         │
│   • Firebase token verification • JWT sessions                  │
│   • Razorpay + Stripe payments  • FCM push notifications        │
│   Feature-first: auth / properties / bookings /                 │
│                  payments / chat / notifications                 │
└──────────────────────────────────────────────────────────────────┘
                              │
             ┌────────────────┴────────────────┐
             ▼                                 ▼
┌────────────────────┐              ┌────────────────────┐
│   Oracle XE 21c    │              │   Redis 7          │
│   (port 1521)      │              │   (port 6379)      │
│   Primary DB       │              │   Cache + Pub/Sub  │
└────────────────────┘              └────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                Oracle Cloud Infrastructure (OCI)                 │
│   VM.Standard.E4.Flex  │  Object Storage  │  VCN + Subnet       │
└──────────────────────────────────────────────────────────────────┘
```

---

## Tech Stack

| Layer | Technology |
|---|---|
| Mobile | Flutter 3.x + Dart 3.x |
| State Management | Riverpod 2.x |
| Navigation | GoRouter |
| HTTP Client | Dio + Retrofit |
| Authentication | Firebase Auth |
| Push Notifications | Firebase Cloud Messaging |
| Real-time | Socket.IO |
| Payments | Razorpay + Stripe |
| Maps | Google Maps Flutter |
| Local Storage | Hive + Flutter Secure Storage |
| Backend | Node.js 22 + Express 4 |
| Database | Oracle XE 21c (Docker) |
| Cache | Redis 7 (Docker) |
| Infrastructure | OCI + Terraform |
| Containers | Docker + Docker Compose |

---

## Prerequisites

### Required
| Tool | Version | Install |
|---|---|---|
| Node.js | ≥ 22 | https://nodejs.org |
| Git | ≥ 2.x | https://git-scm.com |
| Docker Desktop | Latest | https://docker.com/products/docker-desktop |
| Java JDK | 17+ | `winget install Microsoft.OpenJDK.17` |

### Installed by Setup Scripts
| Tool | Script |
|---|---|
| Flutter SDK | `scripts\setup\install_flutter.ps1` |
| Android SDK | `scripts\setup\install_android_sdk.ps1` |

---

## Quick Start

### 1. Clone & configure environment

```powershell
git clone https://github.com/your-org/next-home.git
cd next-home
cp .env.example .env
cp backend/.env.example backend/.env
# Edit .env files with your credentials
```

### 2. Install Flutter & Android SDK

```powershell
# Run as Administrator (first time only)
powershell -ExecutionPolicy Bypass -File scripts\setup\install_flutter.ps1
powershell -ExecutionPolicy Bypass -File scripts\setup\install_android_sdk.ps1

# Verify everything is ready
powershell -ExecutionPolicy Bypass -File scripts\setup\check_prerequisites.ps1
```

### 3. Start all dev services

```powershell
powershell -ExecutionPolicy Bypass -File scripts\dev.ps1
```

This starts:
- Oracle XE + Redis (Docker)
- Node.js backend with hot-reload (port 3000)
- Validates Flutter packages

### 4. Run the Flutter app

```powershell
cd mobile
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:3000/api/v1
```

---

## Project Structure

```
next-home/
├── mobile/                    # Flutter app
│   └── lib/
│       ├── core/              # Shared: network, theme, router, constants
│       └── features/          # Feature-first Clean Architecture
│           ├── auth/          # domain/ data/ presentation/
│           ├── home/
│           ├── property/
│           ├── booking/
│           ├── payment/
│           ├── chat/
│           ├── profile/
│           └── notifications/
│
├── backend/                   # Node.js + Express API
│   └── src/
│       ├── config/            # DB, Redis, Firebase, Logger
│       ├── middleware/        # Auth, Error, Rate Limit
│       ├── features/          # Controller → Service → Repository
│       │   ├── auth/
│       │   ├── properties/
│       │   ├── bookings/
│       │   ├── payments/
│       │   ├── chat/
│       │   └── notifications/
│       └── socket/            # Socket.IO handler
│
├── docker/                    # Docker Compose configs
│   ├── docker-compose.yml     # Dev: Oracle + Redis + Backend
│   ├── docker-compose.prod.yml
│   └── oracle/init/01_schema.sql
│
├── infrastructure/            # OCI deployment
│   └── terraform/             # VCN, Compute, Storage
│
├── scripts/                   # PowerShell dev tools
│   ├── setup/                 # install_flutter, install_android_sdk
│   ├── dev.ps1
│   ├── test.ps1
│   ├── format.ps1
│   └── build_prod.ps1
│
├── .vscode/                   # launch.json, tasks.json, settings.json
├── docs/                      # API specs, architecture docs
├── .gitignore
├── .env.example
└── README.md
```

---

## Development

### VS Code Debugger

Open `d:\next-home` in VS Code, then:

| Config | Action |
|---|---|
| **Flutter (Android Debug)** | F5 → runs on connected device/emulator |
| **Node.js Backend (Launch)** | F5 → starts backend with breakpoints |
| **Full Stack (Flutter + Node.js)** | F5 → launches both simultaneously |

### Available Tasks (Ctrl+Shift+P → "Tasks: Run Task")

| Task | Description |
|---|---|
| Dev: Start All | Docker + Backend + Flutter pub get |
| Docker: Start Dev Services | Oracle + Redis only |
| Flutter: Build Runner (watch) | Auto-regenerates Freezed/JSON files |
| CI: Run All Tests | Backend Jest + Flutter tests |

### Code Generation (Freezed + json_serializable)

```powershell
cd mobile
dart run build_runner build --delete-conflicting-outputs
```

---

## Testing

```powershell
# Run all tests
powershell -ExecutionPolicy Bypass -File scripts\test.ps1

# With coverage reports
powershell -ExecutionPolicy Bypass -File scripts\test.ps1 -Coverage

# Backend only
powershell -ExecutionPolicy Bypass -File scripts\test.ps1 -BackendOnly

# Flutter only
powershell -ExecutionPolicy Bypass -File scripts\test.ps1 -FlutterOnly
```

---

## Deployment

### Docker (OCI VM)

```bash
# On the OCI VM
git clone https://github.com/your-org/next-home.git
cp .env.prod .env
docker compose -f docker/docker-compose.prod.yml up -d
```

### Terraform (Infrastructure)

```powershell
cd infrastructure\terraform
cp terraform.tfvars.example terraform.tfvars
# Edit terraform.tfvars with your OCI credentials

terraform init
terraform plan
terraform apply
```

### Production Build

```powershell
# Build APK + Docker image
powershell -ExecutionPolicy Bypass -File scripts\build_prod.ps1 `
    -Version "1.0.0" `
    -ApiUrl "https://api.nexthome.app/api/v1" `
    -Registry "container-registry.oracle.com/nexthome"
```

---

## API Reference

Base URL: `http://localhost:3000/api/v1`

| Endpoint | Method | Auth | Description |
|---|---|---|---|
| `/auth/login` | POST | No | Firebase token exchange |
| `/auth/me` | GET | Yes | Get current user |
| `/auth/me` | PATCH | Yes | Update profile |
| `/properties` | GET | No | List properties (with filters) |
| `/properties/:id` | GET | No | Property detail |
| `/properties` | POST | Landlord | Create property |
| `/bookings` | GET | Yes | My bookings |
| `/bookings` | POST | Tenant | Create booking |
| `/payments/order` | POST | Yes | Create payment order |
| `/payments/verify` | POST | Yes | Verify payment |
| `/chat/rooms` | GET | Yes | My chat rooms |
| `/notifications` | GET | Yes | My notifications |
| `/health` | GET | No | Health check |

Full OpenAPI spec: `docs/api/openapi.yaml`

---

## Environment Variables

See [`.env.example`](.env.example) and [`backend/.env.example`](backend/.env.example) for all required variables.

| Variable | Required | Description |
|---|---|---|
| `ORACLE_APP_PASSWORD` | Yes | Oracle DB app user password |
| `REDIS_PASSWORD` | Yes | Redis auth password |
| `JWT_SECRET` | Yes | ≥ 32 chars, random |
| `FIREBASE_PROJECT_ID` | Yes | Firebase project ID |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Yes (prod) | Firebase admin SDK JSON |
| `GOOGLE_MAPS_API_KEY` | Yes | Server-side Maps API key |
| `RAZORPAY_KEY_ID` / `_SECRET` | Yes | Razorpay credentials |
| `STRIPE_SECRET_KEY` | Yes | Stripe secret key |

---

## Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/your-feature`
3. Format code: `powershell scripts\format.ps1`
4. Run tests: `powershell scripts\test.ps1`
5. Submit a pull request

---

## License

MIT © Next Home
