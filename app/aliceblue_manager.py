import requests
import logging
from typing import Dict, Optional

logger = logging.getLogger(__name__)

class AliceBlueManager:
    """AliceBlue Broker API Manager"""
    
    BASE_URL = "https://api.aliceblueonline.com"
    
    def __init__(self, app_id: str, api_key: str, access_token: str, user_id: str):
        self.app_id = app_id
        self.api_key = api_key
        self.access_token = access_token
        self.user_id = user_id
        self.session = requests.Session()
        self.session.headers.update(self._get_headers())
    
    def _get_headers(self) -> Dict:
        """Build request headers"""
        return {
            "Authorization": f"Bearer {self.access_token}",
            "Content-Type": "application/json",
            "X-AppID": self.app_id
        }
    
    def place_order(self, order_data: Dict) -> Dict:
        """Place an order for CE/PE option"""
        try:
            payload = {
                "symboltoken": self._get_symbol_token(order_data["symbol"]),
                "tradingsymbol": f"{order_data['symbol']}_{order_data['option_type']}_{order_data['strike']}",
                "transactiontype": order_data["side"].upper(),
                "ordertype": "MARKET",
                "quantity": order_data["qty"],
                "price": 0,
                "stoplosses": order_data.get("sl_level", 0),
                "userid": self.user_id
            }
            
            response = self.session.post(
                f"{self.BASE_URL}/api/orders/regular",
                json=payload,
                timeout=10
            )
            
            response.raise_for_status()
            logger.info(f"Order placed: {response.json()}")
            return response.json()
        
        except Exception as e:
            logger.error(f"Order placement failed: {str(e)}")
            raise
    
    def _get_symbol_token(self, symbol: str) -> str:
        """Fetch symbol token from AliceBlue API"""
        try:
            response = self.session.get(
                f"{self.BASE_URL}/api/master",
                params={"searchsymbol": symbol},
                timeout=10
            )
            response.raise_for_status()
            data = response.json()
            return data[0]["token"] if data else "0"
        except Exception as e:
            logger.error(f"Symbol token fetch failed: {str(e)}")
            return "0"
    
    def close_position(self, symbol: str) -> Dict:
        """Close an open position"""
        try:
            payload = {
                "symboltoken": self._get_symbol_token(symbol),
                "transactiontype": "SELL",
                "ordertype": "MARKET",
                "quantity": 1,
                "userid": self.user_id
            }
            
            response = self.session.post(
                f"{self.BASE_URL}/api/orders/regular",
                json=payload,
                timeout=10
            )
            response.raise_for_status()
            logger.info(f"Position closed: {symbol}")
            return response.json()
        
        except Exception as e:
            logger.error(f"Close position failed: {str(e)}")
            raise
    
    def get_positions(self) -> Dict:
        """Get all open positions"""
        try:
            response = self.session.get(
                f"{self.BASE_URL}/api/positions",
                params={"userid": self.user_id},
                timeout=10
            )
            response.raise_for_status()
            return response.json()
        except Exception as e:
            logger.error(f"Fetch positions failed: {str(e)}")
            return {}
