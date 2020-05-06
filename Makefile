CURRENT_DIR = $(shell pwd)

# Deployments of the pods
deploymentFile=hello-world-deployment.yaml
deploymentName=hello-world

# PersistentVolume
persistentVolumeFile=hello-world-pv.yaml
persistentVolumeName=hello-world-pv

# PersistentVolumeClaim
persistentVolumeClaimFile=hello-world-pvc.yaml
persistentVolumeClaimName=hello-world-pvc

# Service
serviceFile=hello-world-service.yaml
serviceName=hello-world-service

$(info ############################################### )
$(info # )
$(info # Environment variables )
$(info # )
$(info ############################################### )
$(info CURRENT_DIR: $(CURRENT_DIR))

$(info )
$(info ############################################### )
$(info # )
$(info # Parameters )
$(info # )
$(info ############################################### )
$(info deploymentFile: $(deploymentFile))
$(info deploymentName: $(deploymentName))
$(info persistentVolumeFile: $(persistentVolumeFile))
$(info persistentVolumeName: $(persistentVolumeName))
$(info persistentVolumeClaimFile: $(persistentVolumeClaimFile))
$(info persistentVolumeClaimName: $(persistentVolumeClaimName))
$(info serviceFile: $(serviceFile))
$(info serviceName: $(serviceName))
$(info )

include $(CURRENT_DIR)/make-commons-k8s.mk
