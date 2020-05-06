# Créer le fichier "load-balancer-example.yaml"

```
$ cat load-balancer-example.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: hello-world
spec:
  selector:
    matchLabels:
      run: load-balancer-example
  replicas: 2
  template:
    metadata:
      labels:
        run: load-balancer-example
    spec:
      containers:
        - name: hello-world
          image: gcr.io/google-samples/node-hello:1.0
          ports:
            - containerPort: 8080
              protocol: TCP
```

# Déployer l'application "hello-world"

```
$ kubectl apply -f load-balancer-example.yaml
deployment.apps/hello-world created
```

# Afficher le déploiement de l'application "hello-world"

```
$ kubectl get deployments hello-world
NAME          READY   UP-TO-DATE   AVAILABLE   AGE
hello-world   0/5     5            0           15s
```

# Afficher la description du déploiement de l'application "hello-world"

```
$ kubectl describe deployments hello-world
Name:                   hello-world
Namespace:              default
CreationTimestamp:      Tue, 05 May 2020 18:31:26 +0200
Labels:                 <none>
Annotations:            deployment.kubernetes.io/revision: 1
Selector:               run=load-balancer-example
Replicas:               2 desired | 2 updated | 2 total | 2 available | 0 unavailable
StrategyType:           RollingUpdate
MinReadySeconds:        0
RollingUpdateStrategy:  25% max unavailable, 25% max surge
Pod Template:
  Labels:  run=load-balancer-example
  Containers:
   hello-world:
    Image:        gcr.io/google-samples/node-hello:1.0
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Conditions:
  Type           Status  Reason
  ----           ------  ------
  Available      True    MinimumReplicasAvailable
  Progressing    True    NewReplicaSetAvailable
OldReplicaSets:  <none>
NewReplicaSet:   hello-world-6db874c846 (2/2 replicas created)
Events:
  Type    Reason             Age   From                   Message
  ----    ------             ----  ----                   -------
  Normal  ScalingReplicaSet  5s    deployment-controller  Scaled up replica set hello-world-6db874c846 to 2
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
Name:           hello-world-6db874c846
Namespace:      default
Selector:       pod-template-hash=6db874c846,run=load-balancer-example
Labels:         pod-template-hash=6db874c846
                run=load-balancer-example
Annotations:    deployment.kubernetes.io/desired-replicas: 2
                deployment.kubernetes.io/max-replicas: 3
                deployment.kubernetes.io/revision: 1
Controlled By:  Deployment/hello-world
Replicas:       2 current / 2 desired
Pods Status:    2 Running / 0 Waiting / 0 Succeeded / 0 Failed
Pod Template:
  Labels:  pod-template-hash=6db874c846
           run=load-balancer-example
  Containers:
   hello-world:
    Image:        gcr.io/google-samples/node-hello:1.0
    Port:         8080/TCP
    Host Port:    0/TCP
    Environment:  <none>
    Mounts:       <none>
  Volumes:        <none>
Events:
  Type    Reason            Age    From                   Message
  ----    ------            ----   ----                   -------
  Normal  SuccessfulCreate  3m36s  replicaset-controller  Created pod: hello-world-6db874c846-nkvz2
  Normal  SuccessfulCreate  3m36s  replicaset-controller  Created pod: hello-world-6db874c846-wwqn4
```

# Créer le service "example-service" pour exposer les ports de l'application "hello-world"

```
$ kubectl expose deployment hello-world --type=NodePort --name=example-service
service/example-service exposed
```

# Afficher le service "example-service"

```
$ kubectl get services example-service
NAME              TYPE       CLUSTER-IP     EXTERNAL-IP   PORT(S)          AGE
example-service   NodePort   10.99.144.40   <none>        8080:31886/TCP   5m2s
```

# Afficher la description du service "example-service"

```
$ kubectl describe services example-service
Name:                     example-service
Namespace:                default
Labels:                   <none>
Annotations:              <none>
Selector:                 run=load-balancer-example
Type:                     NodePort
IP:                       10.99.144.40
LoadBalancer Ingress:     localhost
Port:                     <unset>  8080/TCP
TargetPort:               8080/TCP
NodePort:                 <unset>  31886/TCP
Endpoints:                10.1.0.122:8080,10.1.0.123:8080
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
$ kubectl port-forward service/example-service 8080:8080 &
Forwarding from 127.0.0.1:8080 -> 8080
Forwarding from [::1]:8080 -> 8080
Handling connection for 8080
Handling connection for 8080
```


