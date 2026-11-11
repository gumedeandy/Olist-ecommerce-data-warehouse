# Olist E-Commerce Data Engineering Project

## Overview

This project builds an end-to-end e-commerce data warehouse using the Olist Brazilian E-Commerce Public Dataset.

The solution uses SQL Server, SQL Server Integration Services (SSIS), and a Bronze-Silver-Gold medallion architecture to transform raw e-commerce data into structured, reliable, and analytics-ready datasets.

### Architecture

![Olist Data Warehouse Architecture](docs/olist_data_warehouse_architecture.drawio.png)

See the [architecture documentation](docs/architecture.md) for details.

## Project Objectives

- Design a relational data warehouse for e-commerce data.
- Load and transform source datasets using ETL processes.
- Apply data validation and data-quality checks.
- Build analytical tables to support business reporting.
- Document the pipeline and its development process.

## Technology Stack

- Microsoft SQL Server
- SQL Server Management Studio (SSMS)
- SQL Server Integration Services (SSIS)
- Git and GitHub
- Power BI (planned for analytics and reporting)

## Source Dataset

**Olist Brazilian E-Commerce Public Dataset**

Source: [Kaggle — Olist Brazilian E-Commerce Dataset](https://www.kaggle.com/datasets/olistbr/brazillian-ecommerce)

The dataset contains information about customers, orders, order items, payments, reviews, products, sellers, and geolocation.

The original CSV files are preserved locally and unchanged. Raw data is excluded from the GitHub repository.

## Planned Project Structure

```text
olist_ssis_dwh/
├── data/
│   ├── README.md
│   └── raw/                 # Local source CSV files; excluded from Git
├── sql/                     # SQL scripts (to be added)
├── ssis/                    # SSIS packages (to be added)
├── docs/                    # Design and project documentation
├── .gitignore
└── README.md
```

## Current Status

**Stage:** Project setup and source-data preparation.

The local repository has been initialized. SQL scripts, SSIS packages, data transformations, validation checks, and warehouse development will be added as the project progresses.

## Data Handling

The original source files are not modified. Generated outputs, credentials, local configuration files, and temporary build files should not be committed.

## Future Deliverables

- Source-to-target mapping
- Data warehouse schema and table definitions
- Bronze, Silver, and Gold data layers where appropriate
- Repeatable ETL pipeline
- Data-quality and reconciliation checks
- Documentation and sample analytical queries
- Optional Power BI reporting

## Disclaimer

This is an educational portfolio project using a publicly available dataset. It is not affiliated with Olist.
