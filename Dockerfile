# ==========================================
# Estágio de Desenvolvimento (Local)
# ==========================================
FROM node:20-alpine AS development

RUN apk add --no-cache git
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

EXPOSE 5173
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0"]

# ==========================================
# Estágio de Build (Produção)
# ==========================================
FROM node:20-alpine AS builder

RUN apk add --no-cache git
WORKDIR /app

COPY package*.json ./
RUN npm install

COPY . .

# Argumentos de compilação injetados pelo Dokploy ou Docker
ARG VITE_SUPABASE_URL
ARG VITE_SUPABASE_KEY
ENV VITE_SUPABASE_URL=$VITE_SUPABASE_URL
ENV VITE_SUPABASE_KEY=$VITE_SUPABASE_KEY

RUN npm run build

# ==========================================
# Estágio de Execução em Produção (Nginx)
# ==========================================
FROM nginx:alpine AS production

COPY --from=builder /app/dist /usr/share/nginx/html
COPY nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
