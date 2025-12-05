from fastapi import FastAPI, Request, HTTPException
from pydantic import BaseModel
from datetime import datetime
import os
import json
import logging
from dotenv import load_dotenv
from .aliceblue_manager import AliceBlueManager
from .trailing_sl import TrailingSLManager

load_dotenv()

# Configure logging for Windows
logging.basicConfig(
    level=logging.INFO,
    format='[%(asctime)s] %(levelname)s - %(message)s',
    datefmt='%Y-%m-%d %H:%M:%S'
)

app = FastAPI(title="Momentum Pulse - Option Trading")
logger = logging.getLogger(__name__)

# Initialize Managers
alice_manager = AliceBlueManager(
    app_id=os.getenv("ALICE_APP_ID"),
    api_key=os.getenv("ALICE_API_KEY"),
    access_token=os.getenv("ALICE_ACCESS_TOKEN"),
    user_id=os.getenv("ALICE_USER_ID")
)
sl_manager = TrailingSLManager()

# Request Model
class TradingViewAlert(BaseModel):
    symbol: str
    option_type: str  # CE or PE
    strike: str
    qty: int
    sl_percent: float
    side: str = "BUY"

# Track Active Trades
active_trades = {}

@app.post("/webhook")
async def receive_webhook(request: Request):
    """Receive alerts from TradingView"""
    try:
        payload = await request.json()
        logger.info(f"Webhook received: {payload}")
        
        # Validate payload
        required_fields = ["symbol", "option_type", "strike", "qty", "sl_percent"]
        if not all(field in payload for field in required_fields):
            raise HTTPException(status_code=400, detail="Missing required fields")
        
        # Create alert object
        alert = TradingViewAlert(**payload)
        
        # Time window validation
        now = datetime.now()
        if not (9 <= now.hour <= 15):  # Market hours check
            logger.warning(f"Outside trading hours: {now}")
            return {"status": "rejected", "reason": "Outside trading hours"}
        
        # Execute trade
        order_response = await execute_trade(alert)
        
        return {"status": "success", "order": order_response}
    
    except Exception as e:
        logger.error(f"Webhook error: {str(e)}")
        return {"status": "error", "message": str(e)}

async def execute_trade(alert: TradingViewAlert):
    """Execute trade via AliceBlue API"""
    try:
        # Calculate SL level
        sl_level = calculate_sl(alert.strike, alert.sl_percent)
        
        # Prepare order
        order_data = {
            "symbol": alert.symbol,
            "option_type": alert.option_type,
            "strike": alert.strike,
            "qty": alert.qty,
            "side": alert.side,
            "sl_level": sl_level,
            "timestamp": datetime.now().isoformat()
        }
        
        # Check dry-run mode
        dry_run = os.getenv("DRY_RUN", "false").lower() == "true"
        
        if dry_run:
            logger.info(f"DRY RUN: {json.dumps(order_data, indent=2)}")
            active_trades[alert.symbol] = order_data
            return order_data
        
        # Place actual order
        response = alice_manager.place_order(order_data)
        active_trades[alert.symbol] = order_data
        
        # Initialize trailing SL
        sl_manager.add_trade(alert.symbol, sl_level, alert.sl_percent)
        
        logger.info(f"Order executed: {response}")
        return response
    
    except Exception as e:
        logger.error(f"Trade execution error: {str(e)}")
        raise

def calculate_sl(strike_price: str, sl_percent: float) -> float:
    """Calculate SL level based on percentage"""
    try:
        strike = float(strike_price)
        sl_level = strike * (1 - sl_percent / 100)
        return round(sl_level, 2)
    except:
        return float(strike_price) * 0.9

@app.get("/health")
async def health_check():
    """Health check endpoint"""
    return {"status": "healthy", "timestamp": datetime.now().isoformat()}

@app.get("/active-trades")
async def get_active_trades():
    """Get all active trades"""
    return {"active_trades": active_trades}

@app.post("/exit/{symbol}")
async def manual_exit(symbol: str):
    """Manual exit for a trade"""
    try:
        if symbol in active_trades:
            alice_manager.close_position(symbol)
            del active_trades[symbol]
            sl_manager.remove_trade(symbol)
            return {"status": "success", "message": f"Exited {symbol}"}
        return {"status": "error", "message": f"No active trade for {symbol}"}
    except Exception as e:
        logger.error(f"Exit error: {str(e)}")
        return {"status": "error", "message": str(e)}

if __name__ == "__main__":
    import uvicorn
    logger.info("🚀 Starting Momentum Pulse Option Trading Bot")
    logger.info("📡 Webhook: http://localhost:8000/webhook")
    logger.info("💚 Health: http://localhost:8000/health")
    uvicorn.run(app, host="0.0.0.0", port=8000)
