# ── Build stage ───────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jdk AS build
WORKDIR /app

COPY .mvn .mvn
COPY mvnw pom.xml ./
# Windows checkout'ta CRLF gelebilir; Linux'ta script bozulmasın.
RUN sed -i 's/\r$//' mvnw && chmod +x mvnw
RUN ./mvnw -B -ntp dependency:go-offline

COPY src src
RUN ./mvnw -B -ntp package -DskipTests

# ── Runtime stage ─────────────────────────────────────────────────────────
FROM eclipse-temurin:17-jre
WORKDIR /app

COPY --from=build /app/target/*.jar app.jar

# Railway PORT ortam değişkenini verir; application.yml ${PORT:...} okur.
EXPOSE 8080

ENTRYPOINT ["java", "-jar", "app.jar"]
