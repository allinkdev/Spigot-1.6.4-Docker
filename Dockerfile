FROM alpine as environment-creator

RUN addgroup -S -g 65532 nonroot
RUN adduser -S -D -u 65532 nonroot nonroot

USER nonroot:nonroot
WORKDIR /home/nonroot/

RUN mkdir runtime
ADD ./bin/spigot.jar ./runtime/server.jar

USER root:root

RUN chown -Rv root:root ./runtime/
RUN chmod -Rv a=r-x ./runtime/

FROM gcr.io/distroless/java17-debian11:nonroot

USER nonroot:nonroot

COPY --from=environment-creator /home/nonroot/runtime/ /runtime/

WORKDIR /server/

# Flags from: https://docs.papermc.io/paper/aikars-flags
# The 1.6.4 server barely uses over 384Mb of ram, so even a small 1024m is overkill.  

ENTRYPOINT [ "java", "-Xms1024M", "-Xmx1024M", "-XX:+UseG1GC", "-XX:+ParallelRefProcEnabled", "-XX:MaxGCPauseMillis=200", "-XX:+UnlockExperimentalVMOptions", "-XX:+DisableExplicitGC", "-XX:+AlwaysPreTouch", "-XX:G1NewSizePercent=30", "-XX:G1MaxNewSizePercent=40", "-XX:G1HeapRegionSize=8M", "-XX:G1ReservePercent=20", "-XX:G1HeapWastePercent=5", "-XX:G1MixedGCCountTarget=4", "-XX:InitiatingHeapOccupancyPercent=15", "-XX:G1MixedGCLiveThresholdPercent=90", "-XX:G1RSetUpdatingPauseTimePercent=5", "-XX:SurvivorRatio=32", "-XX:+PerfDisableSharedMem", "-XX:MaxTenuringThreshold=1", "-jar", "/runtime/server.jar", "--nojline" ]