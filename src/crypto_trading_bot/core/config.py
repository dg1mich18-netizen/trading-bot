from pydantic import Field, PostgresDsn, RedisDsn
from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    """Настройки приложения, загружаемые из переменных окружения."""

    # API Keys (Binance Testnet для начала)
    BINANCE_API_KEY: str = Field(..., description="API Key from Binance")
    BINANCE_API_SECRET: str = Field(..., description="API Secret from Binance")

    # Database URLs
    DATABASE_URL: PostgresDsn = Field(
        "postgresql://postgres:password@localhost:5432/trading_bot",
        description="URL for PostgreSQL connection",
    )
    REDIS_URL: RedisDsn = Field(
        "redis://localhost:6379/0", description="URL for Redis connection"
    )

    # Trading Settings
    TESTNET: bool = Field(True, description="Use exchange testnet")
    LOG_LEVEL: str = Field("INFO", description="Logging level")

    class Config:
        env_file = ".env"
        case_sensitive = False


# Создаем глобальный экземпляр настроек
settings = Settings()
