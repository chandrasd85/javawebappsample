FROM maven:3.5.4-jdk-8-alpine as build

COPY ./pom.xml ./pom.xml

COPY ./src ./src

RUN mvn package

FROM openjdk:8-jdk

WORKDIR /app

COPY --from=build target/sample-*.jar ./sample.jar

CMD ["java", "-jar", "./sample.jar"]