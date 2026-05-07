# 1. Copy and fill secrets
cp .env.example .env && nano .env

# 2. Start the stack (main + infra)
docker compose up -d postgres redis n8n

# 3. Scale workers to 5
docker compose up -d --scale n8n_worker=5

# 4. Check logs
docker compose logs -f n8n
docker compose logs -f n8n_worker


🚀 Build & deploy on your VPS

# 1. Fill secrets
cp .env.example .env && nano .env

# 2. Build all 3 images
chmod +x build.sh
./build.sh

# 3. Deploy (build + start + scale workers)
./build.sh --deploy

# 4. Push to a private registry (optional)
REGISTRY=registry.yourdomain.com/n8n ./build.sh --push