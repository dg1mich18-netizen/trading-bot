"""
Настройки торгового бота для Bybit.
Этот файл содержит все настройки для работы бота с Bybit.
"""

from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Основные настройки приложения для Bybit."""

    # Bybit API Configuration
    BYBIT_API_KEY: str = Field(..., env="BYBIT_API_KEY")
    BYBIT_SECRET_KEY: str = Field(..., env="BYBIT_SECRET_KEY")

    # Exchange Settings
    EXCHANGE: str = Field(default="bybit", env="EXCHANGE")
    TESTNET: bool = Field(default=True, env="TESTNET")

    # Trading Settings
    TRADING_PAIR: str = Field(default="BTCUSDT", env="TRADING_PAIR")
    TRADE_AMOUNT: float = Field(default=100.0, env="TRADE_AMOUNT")

    # Risk Management
    MAX_POSITION_SIZE: float = Field(default=0.1, env="MAX_POSITION_SIZE")
    STOP_LOSS_PERCENT: float = Field(default=2.0, env="STOP_LOSS_PERCENT")
    TAKE_PROFIT_PERCENT: float = Field(default=3.0, env="TAKE_PROFIT_PERCENT")
    LEVERAGE: int = Field(default=10, env="LEVERAGE")

    # Trading Strategy
    STRATEGY: str = Field(default="simple_mean_reversion", env="STRATEGY")
    TIMEFRAME: str = Field(default="5m", env="TIMEFRAME")
    RSI_PERIOD: int = Field(default=14, env="RSI_PERIOD")
    RSI_OVERSOLD: int = Field(default=30, env="RSI_OVERSOLD")
    RSI_OVERBOUGHT: int = Field(default=70, env="RSI_OVERBOUGHT")

    # Order Settings
    ORDER_TYPE: str = Field(default="market", env="ORDER_TYPE")
    POST_ONLY: bool = Field(default=False, env="POST_ONLY")

    # Logging and Monitoring
    LOG_LEVEL: str = Field(default="INFO", env="LOG_LEVEL")
    TELEGRAM_BOT_TOKEN: str = Field(default="", env="TELEGRAM_BOT_TOKEN")
    TELEGRAM_CHAT_ID: str = Field(default="", env="TELEGRAM_CHAT_ID")

    # Database (опционально)
    DATABASE_URL: str = Field(default="", env="DATABASE_URL")

    class Config:
        """Конфигурация Pydantic."""

        env_file = ".env"
        env_file_encoding = "utf-8"
        case_sensitive = False


# Создаем глобальный объект настроек
settings = Settings()
