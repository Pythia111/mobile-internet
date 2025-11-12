#!/bin/bash

# Mobile Internet Project - Quick Start Script
# This script helps you quickly start the backend and frontend servers

set -e  # Exit on error

echo "=================================="
echo "Mobile Internet - Quick Start"
echo "=================================="
echo ""

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Check prerequisites
echo "Checking prerequisites..."

if ! command_exists java; then
    echo "❌ Java is not installed. Please install Java 17 or higher."
    exit 1
fi

if ! command_exists mvn; then
    echo "❌ Maven is not installed. Please install Maven 3.6 or higher."
    exit 1
fi

if ! command_exists node; then
    echo "❌ Node.js is not installed. Please install Node.js 18 or higher."
    exit 1
fi

if ! command_exists npm; then
    echo "❌ npm is not installed. Please install npm."
    exit 1
fi

echo "✅ All prerequisites are installed"
echo ""

# Check Java version
JAVA_VERSION=$(java -version 2>&1 | head -n 1 | awk -F '"' '{print $2}' | awk -F '.' '{print $1}')
if [ "$JAVA_VERSION" -lt 17 ]; then
    echo "⚠️  Warning: Java version is lower than 17. Java 17 or higher is recommended."
fi

# Install frontend dependencies if needed
if [ ! -d "web-frontend/node_modules" ]; then
    echo "Installing frontend dependencies..."
    cd web-frontend
    npm install
    cd ..
    echo "✅ Frontend dependencies installed"
    echo ""
fi

# Build backend
echo "Building backend..."
cd backend
mvn clean install -DskipTests
cd ..
echo "✅ Backend built successfully"
echo ""

# Start backend in background
echo "Starting backend server..."
cd backend
mvn spring-boot:run > backend.log 2>&1 &
BACKEND_PID=$!
cd ..
echo "✅ Backend server starting (PID: $BACKEND_PID)"
echo "   Logs: backend/backend.log"
echo "   URL: http://localhost:8080"
echo ""

# Wait for backend to be ready
echo "Waiting for backend to be ready..."
MAX_WAIT=60
WAITED=0
while [ $WAITED -lt $MAX_WAIT ]; do
    if curl -s http://localhost:8080/api/health > /dev/null 2>&1; then
        echo "✅ Backend is ready!"
        break
    fi
    sleep 2
    WAITED=$((WAITED + 2))
    echo -n "."
done
echo ""

if [ $WAITED -ge $MAX_WAIT ]; then
    echo "⚠️  Backend took longer than expected to start"
    echo "   Check backend/backend.log for details"
fi

# Start frontend
echo "Starting frontend server..."
cd web-frontend
npm run dev > frontend.log 2>&1 &
FRONTEND_PID=$!
cd ..
echo "✅ Frontend server starting (PID: $FRONTEND_PID)"
echo "   Logs: web-frontend/frontend.log"
echo "   URL: http://localhost:5173"
echo ""

# Save PIDs for cleanup
echo $BACKEND_PID > .backend.pid
echo $FRONTEND_PID > .frontend.pid

echo "=================================="
echo "🎉 Mobile Internet is running!"
echo "=================================="
echo ""
echo "Backend:  http://localhost:8080"
echo "Frontend: http://localhost:5173"
echo ""
echo "To stop the servers, run: ./stop.sh"
echo "or press Ctrl+C and run: ./cleanup.sh"
echo ""
echo "View logs:"
echo "  Backend:  tail -f backend/backend.log"
echo "  Frontend: tail -f web-frontend/frontend.log"
echo ""
