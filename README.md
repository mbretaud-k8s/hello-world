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
$ kubectl get pv hello-world-pv
NAME             CAPACITY   ACCESS MODES   RECLAIM POLICY   STATUS      CLAIM   STORAGECLASS   REASON   AGE
hello-world-pv   10Gi       RWO            Retain           Available           hello-world             5s
```

## Display the description of the PersistentVolume
```
$ kubectl describe pv hello-world-pv
Name:            hello-world-pv
Labels:          type=local
Annotations:     <none>
Finalizers:      [kubernetes.io/pv-protection]
StorageClass:    hello-world
Status:          Available
Claim:
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
$ kubectl get pvc hello-world-pvc
NAME              STATUS   VOLUME           CAPACITY   ACCESS MODES   STORAGECLASS   AGE
hello-world-pvc   Bound    hello-world-pv   10Gi       RWO            hello-world    5s
```

## Display the description of the PersistentVolumeClaim
```
$ kubectl describe pvc hello-world-pvc
Name:          hello-world-pvc
Namespace:     default
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
$ kubectl get pods
NAME                           READY   STATUS    RESTARTS   AGE
hello-world-6d4f6bdb67-4d99z   1/1     Running   0          14s
hello-world-6d4f6bdb67-njz9h   1/1     Running   0          14s
```

## Display the list of deployments
```
$ kubectl get deployments
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
hello-world   2/2     2            2           26s
```

## Display the description of the deployment
```
$ kubectl describe deployments hello-world
Name:                   hello-world
Namespace:              default
CreationTimestamp:      Wed, 06 May 2020 16:17:25 +0200
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
NewReplicaSet:   hello-world-6d4f6bdb67 (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  67s   deployment-controller  Scaled up replica set hello-world-6d4f6bdb67 to 2
```

# Service

## Create the yaml file
```
$ cat hello-world-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: hello-world-service
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
$ kubectl get service
NAME                  TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)          AGE
hello-world-service   LoadBalancer   10.108.106.241   localhost     8080:32546/TCP   8s
```

# Execution

## Enter into the pod
```
$ kubectl exec hello-world-6d4f6bdb67-4d99z -i -t -- /bin/sh
# printenv
KUBERNETES_SERVICE_PORT=443
KUBERNETES_PORT=tcp://10.96.0.1:443
NODE_VERSION=4.4.2
HOSTNAME=hello-world-6d4f6bdb67-4d99z
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
$ kubectl describe pod hello-world-6d4f6bdb67-4d99z
Name:           hello-world-6d4f6bdb67-4d99z
Namespace:      default
Priority:       0
Node:           docker-desktop/192.168.65.3
Start Time:     Wed, 06 May 2020 16:17:25 +0200
Labels:         app=hello-world
                pod-template-hash=6d4f6bdb67
Annotations:    <none>
Status:         Running
IP:             10.1.0.143
IPs:            <none>
Controlled By:  ReplicaSet/hello-world-6d4f6bdb67
Containers:
  hello-world:
    Container ID:   docker://8a8920f7ef923b70ab15fe6161d93fb28b7388ce9f95ba641c57eb0da5cd45a4
    Image:          gcr.io/google-samples/node-hello:1.0
    Image ID:       docker-pullable://gcr.io/google-samples/node-hello@sha256:d238d0ab54efb76ec0f7b1da666cefa9b40be59ef34346a761b8adc2dd45459b
    Port:           8080/TCP
    Host Port:      0/TCP
    State:          Running
      Started:      Wed, 06 May 2020 16:17:28 +0200
    Ready:          True
    Restart Count:  0
    Environment:    <none>
    Mounts:
      /tmp from volume-mounts-on-the-pods (rw)
      /var/run/secrets/kubernetes.io/serviceaccount from default-token-h6dzm (ro)
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
  default-token-h6dzm:
    Type:        Secret (a volume populated by a Secret)
    SecretName:  default-token-h6dzm
    Optional:    false
QoS Class:       BestEffort
Node-Selectors:  <none>
Tolerations:     node.kubernetes.io/not-ready:NoExecute for 300s
                 node.kubernetes.io/unreachable:NoExecute for 300s
Events:
  Type    Reason     Age    From                     Message
  ----    ------     ----   ----                     -------
  Normal  Scheduled  3m32s  default-scheduler        Successfully assigned default/hello-world-6d4f6bdb67-4d99z to docker-desktop
  Normal  Pulled     3m29s  kubelet, docker-desktop  Container image "gcr.io/google-samples/node-hello:1.0" already present on machine
  Normal  Created    3m29s  kubelet, docker-desktop  Created container hello-world
  Normal  Started    3m29s  kubelet, docker-desktop  Started container hello-world
```

# Replicasets

## Display the list of replicasets
```
$ kubectl get replicasets
NAME                     DESIRED   CURRENT   READY   AGE
hello-world-6d4f6bdb67   2         2         2       3m55s
```

## Display the description of the replicasets
```
$ kubectl describe replicasets hello-world-6d4f6bdb67
Name:           hello-world-6d4f6bdb67
Namespace:      default
Selector:       app=hello-world,pod-template-hash=6d4f6bdb67
Labels:         app=hello-world
                pod-template-hash=6d4f6bdb67
Annotations:    deployment.kubernetes.io/desired-replicas: 2
                deployment.kubernetes.io/max-replicas: 3
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/hello-world
Replicas:       2 current / 2 desired
Pods Status:    2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=hello-world
           pod-template-hash=6d4f6bdb67
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
  Normal  SuccessfulCreate  4m30s  replicaset-controller  Created pod: hello-world-6d4f6bdb67-njz9h
  Normal  SuccessfulCreate  4m30s  replicaset-controller  Created pod: hello-world-6d4f6bdb67-4d99z
```

# Expose ports

## Export the port of the Service
```
$ kubectl port-forward service/hello-world-service 8080:8080 &
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
```










# Créer le fichier "load-balancer-example.yaml"

```
$ cat hello-world-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
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

# Déployer l'application "hello-world"

```
$ kubectl apply -f hello-world-deployment.yaml
deployment.apps/hello-world created
```

# Afficher le déploiement de l'application "hello-world"

```
$ kubectl get deployments hello-world
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
hello-world   2/2     2            2           2m2s
```

# Afficher la description du déploiement de l'application "hello-world"

```
$ kubectl describe deployments hello-world
Name:                   hello-world
Namespace:              default
CreationTimestamp:      Wed, 06 May 2020 15:48:50 +0200
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
NewReplicaSet:   hello-world-6d4f6bdb67 (2/2 replicas created)
Events:
  Type    Reason             Age    From                   Message
  ----    ------             ----   ----                   -------
  Normal  ScalingReplicaSet  2m20s  deployment-controller  Scaled up replica set hello-world-6d4f6bdb67 to 2
```

# Afficher la liste des Replicasets

```
$ kubectl get replicasets
NAME                     DESIRED   CURRENT   READY   AGE
hello-world-6db874c846   2         2         2       3m23s
```

# Afficher la descriptions des Replicasets

```
$ kubectl describe replicasets
Name:           hello-world-6d4f6bdb67
Namespace:      default
Selector:       app=hello-world,pod-template-hash=6d4f6bdb67
Labels:         app=hello-world
                pod-template-hash=6d4f6bdb67
Annotations:    deployment.kubernetes.io/desired-replicas: 2
                deployment.kubernetes.io/max-replicas: 3
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/hello-world
Replicas:       2 current / 2 desired
Pods Status:    2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  app=hello-world
           pod-template-hash=6d4f6bdb67
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
  Normal  SuccessfulCreate  2m49s  replicaset-controller  Created pod: hello-world-6d4f6bdb67-9l6wx
  Normal  SuccessfulCreate  2m49s  replicaset-controller  Created pod: hello-world-6d4f6bdb67-jj679
```

# Créer le service "hello-world-service" pour exposer les ports de l'application "hello-world"

```
$ kubectl expose deployment hello-world --type=NodePort --name=hello-world-service --port 8080
service/hello-world-service exposed
```

# Afficher le service "hello-world-service"

```
$ kubectl get services hello-world-service
NAME                  TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
hello-world-service   NodePort   10.111.5.237   <none>        8080:31718/TCP   76s
```

# Afficher la description du service "hello-world-service"

```
$ kubectl describe services hello-world-service
Name:                     hello-world-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 app=hello-world
Type:                     NodePort
IP:                       10.111.5.237
LoadBalancer Ingress:     localhost
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  31718/TCP
Endpoints:                10.1.0.140:8080,10.1.0.141:8080
Session Affinity:         None
External Traffic Policy:  Cluster
Events:                   <none>
```

# Afficher la liste des pods du namespace courant

```
$ kubectl get pods --output=wide
NAME                           READY   STATUS    RESTARTS   AGE     IP           NODE             NOMINATED NODE   READINESS GATES
hello-world-6db874c846-nkvz2   1/1     Running   0          5m31s   10.1.0.122   docker-desktop   <none>           <none>
hello-world-6db874c846-wwqn4   1/1     Running   0          5m31s   10.1.0.123   docker-desktop   <none>           <none>
```

# Faire du port-forwarding en fond de tâche pour exposer les ports de l'application "hello-world"

```
$ kubectl port-forward service/hello-world-service 8080:8080 &
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
Handling connection for 8080
```


