#!/usr/bin/env python3
"""
데이터베이스 초기화 스크립트
SQLite 데이터베이스와 필요한 테이블들을 생성합니다.
"""

import sqlite3
import os
from datetime import datetime

def init_database():
    """데이터베이스와 테이블을 초기화합니다."""
    
    # 데이터베이스 파일 경로
    db_path = "trading.db"
    
    # logs 디렉토리 생성
    os.makedirs("logs", exist_ok=True)
    
    # 데이터베이스 연결
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()
    
    try:
        # trading_history 테이블 생성
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS trading_history (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
                decision TEXT NOT NULL,
                percentage REAL,
                reason TEXT,
                btc_balance REAL DEFAULT 0,
                krw_balance REAL DEFAULT 0,
                btc_avg_buy_price REAL DEFAULT 0,
                btc_krw_price REAL DEFAULT 0,
                trade_amount REAL DEFAULT 0,
                trade_type TEXT DEFAULT 'analysis'
            )
        ''')
        
        # trading_reflection 테이블 생성
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS trading_reflection (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                trading_id INTEGER,
                reflection_date DATETIME DEFAULT CURRENT_TIMESTAMP,
                reflection_text TEXT,
                mood_score INTEGER,
                learning_points TEXT,
                next_actions TEXT,
                FOREIGN KEY (trading_id) REFERENCES trading_history (id)
            )
        ''')
        
        # 샘플 데이터 삽입 (테스트용)
        sample_trades = [
            (datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 'HOLD', 65.5, '시장 안정성 유지', 0.001, 50000, 45000000, 45000000, 0, 'analysis'),
            (datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 'BUY', 75.2, 'RSI 과매도 구간 진입', 0.002, 40000, 44000000, 44000000, 10000, 'analysis'),
            (datetime.now().strftime('%Y-%m-%d %H:%M:%S'), 'SELL', 80.1, '이익 실현', 0.001, 60000, 46000000, 46000000, -10000, 'analysis'),
        ]
        
        cursor.executemany('''
            INSERT INTO trading_history 
            (timestamp, decision, percentage, reason, btc_balance, krw_balance, btc_avg_buy_price, btc_krw_price, trade_amount, trade_type)
            VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
        ''', sample_trades)
        
        # 샘플 반성 데이터 삽입
        sample_reflections = [
            (1, '오늘은 시장이 안정적이었습니다. HOLD 결정이 적절했던 것 같습니다.', 7, '인내심의 중요성', '계속 모니터링'),
            (2, 'RSI 신호를 잘 포착했습니다. 적절한 진입 시점이었습니다.', 8, '기술적 지표 활용', '손절선 설정'),
            (3, '목표 수익률 달성으로 이익 실현했습니다.', 9, '목표 설정의 중요성', '다음 기회 대기'),
        ]
        
        cursor.executemany('''
            INSERT INTO trading_reflection 
            (trading_id, reflection_text, mood_score, learning_points, next_actions)
            VALUES (?, ?, ?, ?, ?)
        ''', sample_reflections)
        
        # 변경사항 저장
        conn.commit()
        
        print("✅ 데이터베이스 초기화 완료!")
        print(f"📁 데이터베이스 파일: {db_path}")
        print("📊 생성된 테이블:")
        print("   - trading_history (거래 기록)")
        print("   - trading_reflection (반성 일기)")
        print("📝 샘플 데이터 3개 추가됨")
        
    except Exception as e:
        print(f"❌ 데이터베이스 초기화 오류: {e}")
        conn.rollback()
    finally:
        conn.close()

if __name__ == "__main__":
    init_database() 