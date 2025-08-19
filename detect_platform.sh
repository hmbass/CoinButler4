#!/bin/bash

# 플랫폼 감지 스크립트
echo "🔍 플랫폼 감지 중..."

# 기본값 설정
MODE="batch"
IMMEDIATE=""

# 도움말 함수
show_help() {
    echo "사용법: $0 [옵션]"
    echo ""
    echo "옵션:"
    echo "  --mode <mode>      실행 모드 선택 (batch|manual, 기본값: batch)"
    echo "  --immediate        배치 모드에서 즉시 한 번 실행"
    echo "  -h, --help         이 도움말 표시"
    echo ""
    echo "예시:"
    echo "  $0                           # 배치 모드로 실행"
    echo "  $0 --mode manual            # 수동 모드로 실행"
    echo "  $0 --mode batch --immediate # 배치 모드 + 즉시 실행"
    echo ""
}

# 명령행 인자 파싱
while [[ $# -gt 0 ]]; do
    case $1 in
        --mode)
            MODE="$2"
            if [[ "$MODE" != "batch" && "$MODE" != "manual" ]]; then
                echo "❌ 잘못된 모드: $MODE"
                echo "💡 사용 가능한 모드: batch, manual"
                exit 1
            fi
            shift 2
            ;;
        --immediate)
            IMMEDIATE="--immediate"
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        *)
            echo "❌ 알 수 없는 옵션: $1"
            show_help
            exit 1
            ;;
    esac
done

# 모드 표시
MODE_KR="배치실행"
if [ "$MODE" = "manual" ]; then
    MODE_KR="수동실행"
fi

echo "🎯 실행 모드: $MODE_KR"
if [ "$MODE" = "batch" ] && [ -n "$IMMEDIATE" ]; then
    echo "⚡ 즉시 실행: 활성화"
fi

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

# 실행 모드 환경변수 설정
export TRADING_MODE="$MODE"
export TRADING_IMMEDIATE="$IMMEDIATE"

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