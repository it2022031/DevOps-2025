FROM node:18 AS build
WORKDIR /src

# Εγκαθιστούμε git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

ARG REPO_URL
ARG REPO_BRANCH=main-branch

RUN git clone --depth 1 --branch ${REPO_BRANCH} ${REPO_URL} app
WORKDIR /src/app/frontend/vue-argon-design-system-master

ENV VUE_APP_API_BASE_URL=/api

RUN npm ci || npm install

# αφαιρούμε hardcoded calls στο http://localhost:8080
# και τα αντικαθιστούμε ώστε να περνάνε από το nginx (/api)
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


# σερβίρισμα του built frontend με nginx
FROM nginx:alpine
COPY --from=build /src/app/frontend/vue-argon-design-system-master/dist /usr/share/nginx/html

# Custom nginx config
COPY dockerfiles/nginx-frontend.conf /etc/nginx/conf.d/default.conf
EXPOSE 80
