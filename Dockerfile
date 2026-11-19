FROM quay.io/keycloak/keycloak:26.8.1 AS upstream
FROM eclipse-temurin:21-jdk-alpine AS school-profile
WORKDIR /build
COPY --from=upstream /opt/keycloak/lib/lib/main/ /keycloak-lib/
COPY school-profile/ ./
RUN mkdir classes \
    && javac -encoding UTF-8 -cp '/keycloak-lib/*' -d classes src/*.java \
    && jar --create --file profil-scolaire.jar -C classes . -C resources .

FROM upstream AS builder
ENV KC_DB=postgres KC_HEALTH_ENABLED=true
COPY --from=school-profile --chown=keycloak:keycloak /build/profil-scolaire.jar /opt/keycloak/providers/
RUN /opt/keycloak/bin/kc.sh build

FROM upstream
COPY --from=builder /opt/keycloak/ /opt/keycloak/
COPY --chown=keycloak:keycloak realm/ /opt/keycloak/data/import/
COPY --chown=keycloak:keycloak themes/ /opt/keycloak/themes/
ENV KC_DB=postgres KC_HEALTH_ENABLED=true
ENTRYPOINT ["/opt/keycloak/bin/kc.sh"]
CMD ["start", "--optimized", "--import-realm", "--spi-theme--welcome-theme=atelier"]
