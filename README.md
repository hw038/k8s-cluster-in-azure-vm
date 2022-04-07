# k8s-cluster-in-azure-vm
kubeadm을 통해 쿠버네티스 클러스터를 azure vm에서 구축하기 위한 툴

1. 테라폼을 이용한 Azure VM Deploy
2. 앤서블을 이용한 VM의 기본 세팅 및 Kubeadm / kubernetes Cluster 구축

# 동작 방법

## 환경 초기화
테라폼 소스의 최상위 폴더에서 아래 명령어를 통해 환경 초기화를 합니다.

```
terraform init
```

## 코드 문법 검사
테라폼 소스가 문법적으로 문제가 없는지 소스 기준으로 검사합니다.
- 실제 배포되어있는 곳에 충돌이 발생하는 리소스가 있는지는 확인하지 않습니다.

```
terraform plan
```

## 코드를 통한 Azure 리소스 배포

```
terraform apply
```

## 코드를 통한 Azure 리소스 정리(삭제)

```
terraform destroy
```
