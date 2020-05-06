#
# You need to define
#   deploymentFile
#   deploymentName
#   persistentVolumeFile
#   persistentVolumeName
#   persistentVolumeClaimFile
#   persistentVolumeClaimName
#   serviceFile
#   serviceName

POD_NAME=$(shell kubectl get pods --output='json' | jq ".items | .[] | .metadata | select(.name | startswith(\"$(deploymentName)\")) | .name" | head -1 | sed 's/"//g')

default:

###############################################
#
# PersistentVolume
#
###############################################
create-pv:
	kubectl create -f $(persistentVolumeFile)

delete-pv:
	kubectl delete pv/$(persistentVolumeName)

describe-pv:
	kubectl describe pv/$(persistentVolumeName)

get-pv:
	kubectl get pv/$(persistentVolumeName)

###############################################
#
# PersistentVolumeClaim
#
###############################################
create-pvc:
	kubectl create -f $(persistentVolumeClaimFile)

delete-pvc:
	kubectl delete pvc/$(persistentVolumeClaimName)

describe-pvc:
	kubectl describe pvc/$(persistentVolumeClaimName)

get-pvc:
	kubectl get pvc/$(persistentVolumeClaimName)

###############################################
#
# Pods
#
###############################################
deploy-pods:
	kubectl create -f $(deploymentFile)

delete-pods:
	kubectl delete -f $(deploymentFile) --force --grace-period=0

exec-pod:
	kubectl exec pods/$(POD_NAME) -i -t -- /bin/sh

get-pods:
	kubectl get pods

get-deployments:
	kubectl get deployments/$(deploymentName)

###############################################
#
# Services
#
###############################################	
create-service:
	kubectl create -f $(serviceFile)

delete-service:
	kubectl delete service/$(serviceName)

describe-service:
	kubectl describe service/$(serviceName)

get-service:
	kubectl get service/$(serviceName)
