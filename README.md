# beautiful mimic

Imitate beautiful art with your selfies.

## Docker

Docker is used to deploy the app on kubernetes on Google Cloud.  

Build with:

```
docker build -t bm-app .
docker tag -f bm-app:<tag> us.gcr.io/fleet-authority-143304/bm-app
```

Push to cloud with

```
docker tag -f bm-app:<tag> us.gcr.io/fleet-authority-143304/bm-app
```

Deploy with

```
kubectl rolling-update bm-prod-app --image=us.gcr.io/fleet-authority-143304/bm-app:<tag>
```


## MongoDB

Hosted on `compose.com`

```
mongo --ssl --sslCAFile app/environments/prod.pem aws-us-east-1-portal.12.dblayer.com:15330/bm_app_production -u bm_prod_user -p <password>
```

## AWS

*AMI Instance*: Amazon Linux AMI 2015.09.2 x86_64 Graphics HVM EBS
*Instance Type*: g2.2xlarge

## Provision and Deploy

Locally, edit the inventory to point to the correct IP addresses.

```
ansible-playbook -i ops/inventory ops/playbooks/compute.yml
cap production deploy
```

NOTE:
The system uses the `bm`, who needs to be given NOPASSWD permission in the sudoers file.
This permission still needs to be granted manually.

## Execution

```
cd /opt/compute/lib/neural-style/
mkdir /opt/beautiful-mimic/current/splash/assets/images/combos
LD_LIBRARY_PATH=/opt/nvidia/cuda/lib64/:$LD_LIBRARY_PATH CUDA_BIN_PATH=/opt/nvidia/cuda/bin \ 
  /opt/compute/lib/torch/install/bin/th neural_style.lua \
  -gpu 0 -backend cudnn -cudnn_autotune \
  -content_image /opt/beautiful-mimic/current/splash/assets/images/frank-sinatra.jpg \
  -style_image /opt/beautiful-mimic/current/splash/assets/images/great-wave.jpg \
  -output_image /opt/beautiful-mimic/current/splash/assets/images/combos/frank-sinatra+great-wave.jpg
```

## App Development Notes

Use _rerun_ to for a local web server:
`rerun -i 'src/*' -i 'public/*' unicorn`

To build _bundle.js_:

`babel --presets react src/app --watch --out-file public/javascripts/bundle.js`

To build _react-bundle.js_:

`browserify -t [ babelify --presets [ react ] ] src/react-bundle.js -o public/javascripts/react-bundle.min.js`
