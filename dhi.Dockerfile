# Adapted from https://www.chainguard.dev/unchained/building-minimal-and-low-cve-images-for-java

FROM dhi.io/maven:3-jdk25-debian13-dev AS builder

WORKDIR /work

COPY src/ src/
COPY pom.xml pom.xml

RUN mvn clean package
RUN REPOSITORY=$(mvn help:evaluate -Dexpression=settings.localRepository -q -DforceStdout) && rm -rf ${REPOSITORY}

FROM dhi.io/eclipse-temurin:25-alpine3.23 AS runner

WORKDIR /app

COPY --from=builder /work/target/demo-0.0.1-SNAPSHOT.jar .

ENTRYPOINT ["java", "-jar", "demo-0.0.1-SNAPSHOT.jar"]