# 🍔 Delivery Market Analysis

Repository: delivery-market-analysis

Duration: 4 days

Project Type: Solo Project


##  Project Overview

This project explores food delivery market data to extract actionable insights for restaurant partners and consumers. Using SQL and Python-based data analysis and visualization, the project investigates pricing, restaurant distribution, cuisine availability, and market gaps across delivery platforms. The analysis focuses primarily on the Takeaway database.

##  Mission Objectives

The objectives of this project are to:

Apply SQL querying techniques (SELECT, JOIN, GROUP BY, aggregations)

Perform exploratory data analysis on relational databases

Identify spatial and market patterns in food delivery data

Visualize insights using Python

##  Data Description

The project uses SQLite databases containing food delivery data. Main tables include:

- restaurants
, menuItems
, locations
, categories
, categories_restaurants
, locations_to_restaurants

These tables allow analysis of restaurant offerings, pricing, locations, and coverage.

##  Business Questions Addressed

- What is the price distribution of menu items?

- What is the distribution of restaurants per location?

- Which are the top 10 pizza restaurants by rating?

- Which locations offer a selected dish, and what is the average price?

- Which restaurants have the best price-to-rating ratio?

- Where are the delivery “dead zones” with minimal restaurant coverage?

- How does vegetarian and vegan availability vary by area?

- Who are the World Hummus Order (WHO) top hummus-serving restaurants?

Additionally, a number of further original questions were explored in the notebooks.

##  Project Structure
```text
delivery-market-analysis/
│
├── data/ # Local SQLite database (excluded via .gitignore)
│ └── takeaway.db
│
├── notebooks/ # Jupyter notebook with analysis and visualizations
│ └── analysis.ipynb
│
├── notes/ # Methodology notes and insights
│ ├── ER-schema_takeaway.png # Database ER diagram
│ └── exploration.sql # Personal SQL exploration and analysis notes
│
├── .gitignore # Excludes database files from GitHub
└── README.md # Project overview and documentation
```

##  Key Insights (Example)


The delivery market is dominated by affordable meals, with nearly 93% of menu items priced below €20, indicating a strongly price-sensitive customer base.

###  Actionable Business Recommendation (Sample)

This is just a sample recommendation. You can find many more insights, recommendations, and maps in the notebook.

For this example:
Restaurants aiming to increase margins can focus on the €10–€20 price range, where most customer demand already exists. Instead of raising prices, they can optimize portion size, ingredients, or perceived quality within this range.

###  Lifestyle & Cost Planning Insight

For people planning living expenses—such as students or migrants—takeaway meals priced mostly under €20 can serve as a realistic benchmark for affordable daily food costs.


##  Personal Situation

This project was done as part of the AI Boocamp at BeCode.org. 

Connect with me on [LinkedIn](https://www.linkedin.com/in/hamideh-be/ ).


