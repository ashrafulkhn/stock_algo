# Momentum Pulse - Option Trading Bot

An automated option trading system combining TradingView signals with AliceBlue broker integration.

## 📋 Features

✅ **TradingView Pine Script** - Momentum detection + top-N stock auto-selection  
✅ **Webhook Integration** - Real-time alerts → Python backend  
✅ **CE/PE Trading** - Simultaneous call & put option orders  
✅ **Trailing Stop Loss** - Dynamic SL management  
✅ **AliceBlue Integration** - Automated order execution  
✅ **Dry-Run Mode** - Safe testing before live trading  
✅ **Time Window Rules** - Entry 9:40-9:45 AM, Exit 11:15 AM  

## 🚀 Quick Start

### 1. Clone and Setup
```bash
cd c:\Users\dev_1\Documents\GitHub\stock_algo
python -m venv venv
venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Credentials
```bash
cp .env.example .env
# Edit .env and add your AliceBlue API credentials
```

### 3. Start Server
```bash
python -m app.main
# Server runs on http://localhost:8000
```

### 4. Health Check
```bash
curl http://localhost:8000/health
```

## 📡 Webhook Setup (TradingView)

1. Go to **TradingView Chart** → **Strategy** → **Alerts**
2. Create new alert on the strategy
3. Alert message format:
```json
{
  "symbol": "{{exchange}}:{{ticker}}",
  "option_type": "CE",
  "strike": "ATM",
  "qty": 1,
  "sl_percent": 10.0
}
```
4. Webhook URL: `http://your-server:8000/webhook`

## 🔧 API Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/webhook` | Receive TradingView alerts |
| GET | `/health` | Server health check |
| GET | `/active-trades` | List active positions |
| POST | `/exit/{symbol}` | Manual trade exit |

## 📊 Trade Execution Flow

```
TradingView Alert
    ↓
Webhook → FastAPI
    ↓
Validate Payload
    ↓
Calculate SL Level
    ↓
Place Order (AliceBlue)
    ↓
Track Trailing SL
    ↓
Auto-Exit @ 11:15 AM
```

## 🧪 Testing (Dry-Run Mode)

Set `DRY_RUN=true` in `.env`:

```bash
curl -X POST http://localhost:8000/webhook \\
  -H "Content-Type: application/json" \\
  -d '{
    "symbol": "NIFTY50",
    "option_type": "CE",
    "strike": "21000",
    "qty": 1,
    "sl_percent": 10.0
  }'
```

## 📈 Strategy Rules

- **Entry Time**: 9:40 AM - 9:45 AM
- **Exit Time**: 11:15 AM (auto-close all)
- **SL**: 10% below entry
- **Symbols**: Top 10 momentum stocks (manual selection)
- **Options**: Both CE + PE simultaneous buy

## 🔐 AliceBlue Credentials

Get your credentials from [AliceBlue Dashboard](https://alice.aliceblueonline.com):

1. Login to your account
2. Navigate to **API Settings**
3. Generate **App ID**, **API Key**, **Access Token**
4. Copy your **User ID**
5. Add to `.env` file

## 📦 Project Structure

```
stock_algo/
├── app/
│   ├── __init__.py
│   ├── main.py                 # FastAPI server
│   ├── aliceblue_manager.py    # Broker integration
│   └── trailing_sl.py          # SL management
├── pine_script_strategy.pine   # TradingView script
├── requirements.txt
├── .env.example
├── .env (create from example)
└── README.md
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| 401 Unauthorized | Check AliceBlue credentials in `.env` |
| Webhook not received | Verify firewall/port 8000 is accessible |
| Orders not executing | Enable `DRY_RUN=false` and check broker status |
| SL not working | Ensure price feed is active |

## 📚 Logs

All activities logged to console:
```bash
python -m app.main 2>&1 | tee trading.log
```

## 🚢 Deployment Options

### Cloud Run (Google - Recommended)
```bash
gcloud run deploy momentum-pulse \\
  --source . \\
  --platform managed \\
  --region us-central1 \\
  --allow-unauthenticated
```

### Railway.app
Push to GitHub → Connect repo → Auto-deploy

### Render.com
Similar to Railway - simple dashboard deployment

## ⚠️ Risk Disclaimer

- Paper trade first before live
- Test SL triggers in dry-run mode
- Monitor positions actively
- AliceBlue account required

## 📞 Support

For issues:
1. Check logs: `trading.log`
2. Verify `.env` configuration
3. Test webhook with curl
4. Review AliceBlue API docs

---

**Built with ❤️ for option traders**

