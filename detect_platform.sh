#!/bin/bash

# 플랫폼 감지 스크립트
echo "🔍 플랫폼 감지 중..."

# 아키텍처 확인
ARCH=$(uname -m)
echo "📊 현재 아키텍처: $ARCH"

# 운영체제 확인
OS=$(uname -s)
echo "💻 운영체제: $OS"

# 환경 변수 파일 확인
if [ ! -f ".env" ]; then
    echo "⚠️  .env 파일이 없습니다. env.example을 복사하여 생성하세요."
    echo "   cp env.example .env"
    exit 1
fi

# 아키텍처별 실행
case $ARCH in
    "x86_64"|"amd64")
        echo "🚀 x86_64 환경으로 실행합니다..."
        echo "📁 사용할 파일: docker-compose.x86_64.yml"
        
        # 기존 컨테이너 정리
        echo "🧹 기존 컨테이너 정리 중..."
        docker-compose down 2>/dev/null || true
        
        # x86_64용 실행
        echo "🏗️  x86_64용 컨테이너 빌드 및 실행 중..."
        docker-compose -f docker-compose.x86_64.yml up -d --build
        
        echo "✅ x86_64 환경 실행 완료!"
        echo "🌐 대시보드 접속: http://localhost:8501"
        echo "📋 로그 확인: docker-compose -f docker-compose.x86_64.yml logs -f"
        ;;
        
    "arm64"|"aarch64")
        echo "🚀 ARM64 환경으로 실행합니다..."
        echo "📁 사용할 파일: docker-compose.arm64.yml"
        
        # 기존 컨테이너 정리
        echo "🧹 기존 컨테이너 정리 중..."
        docker-compose down 2>/dev/null || true
        
        # ARM64용 실행
        echo "🏗️  ARM64용 컨테이너 빌드 및 실행 중..."
        docker-compose -f docker-compose.arm64.yml up -d --build
        
        echo "✅ ARM64 환경 실행 완료!"
        echo "🌐 대시보드 접속: http://localhost:8501"
        echo "📋 로그 확인: docker-compose -f docker-compose.arm64.yml logs -f"
        ;;
        
    *)
        echo "❌ 지원하지 않는 아키텍처: $ARCH"
        echo "💡 지원되는 아키텍처: x86_64, arm64"
        exit 1
        ;;
esac

echo ""
echo "📊 컨테이너 상태 확인:"
docker ps --filter "name=gpt-bitcoin" --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" 