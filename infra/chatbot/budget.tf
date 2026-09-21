# infra/chatbot/budget.tf
# Alerta de coste mensual para vigilar el gasto total de la cuenta AWS.
# No está limitado solo al chatbot porque AWS Budgets no puede filtrar
# fácilmente por "solo estos recursos" sin cost allocation tags previos;
# esta alarma cubre el gasto total de la cuenta, que en tu caso es
# principalmente este proyecto.

variable "budget_alert_email" {
  description = "Email donde recibir las alertas de presupuesto."
  type        = string
}

resource "aws_budgets_budget" "monthly_total" {
  name         = "cloud-resume-ai-monthly-budget"
  budget_type  = "COST"
  limit_amount = "5"
  limit_unit   = "USD"
  time_unit    = "MONTHLY"

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 80
    threshold_type             = "PERCENTAGE"
    notification_type          = "ACTUAL"
    subscriber_email_addresses = [var.budget_alert_email]
  }

  notification {
    comparison_operator        = "GREATER_THAN"
    threshold                  = 100
    threshold_type             = "PERCENTAGE"
    notification_type          = "FORECASTED"
    subscriber_email_addresses = [var.budget_alert_email]
  }
}
