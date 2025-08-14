-- PostgreSQL 데이터베이스 초기화 스크립트

-- 거래 기록 테이블 생성
CREATE TABLE IF NOT EXISTS trading_history (
    id SERIAL PRIMARY KEY,
    timestamp TIMESTAMP NOT NULL,
    decision VARCHAR(10) NOT NULL,
    percentage DECIMAL(5,2) NOT NULL,
    reason TEXT NOT NULL,
    btc_balance DECIMAL(20,8) NOT NULL,
    krw_balance DECIMAL(20,2) NOT NULL,
    btc_avg_buy_price DECIMAL(20,2) NOT NULL,
    btc_krw_price DECIMAL(20,2) NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 반성 일기 테이블 생성
CREATE TABLE IF NOT EXISTS trading_reflection (
    id SERIAL PRIMARY KEY,
    trading_id INTEGER NOT NULL,
    reflection_date TIMESTAMP NOT NULL,
    market_condition TEXT NOT NULL,
    decision_analysis TEXT NOT NULL,
    improvement_points TEXT NOT NULL,
    success_rate DECIMAL(5,2) NOT NULL,
    learning_points TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (trading_id) REFERENCES trading_history(id)
);

-- 인덱스 생성
CREATE INDEX IF NOT EXISTS idx_trading_history_timestamp ON trading_history(timestamp);
CREATE INDEX IF NOT EXISTS idx_trading_history_decision ON trading_history(decision);
CREATE INDEX IF NOT EXISTS idx_trading_reflection_date ON trading_reflection(reflection_date);

-- 뷰 생성 (성과 분석용)
CREATE OR REPLACE VIEW trading_performance AS
SELECT 
    DATE(timestamp) as trade_date,
    COUNT(*) as total_trades,
    COUNT(CASE WHEN decision = 'buy' THEN 1 END) as buy_trades,
    COUNT(CASE WHEN decision = 'sell' THEN 1 END) as sell_trades,
    COUNT(CASE WHEN decision = 'hold' THEN 1 END) as hold_trades,
    AVG(percentage) as avg_percentage,
    AVG(btc_krw_price) as avg_btc_price
FROM trading_history
GROUP BY DATE(timestamp)
ORDER BY trade_date DESC;

-- 뷰 생성 (일별 수익률 분석용)
CREATE OR REPLACE VIEW daily_profit_analysis AS
WITH daily_stats AS (
    SELECT 
        DATE(timestamp) as trade_date,
        FIRST_VALUE(btc_krw_price) OVER (PARTITION BY DATE(timestamp) ORDER BY timestamp) as open_price,
        LAST_VALUE(btc_krw_price) OVER (PARTITION BY DATE(timestamp) ORDER BY timestamp ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) as close_price,
        SUM(CASE WHEN decision = 'buy' THEN krw_balance * -1 ELSE 0 END) as buy_amount,
        SUM(CASE WHEN decision = 'sell' THEN krw_balance ELSE 0 END) as sell_amount
    FROM trading_history
    GROUP BY DATE(timestamp), timestamp, btc_krw_price, decision, krw_balance
)
SELECT 
    trade_date,
    open_price,
    close_price,
    (close_price - open_price) / open_price * 100 as price_change_percent,
    buy_amount,
    sell_amount,
    (sell_amount + buy_amount) as net_cash_flow
FROM daily_stats
ORDER BY trade_date DESC;

-- 함수 생성 (거래 통계)
CREATE OR REPLACE FUNCTION get_trading_stats(days_back INTEGER DEFAULT 30)
RETURNS TABLE (
    total_trades BIGINT,
    buy_trades BIGINT,
    sell_trades BIGINT,
    hold_trades BIGINT,
    avg_percentage DECIMAL(5,2),
    success_rate DECIMAL(5,2)
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        COUNT(*) as total_trades,
        COUNT(CASE WHEN decision = 'buy' THEN 1 END) as buy_trades,
        COUNT(CASE WHEN decision = 'sell' THEN 1 END) as sell_trades,
        COUNT(CASE WHEN decision = 'hold' THEN 1 END) as hold_trades,
        AVG(percentage) as avg_percentage,
        AVG(r.success_rate) as success_rate
    FROM trading_history h
    LEFT JOIN trading_reflection r ON h.id = r.trading_id
    WHERE h.timestamp >= CURRENT_DATE - INTERVAL '1 day' * days_back;
END;
$$ LANGUAGE plpgsql;

-- 초기 데이터 삽입 (테스트용)
INSERT INTO trading_history (timestamp, decision, percentage, reason, btc_balance, krw_balance, btc_avg_buy_price, btc_krw_price) VALUES
(CURRENT_TIMESTAMP - INTERVAL '1 day', 'buy', 10.0, 'AI 분석 결과 매수 신호', 0.001, 1000000.0, 50000000.0, 50000000.0),
(CURRENT_TIMESTAMP - INTERVAL '2 days', 'sell', 5.0, '이익 실현', 0.0005, 1025000.0, 50000000.0, 51000000.0),
(CURRENT_TIMESTAMP - INTERVAL '3 days', 'hold', 0.0, '시장 관망', 0.0005, 1025000.0, 50000000.0, 50500000.0);

-- 권한 설정
GRANT ALL PRIVILEGES ON ALL TABLES IN SCHEMA public TO trading_user;
GRANT ALL PRIVILEGES ON ALL SEQUENCES IN SCHEMA public TO trading_user;
GRANT EXECUTE ON ALL FUNCTIONS IN SCHEMA public TO trading_user; 