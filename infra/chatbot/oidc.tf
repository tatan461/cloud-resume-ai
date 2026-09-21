# infra/chatbot/oidc.tf
# El rol de GitHub Actions se gestiona de forma centralizada en
# infra/backend/oidc.tf. Este módulo no crea su propio rol IAM ni su
# propio proveedor OIDC, para evitar duplicados y fragmentación de permisos.