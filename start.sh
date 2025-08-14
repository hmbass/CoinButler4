#!/bin/bash

# GPT 비트코인 자동 거래 시스템 시작 스크립트
# Docker Compose로 한번에 실행

echo "🚀 GPT 비트코인 자동 거래 시스템 시작 중..."

# 1. 기존 컨테이너 중지 및 정리
echo "📦 기존 컨테이너 정리 중..."
docker-compose -f docker-compose.simple.yml down

# 2. 데이터베이스 초기화 (필요한 경우)
if [ ! -f "trading.db" ]; then
    echo "🗄️ 데이터베이스 초기화 중..."
    docker-compose -f docker-compose.simple.yml --profile init up init-db
    docker-compose -f docker-compose.simple.yml --profile init down
    echo "✅ 데이터베이스 초기화 완료!"
else
    echo "✅ 데이터베이스 파일이 이미 존재합니다."
fi

# 3. 필요한 디렉토리 생성
echo "📁 필요한 디렉토리 생성 중..."
mkdir -p data logs

# 4. 컨테이너 빌드 및 시작
echo "🐳 Docker 컨테이너 빌드 및 시작 중..."
docker-compose -f docker-compose.simple.yml up -d --build

# 5. 상태 확인
echo "📊 서비스 상태 확인 중..."
sleep 5

# 6. 로그 확인
echo "📋 서비스 로그 확인 중..."
docker-compose -f docker-compose.simple.yml logs --tail=20

# 7. 완료 메시지
echo ""
echo "🎉 GPT 비트코인 자동 거래 시스템이 성공적으로 시작되었습니다!"
echo ""
echo "📱 접속 정보:"
echo "   - 대시보드: http://localhost:8501"
echo "   - PostgreSQL: localhost:5432"
echo "   - Redis: localhost:6379"
echo ""
echo "📋 유용한 명령어:"
echo "   - 로그 확인: docker-compose -f docker-compose.simple.yml logs -f"
echo "   - 서비스 중지: docker-compose -f docker-compose.simple.yml down"
echo "   - 서비스 재시작: docker-compose -f docker-compose.simple.yml restart"
echo ""
echo "⚠️  주의사항:"
echo "   - API 키가 설정되지 않은 경우 시뮬레이션 모드로 실행됩니다"
echo "   - 실제 거래를 원한다면 .env 파일에 API 키를 설정하세요"
echo "" 