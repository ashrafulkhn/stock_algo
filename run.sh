#!/bin/bash
set -e

echo "🚀 Starting Momentum Pulse Option Trading Bot..."

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "📦 Creating virtual environment..."
    python -m venv venv
fi

# Activate venv
source venv/Scripts/activate

# Install dependencies
echo "📥 Installing dependencies..."
pip install -q -r requirements.txt

# Check .env file
if [ ! -f ".env" ]; then
    echo "⚠️  .env file not found. Creating from .env.example..."
    cp .env.example .env
    echo "📝 Please edit .env with your AliceBlue credentials"
fi

# Start server
echo "✅ Starting FastAPI server..."
echo "📡 Webhook URL: http://localhost:8000/webhook"
echo "💚 Health check: http://localhost:8000/health"
echo ""

python -m app.main
