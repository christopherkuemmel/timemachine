# Timemachine

## Add new timemachine services

Build and upload a docker image to the registry of your choice.

1. `docker build -t YOUR_REGISTRY/USERNAME/timemachine:TAG`
2. `docker push YOUR_REGISTRY/USERNAME/timemachine:TAG`

**Note:** You should replace the given secret within the Dockerfile (line:31) with something more safe. May consider researching docker BuildKit and secrets.

Make sure to replace the `{{USER}}` field in the three yamls and define a proper *persistentvolumeclaim* size. Then run:

1. `kubectl create -n NAMESPACE_NAME -f timemachine-volume-persistentvolumeclaim.yaml`
2. `kubectl create -n NAMESPACE_NAME -f timemachine-service.yaml`
3. `kubectl create -n NAMESPACE_NAME -f timemachine-deployment.yaml`

In order to allow write rights you have to modifiy the directory permissions right in the volume. Therefore:

1. `kubectl get pods` returns the pod names
2. `kubectl exec -it <POD NAME> sh`
3. In the pod: `cd backup`
4. `chmod 700 timemachine/`
5. `chown timemachine timemachine/`

After the configuration you can mount the server via *finder* (cmd+k). You now can enable Timemachine on the Volume. Make sure to auto start/login the server and the volume! (System Preferences -> Users & Groups -> Login Items)

1. `sudo tmutil setdestination /Volumes/<VOLUME NAME>`

Set the default limit for timeMachine to specific/defined size to avoid capacity problems.

1. `defaults write /Library/Preferences/com.apple.TimeMachine MaxSize 1000000`

## Note: 

The **NodePort** will be defined automatically. You should manually add the given port to the `timemachine-service.yaml` after the assign. 

**Keychain Access** may saves the wrong URL, if you click on connect and let TimeMachine automatically set the user and password. Make sure the URL includes the correct **port**.