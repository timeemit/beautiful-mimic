# beautiful mimic

Imitate beautiful art with your selfies.

## Vagrant

There are a few different vagrants used for development.
The most interesting one is hosted by aws.  Don't forget to specify the provider!

```
vagrant up --provider=aws sidekiq-aws
```

## Development Notes

Use _rerun_ to for a local web server:
`rerun -i 'src/*' -i 'public/*' unicorn`

To build _bundle.js_:

`babel --presets react src/app --watch --compact --out-file public/javascripts/bundle.js`

To build _react-bundle.js_:

`browserify -t [ babelify --presets [ react ] ] src/react-bundle.js -o public/javascripts/react-bundle.min.js`

## Docker

Docker is used to deploy the app on kubernetes on Google Cloud.  

Determine tag with `git tag -l` and set it with:

```
export TAG=<tag>
git tag -a $TAG -m $TAG
git tag push --tags
```

Build with:

```
docker build -t bm-app:$TAG .
docker tag bm-app:$TAG us.gcr.io/fleet-authority-143304/bm-app:$TAG
```

Push to cloud with

```
gcloud docker push us.gcr.io/fleet-authority-143304/bm-app:$TAG
```

Deploy with

```
kubectl rolling-update bm-prod-app --image=us.gcr.io/fleet-authority-143304/bm-app:$TAG
```

## MongoDB and Redis

Hosted on `compose.com`

```
mongo --ssl --sslCAFile app/environments/prod.pem aws-us-east-1-portal.12.dblayer.com:15330/bm_app_production -u bm_prod_user -p <password>
```

```
redis-cli -h aws-us-east-1-portal.16.dblayer.com -p 15329 -a
```

## AWS

*AMI Instance*: Amazon Linux AMI 2015.09.2 x86_64 Graphics HVM EBS
*Instance Type*: g2.2xlarge

## Provision and Deploy

Locally, edit the inventory to point to the correct IP addresses.

```
ansible-playbook -i ops/inventory ops/playbooks/sidekiq.yml
cap production deploy
```

Note: Be sure to [download cuDNN](https://developer.nvidia.com/rdp/cudnn-download) into _ops/files/cudnn-7.5-linux-x64-v5.1.tgz_

## Train

Execute the following command as the user `bm`.

```
export IMAGE_FILE=starry-night.jpg &&
cd /opt/beautiful-mimic/neural-style && 
PATH=/usr/local/nvidia/cuda/bin:$PATH \
CPATH=/opt/nvidia/cuda/:$CPATH \
LIBRARY_PATH=/opt/nvidia/cuda/lib:$LIBRARY_PATH \
LD_LIBRARY_PATH=/opt/nvidia/cuda/lib/:/opt/nvidia/cuda/lib64:$LD_LIBRARY_PATH \
nohup time /opt/beautiful-mimic/venv_2_7/bin/python \
    /opt/beautiful-mimic/neural-style/train.py \
    --gpu 0 \
    --dataset /opt/beautiful-mimic/neural-style/train2014/ \
    --style_image /opt/beautiful-mimic/current/splash/images/$IMAGE_FILE \
  > ~/nohup.out &
```


## Execution

```
PATH=/usr/local/nvidia/cuda/bin:$PATH \
CPATH=/opt/nvidia/cuda/:$CPATH \
LIBRARY_PATH=/opt/nvidia/cuda/lib:$LIBRARY_PATH \
LD_LIBRARY_PATH=/opt/nvidia/cuda/lib/:/opt/nvidia/cuda/lib64:$LD_LIBRARY_PATH \
/opt/beautiful-mimic/venv_2_7/bin/python \
  /opt/beautiful-mimic/neural-style/generate.py \
  --model /opt/beautiful-mimic/neural-style/models/seurat.model \
  --gpu 0 \
  --out produced.jpg \
  /opt/beautiful-mimic/current/splash/images/marilyn-monroe.jpg
```
