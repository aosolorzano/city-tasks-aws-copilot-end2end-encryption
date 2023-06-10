FROM envoyproxy/envoy:v1.26-latest
ARG envoy_env=dev

RUN echo "Copying configuration files for '$envoy_env' environment."
COPY ./utils/docker/envoy/envoy-https-http.yaml     /etc/envoy/envoy.yaml
COPY ./utils/certs/$envoy_env/server-cert.pem       /etc/server.crt
COPY ./utils/certs/$envoy_env/server-key.pem        /etc/server.key

RUN chmod go+r /etc/envoy/envoy.yaml
EXPOSE 443
