# Adapted from https://www.chainguard.dev/unchained/building-minimal-and-low-cve-images-for-java

FROM cgr.dev/chainguard/maven AS builder

WORKDIR /work

COPY src/ src/
COPY pom.xml pom.xml

RUN mvn clean package
RUN REPOSITORY=$(mvn help:evaluate -Dexpression=settings.localRepository -q -DforceStdout) && rm -rf ${REPOSITORY}

FROM cgr.dev/chainguard/jre AS runner

WORKDIR /app

COPY --from=builder /work/target/demo-0.0.1-SNAPSHOT.jar .

ENTRYPOINT ["java", "-jar", "demo-0.0.1-SNAPSHOT.jar"]