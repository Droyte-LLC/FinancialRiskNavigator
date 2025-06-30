# FinancialRiskNavigator
### Real-time, AI-powered financial risk scoring using cloud-native architecture

# TODO - BADGE & Author section

---

## TODO - Table of Contents

---

## Overview

**FinancialRiskNavigator** is a secure, event-driven financial risk scoring platform built using Azure's cloud-native services and modern architectural patterns. Designed with scalability, performance, and security in mind, this platform ingests third-party financial data, processes it asynchronously, and applies ML-based scoring logic in real-time.

Ideal for financial institutions, risk analysts, and compliance teams, this solution empowers organizations to evaluate risk confidently using auditable, automated pipelines.

---

## Design Decisions

### CQRS (Command Query Responsibility Segregation)

**Decision**: Separated command (write) and query (read) operations into distinct services.  
**Reason**: Improves scalability, performance, and maintainability by allowing each path to evolve independently.  Command and query operations can scale independently.
**Benefits**:
- Simplified write pipeline (validation, scoring, persistence)
- Optimized read path for performance, caching, and API versioning
- Clean separation of concerns with asynchronous event processing
- Queries can operate via Azure Functions since they are lightweight, less complex
- Commands are more complexe and makes more sense to run those on Azure App Services
---

### Cosmos DB with Custom Indexing

**Decision**: Used Azure Cosmos DB (SQL API) with custom indexing policies.  
**Reason**: Cosmos DB by default indexes all properties, which can lead to high RU consumption in write-heavy workloads.  
**Benefits**:
-  Performance: Accelerates queries on frequently used properties (e.g., `/customerId`, `/scoreDate`)
-  Cost Optimization: Excludes large or infrequently queried fields (e.g., `rawInput`, `auditLog`)
-  Predictable Query Performance: Ensures fast, consistent results under high load

**Indexing Strategy**:
- **Included paths**: `/customerId/?`, `/scoreDate/?`
- **Excluded paths**: `/rawInput`, `/auditLog`

---

### Azure Event Hubs + Capture → Data Lake

**Decision**: Used Event Hubs for high-throughput, real-time ingestion with **Capture** enabled to persist raw events to Azure Data Lake Gen2.  
**Reason**: Combines real-time streaming and long-term archival.  
**Benefits**:
- Supports both real-time processing (via subscribers) and batch analytics (via Azure Data Factory or Synapse)
- Enables replay, historical debugging, or re-training ML models
- Supports regulatory retention/auditing requirements

---

### Azure Functions for Query API

**Decision**: Exposed read-side query endpoints using serverless Azure Functions.  
**Reason**: Read-heavy and bursty workloads benefit from elastic scale and consumption-based pricing.  
**Benefits**:
- Low-cost, event-driven compute for unpredictable load
- Keeps read services separate from write path for fault isolation
- Cold-start impact is minimal due to caching and lightweight logic

---

### OAuth 2.0 / OpenID Connect with JWT

**Decision**: Used Azure AD for authentication and authorization using OAuth2 + OIDC flows. APIs accept JWT bearer tokens.  
**Reason**: Ensures secure, federated identity handling and zero-trust access controls.  
**Benefits**:
- Stateless auth with token expiration and claims-based authorization
- Centralized identity via Azure AD (MFA, RBAC, audit trails)
- Simplifies token validation and role-based logic on APIs

---

### Infrastructure as Code with Terraform

**Decision**: All infrastructure is declared and managed using Terraform modules.  
**Reason**: Enables consistent, version-controlled, and reproducible deployments across environments.  
**Benefits**:
- Environment parity between dev, staging, and production
- Easy to validate infrastructure changes with `plan` and `apply`
- GitOps-friendly and CI/CD compatible
- Terraform is my default IAC strategy as that skillset is transferable to other cloud providers as opposed to Azure ARM Templates

---

### Event Sourcing for Audit Trail

**Decision**: Write-side commands emit domain events to capture system state changes over time.  
**Reason**: Enables full auditability, replayability, and decoupled projections.  
**Benefits**:
- Immutable log of all changes for forensic and compliance reviews
- Allows rebuilding of read models or ML training data on demand
- Events can drive workflows, notifications, or analytics

---

### Testing Strategy

- **Unit Tests**: For business logic, services, and function triggers  
- **Integration Tests**: Cover repository behavior and service boundaries  
- **Infrastructure Tests**: Validate Terraform provisioning using tools like `terratest`  
- **Resilience**: Retry logic and poison message handling built into Service Bus consumers

---

### Monitoring and Observability

**Tools Used**: Azure Monitor, Application Insights, Log Analytics  
**What’s Tracked**:
- API performance, dependency health, function cold starts
- Custom telemetry for scoring success/failure
- Alerts on dead-letter queues, latency spikes, error rates

---

### Deployment Strategy

- Blue/green deployments via App Service slots  
- Preview environments for safe feature validation  
- Secrets stored in Azure Key Vault  
- CI/CD pipelines using GitHub Actions
- Deployed as a single microservice to optimize scalability and cost efficiency

---

### API Documentation & Tooling

- OpenAPI / Swagger with versioning  
- Postman collection for manual testing  
- OAuth2 flows tested with MSAL and Azure AD App Registrations  

---

## TODO - 💡 Lessons Learned

---

## Use Case & Real-World Value

- **Banks & Lenders**: Assess borrower creditworthiness or exposure  
- **Regulatory Teams**: Track suspicious transactions (AML, KYC, etc.)  
- **Investment Firms**: Evaluate asset risk before trading  
- **Insurance Providers**: Score underwriting risk  
- **Risk Teams**: Build dashboards to surface critical financial events  

---

## Types of Risks

- **Credit Risk** – Default probability of a borrower  
- **Market Risk** – Exposure to rate or currency changes  
- **Operational Risk** – Tech/system/process failures  
- **Compliance Risk** – AML, KYC, regulatory violations  
- **Reputational Risk** – Behavior damaging public trust  
- **Transaction Risk** – Fraud or non-viability of a transaction  

---

## TODO - Architecture Diagram

[Architecture Diagram](./FinancialRiskNavigator.Application/assets/Cloud_Architecture_Diagram.pdf)

---

## Summary of Technologies

- **Azure**: App Services, Functions, Event Hubs, Cosmos DB, Service Bus, Key Vault, Monitor  
- **Security**: OAuth2, OpenID Connect, JWT, Managed Identity, Key Vault  
- **Architecture**: CQRS, async/await, microservices, OpenAPI versioning  
- **Data**: Cosmos DB (custom indexing), Table Storage archiving  
- **ML**: Azure ML integration for risk scoring  
- **DevOps**: CI/CD pipelines, Terraform, GitHub Actions

---

## Functional Output

- Scored risk data stored in Cosmos DB (queryable via API)  
- Raw data archived in Azure Data Lake (via Event Hub Capture)  
- Telemetry available in App Insights and Azure Monitor  
- Authenticated API responses testable via Swagger/Postman

---

## TODO - Developer Instructions

---

## TODO - Project Status

✅ In Progress ...

