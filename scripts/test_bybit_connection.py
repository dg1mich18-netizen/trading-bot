#!/usr/bin/env python3
"""
Test connection to Bybit exchange.
"""
import os
import sys

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def test_bybit_connection():
    """Test if we can load Bybit settings."""
    try:
        from config.core.settings import settings

        print("✅ Settings loaded successfully!")
        print(f"🔐 Exchange: {settings.EXCHANGE}")
        print(f"🌐 Testnet: {settings.TESTNET}")
        print(f"💰 Trading pair: {settings.TRADING_PAIR}")
        print(f"⚡ API Key: {settings.BYBIT_API_KEY[:10]}...")
        print(f"🔒 Secret Key: {settings.BYBIT_SECRET_KEY[:10]}...")

        return True

    except Exception as e:
        print(f"❌ Error loading settings: {e}")
        return False


if __name__ == "__main__":
    test_bybit_connection()
