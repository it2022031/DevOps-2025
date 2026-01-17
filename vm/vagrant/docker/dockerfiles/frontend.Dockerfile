FROM node:18 AS build
WORKDIR /src

# ensure git exists (needed for git clone)
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

ARG REPO_URL
ARG REPO_BRANCH=main-branch

RUN git clone --depth 1 --branch ${REPO_BRANCH} ${REPO_URL} app
WORKDIR /src/app/frontend/vue-argon-design-system-master

ENV VUE_APP_API_BASE_URL=/api

RUN npm ci || npm install

# PATCH: remove hardcoded localhost:8080 (use /api via nginx proxy)
RUN set -eu; \
    echo "== Before patch (localhost:8080 occurrences) =="; \
    grep -R --line-number "localhost:8080" src || true; \
    \
    find src -type f \( -name "*.vue" -o -name "*.js" \) -print0 \
      | xargs -0 sed -i 's|http://localhost:8080/api|/api|g'; \
    \
    find src -type f \( -name "*.vue" -o -name "*.js" \) -print0 \
      | xargs -0 sed -i 's|http://localhost:8080||g'; \
    \
    echo "== After patch (localhost:8080 occurrences) =="; \
    grep -R --line-number "localhost:8080" src || true

RUN npm run build

FROM nginx:alpine
COPY --from=build /src/app/frontend/vue-argon-design-system-master/dist /usr/share/nginx/html
COPY dockerfiles/nginx-frontend.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
