#!/bin/bash

# Docker Quick Operations Script
# Usage: ./docker-quick.sh [command] [args]

case "$1" in
    "ps"|"list")
        echo "=== RUNNING CONTAINERS ==="
        docker ps --format "table {{.Names}}\t{{.Image}}\t{{.Status}}\t{{.Ports}}"
        ;;
    
    "all")
        echo "=== ALL CONTAINERS ==="
        docker ps -a --format "table {{.Names}}\t{{.Image}}\t{{.Status}}"
        ;;
    
    "images")
        echo "=== DOCKER IMAGES ==="
        docker images --format "table {{.Repository}}:{{.Tag}}\t{{.Size}}\t{{.CreatedSince}}"
        ;;
    
    "logs")
        if [ -z "$2" ]; then
            echo "Usage: $0 logs <container-name>"
            exit 1
        fi
        docker logs --tail 50 -f "$2"
        ;;
    
    "shell"|"exec")
        if [ -z "$2" ]; then
            echo "Usage: $0 shell <container-name> [shell-command]"
            exit 1
        fi
        SHELL_CMD="${3:-/bin/bash}"
        docker exec -it "$2" $SHELL_CMD || docker exec -it "$2" /bin/sh
        ;;
    
    "inspect")
        if [ -z "$2" ]; then
            echo "Usage: $0 inspect <container-name>"
            exit 1
        fi
        docker inspect "$2" | jq '.[0] | {
            Name: .Name,
            State: .State.Status,
            Image: .Config.Image,
            Ports: .NetworkSettings.Ports,
            Env: .Config.Env[:5],
            Mounts: .Mounts,
            Networks: .NetworkSettings.Networks | keys
        }'
        ;;
    
    "clean"|"cleanup")
        echo "=== DOCKER CLEANUP ==="
        echo "Removing stopped containers..."
        docker container prune -f
        echo ""
        echo "Removing unused images..."
        docker image prune -f
        echo ""
        echo "Removing unused volumes..."
        docker volume prune -f
        echo ""
        echo "Cleanup complete!"
        ;;
    
    "stats")
        docker stats --no-stream --format "table {{.Container}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}"
        ;;
    
    "compose-up")
        if [ -f "docker-compose.yml" ]; then
            docker-compose up -d
        else
            echo "No docker-compose.yml found in current directory"
        fi
        ;;
    
    "compose-down")
        if [ -f "docker-compose.yml" ]; then
            docker-compose down
        else
            echo "No docker-compose.yml found in current directory"
        fi
        ;;
    
    "compose-logs")
        if [ -f "docker-compose.yml" ]; then
            docker-compose logs --tail 50 -f "$2"
        else
            echo "No docker-compose.yml found in current directory"
        fi
        ;;
    
    "volumes")
        echo "=== DOCKER VOLUMES ==="
        docker volume ls --format "table {{.Name}}\t{{.Driver}}"
        ;;
    
    "networks")
        echo "=== DOCKER NETWORKS ==="
        docker network ls --format "table {{.Name}}\t{{.Driver}}\t{{.Scope}}"
        ;;
    
    "quick-run")
        # Quick run with common options
        if [ -z "$2" ]; then
            echo "Usage: $0 quick-run <image> [command]"
            exit 1
        fi
        IMAGE="$2"
        shift 2
        docker run --rm -it "$IMAGE" "$@"
        ;;
    
    "build")
        # Quick build with cache info
        if [ -z "$2" ]; then
            TAG="latest"
        else
            TAG="$2"
        fi
        echo "Building image with tag: $TAG"
        docker build -t "$TAG" . --progress=plain
        ;;
    
    *)
        echo "Docker Quick Commands:"
        echo "  $0 ps|list          - Show running containers"
        echo "  $0 all              - Show all containers"
        echo "  $0 images           - List images"
        echo "  $0 logs <name>      - Tail logs for container"
        echo "  $0 shell <name>     - Get shell in container"
        echo "  $0 inspect <name>   - Inspect container (formatted)"
        echo "  $0 clean|cleanup    - Clean up Docker resources"
        echo "  $0 stats            - Show container stats"
        echo "  $0 compose-up       - Docker-compose up -d"
        echo "  $0 compose-down     - Docker-compose down"
        echo "  $0 compose-logs     - Docker-compose logs"
        echo "  $0 volumes          - List volumes"
        echo "  $0 networks         - List networks"
        echo "  $0 quick-run <img>  - Quick run container"
        echo "  $0 build [tag]      - Build Dockerfile in current dir"
        ;;
esac