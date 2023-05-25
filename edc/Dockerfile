FROM eclipse-temurin:17 as Builder
WORKDIR /edc
ARG GIT_URL
ARG TAG
RUN apt-get update && apt-get install git -y
RUN git clone $GIT_URL .
#RUN git checkout tags/$TAG
RUN ./gradlew -Dorg.gradle.jvmargs="-Xmx1g" clean build

FROM eclipse-temurin:17 as Base

# Copy the files into the container
COPY --from=Builder \
    /edc/launchers/data-plane-server/build/libs/data-plane-server.jar \
    ./provider.jar
COPY entrypoint.sh entrypoint.sh

RUN chmod +x entrypoint.sh

# Set the entrypoint
ENTRYPOINT ["/entrypoint.sh"]

