# ==========================================
# STAGE 1: Build (Gradle con JDK 21)
# ==========================================
FROM gradle:8.8-jdk21 AS build
WORKDIR /app

# Copiar archivos de configuración de dependencias para aprovechar la caché
COPY build.gradle settings.gradle ./
COPY src ./src

# Compilar el proyecto omitiendo las pruebas unitarias para acelerar el despliegue
RUN gradle bootWar --no-daemon -x test

# ==========================================
# STAGE 2: Runtime (OpenJDK 21)
# ==========================================
FROM eclipse-temurin:21-jre-alpine
WORKDIR /app

# Exponer el puerto por defecto de Spring Boot
EXPOSE 8080

# Copiar el artefacto generado desde el stage de build
# Al tener rootProject.name='discografia' y version='1', el archivo generado es discografia-1.war
COPY --from=build /app/build/libs/discografia-1.war app.war

# Comando de ejecución
ENTRYPOINT ["java", "-jar", "app.war"]