# handle certificate and downloads in another stage to reduce image size
FROM alpine as certs
ARG version

RUN apk update && apk add ca-certificates
ENV CELLS_VERSION ${version}

WORKDIR /pydio

RUN wget "https://download.pydio.com/pub/cells/release/${CELLS_VERSION}/linux-amd64/cells"
RUN wget "https://download.pydio.com/pub/cells/release/${CELLS_VERSION}/linux-amd64/cells-ctl"

RUN chmod +x /pydio/cells
RUN chmod +x /pydio/cells-ctl

# Creates the final image
FROM busybox:glibc
ARG version

WORKDIR /pydio


# Add necessary files
COPY cells-install  /pydio/cells-install
COPY libdl.so.2 /pydio/libdl.so.2
COPY --from=certs /etc/ssl/certs /etc/ssl/certs
COPY --from=certs /pydio/cells-ctl .
COPY --from=certs /pydio/cells .


# Final configuration
RUN ln -s /pydio/cells /bin/cells \
    && ln -s /pydio/cells-ctl /bin/cells-ctl \
    && ln -s /pydio/libdl.so.2 /lib64/libdl.so.2 \
    && ln -s /pydio/docker-entrypoint.sh /bin/docker-entrypoint.sh \
    && chmod +x /pydio/cells-install

VOLUME ["/root/.config"]
ENTRYPOINT ["./cells-install"]
CMD ["cells", "start"]
