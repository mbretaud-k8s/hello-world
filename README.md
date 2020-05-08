# Namespace

## Create the yaml file
```
$ cat hello-world-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: hello-world
  labels:
    name: development
```

## Deploy the creation of the Namespace
```
$ kubectl create -f hello-world-namespace.yaml
namespace/hello-world created
```

## Display the list of the Namespaces with the labels
```
$ kubectl get namespaces --show-labels
NAME              STATUS   AGE   LABELS
default           Active   30h   <none>
docker            Active   30h   <none>
hello-world       Active   6s    name=development
jenkins           Active   13m   name=production
kube-node-lease   Active   30h   <none>
kube-public       Active   30h   <none>
kube-system       Active   30h   <none>
```

## Display the description of the Namespace
```
$ kubectl describe namespaces hello-world
Name:         hello-world
Labels:       name=development
Annotations:  <none>
Status:       Active

No resource quota.

No LimitRange resource.
```

## Change the Namespace
```
$ kubectl config set-context $(kubectl config current-context) --namespace=hello-world
Context "docker-desktop" modified.
```

## Display the current Namespace
```
$ kubectl config get-contexts
CURRENT   NAME                 CLUSTER          AUTHINFO         NAMESPACE
*         docker-desktop       docker-desktop   docker-desktop   hello-world
          docker-for-desktop   docker-desktop   docker-desktop
```

# PersistentVolume

## Create the directory of the volume
```
$ mkdir /c/tmp/hello-world
```

## Create the yaml file
```
$ cat hello-world-pv.yaml
kind: PersistentVolume
apiVersion: v1
metadata:
  name: hello-world-pv
  namespace: hello-world
  labels:
    type: local
spec:
  storageClassName: hello-world
  capacity:
    storage: 10Gi
  accessModes:
    - ReadWriteOnce
  hostPath:
    path: "/c/tmp/hello-world"
```

## Deploy the creation of the PersistentVolume
```
$ kubectl create -f hello-world-pv.yaml
persistentvolume/hello-world-pv created
```

## Display the PersistentVolume
```
$ kubectl get pv hello-world-pv --namespace=hello-world
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS   CLAIM                         STORAGECLASS   REASON   AGE
hello-world-pv   10Gi       RWO            Retain           Bound    hello-world/hello-world-pvc   hello-world             2m26s
```

## Display the description of the PersistentVolume
```
$ kubectl describe pv hello-world-pv --namespace=hello-world
Name:            hello-world-pv
Labels:          type=local
Annotations:     pv.kubernetes.io/bound-by-controller: yes
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    hello-world
Status:          Bound
Claim:           hello-world/hello-world-pvc
Reclaim Policy:  Retain
Access Modes:    RWO
VolumeMode:      Filesystem
Capacity:        10Gi
Node Affinity:   <none>
Message:
Source:
    Type:          HostPath (bare host directory volume)
    Path:          /c/tmp/hello-world
    HostPathType:
Events:            <none>
```

# PersistentVolumeClaim

## Create the yaml file
```
$ cat hello-world-pvc.yaml
kind: PersistentVolumeClaim
apiVersion: v1
metadata:
  name: hello-world-pvc
  namespace: hello-world
  labels:
    type: local
spec:
  storageClassName: hello-world
  accessModes:
    - ReadWriteOnce
  resources:
    requests:
      storage: 2Gi
```

## Deploy the creation of the PersistentVolumeClaim
```
$ kubectl create -f hello-world-pvc.yaml
persistentvolumeclaim/hello-world-pvc created
```

## Display the PersistentVolumeClaim
```
$ kubectl get pvc hello-world-pvc --namespace=hello-world
NAME              STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   AGE
hello-world-pvc   Bound    hello-world-pv   10Gi       RWO            hello-world    2m34s
```

## Display the description of the PersistentVolumeClaim
```
$ kubectl describe pvc hello-world-pvc --namespace=hello-world
Name:          hello-world-pvc
Namespace:     hello-world
StorageClass:  hello-world
Status:        Bound
Volume:        hello-world-pv
Labels:        type=local
Annotations:   pv.kubernetes.io/bind-completed: yes
               pv.kubernetes.io/bound-by-controller: yes
Finalizers:    [kubernetes.io/pvc-protection]
Capacity:      10Gi
Access Modes:  RWO
VolumeMode:    Filesystem
Mounted By:    <none>
Events:        <none>
```

# Deployment

## Create the yaml file
```
$ cat hello-world-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
  namespace: hello-world
spec:
  replicas: 2
  selector:
    matchLabels:
      app: hello-world
  template:
    metadata:
      labels:
        app: hello-world
    spec:
      containers:
        - name: hello-world
          image: gcr.io/google-samples/node-hello:1.0
          ports:
            - name: tcp
              containerPort: 8080
          volumeMounts:
            - name: volume-mounts-on-the-pods
              mountPath: "/tmp"
      volumes:
        - name: volume-mounts-on-the-pods
          persistentVolumeClaim:
              claimName: hello-world-pvc
```

## Deploy the creation of the pods
```
$ kubectl create -f hello-world-deployment.yaml
deployment.apps/hello-world created
```

## Display the list of pods
```
$ kubectl get pods --namespace=hello-world
NAME                           READY   STATUS    RESTARTS   AGE
hello-world-547c97fc86-h6lgq   1/1     Running   0          12s
hello-world-547c97fc86-vgdtt   1/1     Running   0          12s
```

## Display the list of deployments
```
$ kubectl get deployments --namespace=hello-world
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
hello-world   2/2     2            2           26s
```

## Display the description of the deployment
```
$ kubectl describe deployments hello-world --namespace=hello-world
Name:                   hello-world
Namespace:              hello-world
CreationTimestamp:      Wed, 06 May 2020 17:15:56 +0200
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               app=hello-world
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  app=hello-world
  Containers:
   hello-world:
    Image:        gcr.io/google-samples/node-hello:1.0
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /tmp from volume-mounts-on-the-pods (rw)
  Volumes:
   volume-mounts-on-the-pods:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  hello-world-pvc
    ReadOnly:   false
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   hello-world-547c97fc86 (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  59s   deployment-controller  Scaled up replica set hello-world-547c97fc86 to 2
```

# Service

## Create the yaml file
```
$ cat hello-world-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
  namespace: hello-world
spec:
  type: LoadBalancer
  ports:
    - port: 8080
      targetPort: 8080
  selector:
    app: hello-world
```

## Deploy the creation of the Service
```
$ kubectl create -f hello-world-service.yaml
service/hello-world-service created
```

## Display the Service
```
$ kubectl get service --namespace=hello-world
NAME                  TYPE           CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-world-service   LoadBalancer   10.108.27.55   localhost     8080:30069/TCP   16s
```

# Execution

## Enter into the pod
```
$ kubectl exec hello-world-547c97fc86-h6lgq --namespace=hello-world -i -t -- /bin/sh
# printenv
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.96.0.1:443
NODE_VERSION=4.4.2
HOSTNAME=hello-world-547c97fc86-h6lgq
HOME=/root
TERM=xterm
KUBERNETES_PORT_443_TCP_ADDR=10.96.0.1
PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
KUBERNETES_PORT_443_TCP_PORT=443
NPM_CONFIG_LOGLEVEL=info
KUBERNETES_PORT_443_TCP_PROTO=tcp
KUBERNETES_SERVICE_PORT_HTTPS=443
KUBERNETES_PORT_443_TCP=tcp://10.96.0.1:443
KUBERNETES_SERVICE_HOST=10.96.0.1
PWD=/
# exit
$
```

## Display the description of the Pod
```
$ kubectl describe pod hello-world-547c97fc86-h6lgq --namespace=hello-world
Name:           hello-world-547c97fc86-h6lgq
Namespace:      hello-world
Priority:       0
Node:           docker-desktop/192.168.65.3
Start Time:     Wed, 06 May 2020 17:15:56 +0200
Labels:         app=hello-world
                pod-template-hash=547c97fc86
Annotations:    <none>
Status:         Running
IP:             10.1.0.147
IPs:            <none>
Controlled By:  ReplicaSet/hello-world-547c97fc86
Containers:
  hello-world:
    Container ID:   docker://a65ade40c9749528652d1556f22e2cdfcc451c364840c0bfa526b1458474659b
    Image:          gcr.io/google-samples/node-hello:1.0
    Image ID:       docker-pullable://gcr.io/google-samples/node-hello@sha256:d238d0ab54efb76ec0f7b1da666cefa9b40be59ef34346a761b8adc2dd45459b
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 06 May 2020 17:15:59 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /tmp from volume-mounts-on-the-pods (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-bqwbn (ro)
Conditions:
  Type              Status
  Initialized       True
  Ready             True
  ContainersReady   True
  PodScheduled      True
Volumes:
  volume-mounts-on-the-pods:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  hello-world-pvc
    ReadOnly:   false
  default-token-bqwbn:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-bqwbn
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From                     Message
  ----    ------     ----   ----                     -------
  Normal  Scheduled  3m40s  default-scheduler        Successfully assigned hello-world/hello-world-547c97fc86-h6lgq to docker-desktop
  Normal  Pulled     3m38s  kubelet, docker-desktop  Container image "gcr.io/google-samples/node-hello:1.0" already present on machine
  Normal  Created    3m38s  kubelet, docker-desktop  Created container hello-world
  Normal  Started    3m37s  kubelet, docker-desktop  Started container hello-world
```

# Replicasets

## Display the list of replicasets
```
$ kubectl get replicasets --namespace=hello-world
NAME                     DESIRED   CURRENT   READY   AGE
hello-world-547c97fc86   2         2         2       4m7s
```

## Display the description of the replicasets
```
$ kubectl describe replicasets hello-world-547c97fc86 --namespace=hello-world
Name:           hello-world-547c97fc86
Namespace:      hello-world
Selector:       app=hello-world,pod-template-hash=547c97fc86
Labels:         app=hello-world
                pod-template-hash=547c97fc86
Annotations:    deployment.kubernetes.io/desired-replicas: 2
                deployment.kubernetes.io/max-replicas: 3
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/hello-world
Replicas:       2 current / 2 desired
Pods Status:    2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=hello-world
           pod-template-hash=547c97fc86
  Containers:
   hello-world:
    Image:        gcr.io/google-samples/node-hello:1.0
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:
      /tmp from volume-mounts-on-the-pods (rw)
  Volumes:
   volume-mounts-on-the-pods:
    Type:       PersistentVolumeClaim (a reference to a PersistentVolumeClaim in the same namespace)
    ClaimName:  hello-world-pvc
    ReadOnly:   false
Events:
  Type    Reason            Age    From                   Message
  ----    ------            ----   ----                   -------
  Normal  SuccessfulCreate  4m31s  replicaset-controller  Created pod: hello-world-547c97fc86-vgdtt
  Normal  SuccessfulCreate  4m31s  replicaset-controller  Created pod: hello-world-547c97fc86-h6lgq
```

# Expose ports

## Export the port of the Service
```
$ kubectl port-forward service/hello-world-service --namespace=hello-world 8080:8080 &
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
```