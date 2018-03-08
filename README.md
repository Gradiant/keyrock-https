# KeyRock Identity Manager (HTTPS)
This dockerfile adds support for HTTPs connections to the official [KeyRock DockerHub repository](https://hub.docker.com/r/ging/fiware-idm/) by setting up an APACHE server.

## Building the image
### Configuring certificates
First change `[ keyrock ]` and `[ alt_names ]` parameters in the script `generate_certificates.sh` to match your setup.

### Build the image
```
sudo docker build -t keyrock-https .
```
### Launch KeyRock container
```
sudo docker run -d --name keyrock -p 8000:8000 -p 5000:5000 -t  keyrock-https
```

## Without building the image
You can copy your custom certificates with the `-v` Docker parameter.
```
sudo docker run -d --name keyrock -p 8000:8000 -p 5000:5000 -v $PWD/certificate_key:/horizon/certs/horizon.key -v $PWD/certificate_key:/keystone/certs/keystone.key -v $PWD/certificate:/horizon/certs/horizon.pem -v $PWD/certificate:/keystone/certs/keystone.pem -t  gradiant/keyrock-https
```

