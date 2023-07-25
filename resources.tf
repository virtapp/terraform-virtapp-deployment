
####---keycloak
resource "helm_release" "keycloak" {
  name       = "keycloak"

  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  create_namespace = true
  timeout = 900
  values = [
    file("config/keycloak-value.yaml")
  ]
  depends_on = [helm_release.argocd]
}

####---kong
resource "helm_release" "kong" {
  name       = "kong"

  repository = "https://charts.konghq.com"
  chart      = "kong"
  create_namespace = true
  wait             = true
  set {
    name  = "ingressController.enabled"
    value = "true"
  }

  set {
    name  = "admin.enabled"
    value = "true"
  }

  set {
    name  = "admin.http.enabled"
    value = "true"
  }
  
  set {
    name  = "proxy.enabled"
    value = "true"
  }
  
  set {
    name  = "proxy.type"
    value = "ClusterIP"
  }

  set {
    name  = "ingressController.installCRDs"
    value = "false"
  }
  depends_on = [helm_release.argocd]
}

####---vault
resource "helm_release" "vault" {
  chart            = "vault"
  name             = "vault"
  namespace        = "vault"
  create_namespace = true
  repository       = "https://helm.releases.hashicorp.com"
  depends_on = [helm_release.ingress_nginx]
  values = [
    file("config/vault-values.yaml")
  ]

  set {
    name  = "server.dev.enabled"
    value = "true"
  }

  set {
    name  = "csi.enabled"
    value = "true"
  }

  set {
    name  = "injector.enabled"
    value = "false"
  }

}

####---csi
resource "helm_release" "csi" {
  chart            = "secrets-store-csi-driver"
  name             = "secrets-store-csi-driver"
  namespace        = "vault"
  create_namespace = true
  repository       = "https://kubernetes-sigs.github.io/secrets-store-csi-driver/charts"
  depends_on = [helm_release.vault]
  
  set {
    name  = "syncSecret.enabled"
    value = "true"
  }

}



