#!/bin/bash

# Mobile Internet Project - Stop Script
# This script stops the backend and frontend servers

echo "Stopping Mobile Internet servers..."

# Read PIDs
if [ -f .backend.pid ]; then
    BACKEND_PID=$(cat .backend.pid)
    if ps -p $BACKEND_PID > /dev/null 2>&1; then
        echo "Stopping backend server (PID: $BACKEND_PID)..."
        kill $BACKEND_PID
        echo "✅ Backend server stopped"
    else
        echo "Backend server is not running"
    fi
    rm .backend.pid
fi

if [ -f .frontend.pid ]; then
    FRONTEND_PID=$(cat .frontend.pid)
    if ps -p $FRONTEND_PID > /dev/null 2>&1; then
        echo "Stopping frontend server (PID: $FRONTEND_PID)..."
        kill $FRONTEND_PID
        echo "✅ Frontend server stopped"
    else
        echo "Frontend server is not running"
    fi
    rm .frontend.pid
fi

# Clean up any remaining Java processes (backend)
pkill -f "spring-boot:run" > /dev/null 2>&1 || true

# Clean up any remaining Vite processes (frontend)
pkill -f "vite" > /dev/null 2>&1 || true

echo "✅ All servers stopped"
