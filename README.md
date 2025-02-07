# Spring Boot Chainguard Java Container Demo

This demo project will show how to build an optimized, secure, vulnerability-free [Spring Boot](https://spring.io/projects/spring-boot) 
container image using the Chainguard [JRE base image](https://console.chainguard.dev/org/welcome/images/public/image/jre/versions#/).

As a bonus, a [CycloneDX SBOM](https://github.com/CycloneDX) will be generated for the application and included into the image, which can then be scanned by [grype](https://github.com/anchore/grype). 

## Prerequisites

* [JDK 21](https://www.oracle.com/java/technologies/downloads/) or higher version
* [Docker](https://www.docker.com/)
* [grype](https://github.com/anchore/grype) - Vulnerability scanner CLI tool

`grype` can be installed using Homebrew:

```shell
brew tap anchore/grype
brew install grype
```

## Build the Spring Boot Application

```shell
./mvnw clean install
```

## Run Jib Docker Build for Local Container Image

[Jib](https://github.com/GoogleContainerTools/jib) can use Docker to build a local container image for the application.
This demo project uses the [Jib Maven Plugin](https://github.com/GoogleContainerTools/jib/tree/master/jib-maven-plugin).

```shell
./mvnw jib:dockerBuild
```

Run the application using the local container image using Docker: 
```shell
docker run docker.io/murphye/spring-boot-chainguard-demo
```

## Run `grype` against Local Container Image

```shell
grype docker.io/murphye/spring-boot-chainguard-demo:latest
 ✔ Loaded image                                                                                                                                 docker.io/murphye/spring-boot-chainguard-demo:latest
 ✔ Parsed image                                                                                                                            sha256:18f64293e66f391c41e7363c989687b852203e0fb9c32744f0c5d7b80a0e7f79
 ✔ Cataloged contents                                                                                                                             0b944452baefa268f36e01336d79d0fb1fc35f13bef0c11c262d3ef2c9e46d06
   ├── ✔ Packages                        [74 packages]  
   ├── ✔ File digests                    [1,186 files]  
   ├── ✔ File metadata                   [1,186 locations]  
   └── ✔ Executables                     [121 executables]  
 ✔ Scanned for vulnerabilities     [0 vulnerability matches]  
   ├── by severity: 0 critical, 0 high, 0 medium, 0 low, 0 negligible
   └── by status:   0 fixed, 0 not-fixed, 0 ignored 
No vulnerabilities found
```

As you can see, there are no vulnerabilities found when using the latest version of Spring Boot and the Chainguard [JRE base image](https://console.chainguard.dev/org/welcome/images/public/image/jre/versions#/).
Currently, the Chainguard image is the only available JRE image with 0 vulnerabilities.

## Bonus: Run `gype` against CycloneDX SBOM

Spring Boot support building CycloneDX SBOM [out of the box](https://spring.io/blog/2024/05/24/sbom-support-in-spring-boot-3-3).
This demo project includes the `cyclonedx-maven-plugin` which will automatically build the SBOM file.

This may be useful for the following reasons:

1. Use a common scanning tool (i.e. `grype`) for both Java dependencies immediately and also the container image after packaging
2. Catch Java vulnerabilities before building a GraalVM native image
3. Catch Java vulnerabilities before packaging a container image

### Run `grype` When Using Spring Boot version 3.4.0 (Has Vulnerabilities)

```shell
./mvnw compile
grype target/classes/META-INF/sbom/application.cdx.json
 ✔ Scanned for vulnerabilities     [4 vulnerability matches]  
   ├── by severity: 0 critical, 2 high, 1 medium, 1 low, 0 negligible
   └── by status:   4 fixed, 0 not-fixed, 0 ignored 
NAME               INSTALLED  FIXED-IN  TYPE          VULNERABILITY        SEVERITY 
logback-core       1.5.12     1.5.13    java-archive  GHSA-pr98-23f8-jwxv  Medium    
logback-core       1.5.12     1.5.13    java-archive  GHSA-6v67-2wr5-gvf4  Low       
tomcat-embed-core  10.1.33    10.1.34   java-archive  GHSA-5j33-cvvr-w245  High      
tomcat-embed-core  10.1.33    10.1.34   java-archive  GHSA-27hp-xhwr-wr2m  High
```

### Run `grype` When Using Spring Boot version 3.4.2 (No Vulnerabilities)

```shell
./mvnw compile
grype target/classes/META-INF/sbom/application.cdx.json
 ✔ Scanned for vulnerabilities     [0 vulnerability matches]  
   ├── by severity: 0 critical, 0 high, 0 medium, 0 low, 0 negligible
   └── by status:   0 fixed, 0 not-fixed, 0 ignored 
No vulnerabilities found
```

## Bonus: Use `dive` to Examine Image Layers

To gain a deeper understanding of how the image is being packaged by Jib, `dive` is an easy way to
dive into the various image layers.

```shell
alias dive="docker run -ti --rm  -v /var/run/docker.sock:/var/run/docker.sock wagoodman/dive"
dive docker.io/murphye/spring-boot-chainguard-demo
```
When using `dive` you will see 5 image layers, and you can examine which layers are storing the dependencies, 
configurations, and the Spring Boot application itself. The bottom layer will be the JRE base image.

## Optional: Jib Build and Push Image to Repo

Jib can build and push the image to your repo without the Docker daemon.

```shell
jib:build
```

> **Note:** The full `docker.io` image repository reference is used so `jib:build` will correctly authenticate with the Docker Hub registry.

