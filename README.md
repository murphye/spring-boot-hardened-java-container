# Spring Boot Hardened Java Container Demo

This demo project will show how to build an optimized, secure, vulnerability-free [Spring Boot](https://spring.io/projects/spring-boot) 
container image using either:

* Chainguard [OpenJDK image](https://console.chainguard.dev/org/welcome/images/public/image/jre/versions#/)
* Docker Hardened Images (DHI) OpenJDK ([Amazon Corretto](https://hub.docker.com/hardened-images/catalog/dhi/amazoncorretto/)/[Eclipse Temurin](https://hub.docker.com/hardened-images/catalog/dhi/eclipse-temurin)) images

## Differences Between Chainguard and Docker Hardened Image (DHI)

| Provider   | OpenJDK Distros                     | Free JRE LTS Versions | Licensed JRE LTS Versions | Base Images    | Long Term Support |
|------------|-------------------------------------|-----------------------|---------------------------|----------------|-------------------|
| Chainguard | Chainguard                          | 25 (Latest)           | 21, 17, 11, 8, FIPS       | Wolfi          | Requires License  |
| DHI        | Eclipse Temurin and Amazon Corretto | 25, 21, 17, 11, 8     | FIPS                      | Debian, Alpine | Up to Oct 2032    |


## Vulnerability Survey of JRE Images (as of January 7, 2026)

| JRE Image                                     | Vulnerabilities                                                              | Disk Usage | Content Size |
|-----------------------------------------------|------------------------------------------------------------------------------|------------|--------------|
| chainguard/jre:latest                         | <ul><li>0 Critical</li><li>0 High</li><li>0 Medium</li><li>0 Low</li></ul>   | 427MB      | 104MB        |
| amazoncorretto:25                             | <ul><li>0 Critical</li><li>0 High</li><li>0 Medium</li><li>0 Low</li></ul>   | 848MB      | 245MB        |
| amazoncorretto:25-alpine                      | <ul><li>0 Critical</li><li>0 High</li><li>3 Medium</li><li>0 Low</li></ul>   | 557MB      | 183MB        |
| dhi.io/amazoncorretto:25                      | <ul><li>0 Critical</li><li>0 High</li><li>0 Medium</li><li>0 Low</li></ul>   | 680MB      | 217MB        |
| dhi.io/amazoncorretto:25-alpine3.22           | <ul><li>0 Critical</li><li>0 High</li><li>0 Medium</li><li>0 Low</li></ul>   | 619MB      | 207MB        |
| eclipse-temurin:25                            | <ul><li>0 Critical</li><li>1 High</li><li>76 Medium</li><li>95 Low</li></ul> | 579MB      | 142MB        |
| eclipse-temurin:25-jre-alpine                 | <ul><li>0 Critical</li><li>3 High</li><li>9 Medium</li><li>1 Low</li></ul>   | 303MB      | 75MB         |
| dhi.io/eclipse-temurin:25                     | <ul><li>0 Critical</li><li>0 High</li><li>0 Medium</li><li>0 Low</li></ul>   | 314MB      | 60.1MB       |
| dhi.io/eclipse-temurin:25-alpine3.23          | <ul><li>0 Critical</li><li>0 High</li><li>0 Medium</li><li>0 Low</li></ul>   | 246MB      | 48.4MB       |
| mcr.microsoft.com/openjdk/jdk:25-distroless   | <ul><li>0 Critical</li><li>0 High</li><li>0 Medium</li><li>0 Low</li></ul>   | 602MB      | 127MB        |
| bitnami/java                                  | <ul><li>0 Critical</li><li>0 High</li><li>0 Medium</li><li>0 Low</li></ul>   | 823MB      | 281MB        |
| gcr.io/distroless/java25-debian13             | <ul><li>0 Critical</li><li>1 High</li><li>2 Medium</li><li>0 Low</li></ul>   | 321MB      | 82MB         |
| ibm-semeru-runtimes:open-25-jre               | <ul><li>0 Critical</li><li>1 High</li><li>16 Medium</li><li>22 Low</li></ul> | 456MB      | 108MB        |
| container-registry.oracle.com/java/openjdk:25 | <ul><li>0 Critical</li><li>2 High</li><li>25 Medium</li><li>1 Low</li></ul>  | 1.04GB     | 328MB        |
| bellsoft/liberica-openjre-alpine:25           | <ul><li>0 Critical</li><li>0 High</li><li>3 Medium</li><li>6 Low</li></ul>   | 208MB      | 52.7MB       |



## Demo App Prerequisites

* [JDK 25](https://www.oracle.com/java/technologies/downloads/)
* [Docker](https://www.docker.com/)
* [grype](https://github.com/anchore/grype) - Vulnerability scanner CLI tool

`grype` can be installed using Homebrew:

```shell
brew tap anchore/grype
brew install grype
```

Additionally, you must login to `dhi.io` to pull the Docker Hardened Images.

```shell
docker login dhi.io
```

## Build the Spring Boot Demo Application

```shell
./mvnw clean install
```

## Build the Demo Application Container Image from a Dockerfile

There are two multi-stage Dockerfiles to build the Spring Boot application from scratch using Maven, one for DHI and one for Chainguard.

### DHI Images

```shell
docker build -f dhi.Dockerfile -t docker.io/murphye/spring-boot-dhi-demo .
```
```shell
docker run --mount type=tmpfs,destination=/tmp docker.io/murphye/spring-boot-dhi-demo
```

> Note: Using the Alpine-based image requires manually mounting `/tmp` as shown in the previous command


### Chainguard Images

```shell
docker build -f chainguard.Dockerfile -t docker.io/murphye/spring-boot-chainguard-demo .
```
```shell
docker run docker.io/murphye/spring-boot-chainguard-demo
```

## Optional: Build the Container Image with Jib

[Jib](https://github.com/GoogleContainerTools/jib) can use Docker to build a local container image for the application.
This demo project uses the [Jib Maven Plugin](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin).
This plugin can be configured with a custom image (i.e. `chainguard/jre:latest`) as shown:

```xml
<from>
    <image>chainguard/jre:latest</image> <!-- Customize the JRE Image -->
    <platforms>
        <platform>
            <os>linux</os>
            <architecture>arm64</architecture>
        </platform>
    </platforms>
</from>
```

> **Important:** DHI images are not currently compatible with Jib due to zstd-compressed image layers. This may be supported in a future version of Jib. See https://github.com/GoogleContainerTools/jib/issues/3822

> **Note:** Jib has the ability to build images without the Docker daemon which his great for CI/CD pipelines.

> **Note:** Spring Boot offers [Buildpack integration](https://docs.spring.io/spring-boot/reference/packaging/container-images/cloud-native-buildpacks.html)
> out of the box, but there is no Buildpack available that uses the Chainguard or DHI images.


### Run Jib Docker Build for Local Container Image

Jib can be used to use Docker to build a local image:

```shell
./mvnw jib:dockerBuild
```

Run the application using the local container image using Docker: 
```shell
docker run docker.io/murphye/spring-boot-hardened-demo
```

## Run `grype` Against the Local Container Image

```shell
grype docker.io/murphye/spring-boot-hardened-demo
 ✔ Loaded image
 ✔ Parsed image
 ✔ Cataloged contents
   ├── ✔ Packages                        [72 packages]  
   ├── ✔ Executables                     [121 executables]  
   ├── ✔ File metadata                   [1,341 locations]  
   └── ✔ File digests                    [1,341 files]  
 ✔ Scanned for vulnerabilities     [0 vulnerability matches]  
   ├── by severity: 0 critical, 0 high, 0 medium, 0 low, 0 negligible
No vulnerabilities found
```

As you can see, there are no vulnerabilities found when using the latest version of Spring Boot with a hardened or zero-CVE JRE image.

## Bonus: Integrated SBOM Generation

As a bonus, a [CycloneDX SBOM](https://github.com/CycloneDX) will be generated for the application, which can then be scanned by [grype](https://github.com/anchore/grype).
This demo will show how `grype` can be used to scan both images and SBOMs.

### Run `gype` against CycloneDX SBOM

Spring Boot support building CycloneDX SBOM [out of the box](https://spring.io/blog/2024/05/24/sbom-support-in-spring-boot-3-3).
This demo project includes the `cyclonedx-maven-plugin` which will automatically build the SBOM file.

This may be useful for the following reasons:

1. Use a common scanning tool (i.e. `grype`) for both Java dependencies immediately and also the container image after packaging
2. Catch Java vulnerabilities before building a GraalVM native image
3. Catch Java vulnerabilities before packaging a container image

### Run `grype` When Using Spring Boot version 3.5.0 (Has Vulnerabilities)

```shell
grype target/classes/META-INF/sbom/application.cdx.json
 ✔ Scanned for vulnerabilities     [11 vulnerability matches]  
   ├── by severity: 0 critical, 4 high, 5 medium, 2 low, 0 negligible
NAME               INSTALLED  FIXED IN  TYPE          VULNERABILITY        SEVERITY  EPSS           RISK   
tomcat-embed-core  10.1.41    10.1.44   java-archive  GHSA-gqp3-2cvr-x8m3  High      0.2% (47th)    0.2    
tomcat-embed-core  10.1.41    10.1.45   java-archive  GHSA-wmwf-9ccg-fff5  High      0.2% (43rd)    0.2    
tomcat-embed-core  10.1.41    10.1.42   java-archive  GHSA-h3gc-qfqq-6h8f  High      0.1% (32nd)    < 0.1  
spring-web         6.2.7      6.2.8     java-archive  GHSA-6r3c-xf4w-jxjm  Medium    0.1% (31st)    < 0.1  
spring-core        6.2.7      6.2.11    java-archive  GHSA-jmp9-x22r-554x  High      < 0.1% (24th)  < 0.1  
tomcat-embed-core  10.1.41    10.1.45   java-archive  GHSA-vfww-5hm6-hx2j  Low       < 0.1% (23rd)  < 0.1  
tomcat-embed-core  10.1.41    10.1.42   java-archive  GHSA-wc4r-xq3c-5cf3  Medium    < 0.1% (26th)  < 0.1  
logback-core       1.5.18     1.5.19    java-archive  GHSA-25qh-j22f-pwp8  Medium    < 0.1% (22nd)  < 0.1  
spring-webmvc      6.2.7      6.2.10    java-archive  GHSA-r936-gwx5-v52f  Medium    < 0.1% (20th)  < 0.1  
tomcat-embed-core  10.1.41    10.1.47   java-archive  GHSA-hgrr-935x-pq79  Low       0.1% (29th)    < 0.1  
tomcat-embed-core  10.1.41    10.1.42   java-archive  GHSA-42wg-hm62-jcwg  Medium    < 0.1% (6th)   < 0.1
```

### Run `grype` When Using Spring Boot version 3.5.9 (No Vulnerabilities)

```shell
grype target/classes/META-INF/sbom/application.cdx.json
 ✔ Scanned for vulnerabilities     [0 vulnerability matches]  
   ├── by severity: 0 critical, 0 high, 0 medium, 0 low, 0 negligible
No vulnerabilities found
```

## Bonus: Use `dive` to Examine Image Layers

To gain a deeper understanding of how the image is being packaged by Jib, `dive` is an easy way to
dive into the various image layers.

```shell
alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
dive docker.io/murphye/spring-boot-hardened-demo
```
When using `dive` you will see 14 layers for the image built with Jib, and you can examine which layers are storing the dependencies, 
configurations, and the Spring Boot application itself.

## Optional: Jib Build and Push Image to Repo

Jib can build and push the image to your repo without the Docker daemon.

```shell
./mvnw jib:build
```

> **Note:** The full `docker.io` image repository reference is used so `jib:build` will correctly authenticate with the Docker Hub registry.