#!/bin/sh

export TAG="$@"

# Build bundle
babel --presets react app/src/app --compact --out-file app/public/javascripts/bundle.js

# Tag repository
git tag -a $TAG -m $TAG ||
git push --tags &&

# Build and push docker image
docker build -t bm-app:$TAG app &&
docker tag bm-app:$TAG us.gcr.io/fleet-authority-143304/bm-app:$TAG &&
gcloud docker push us.gcr.io/fleet-authority-143304/bm-app:$TAG &&

# Deploy
kubectl rolling-update bm-prod-app --image=us.gcr.io/fleet-authority-143304/bm-app:$TAG
