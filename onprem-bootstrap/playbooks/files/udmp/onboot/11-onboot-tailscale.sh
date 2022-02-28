#!/bin/sh
CONTAINER=tailscaled
IMAGE=ghcr.io/tailscale/tailscale:v1.20.4
# Starts a Tailscale container that is deleted after it is stopped.
# All configs stored in /mnt/data/tailscale
if podman container exists ${CONTAINER} && [ "$(podman inspect ${CONTAINER} | jq -r '.[].ImageName')" != "$IMAGE" ]; then
  podman stop ${CONTAINER}
  podman rm -f ${CONTAINER}
fi
if podman container exists ${CONTAINER}; then
  podman start ${CONTAINER}
else
  mkdir -p /mnt/data/tailscale
  podman run --rm --device=/dev/net/tun --net=host --cap-add=NET_ADMIN --cap-add=SYS_ADMIN --cap-add=CAP_SYS_RAWIO -v /mnt/data/tailscale:/var/lib/tailscale --name=${CONTAINER} -d --entrypoint /bin/sh ${IMAGE} -c "tailscaled"
fi