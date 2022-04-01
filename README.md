# Running Tanzu Community Edition on your local workstation

### Quick Start (DaShaun's version)

This is not supported at all!!!!  For learning purposes only.....

- Install Tanzu CLI

```bash
tanzu unmanaged-cluster create tce-local -p 80:80 -p 443:443
tanzu package repository add tce-local --url ghcr.io/dashaun/tce-local -n tanzu-package-repo-global
tanzu package install local-bootiful --package-name bootiful.local.community.tanzu.vmware.com --version 1.0.0
```

## Deploying apps to your local Kubernetes cluster

So, you have your Kubernetes cluster up and running on your workstation, now what?
Time to deploy sample apps!

### Scale-to-zero with Knative

Thanks to Knative, you can build scale-to-zero apps, while simplifying deployment:
basicall you declare a Knative Service, and forget about everything else
(`Deployment`, `Service`, `Ingress`)...!

Run this command to deploy a simple Knative Service:

```shell
kubectl apply -f samples/hello-knative/config
```

This command will deploy an app under: http://kuar.hello-knative.kn.127.0.0.1.nip.io.

Bonus point: you also get scale-to-zero for free. If you don't touch the app
for about 2 minutes, pods will be destroyed (down to zero instances).
As you start using this app again, new pods will be created (up to 10 instances).

Have fun!

## Contribute

Contributions are always welcome!

Feel free to open issues & send PR.

## License

Copyright &copy; 2022 [VMware, Inc. or its affiliates](https://vmware.com).

This project is licensed under the [Apache Software License version 2.0](https://www.apache.org/licenses/LICENSE-2.0).
