# Resort Data Warehouse & Business Intelligence Dashboard

An end-to-end, enterprise-grade Business Intelligence (BI) solution designed to support data-driven decision-making for luxury resort operations. This project covers the full data engineering lifecycle: from relational modeling and analytical requirement mapping to OLAP implementation and interactive presentation layer development.

## 🏗️ Architecture Overview
The platform is organized into a clean, modular 3-tier architecture:
1. **Data Warehouse Layer (PostgreSQL):** A custom analytical database structured using a hybrid **Star/Snowflake Schema** optimized for fast Online Analytical Processing (OLAP) queries. It features 6 core Fact tables (Data Marts) bound to conformed dimensions tracking customer demographics, hospitality metrics, and corporate financial investments.
2. **Backend / Semantic Layer (Python & SQL):** A high-performance database connection layer utilizing `psycopg2` and `pandas` to securely map business requirements into raw, highly optimized SQL queries (leveraging advanced filtering, aggregation, and analytical window functions).
3. **Presentation Layer (Streamlit & Plotly):** A highly responsive web application built to serve interactive visual analytics.

---

## 📊 Dashboard Modules

### 🗺️ Tab 1: Architecture & Data Modeling
* Features the complete, live **Entity-Relationship Diagram (ERD)** exported straight from the database schema.
* Details the precise layout of conformed dimensions (Time, Demographics, Catalog) and multi-fact tables.

### 📈 Tab 2: Executive Summary (C-Suite View)
* High-level KPI monitoring (Total Revenue, Volume Performance, Corporate Investment Scales).
* Dynamic **Yearly/Time-Series Filtering** coupled with rolling historical trend areas.

### 🔍 Tab 3: Decisional Business Queries
Includes an interactive suite of 10 complex multi-join analytical queries tracking cross-selling rates, marketing attribution across social media channels, demographic spending behavior, and market portfolio volatility.

---

## 🛠️ Tech Stack
* **Database Backend:** PostgreSQL
* **Data Engineering Tools:** DBeaver Enterprise
* **Application Framework:** Python 3, Streamlit
* **Data Manipulation & Visualization:** Pandas, Plotly Express
* **Version Control:** Git, GitHub