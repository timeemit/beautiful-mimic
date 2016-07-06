# beautiful mimic

Imitate beautiful art with your selfies.

## AWS

AMI Instance: Amazon Linux AMI 2015.09.2 x86_64 Graphics HVM EBS
Instance Type: g2.2xlarge

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
mkdir /opt/code/current/splash/assets/images/combos
/opt/compute/lib/torch/install/bin/th neural_style.lua -gpu 0 \
  -content_image /opt/code/current/splash/assets/images/frank-sinatra.jpg \
  -style_image /opt/code/current/splash/assets/images/bottle-of-anis.jpg \
  -output_image /opt/code/current/splash/assets/images/combos/frank-sinatra+bottle-of-anis.jpg
```

## Development notes

To build _bundle.js_:

`babel --presets react src/app --watch --out-file public/javascripts/bundle.js`

To build _react-bundle.js_:

`browserify -t [ babelify --presets [ react ] ] src/react-bundle.js -o public/javascripts/react-bundle.min.js`
