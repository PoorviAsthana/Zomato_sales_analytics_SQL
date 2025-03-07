
# Zomato Customer Insights & Transactions Analysis

## 📌 Project Overview

This project analyzes customer transactions on Zomato, focusing on spending behavior, order frequency, popular products, membership impact, and reward points. The data has been structured using MySQL for efficient querying and analysis.

## 🎯 Objectives

The project aims to answer the following key questions:

Total Spending: What is the total amount each customer spent on Zomato?

Customer Engagement: How many days has each customer visited Zomato?

First Purchase Analysis: What was the first product purchased by each customer?

Most Purchased Item: Which product was purchased the most and how many times?

Customer Preferences: Which product was the most popular for each customer?

Gold Membership Impact: What was the first product purchased after becoming a Gold member?

Pre-Membership Analysis: What was the first product purchased before becoming a Gold member?

Orders & Spending Before Membership: What were the total orders and spending before Gold membership?

Reward Points System: How many points did each customer earn based on different reward structures?

Gold Membership Earnings: Who earned more in their first year as a Gold member, and what were their earnings?

Transaction Ranking: Rank all transactions made by customers.

Membership Status in Transactions: Rank all transactions where Gold membership exists and mark others as "NA."

## 📊 Insights & Findings

Top Spenders: Customers 1, 2, and 3 had significant spending patterns.

Most Frequent Orders: Certain customers visited more often than others.

Popular Products: Product P2 was the most frequently purchased item.

Gold Membership Influence: Some customers increased their spending after becoming Gold members.

Reward System Impact: Customers accumulated points based on varied spending behaviors.

## 🗃️ Database Schema & ER Diagram

The project follows a structured Entity-Relationship (ER) Model, where tables include:

Customers (User ID, Total Spend, Visit Days)

Orders (Order ID, Product ID, Date, Price)

Products (Product ID, Name, Price, Reward Points System)

Gold Memberships (User ID, Signup Date, First Purchase After Membership)

The ER Diagram visually represents the relationships between tables and how data is structured.

### 🔍 How to Use

Clone the repository:

git clone https://github.com/your-username/your-repo-name.git

Import the SQL database schema.

Run queries to analyze customer behavior and spending patterns.

## 📂 File Structure

/SQL Queries/ → Contains all queries used for analysis.

/ER Diagram/ → Entity-Relationship diagram for database structure.

README.md → Project documentation.

## 💡 Conclusion

This project provides valuable insights into customer spending, preferences, and Gold membership benefits. Businesses can leverage these findings to optimize their reward programs and improve customer retention.

## 🛠️ Technologies Used

Database: MySQL

Visualization: ER Diagramming Tools

Scripting: SQL Queries

## 📌 Future Scope

Enhancing customer segmentation for personalized offers.

Expanding data analysis with machine learning models.

Real-time tracking of Gold membership impact.
