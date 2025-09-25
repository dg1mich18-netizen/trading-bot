"""
Настройки торгового бота.
Этот файл содержит все настройки для работы бота.
"""

from pydantic import Field
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Основные настройки приложения."""

    # API Keys для Binance
    BINANCE_API_KEY: str = Field(..., env="BINANCE_API_KEY")
    BINANCE_SECRET_KEY: str = Field(..., env="BINANCE_SECRET_KEY")

    # Настройки торговли
    TRADING_PAIR: str = Field(default="BTCUSDT", env="TRADING_PAIR")
    TESTNET: bool = Field(default=True, env="TESTNET")

    # Управление рисками
    MAX_POSITION_SIZE: float = Field(default=0.1, env="MAX_POSITION_SIZE")
    STOP_LOSS_PERCENT: float = Field(default=2.0, env="STOP_LOSS_PERCENT")

    # Логирование
    LOG_LEVEL: str = Field(default="INFO", env="LOG_LEVEL")

    class Config:
        """Конфигурация Pydantic."""

        env_file = ".env"
        case_sensitive = False


# Создаем глобальный объект настроек
settings = Settings()
