#!/usr/bin/env python3
"""
Deneysel Çalışma: Veri Analizi ve Görselleştirme
Bu kod çeşitli Python kütüphanelerini kullanarak basit bir veri analizi yapar.
"""

# Standart kütüphaneler
# JSON işleme
import json
import time
from datetime import datetime
from pathlib import Path
from typing import Any

# Görselleştirme kütüphaneleri
import matplotlib.pyplot as plt

# Veri işleme kütüphaneleri
import numpy as np
import pandas as pd
import seaborn as sns

# İstatistik kütüphaneleri
from sklearn.linear_model import LinearRegression
from sklearn.metrics import r2_score


def get_output_dir() -> Path:
    """Çıktı dosyalarının kaydedileceği dizini döndürür"""
    # Script'in bulunduğu dizini kullan
    script_dir = Path(__file__).parent
    return script_dir


def generate_sample_data(n: int = 100) -> pd.DataFrame:
    """Deneysel veri oluşturur"""
    np.random.seed(42)

    data: dict[str, Any] = {
        "x": np.random.normal(50, 15, n),
        "y": np.random.normal(100, 25, n),
        "kategori": np.random.choice(["A", "B", "C"], n),
        "zaman": pd.date_range("2024-01-01", periods=n, freq="D"),
    }

    # Y değerini X'e bağımlı hale getir
    data["y"] = data["x"] * 2 + np.random.normal(0, 10, n)

    return pd.DataFrame(data)


def analyze_data(df: pd.DataFrame) -> tuple[LinearRegression, np.ndarray]:
    """Veri analizi yapar"""
    print("=== VERİ ANALİZİ ===")
    print(f"Veri boyutu: {df.shape}")
    print("Temel istatistikler:")
    print(df.describe())

    # Korelasyon analizi
    correlation: float = df["x"].corr(df["y"])
    print(f"\nX-Y Korelasyonu: {correlation:.3f}")

    # Linear regression
    X: pd.DataFrame = df[["x"]]
    y: pd.Series = df["y"]
    model: LinearRegression = LinearRegression()
    model.fit(X, y)

    y_pred: np.ndarray = model.predict(X)
    r2: float = r2_score(y, y_pred)

    print(f"R² Skoru: {r2:.3f}")
    print(f"Regresyon denklemi: y = {model.coef_[0]:.2f}x + {model.intercept_:.2f}")

    return model, y_pred


def create_visualizations(df: pd.DataFrame, y_pred: np.ndarray) -> None:
    """Görselleştirmeler oluşturur"""
    plt.style.use("seaborn-v0_8")
    fig, axes = plt.subplots(2, 2, figsize=(12, 10))

    # Scatter plot
    axes[0, 0].scatter(df["x"], df["y"], alpha=0.6)
    axes[0, 0].plot(df["x"], y_pred, color="red", linewidth=2)
    axes[0, 0].set_title("X vs Y (Linear Regression)")
    axes[0, 0].set_xlabel("X")
    axes[0, 0].set_ylabel("Y")

    # Histogram
    axes[0, 1].hist(df["x"], bins=20, alpha=0.7, color="blue")
    axes[0, 1].set_title("X Değerlerinin Dağılımı")
    axes[0, 1].set_xlabel("X")
    axes[0, 1].set_ylabel("Frekans")

    # Box plot
    sns.boxplot(data=df, x="kategori", y="y", ax=axes[1, 0])
    axes[1, 0].set_title("Kategorilere Göre Y Dağılımı")

    # Time series
    df_time: pd.Series = df.groupby("zaman")["y"].mean()
    axes[1, 1].plot(df_time.index, df_time.values)
    axes[1, 1].set_title("Zaman Serisi")
    axes[1, 1].set_xlabel("Tarih")
    axes[1, 1].set_ylabel("Y Ortalama")
    axes[1, 1].tick_params(axis="x", rotation=45)

    plt.tight_layout()
    output_dir = get_output_dir()
    output_path = output_dir / "experiment_results.png"
    plt.savefig(output_path, dpi=300)
    print(f"Grafik kaydedildi: {output_path}")


def export_results(df: pd.DataFrame, model: LinearRegression) -> None:
    """Sonuçları JSON formatında dışa aktarır"""
    results: dict[str, Any] = {
        "timestamp": datetime.now().isoformat(),
        "sample_size": len(df),
        "correlation": df["x"].corr(df["y"]),
        "regression_coef": model.coef_[0],
        "regression_intercept": model.intercept_,
        "mean_x": df["x"].mean(),
        "mean_y": df["y"].mean(),
        "std_x": df["x"].std(),
        "std_y": df["y"].std(),
    }

    output_dir = get_output_dir()
    output_path = output_dir / "results.json"
    with open(output_path, "w") as f:
        json.dump(results, f, indent=2)

    print(f"Sonuçlar kaydedildi: {output_path}")


def main() -> None:
    """Ana fonksiyon"""
    print("Deneysel Çalışma Başlatılıyor...")
    start_time: float = time.time()

    # Veri oluştur
    df: pd.DataFrame = generate_sample_data(150)

    # Analiz yap
    model: LinearRegression
    y_pred: np.ndarray
    model, y_pred = analyze_data(df)

    # Görselleştir
    create_visualizations(df, y_pred)

    # Sonuçları kaydet
    export_results(df, model)

    end_time: float = time.time()
    print(f"\nDeneysel çalışma tamamlandı! Süre: {end_time - start_time:.2f} saniye")


if __name__ == "__main__":
    main()
