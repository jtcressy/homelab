#!/bin/sh
CONTAINER=tailscaled
IMAGE=ghcr.io/tailscale/tailscale:v1.22.0
# Starts a Tailscale container that is deleted after it is stopped.
# All configs stored in /mnt/data/tailscale

# Temporary workaround: copy default route to main table so that tailscale properly discovers it
if ![ "$(ip -4 route show)" ~= "default via" ] && [ "$(ip -4 route show table 201)" ~= "default via" ]; then
  ip route add $(ip -4 route show table 201 | grep "default via" | sed -r 's/table 201 /table 0 /g' | sed -r 's/proto dhcp//g')
fi

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