import logging
from typing import Dict, Optional
from datetime import datetime

logger = logging.getLogger(__name__)

class TrailingSLManager:
    """Trailing Stop Loss Manager"""
    
    def __init__(self):
        self.trades: Dict = {}
    
    def add_trade(self, symbol: str, entry_price: float, sl_percent: float):
        """Add a new trade for SL tracking"""
        self.trades[symbol] = {
            "entry_price": entry_price,
            "sl_percent": sl_percent,
            "current_sl": entry_price * (1 - sl_percent / 100),
            "highest_price": entry_price,
            "entry_time": datetime.now().isoformat(),
            "status": "active"
        }
        logger.info(f"Trade added: {symbol} | Entry: {entry_price} | SL: {self.trades[symbol]['current_sl']}")
    
    def update_trade(self, symbol: str, current_price: float) -> Optional[Dict]:
        """Update trade with current price and adjust trailing SL"""
        if symbol not in self.trades:
            logger.warning(f"Trade not found: {symbol}")
            return None
        
        trade = self.trades[symbol]
        
        # Update highest price
        if current_price > trade["highest_price"]:
            trade["highest_price"] = current_price
            # Adjust SL upward (trailing logic)
            new_sl = current_price * (1 - trade["sl_percent"] / 100)
            if new_sl > trade["current_sl"]:
                trade["current_sl"] = new_sl
                logger.info(f"Trailing SL updated: {symbol} | New SL: {new_sl:.2f}")
        
        # Check if SL is hit
        if current_price <= trade["current_sl"]:
            trade["status"] = "sl_hit"
            logger.warning(f"STOP LOSS HIT: {symbol} | Price: {current_price} | SL: {trade['current_sl']}")
            return {"action": "close", "symbol": symbol, "reason": "stop_loss"}
        
        return {"action": "hold", "symbol": symbol, "current_sl": trade["current_sl"]}
    
    def remove_trade(self, symbol: str):
        """Remove a closed trade"""
        if symbol in self.trades:
            del self.trades[symbol]
            logger.info(f"Trade removed: {symbol}")
    
    def get_trade_status(self, symbol: str) -> Optional[Dict]:
        """Get status of a specific trade"""
        return self.trades.get(symbol)
    
    def get_all_trades(self) -> Dict:
        """Get all tracked trades"""
        return self.trades
