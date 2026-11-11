# Olist E-Commerce Data Warehouse Architecture

## Overview

This project implements an end-to-end e-commerce data warehouse using SQL Server, SSIS, and a Bronze-Silver-Gold medallion architecture.

## Data Flow

OLIST Raw CSV Files → Bronze → Silver → Gold

- **Bronze:** Raw source data ingestion.
- **Silver:** Data cleaning, standardisation, and quality checks.
- **Gold:** Business-ready dimensions and fact tables.
- **SSIS:** Orchestrates database validation, customer SCD Type 2 loading, and fact loading.

## Gold Layer

### Dimension Tables
- dim_customer
- dim_product
- dim_seller
- dim_date

### Fact Tables
- fact_sales
- fact_payments
- fact_reviews

## Database

SQL Server database: `olist_dwh`

Schemas: `bronze`, `silver`, `gold`, and `etl`.

## Architecture Diagram

![Olist Data Warehouse Architecture](olist_data_warehouse_architecture.png)
## Mermaid Architecture Diagram

```mermaid
flowchart TD
    A["Olist Raw CSV Files<br/>9 Source Files"] --> B["Bronze Layer<br/>Raw Data"]
    B --> C["Silver Layer<br/>Cleaned and Standardised Data"]
    C --> D["Gold Layer"]

    D --> E["Dimensions<br/>Customer, Product, Seller, Date"]
    D --> F["Fact Tables<br/>Sales, Payments, Reviews"]

    G["SQL Server Database<br/>olist_dwh"] <--> H["SSIS Orchestration<br/>00_master.dtsx"]
    H --> D