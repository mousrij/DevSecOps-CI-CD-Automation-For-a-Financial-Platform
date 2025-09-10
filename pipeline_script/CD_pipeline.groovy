pipeline {
    agent any

    environment {
        KUBECTL = '/usr/local/bin/kubectl'
        PROM_NAMESPACE = 'prometheus'
        PROM_RELEASE_NAME = 'kube-prom-stack'
    }

    parameters {
        string(name: 'CLUSTER_NAME', defaultValue: 'budget-project-cluster', description: 'Enter your EKS cluster name')
    }

    stages {
        stage("Login to EKS") {
            steps {
                script {
                    withCredentials([string(credentialsId: 'aws_access_key_id', variable: 'AWS_ACCESS_KEY'),
                                     string(credentialsId: 'aws_secret_access_key', variable: 'AWS_SECRET_KEY')]) {
                        sh "aws eks --region eu-west-3 update-kubeconfig --name ${params.CLUSTER_NAME}"
                    }
                }
            }
        }

        stage("Configure Prometheus & Grafana") {
            steps {
                script {
                    sh """
                    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts || true

                    if kubectl get namespace ${env.PROM_NAMESPACE} > /dev/null 2>&1; then
                        # If namespace exists, upgrade the Helm release
                        helm upgrade --install ${env.PROM_RELEASE_NAME} prometheus-community/kube-prometheus-stack -n ${env.PROM_NAMESPACE}
                    else
                        # If namespace does not exist, create it and install Helm release
                        kubectl create namespace ${env.PROM_NAMESPACE}
                        helm install ${env.PROM_RELEASE_NAME} prometheus-community/kube-prometheus-stack -n ${env.PROM_NAMESPACE}
                    fi

                    # Patch Prometheus service to LoadBalancer
                    kubectl patch svc ${env.PROM_RELEASE_NAME}-kube-prometheus-sta-prometheus -n ${env.PROM_NAMESPACE} -p '{"spec": {"type": "LoadBalancer"}}'

                    # Patch Grafana service to LoadBalancer
                    kubectl patch svc ${env.PROM_RELEASE_NAME}-grafana -n ${env.PROM_NAMESPACE} -p '{"spec": {"type": "LoadBalancer"}}'
                    """
                }
            }
        }


        stage("Configure ArgoCD") {
            steps {
                script {
                    sh """
                    # Install ArgoCD
                    kubectl create namespace argocd || true
                    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml
                    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'
                    """
                }
            }
        }
		
    }
}
