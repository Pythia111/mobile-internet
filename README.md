# Mobile Internet

A full-stack mobile internet application featuring web frontend, backend API, and HarmonyOS native client.

## Project Overview

This project demonstrates a complete mobile internet solution with three main components:

1. **Web Frontend** (`web-frontend/`) - Vue.js 3 application with TypeScript
2. **Backend API** (`backend/`) - Spring Boot REST API with Java 17
3. **HarmonyOS Client** (`harmony-client/`) - Native HarmonyOS application

## Architecture

```
┌─────────────────┐         ┌─────────────────┐
│  Web Frontend   │         │ HarmonyOS Client│
│    (Vue.js)     │         │    (ArkTS)      │
└────────┬────────┘         └────────┬────────┘
         │                           │
         │       HTTP/REST API       │
         │                           │
         └───────────┬───────────────┘
                     │
              ┌──────▼──────┐
              │   Backend   │
              │ (Spring Boot)│
              └─────────────┘
```

## Technologies

### Web Frontend
- **Framework**: Vue.js 3
- **Language**: TypeScript
- **Build Tool**: Vite
- **Router**: Vue Router
- **State Management**: Pinia
- **Styling**: CSS3
- **Testing**: Vitest

### Backend
- **Framework**: Spring Boot 3.2.0
- **Language**: Java 17
- **Build Tool**: Maven
- **Database**: H2 (in-memory for development)
- **ORM**: Spring Data JPA
- **API Style**: RESTful

### HarmonyOS Client
- **SDK**: HarmonyOS SDK 10
- **Language**: ArkTS (TypeScript-based)
- **UI Framework**: ArkUI (Declarative)
- **IDE**: DevEco Studio

## Quick Start

### Prerequisites

- **For Web Frontend**: Node.js 18+ and npm
- **For Backend**: Java 17+ and Maven
- **For HarmonyOS**: DevEco Studio and HarmonyOS SDK

### Running the Complete Stack

#### 1. Start the Backend

```bash
cd backend
mvn clean install
mvn spring-boot:run
```

The backend will start at `http://localhost:8080`

Available endpoints:
- `GET /api/hello` - Test endpoint
- `GET /api/health` - Health check
- `GET /h2-console` - Database console

#### 2. Start the Web Frontend

```bash
cd web-frontend
npm install
npm run dev
```

The frontend will start at `http://localhost:5173`

#### 3. Run HarmonyOS Client

1. Open `harmony-client/` in DevEco Studio
2. Configure HarmonyOS SDK
3. Connect a device or start an emulator
4. Click "Run" to build and deploy

## Project Structure

```
mobile-internet/
├── web-frontend/          # Vue.js web application
│   ├── src/
│   │   ├── components/    # Vue components
│   │   ├── views/         # Page views
│   │   ├── router/        # Vue Router configuration
│   │   ├── stores/        # Pinia stores
│   │   ├── services/      # API services
│   │   └── main.ts        # Application entry
│   ├── public/            # Static assets
│   └── package.json       # Dependencies
│
├── backend/               # Spring Boot backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/      # Java source code
│   │   │   └── resources/ # Configuration files
│   │   └── test/          # Test files
│   └── pom.xml            # Maven configuration
│
└── harmony-client/        # HarmonyOS application
    ├── entry/
    │   └── src/main/
    │       ├── ets/       # ArkTS source code
    │       └── resources/ # App resources
    └── app.json5          # App configuration
```

## Development

### Web Frontend Development

```bash
cd web-frontend

# Install dependencies
npm install

# Run development server
npm run dev

# Build for production
npm run build

# Run tests
npm run test

# Lint code
npm run lint

# Format code
npm run format
```

### Backend Development

```bash
cd backend

# Build project
mvn clean install

# Run application
mvn spring-boot:run

# Run tests
mvn test

# Package as JAR
mvn package
```

### HarmonyOS Development

Development requires DevEco Studio. See `harmony-client/README.md` for detailed instructions.

## API Documentation

### Backend Endpoints

#### Health Check
```
GET /api/health
Response: { "status": "UP", "service": "Mobile Internet Backend" }
```

#### Hello
```
GET /api/hello
Response: { "message": "Hello from Mobile Internet Backend!", "status": "success" }
```

## Configuration

### Web Frontend

Environment variables are configured in `.env` files:
- `.env` - Default configuration
- `.env.development` - Development configuration

Key variables:
- `VITE_API_BASE_URL` - Backend API URL (default: `http://localhost:8080/api`)

### Backend

Configuration is in `application.properties`:
- Server port: `8080`
- Database: H2 in-memory
- CORS: Enabled for local development

### HarmonyOS

Configuration files:
- `app.json5` - Application metadata
- `module.json5` - Module configuration
- Build configuration in DevEco Studio

## Testing

### Web Frontend
```bash
cd web-frontend
npm run test
```

### Backend
```bash
cd backend
mvn test
```

### HarmonyOS
Use DevEco Studio's built-in test runner.

## Deployment

### Web Frontend
```bash
cd web-frontend
npm run build
# Deploy the dist/ folder to your web server
```

### Backend
```bash
cd backend
mvn package
# Deploy the JAR file from target/ directory
java -jar target/backend-1.0.0.jar
```

### HarmonyOS
Build release HAP in DevEco Studio and distribute through AppGallery.

## Features

- ✅ Modern web frontend with Vue.js 3
- ✅ RESTful backend API with Spring Boot
- ✅ Native HarmonyOS mobile client
- ✅ Cross-origin resource sharing (CORS) enabled
- ✅ Type-safe development with TypeScript
- ✅ Hot module replacement for fast development
- ✅ Component-based architecture
- ✅ Responsive design
- ✅ API service layer for backend communication

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is provided as-is for educational and development purposes.

## Support

For detailed information about each component, see the README files in their respective directories:
- [Web Frontend README](web-frontend/README.md)
- [Backend README](backend/README.md)
- [HarmonyOS Client README](harmony-client/README.md)

