# Docker Build instructions

## Build command:

```
docker build -t orbsmiv/supercollider-rpi:3.10.4 .
```

### Updating latest tag

If you're pushing a new version and want to override the _latest_ tag:

```
docker tag orbsmiv/supercollider-rpi:3.10.4 orbsmiv/supercollider-rpi:latest
```

## Pushing to Docker Hub

```
docker push orbsmiv/supercollider-rpi:3.10.4
docker push orbsmiv/supercollider-rpi:latest
```
