"""
Bybit exchange client implementation.
"""
import logging
from typing import Any, Dict

import ccxt

from config.core.settings import settings

logger = logging.getLogger(__name__)


class BybitClient:
    """Client for Bybit exchange."""

    def __init__(self):
        self.api_key = settings.BYBIT_API_KEY
        self.secret = settings.BYBIT_SECRET_KEY
        self.testnet = settings.TESTNET

        config = {
            "apiKey": self.api_key,
            "secret": self.secret,
            "sandbox": self.testnet,
            "enableRateLimit": True,
        }

        self.exchange = ccxt.bybit(config)
        logger.info(f"Bybit client initialized (testnet: {self.testnet})")

    def test_connection(self) -> bool:
        """Test connection to Bybit."""
        try:
            self.exchange.fetch_balance()
            return True
        except Exception as e:
            logger.error(f"Connection test failed: {e}")
            return False

    def get_balance(self) -> Dict[str, float]:
        """Get account balance."""
        try:
            balance = self.exchange.fetch_balance()
            return {k: v for k, v in balance["total"].items() if v > 0}
        except Exception as e:
            logger.error(f"Error fetching balance: {e}")
            return {}

    def get_ticker(self, symbol: str) -> Dict[str, Any]:
        """Get ticker data for symbol."""
        try:
            return self.exchange.fetch_ticker(symbol)
        except Exception as e:
            logger.error(f"Error fetching ticker for {symbol}: {e}")
            return {}

    def get_available_symbols(self) -> list:
        """Get available trading symbols."""
        try:
            markets = self.exchange.fetch_markets()
            return [market["symbol"] for market in markets]
        except Exception as e:
            logger.error(f"Error fetching symbols: {e}")
            return []


# Create global client instance
bybit_client = BybitClient()
