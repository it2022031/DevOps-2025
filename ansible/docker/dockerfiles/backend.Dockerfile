FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /src

# Εγκαθιστούμε git
RUN apt-get update && apt-get install -y git && rm -rf /var/lib/apt/lists/*

ARG REPO_URL
ARG REPO_BRANCH=main-branch

RUN git clone --depth 1 --branch ${REPO_BRANCH} ${REPO_URL} app
WORKDIR /src/app/backend/demo
RUN mvn -DskipTests package


# runtime container με JRE μόνο
FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /src/app/backend/demo/target/*.jar /app/app.jar

EXPOSE 8080
ENTRYPOINT ["java","-jar","/app/app.jar"]
