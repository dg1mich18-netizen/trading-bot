#!/usr/bin/env python3
"""
Comprehensive test for Bybit connection and functionality.
"""
import logging
import os
import sys

# Setup logging
logging.basicConfig(level=logging.INFO, format="%(message)s")

# Add project root to path
sys.path.append(os.path.dirname(os.path.dirname(os.path.abspath(__file__))))


def main():
    """Comprehensive Bybit test."""
    print("Starting comprehensive Bybit test...")
    print("=" * 50)

    try:
        # Test settings loading
        print("Settings loaded successfully")

        # Test Bybit client
        from src.crypto_trading_bot.exchanges.bybit_client import BybitClient

        client = BybitClient()
        print("Testing connection to Bybit...")

        # Test connection
        if client.test_connection():
            print("Connection successful!")
        else:
            print("Connection failed!")
            return

        # Test balance
        print("Fetching balance...")
        balance = client.get_balance()
        if balance:
            print("Balance:", balance)
        else:
            print("No balance data")

        # Test ticker
        print("Fetching BTC/USDT ticker...")
        ticker = client.get_ticker("BTC/USDT")
        if ticker:
            print(f"BTC/USDT: ${ticker['last']}")
            print(f"24h Change: {ticker['percentage']: .2f}%")
        else:
            print("Failed to fetch ticker")

        # Test symbols
        print("Fetching available symbols...")
        symbols = client.get_available_symbols()
        if symbols:
            print(f"Found {len(symbols)} symbols (showing first 10): ")
            for i, symbol in enumerate(symbols[:10]):
                ticker = client.get_ticker(symbol)
                if ticker:
                    print(f"{symbol}: {ticker['last']}")
                else:
                    print(f"{symbol}: N/A")
        else:
            print("Failed to fetch symbols")

    except Exception as e:
        print(f"Test failed with error: {e}")
        return

    print("=" * 50)
    print("All tests completed!")


if __name__ == "__main__":
    main()
